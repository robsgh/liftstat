import SwiftUI
import SwiftData

struct ExercisePickerView: View {
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \Exercise.name) private var exercises: [Exercise]

    let onSelect: (Exercise) -> Void

    @State private var searchText = ""
    @State private var selectedMuscle: MuscleGroup?

    private var recentExercises: [Exercise] {
        exercises
            .filter { mostRecentWorkoutDate(for: $0) != nil }
            .sorted { mostRecentWorkoutDate(for: $0)! > mostRecentWorkoutDate(for: $1)! }
            .prefix(8)
            .map { $0 }
    }

    private func mostRecentWorkoutDate(for exercise: Exercise) -> Date? {
        (exercise.workoutExercises ?? [])
            .compactMap { $0.workout?.startDate }
            .max()
    }

    private var filteredExercises: [Exercise] {
        var result = exercises

        if !searchText.isEmpty {
            let query = searchText.lowercased()
            result = result.filter {
                $0.name.lowercased().contains(query) ||
                $0.muscleGroup.displayName.lowercased().contains(query) ||
                $0.equipmentType.displayName.lowercased().contains(query)
            }
        } else if let muscle = selectedMuscle {
            result = result.filter { $0.muscleGroup == muscle }
        }

        return result
    }

    var body: some View {
        NavigationStack {
            List {
                if searchText.isEmpty && selectedMuscle == nil && !recentExercises.isEmpty {
                    Section("Recent") {
                        ForEach(recentExercises) { exercise in
                            exerciseRow(exercise)
                        }
                    }
                }

                Section(searchText.isEmpty && selectedMuscle == nil ? "All Exercises" : "Results") {
                    ForEach(filteredExercises) { exercise in
                        exerciseRow(exercise)
                    }
                }
            }
            .searchable(text: $searchText, prompt: "Search exercises")
            .navigationTitle("Add Exercise")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .safeAreaInset(edge: .top) {
                if searchText.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(MuscleGroup.orderedCases, id: \.self) { muscle in
                                Button {
                                    withAnimation {
                                        selectedMuscle = selectedMuscle == muscle ? nil : muscle
                                    }
                                } label: {
                                    Text(muscle.displayName)
                                        .font(.subheadline)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(
                                            Capsule()
                                                .fill(selectedMuscle == muscle ? Color.accentColor : Color(.systemGray5))
                                        )
                                        .foregroundStyle(selectedMuscle == muscle ? .white : .primary)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                    }
                    .background(.bar)
                }
            }
        }
    }

    private func exerciseRow(_ exercise: Exercise) -> some View {
        Button {
            onSelect(exercise)
            dismiss()
        } label: {
            VStack(alignment: .leading, spacing: 2) {
                Text(exercise.name)
                Text("\(exercise.muscleGroup.displayName) · \(exercise.equipmentType.displayName)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .foregroundStyle(.primary)
    }
}

#Preview {
    let container = PreviewHelper.makeContainer()
    return ExercisePickerView(onSelect: { _ in })
        .modelContainer(container)
}
