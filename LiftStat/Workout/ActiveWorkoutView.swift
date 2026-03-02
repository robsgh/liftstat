import SwiftUI
import SwiftData

struct ActiveWorkoutView: View {
    @Environment(ActiveWorkoutStore.self) private var store
    @Environment(\.modelContext) private var modelContext

    let onFinish: (Workout) -> Void

    @FocusState private var focusedField: FocusedField?
    @State private var showExercisePicker = false
    @State private var showCancelConfirm = false

    private var workout: Workout? { store.currentWorkout }

    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                LazyVStack(spacing: 0) {
                    // Timer header
                    timerHeader

                    // Exercise list
                    if let workout {
                        ForEach(workout.sortedExercises) { we in
                            ExerciseRowView(workoutExercise: we, focusedField: $focusedField)
                            Divider()
                        }
                    }
                }
            }

            // PR celebration overlay — non-blocking
            if let exercise = store.newPRExercise {
                PRCelebrationView(exerciseName: exercise.name)
            }
        }
        .toolbar(.hidden, for: .tabBar)
        .navigationTitle(workout?.programDayName ?? "Freeform Workout")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    showCancelConfirm = true
                } label: {
                    Image(systemName: "xmark")
                        .fontWeight(.semibold)
                }
                .tint(.red)
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button("Finish") { finishWorkout() }
                    .fontWeight(.semibold)
                    .tint(.accentColor)
            }
        }
        .safeAreaInset(edge: .bottom) {
            Button {
                showExercisePicker = true
            } label: {
                Label("Add Exercise", systemImage: "plus.circle")
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
            }
            .buttonStyle(.bordered)
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(.bar)
        }
        .sheet(isPresented: $showExercisePicker) {
            ExercisePickerView { exercise in
                addExercise(exercise)
            }
        }
        .alert("Cancel Workout?", isPresented: $showCancelConfirm) {
            Button("Cancel Workout", role: .destructive) {
                store.cancelWorkout(context: modelContext)
            }
            Button("Keep Going", role: .cancel) {}
        } message: {
            Text("Your progress will be lost.")
        }
        .onAppear {
            focusFirstIncomplete()
        }
    }

    private var timerHeader: some View {
        HStack {
            Label(formattedTime, systemImage: "timer")
                .font(.title3.monospacedDigit())
                .foregroundStyle(.secondary)
            Spacer()
        }
        .padding()
        .background(.bar)
    }

    private var formattedTime: String {
        let h = store.elapsedSeconds / 3600
        let m = (store.elapsedSeconds % 3600) / 60
        let s = store.elapsedSeconds % 60
        if h > 0 {
            return String(format: "%d:%02d:%02d", h, m, s)
        } else {
            return String(format: "%d:%02d", m, s)
        }
    }

    private func addExercise(_ exercise: Exercise) {
        guard let workout else { return }
        let nextOrder = workout.exercises?.count ?? 0
        let we = WorkoutExercise(order: nextOrder)
        we.exercise = exercise
        we.workout = workout
        let firstSet = LoggedSet(order: 0)
        firstSet.workoutExercise = we
        we.sets = [firstSet]
        workout.exercises = (workout.exercises ?? []) + [we]
        modelContext.insert(we)
        modelContext.insert(firstSet)
        try? modelContext.save()
        focusedField = .weight(firstSet.persistentModelID)
    }

    private func focusFirstIncomplete() {
        guard let workout else { return }
        for we in workout.sortedExercises {
            for set in we.sortedSets where !set.isCompleted {
                focusedField = .weight(set.persistentModelID)
                return
            }
        }
    }

    private func finishWorkout() {
        guard let workout else { return }
        store.endWorkout(context: modelContext)
        onFinish(workout)
    }
}
