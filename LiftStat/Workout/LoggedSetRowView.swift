import SwiftUI
import SwiftData

enum FocusedField: Hashable {
    case weight(PersistentIdentifier)
    case reps(PersistentIdentifier)
}

struct LoggedSetRowView: View {
    @Environment(ActiveWorkoutStore.self) private var store
    @Environment(\.modelContext) private var modelContext

    @Bindable var set: LoggedSet
    let setNumber: Int
    let ghostWeight: Double?   // in lbs
    let ghostReps: Int?
    var focusedField: FocusState<FocusedField?>.Binding
    var exercise: Exercise?

    @State private var weightText: String = ""
    @State private var repsText: String = ""

    private var useKg: Bool { UserDefaults.standard.bool(forKey: "useKilograms") }

    private var weightPrompt: String {
        if let g = ghostWeight, g > 0 {
            let val = useKg ? g * 0.453592 : g
            return String(format: "%.0f", val)
        }
        return useKg ? "kg" : "lbs"
    }

    private var repsPrompt: String {
        if let g = ghostReps, g > 0 { return "\(g)" }
        return "reps"
    }

    var body: some View {
        HStack(spacing: 12) {
            Text("\(setNumber)")
                .font(.caption)
                .foregroundStyle(.secondary)
                .frame(width: 24, alignment: .center)

            TextField("", text: $weightText, prompt: Text(weightPrompt).foregroundStyle(.tertiary))
                .keyboardType(.decimalPad)
                .focused(focusedField, equals: .weight(set.persistentModelID))
                .frame(maxWidth: .infinity)
                .textFieldStyle(.roundedBorder)
                .multilineTextAlignment(.trailing)
                .onSubmit {
                    focusedField.wrappedValue = .reps(set.persistentModelID)
                }

            Text("×")
                .foregroundStyle(.secondary)

            TextField("", text: $repsText, prompt: Text(repsPrompt).foregroundStyle(.tertiary))
                .keyboardType(.numberPad)
                .focused(focusedField, equals: .reps(set.persistentModelID))
                .frame(maxWidth: .infinity)
                .textFieldStyle(.roundedBorder)
                .multilineTextAlignment(.trailing)

            Button {
                completeSet()
            } label: {
                Image(systemName: set.isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(set.isCompleted ? .green : .secondary)
                    .font(.title3)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal)
        .onAppear {
            if set.weight > 0 {
                let val = useKg ? set.weight * 0.453592 : set.weight
                weightText = String(format: "%.0f", val)
            }
            if set.reps > 0 { repsText = "\(set.reps)" }
        }
    }

    private func completeSet() {
        let displayWeight = Double(weightText) ?? (ghostWeight.map { useKg ? $0 * 0.453592 : $0 } ?? 0)
        let repsValue = Int(repsText) ?? ghostReps ?? 0
        let weightInLbs = useKg ? displayWeight / 0.453592 : displayWeight

        set.weight = weightInLbs
        set.reps = repsValue
        set.isCompleted = true

        if weightText.isEmpty, displayWeight > 0 {
            weightText = String(format: "%.0f", displayWeight)
        }
        if repsText.isEmpty, repsValue > 0 {
            repsText = "\(repsValue)"
        }

        if let exercise, weightInLbs > 0, repsValue > 0 {
            let isPR = PRDetectionService.checkAndRecordPR(
                exercise: exercise,
                weight: weightInLbs,
                reps: repsValue,
                context: modelContext
            )
            if isPR { store.triggerPRCelebration(for: exercise) }
        }

        try? modelContext.save()
    }
}
