import SwiftUI
import SwiftData

struct WorkoutListView: View {
    @Query(filter: #Predicate<Workout> { !$0.isActive }, sort: \Workout.startDate, order: .reverse)
    private var workouts: [Workout]

    var body: some View {
        if workouts.isEmpty {
            ContentUnavailableView(
                "No Workouts Yet",
                systemImage: "clock.arrow.circlepath",
                description: Text("Start your first workout to see your history here.")
            )
        } else {
            List {
                ForEach(workouts) { workout in
                    NavigationLink(destination: LogWorkoutDetailView(workout: workout)) {
                        WorkoutCardRow(workout: workout)
                    }
                }
            }
            .listStyle(.plain)
        }
    }
}

private struct WorkoutCardRow: View {
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

    private var exerciseNames: String {
        workout.sortedExercises
            .compactMap { $0.exercise?.name }
            .joined(separator: ", ")
    }

    private var prCount: Int {
        workout.sortedExercises
            .compactMap { $0.exercise }
            .flatMap { $0.personalRecords ?? [] }
            .filter { $0.date >= workout.startDate }
            .count
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(workout.startDate, style: .date)
                    .font(.subheadline.bold())
                Spacer()
                Text(duration)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                if prCount > 0 {
                    Label("\(prCount)", systemImage: "star.fill")
                        .font(.caption.bold())
                        .foregroundStyle(.yellow)
                }
            }
            if !exerciseNames.isEmpty {
                Text(exerciseNames)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    let container = PreviewHelper.makeContainer()
    return NavigationStack {
        WorkoutListView()
    }
    .modelContainer(container)
}
