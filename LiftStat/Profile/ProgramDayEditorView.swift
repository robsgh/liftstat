import SwiftUI
import SwiftData

struct ProgramDayEditorView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var day: ProgramDay

    @State private var showExercisePicker = false

    var body: some View {
        Group {
            if day.sortedExercises.isEmpty {
                ContentUnavailableView {
                    Label("No Exercises", systemImage: "dumbbell")
                } description: {
                    Text("Add exercises to plan this day.")
                } actions: {
                    Button("Add Exercise") { showExercisePicker = true }
                        .buttonStyle(.borderedProminent)
                }
            } else {
                List {
                    ForEach(day.sortedExercises) { pe in
                        @Bindable var pe = pe
                        VStack(alignment: .leading, spacing: 6) {
                            Text(pe.exercise?.name ?? "Unknown")
                                .font(.headline)
                            Stepper("Sets: \(pe.targetSets)", value: $pe.targetSets, in: 1...10)
                                .font(.subheadline)
                            Stepper("Reps: \(pe.targetReps)", value: $pe.targetReps, in: 1...30)
                                .font(.subheadline)
                        }
                        .padding(.vertical, 2)
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
