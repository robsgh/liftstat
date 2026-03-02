import SwiftUI

struct LogTabView: View {
    @State private var selectedTab = 0

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Picker("Log", selection: $selectedTab) {
                    Text("Workouts").tag(0)
                    Text("Exercises").tag(1)
                }
                .pickerStyle(.segmented)
                .padding()

                if selectedTab == 0 {
                    WorkoutListView()
                } else {
                    LoggedExerciseListView()
                }
            }
            .navigationTitle("Log")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}
