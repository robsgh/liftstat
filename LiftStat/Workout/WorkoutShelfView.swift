import SwiftUI
import SwiftData

struct WorkoutShelfView: View {
    @Environment(ActiveWorkoutStore.self) private var store
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \Program.name) private var programs: [Program]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button {
                startFreeformWorkout()
                dismiss()
            } label: {
                Label("Start Freeform Workout", systemImage: "plus.circle.fill")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .padding()

            if !programs.isEmpty {
                Divider()

                List {
                    ForEach(programs) { program in
                        Section(program.name) {
                            ForEach(program.sortedDays) { day in
                                Button("Start \(day.name)") {
                                    startPlannedWorkout(day: day)
                                    dismiss()
                                }
                            }
                        }
                    }
                }
                .listStyle(.insetGrouped)
            }
        }
    }

    private func startFreeformWorkout() {
        let workout = Workout()
        store.startWorkout(workout, context: modelContext)
    }

    private func startPlannedWorkout(day: ProgramDay) {
        let workout = Workout()
        workout.programDay = day
        workout.programDayName = day.name

        var workoutExercises: [WorkoutExercise] = []
        for (index, pe) in day.sortedExercises.enumerated() {
            let we = WorkoutExercise(order: index)
            we.exercise = pe.exercise
            we.workout = workout

            var sets: [LoggedSet] = []
            for setIndex in 0..<pe.targetSets {
                let set = LoggedSet(order: setIndex)
                set.workoutExercise = we
                sets.append(set)
            }
            we.sets = sets
            workoutExercises.append(we)
        }
        workout.exercises = workoutExercises
        store.startWorkout(workout, context: modelContext)
    }
}

#Preview("WorkoutShelf – no programs") {
    let container = PreviewHelper.makeContainer()
    let store = ActiveWorkoutStore()
    return WorkoutShelfView()
        .modelContainer(container)
        .environment(store)
}
