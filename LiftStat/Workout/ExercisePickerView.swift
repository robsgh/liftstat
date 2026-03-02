import SwiftUI
import SwiftData

struct ExercisePickerView: View {
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \Exercise.name) private var exercises: [Exercise]

    let onSelect: (Exercise) -> Void

    private var grouped: [MuscleGroup: [EquipmentType: [Exercise]]] {
        var result: [MuscleGroup: [EquipmentType: [Exercise]]] = [:]
        for exercise in exercises {
            result[exercise.muscleGroup, default: [:]][exercise.equipmentType, default: []].append(exercise)
        }
        return result
    }

    var body: some View {
        NavigationStack {
            List {
                ForEach(MuscleGroup.orderedCases, id: \.self) { muscle in
                    if let equipmentMap = grouped[muscle] {
                        Section(muscle.displayName) {
                            ForEach(EquipmentType.orderedCases, id: \.self) { equipment in
                                if let list = equipmentMap[equipment] {
                                    ForEach(list) { exercise in
                                        Button {
                                            onSelect(exercise)
                                            dismiss()
                                        } label: {
                                            HStack {
                                                Text(exercise.name)
                                                Spacer()
                                                Text(equipment.displayName)
                                                    .font(.caption)
                                                    .foregroundStyle(.secondary)
                                            }
                                        }
                                        .foregroundStyle(.primary)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Add Exercise")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}

#Preview {
    let container = PreviewHelper.makeContainer()
    return ExercisePickerView(onSelect: { _ in })
        .modelContainer(container)
}
