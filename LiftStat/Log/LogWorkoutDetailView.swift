import SwiftUI

struct LogWorkoutDetailView: View {
    let workout: Workout

    private var duration: String {
        let secs = Int(workout.duration)
        let h = secs / 3600
        let m = (secs % 3600) / 60
        let s = secs % 60
        if h > 0 { return "\(h)h \(m)m" }
        if m > 0 { return "\(m)m \(s)s" }
        return "\(s)s"
    }

    private var prsSet: [PersonalRecord] {
        workout.sortedExercises
            .compactMap { $0.exercise }
            .flatMap { $0.personalRecords ?? [] }
            .filter { $0.date >= workout.startDate }
            .sorted { $0.estimatedOneRepMax > $1.estimatedOneRepMax }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {

                // Stats bar
                HStack(spacing: 0) {
                    statCell(title: "Duration", value: duration)
                    Divider()
                    statCell(title: "Volume", value: workout.totalVolume.displayWeight)
                    if !prsSet.isEmpty {
                        Divider()
                        statCell(title: "PRs", value: "\(prsSet.count)")
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(.quaternary, in: RoundedRectangle(cornerRadius: 12))

                // PRs section
                if !prsSet.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Personal Records", systemImage: "star.fill")
                            .font(.headline)
                            .foregroundStyle(.yellow)
                        ForEach(prsSet) { pr in
                            HStack {
                                Text(pr.exercise?.name ?? "")
                                Spacer()
                                Text("\(pr.weight.displayWeight) × \(pr.reps)")
                                    .foregroundStyle(.secondary)
                                Text("e1RM: \(pr.estimatedOneRepMax.displayWeight)")
                                    .font(.caption)
                                    .foregroundStyle(.tertiary)
                            }
                        }
                    }
                    .padding()
                    .background(.quaternary, in: RoundedRectangle(cornerRadius: 12))
                }

                // Exercise list
                VStack(alignment: .leading, spacing: 12) {
                    Text("Exercises")
                        .font(.headline)

                    ForEach(workout.sortedExercises) { we in
                        if let exercise = we.exercise {
                            NavigationLink(destination: ExerciseHistoryView(exercise: exercise)) {
                                ExerciseDetailRow(we: we)
                            }
                            .foregroundStyle(.primary)
                        } else {
                            ExerciseDetailRow(we: we)
                        }
                    }
                }
            }
            .padding()
        }
        .navigationTitle(workout.startDate.formatted(date: .abbreviated, time: .omitted))
        .navigationBarTitleDisplayMode(.inline)
    }

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
}

private struct ExerciseDetailRow: View {
    let we: WorkoutExercise

    private var completedSets: [LoggedSet] {
        we.sortedSets.filter { $0.isCompleted }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(we.exercise?.name ?? "Unknown")
                .font(.subheadline.bold())
            ForEach(completedSets) { set in
                Text("\(set.weight.displayWeight) × \(set.reps)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}
