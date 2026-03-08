import SwiftUI
import SwiftData

struct ExerciseRowView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(ActiveWorkoutStore.self) private var store
    @Bindable var workoutExercise: WorkoutExercise
    var focusedField: FocusState<FocusedField?>.Binding
    var onCompleted: () -> Void = {}

    private var useKg: Bool { UserDefaults.standard.bool(forKey: "useKilograms") }

    private var incompleteWithGhosts: [(LoggedSet, Double, Int)] {
        workoutExercise.sortedSets.enumerated().compactMap { index, set in
            guard !set.isCompleted else { return nil }
            let ghost = lastSets.indices.contains(index) ? lastSets[index] : lastSets.last
            guard let gw = ghost?.weight, gw > 0, let gr = ghost?.reps, gr > 0 else { return nil }
            return (set, gw, gr)
        }
    }

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
                if incompleteWithGhosts.count >= 2 {
                    Button("Complete All") {
                        completeAllSets()
                    }
                    .font(.caption)
                    .foregroundStyle(.orange)
                }
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
                    exercise: workoutExercise.exercise,
                    onCompleted: onCompleted
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

    private func completeAllSets() {
        for (set, ghostWeight, ghostReps) in incompleteWithGhosts {
            set.weight = ghostWeight
            set.reps = ghostReps
            set.isCompleted = true

            if let exercise = workoutExercise.exercise, ghostWeight > 0, ghostReps > 0 {
                let isPR = PRDetectionService.checkAndRecordPR(
                    exercise: exercise,
                    weight: ghostWeight,
                    reps: ghostReps,
                    context: modelContext
                )
                if isPR { store.triggerPRCelebration(for: exercise) }
            }
        }
        try? modelContext.save()
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

#Preview {
    @Previewable @FocusState var focus: FocusedField?
    let container = PreviewHelper.makeContainer()
    let store = PreviewHelper.makeActiveStore(container: container)
    let we = store.currentWorkout!.sortedExercises[0]
    return List {
        ExerciseRowView(workoutExercise: we, focusedField: $focus)
            .listRowInsets(EdgeInsets())
            .listRowSeparator(.hidden)
    }
    .listStyle(.plain)
    .modelContainer(container)
    .environment(store)
    .environment(KeyboardActions())
}
