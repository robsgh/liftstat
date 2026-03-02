import SwiftUI

struct ProfileTabView: View {
    var body: some View {
        NavigationStack {
            List {
                Section("Training") {
                    NavigationLink {
                        ProgramsSection()
                    } label: {
                        Label("Programs", systemImage: "list.clipboard")
                    }
                }

                Section("Exercise Bank") {
                    NavigationLink {
                        ExerciseLibrarySection()
                    } label: {
                        Label("Exercise Library", systemImage: "figure.strengthtraining.traditional")
                    }
                }
            }
            .navigationTitle("Profile")
        }
    }
}
