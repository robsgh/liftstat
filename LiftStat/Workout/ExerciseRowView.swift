import SwiftUI
import SwiftData

struct ExerciseRowView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var workoutExercise: WorkoutExercise
    var focusedField: FocusState<FocusedField?>.Binding

    private var lastSets: [LoggedSet] {
        let exercise = workoutExercise.exercise
        let currentID = workoutExercise.persistentModelID
        let past = (exercise?.workoutExercises ?? [])
            .filter { $0.persistentModelID != currentID && $0.workout?.isActive == false }
            .sorted { ($0.workout?.startDate ?? .distantPast) > ($1.workout?.startDate ?? .distantPast) }
        return past.first?.sortedSets ?? []
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(workoutExercise.exercise?.name ?? "Unknown Exercise")
                    .font(.headline)
                    .padding(.horizontal)
                Spacer()
                Button {
                    addSet()
                } label: {
                    Label("Add Set", systemImage: "plus")
                        .font(.subheadline)
                        .labelStyle(.iconOnly)
                        .padding(.horizontal)
                }
            }
            .padding(.vertical, 4)

            ForEach(Array(workoutExercise.sortedSets.enumerated()), id: \.element.persistentModelID) { index, set in
                let ghost = lastSets.indices.contains(index) ? lastSets[index] : lastSets.last
                LoggedSetRowView(
                    set: set,
                    setNumber: index + 1,
                    ghostWeight: ghost?.weight,
                    ghostReps: ghost?.reps,
                    focusedField: focusedField,
                    exercise: workoutExercise.exercise
                )
                .padding(.vertical, 2)
            }

            // Add Set button (inline, below sets)
            Button {
                addSet()
            } label: {
                Label("Add Set", systemImage: "plus")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal)
                    .padding(.vertical, 4)
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 8)
    }

    private func addSet() {
        let nextOrder = workoutExercise.sets?.count ?? 0
        let lastSet = workoutExercise.sortedSets.last
        let newSet = LoggedSet(weight: lastSet?.weight ?? 0, reps: lastSet?.reps ?? 0, order: nextOrder)
        newSet.workoutExercise = workoutExercise
        workoutExercise.sets = (workoutExercise.sets ?? []) + [newSet]
        modelContext.insert(newSet)
        try? modelContext.save()
        focusedField.wrappedValue = .weight(newSet.persistentModelID)
    }
}
