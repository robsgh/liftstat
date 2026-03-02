import SwiftUI
import SwiftData

struct WorkoutSummaryView: View {
    let workout: Workout
    let onDone: () -> Void

    private var duration: String {
        let secs = Int(workout.duration)
        let h = secs / 3600
        let m = (secs % 3600) / 60
        let s = secs % 60
        if h > 0 { return "\(h)h \(m)m" }
        if m > 0 { return "\(m)m \(s)s" }
        return "\(s)s"
    }

    private var totalVolumeLbs: Double { workout.totalVolume }

    private var prsSet: [PersonalRecord] {
        (workout.exercises ?? [])
            .compactMap { $0.exercise }
            .flatMap { $0.personalRecords ?? [] }
            .filter { $0.date >= workout.startDate }
            .sorted { $0.estimatedOneRepMax > $1.estimatedOneRepMax }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {

                    // Key stats
                    HStack(spacing: 0) {
                        statCell(title: "Duration", value: duration)
                        Divider()
                        statCell(title: "Volume", value: totalVolumeLbs.displayWeight)
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

                    // Per-exercise breakdown
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Exercises")
                            .font(.headline)

                        ForEach(workout.sortedExercises) { we in
                            exerciseSummaryRow(we)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Workout Complete")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done", action: onDone)
                }
            }
        }
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

    @ViewBuilder
    private func exerciseSummaryRow(_ we: WorkoutExercise) -> some View {
        let completedSets = we.sortedSets.filter { $0.isCompleted }
        let maxWeight = completedSets.map { $0.weight }.max() ?? 0
        let totalReps = completedSets.reduce(0) { $0 + $1.reps }

        VStack(alignment: .leading, spacing: 4) {
            Text(we.exercise?.name ?? "Unknown")
                .font(.subheadline.bold())
            HStack {
                Text("\(completedSets.count) sets · \(totalReps) reps")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                if maxWeight > 0 {
                    Text("· top \(maxWeight.displayWeight)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            progressionRow(for: we)
        }
        .padding(.vertical, 4)
    }

    @ViewBuilder
    private func progressionRow(for we: WorkoutExercise) -> some View {
        let exercise = we.exercise
        let currentID = we.persistentModelID
        let previousWE = (exercise?.workoutExercises ?? [])
            .filter { $0.persistentModelID != currentID && $0.workout?.isActive == false }
            .sorted { ($0.workout?.startDate ?? .distantPast) > ($1.workout?.startDate ?? .distantPast) }
            .first

        if let prev = previousWE {
            let prevMax = (prev.sortedSets.filter { $0.isCompleted }.map { $0.weight }.max()) ?? 0
            let currMax = (we.sortedSets.filter { $0.isCompleted }.map { $0.weight }.max()) ?? 0
            let diff = currMax - prevMax

            if abs(diff) > 0.01 {
                HStack(spacing: 4) {
                    Image(systemName: diff > 0 ? "arrow.up" : "arrow.down")
                        .font(.caption2)
                    Text("\(abs(diff).displayWeight) vs last session")
                        .font(.caption)
                }
                .foregroundStyle(diff > 0 ? .green : .red)
            }
        }
    }
}
