import SwiftUI
import SwiftData

struct ExerciseLibrarySection: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Exercise.name) private var exercises: [Exercise]

    @State private var showAddExercise = false
    @State private var newName = ""
    @State private var newMuscle = MuscleGroup.chest
    @State private var newEquipment = EquipmentType.barbell

    private var grouped: [MuscleGroup: [EquipmentType: [Exercise]]] {
        var result: [MuscleGroup: [EquipmentType: [Exercise]]] = [:]
        for exercise in exercises {
            result[exercise.muscleGroup, default: [:]][exercise.equipmentType, default: []].append(exercise)
        }
        return result
    }

    var body: some View {
        List {
            ForEach(MuscleGroup.orderedCases, id: \.self) { muscle in
                if let equipmentMap = grouped[muscle] {
                    Section(muscle.displayName) {
                        ForEach(EquipmentType.orderedCases, id: \.self) { equipment in
                            if let list = equipmentMap[equipment] {
                                ForEach(list) { exercise in
                                    HStack {
                                        Text(exercise.name)
                                        Spacer()
                                        if exercise.isCustom {
                                            Text("Custom")
                                                .font(.caption)
                                                .foregroundStyle(.secondary)
                                                .padding(.horizontal, 6)
                                                .padding(.vertical, 2)
                                                .background(.quaternary, in: Capsule())
                                        } else {
                                            Text(equipment.displayName)
                                                .font(.caption)
                                                .foregroundStyle(.tertiary)
                                        }
                                    }
                                }
                                .onDelete { indexSet in
                                    deleteExercises(from: list, at: indexSet)
                                }
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("Exercise Library")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showAddExercise = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showAddExercise) {
            addExerciseSheet
        }
    }

    private var addExerciseSheet: some View {
        NavigationStack {
            Form {
                Section("Exercise Name") {
                    TextField("e.g. Hack Squat", text: $newName)
                }
                Section("Details") {
                    Picker("Muscle Group", selection: $newMuscle) {
                        ForEach(MuscleGroup.orderedCases, id: \.self) {
                            Text($0.displayName).tag($0)
                        }
                    }
                    Picker("Equipment", selection: $newEquipment) {
                        ForEach(EquipmentType.orderedCases, id: \.self) {
                            Text($0.displayName).tag($0)
                        }
                    }
                }
            }
            .navigationTitle("New Exercise")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        showAddExercise = false
                        resetForm()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        addExercise()
                    }
                    .disabled(newName.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }

    private func addExercise() {
        let exercise = Exercise(name: newName.trimmingCharacters(in: .whitespaces),
                                muscleGroup: newMuscle,
                                equipmentType: newEquipment,
                                isCustom: true)
        modelContext.insert(exercise)
        try? modelContext.save()
        showAddExercise = false
        resetForm()
    }

    private func resetForm() {
        newName = ""
        newMuscle = .chest
        newEquipment = .barbell
    }

    private func deleteExercises(from list: [Exercise], at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(list[index])
        }
        try? modelContext.save()
    }
}

#Preview {
    let container = PreviewHelper.makeContainer()
    return NavigationStack {
        ExerciseLibrarySection()
    }
    .modelContainer(container)
}
