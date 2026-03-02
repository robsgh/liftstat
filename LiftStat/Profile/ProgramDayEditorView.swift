import SwiftUI
import SwiftData

struct ProgramDayEditorView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var day: ProgramDay

    @State private var showExercisePicker = false
    @State private var editingExercise: ProgramExercise? = nil

    var body: some View {
        List {
            ForEach(day.sortedExercises) { pe in
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(pe.exercise?.name ?? "Unknown")
                            .font(.headline)
                        Text("\(pe.targetSets) sets × \(pe.targetReps) reps")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Button {
                        editingExercise = pe
                    } label: {
                        Image(systemName: "pencil")
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                }
            }
            .onDelete { indexSet in
                let sorted = day.sortedExercises
                for index in indexSet { modelContext.delete(sorted[index]) }
                try? modelContext.save()
            }
            .onMove { from, to in
                var exercises = day.sortedExercises
                exercises.move(fromOffsets: from, toOffset: to)
                for (index, pe) in exercises.enumerated() { pe.order = index }
                try? modelContext.save()
            }

            Button {
                showExercisePicker = true
            } label: {
                Label("Add Exercise", systemImage: "plus")
            }
        }
        .navigationTitle(day.name)
        .toolbar {
            EditButton()
        }
        .sheet(isPresented: $showExercisePicker) {
            ExercisePickerView { exercise in
                addExercise(exercise)
            }
        }
        .sheet(item: $editingExercise) { pe in
            SetsRepsEditorView(programExercise: pe)
        }
    }

    private func addExercise(_ exercise: Exercise) {
        let order = day.exercises?.count ?? 0
        let pe = ProgramExercise(targetSets: 3, targetReps: 8, order: order)
        pe.exercise = exercise
        pe.day = day
        day.exercises = (day.exercises ?? []) + [pe]
        modelContext.insert(pe)
        try? modelContext.save()
    }
}

struct SetsRepsEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Bindable var programExercise: ProgramExercise

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Text(programExercise.exercise?.name ?? "Exercise")
                        .font(.headline)
                }
                Section("Target") {
                    Stepper("Sets: \(programExercise.targetSets)", value: $programExercise.targetSets, in: 1...10)
                    Stepper("Reps: \(programExercise.targetReps)", value: $programExercise.targetReps, in: 1...30)
                }
            }
            .navigationTitle("Edit Exercise")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        try? modelContext.save()
                        dismiss()
                    }
                }
            }
        }
    }
}
