import SwiftUI
import SwiftData

struct ProgramsSection: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Program.name) private var programs: [Program]

    @State private var showAddProgram = false
    @State private var newProgramName = ""

    var body: some View {
        List {
            ForEach(programs) { program in
                NavigationLink {
                    ProgramDetailView(program: program)
                } label: {
                    VStack(alignment: .leading) {
                        Text(program.name)
                            .font(.headline)
                        Text("\(program.days?.count ?? 0) day\((program.days?.count ?? 0) == 1 ? "" : "s")")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .onDelete { indexSet in
                for index in indexSet { modelContext.delete(programs[index]) }
                try? modelContext.save()
            }
        }
        .navigationTitle("Programs")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showAddProgram = true
                } label: {
                    Image(systemName: "plus")
                }
            }
            ToolbarItem(placement: .navigationBarLeading) {
                EditButton()
            }
        }
        .sheet(isPresented: $showAddProgram) {
            NavigationStack {
                Form {
                    TextField("Program Name", text: $newProgramName)
                }
                .navigationTitle("New Program")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") {
                            showAddProgram = false
                            newProgramName = ""
                        }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Create") {
                            createProgram()
                        }
                        .disabled(newProgramName.trimmingCharacters(in: .whitespaces).isEmpty)
                    }
                }
            }
        }
    }

    private func createProgram() {
        let program = Program(name: newProgramName.trimmingCharacters(in: .whitespaces))
        modelContext.insert(program)
        try? modelContext.save()
        showAddProgram = false
        newProgramName = ""
    }
}
