import SwiftUI
import SwiftData

struct IdleView: View {
    @Environment(ActiveWorkoutStore.self) private var store
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Program.name) private var programs: [Program]

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Freeform start
                Button {
                    startFreeformWorkout()
                } label: {
                    Label("Start Freeform Workout", systemImage: "plus.circle.fill")
                        .frame(maxWidth: .infinity)
                        .padding()
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)

                // Program days
                if !programs.isEmpty {
                    Divider()

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Programs")
                            .font(.headline)
                            .padding(.horizontal)

                        ForEach(programs) { program in
                            VStack(alignment: .leading, spacing: 8) {
                                Text(program.name)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                    .padding(.horizontal)

                                ForEach(program.sortedDays) { day in
                                    Button {
                                        startPlannedWorkout(day: day)
                                    } label: {
                                        HStack {
                                            Text("Start \(day.name)")
                                            Spacer()
                                            Image(systemName: "chevron.right")
                                                .foregroundStyle(.secondary)
                                        }
                                        .padding()
                                    }
                                    .buttonStyle(.bordered)
                                    .padding(.horizontal)
                                }
                            }
                        }
                    }
                }
            }
            .padding(.vertical)
        }
        .navigationTitle("LiftStat")
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
