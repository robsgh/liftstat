import SwiftUI
import SwiftData

struct DashboardView: View {
    @Query(sort: \PersonalRecord.date, order: .reverse)
    private var allPRs: [PersonalRecord]

    @Query(filter: #Predicate<Workout> { !$0.isActive }, sort: \Workout.startDate, order: .reverse)
    private var completedWorkouts: [Workout]

    private var bestPR: PersonalRecord? {
        allPRs.max(by: { $0.estimatedOneRepMax < $1.estimatedOneRepMax })
    }

    var body: some View {
        if completedWorkouts.isEmpty && allPRs.isEmpty {
            ContentUnavailableView(
                "Start Your Journey",
                systemImage: "figure.strengthtraining.traditional",
                description: Text("Complete your first workout to see your strength dashboard.")
            )
        } else {
            ScrollView {
                VStack(spacing: 20) {
                    heroStatsCard
                    recentPRsSection
                    StrengthTrendChartView(prs: allPRs)
                    recentWorkoutsSection
                    browseByExerciseCard
                }
                .padding()
            }
        }
    }

    // MARK: - Hero Stats

    private var heroStatsCard: some View {
        HStack(spacing: 0) {
            statCell(title: "Total PRs", value: "\(allPRs.count)")
            Divider()
            statCell(
                title: "Streak",
                value: "\(DashboardStatsService.currentStreak(workouts: completedWorkouts))w"
            )
            Divider()
            if let best = bestPR {
                VStack(spacing: 4) {
                    Text(best.estimatedOneRepMax.displayWeight)
                        .font(.title2.bold())
                    Text(best.exercise?.name ?? "Best e1RM")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
                .frame(maxWidth: .infinity)
            } else {
                statCell(title: "Best e1RM", value: "—")
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .cardBackground()
    }

    // MARK: - Recent PRs

    @ViewBuilder
    private var recentPRsSection: some View {
        if !allPRs.isEmpty {
            VStack(alignment: .leading, spacing: 8) {
                Label("Recent PRs", systemImage: "star.fill")
                    .font(.headline)
                    .foregroundStyle(.neonPink)

                ForEach(allPRs.prefix(5)) { pr in
                    if let exercise = pr.exercise {
                        NavigationLink(destination: ExerciseHistoryView(exercise: exercise)) {
                            HStack {
                                Text(exercise.name)
                                Spacer()
                                Text("\(pr.weight.displayWeight) × \(pr.reps)")
                                    .foregroundStyle(.secondary)
                                Text(pr.date, style: .relative)
                                    .font(.caption)
                                    .foregroundStyle(.tertiary)
                            }
                        }
                        .foregroundStyle(.primary)
                    }
                }
            }
            .padding()
            .cardBackground()
        }
    }

    // MARK: - Recent Workouts

    @ViewBuilder
    private var recentWorkoutsSection: some View {
        if !completedWorkouts.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Recent Workouts")
                        .font(.headline)
                    Spacer()
                    NavigationLink(destination: WorkoutListView()) {
                        Text("See All")
                            .font(.subheadline)
                    }
                }

                ForEach(completedWorkouts.prefix(3)) { workout in
                    NavigationLink(destination: LogWorkoutDetailView(workout: workout)) {
                        workoutCard(workout)
                    }
                    .foregroundStyle(.primary)
                }
            }
        }
    }

    private func workoutCard(_ workout: Workout) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(workout.startDate, style: .date)
                    .font(.subheadline.bold())
                Spacer()
                Text(formatDuration(workout.duration))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                let prCount = workoutPRCount(workout)
                if prCount > 0 {
                    Label("\(prCount)", systemImage: "star.fill")
                        .font(.caption.bold())
                        .foregroundStyle(.neonPink)
                }
            }
            let names = workout.sortedExercises.compactMap { $0.exercise?.name }.joined(separator: ", ")
            if !names.isEmpty {
                Text(names)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
        }
        .padding()
        .cardBackground()
    }

    // MARK: - Browse by Exercise

    private var browseByExerciseCard: some View {
        NavigationLink(destination: LoggedExerciseListView()) {
            HStack {
                Text("Browse by Exercise")
                    .font(.subheadline.bold())
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundStyle(.secondary)
            }
            .padding()
            .cardBackground()
        }
        .foregroundStyle(.primary)
    }

    // MARK: - Helpers

    @ViewBuilder
    private func statCell(title: String, value: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title2.bold())
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }

    private func formatDuration(_ interval: TimeInterval) -> String {
        let secs = Int(interval)
        let h = secs / 3600
        let m = (secs % 3600) / 60
        let s = secs % 60
        if h > 0 { return "\(h)h \(m)m" }
        if m > 0 { return "\(m)m \(s)s" }
        return "\(s)s"
    }

    private func workoutPRCount(_ workout: Workout) -> Int {
        workout.sortedExercises
            .compactMap { $0.exercise }
            .flatMap { $0.personalRecords ?? [] }
            .filter { $0.date >= workout.startDate }
            .count
    }
}

#Preview {
    let container = PreviewHelper.makeContainer()
    return NavigationStack {
        DashboardView()
            .navigationTitle("Dashboard")
            .navigationBarTitleDisplayMode(.large)
    }
    .modelContainer(container)
}
