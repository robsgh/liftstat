import SwiftUI
import SwiftData

struct ProgramDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var program: Program

    @State private var showAddDay = false
    @State private var newDayName = ""

    var body: some View {
        List {
            ForEach(program.sortedDays) { day in
                NavigationLink {
                    ProgramDayEditorView(day: day)
                } label: {
                    VStack(alignment: .leading) {
                        Text(day.name)
                            .font(.headline)
                        Text("\(day.exercises?.count ?? 0) exercise\((day.exercises?.count ?? 0) == 1 ? "" : "s")")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .onDelete { indexSet in
                let sorted = program.sortedDays
                for index in indexSet { modelContext.delete(sorted[index]) }
                try? modelContext.save()
            }
            .onMove { from, to in
                var days = program.sortedDays
                days.move(fromOffsets: from, toOffset: to)
                for (index, day) in days.enumerated() { day.order = index }
                try? modelContext.save()
            }
        }
        .navigationTitle(program.name)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showAddDay = true
                } label: {
                    Image(systemName: "plus")
                }
            }
            ToolbarItem(placement: .navigationBarLeading) {
                EditButton()
            }
        }
        .sheet(isPresented: $showAddDay) {
            NavigationStack {
                Form {
                    TextField("Day Name (e.g. Push Day)", text: $newDayName)
                }
                .navigationTitle("New Day")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") {
                            showAddDay = false
                            newDayName = ""
                        }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Add") {
                            addDay()
                        }
                        .disabled(newDayName.trimmingCharacters(in: .whitespaces).isEmpty)
                    }
                }
            }
        }
    }

    private func addDay() {
        let order = program.days?.count ?? 0
        let day = ProgramDay(name: newDayName.trimmingCharacters(in: .whitespaces), order: order)
        day.program = program
        program.days = (program.days ?? []) + [day]
        modelContext.insert(day)
        try? modelContext.save()
        showAddDay = false
        newDayName = ""
    }
}
