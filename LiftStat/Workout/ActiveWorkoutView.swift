import SwiftUI
import SwiftData

@Observable
final class KeyboardActions {
    var adjustDelta: Double? = nil
    var shouldComplete: Bool = false
}

struct ActiveWorkoutView: View {
    @Environment(ActiveWorkoutStore.self) private var store
    @Environment(\.modelContext) private var modelContext

    let onFinish: (Workout) -> Void

    @FocusState private var focusedField: FocusedField?
    @State private var showExercisePicker = false
    @State private var showCancelConfirm = false
    @State private var exerciseToDelete: WorkoutExercise?
    @State private var showDeleteConfirm = false
    @State private var keyboardActions = KeyboardActions()

    private var workout: Workout? { store.currentWorkout }

    var body: some View {
        ZStack(alignment: .bottom) {
            List {
                if let workout {
                    ForEach(workout.sortedExercises) { we in
                        VStack(spacing: 0) {
                            ExerciseRowView(
                                workoutExercise: we,
                                focusedField: $focusedField,
                                onCompleted: focusFirstIncomplete
                            )
                            Divider()
                        }
                        .listRowInsets(EdgeInsets())
                        .listRowSeparator(.hidden)
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                exerciseToDelete = we
                                let hasCompleted = (we.sets ?? []).contains { $0.isCompleted }
                                if hasCompleted {
                                    showDeleteConfirm = true
                                } else {
                                    deleteExercise(we)
                                    exerciseToDelete = nil
                                }
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                }

                Button {
                    showExercisePicker = true
                } label: {
                    Label("Add Exercise", systemImage: "plus.circle")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                }
                .buttonStyle(.bordered)
                .padding()
                .listRowSeparator(.hidden)
            }
            .listStyle(.plain)
            .environment(keyboardActions)

            // PR celebration overlay — non-blocking
            if let exercise = store.newPRExercise {
                PRCelebrationView(exerciseName: exercise.name)
            }
        }
        .toolbar(.hidden, for: .tabBar)
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
            ToolbarItem(placement: .principal) {
                VStack(spacing: 1) {
                    Text(workout?.programDayName ?? "Freeform Workout")
                        .font(.headline)
                    Text(formattedTime)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .monospacedDigit()
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button("Finish") { finishWorkout() }
                    .fontWeight(.semibold)
                    .tint(.accentColor)
            }
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            if focusedField != nil {
                HStack(spacing: 0) {
                    Button("-2.5") { keyboardActions.adjustDelta = -2.5 }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                    Button("+2.5") { keyboardActions.adjustDelta = 2.5 }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                    Spacer()
                    Button {
                        keyboardActions.shouldComplete = true
                    } label: {
                        Label("Complete", systemImage: "checkmark")
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                    }
                }
                .background(.bar)
            }
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
        .confirmationDialog("Delete Exercise?", isPresented: $showDeleteConfirm, titleVisibility: .visible) {
            Button("Delete Exercise", role: .destructive) {
                if let we = exerciseToDelete { deleteExercise(we) }
                exerciseToDelete = nil
            }
            Button("Cancel", role: .cancel) {
                exerciseToDelete = nil
            }
        } message: {
            Text("Completed sets will be lost.")
        }
        .onAppear {
            focusFirstIncomplete()
        }
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

    private func deleteExercise(_ we: WorkoutExercise) {
        if let sets = we.sets {
            for s in sets { modelContext.delete(s) }
        }
        modelContext.delete(we)
        try? modelContext.save()
    }

    private func finishWorkout() {
        guard let workout else { return }
        store.endWorkout(context: modelContext)
        onFinish(workout)
    }
}
