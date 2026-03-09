import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(ActiveWorkoutStore.self) private var store
    @State private var completedWorkout: Workout? = nil
    @State private var showProfile = false
    @State private var showWorkoutSheet = false

    var body: some View {
        NavigationStack {
            if let completedWorkout {
                WorkoutSummaryView(workout: completedWorkout) {
                    self.completedWorkout = nil
                }
            } else if store.currentWorkout != nil {
                ActiveWorkoutView { finishedWorkout in
                    self.completedWorkout = finishedWorkout
                }
            } else {
                LogDashboardView()
                    .navigationTitle("LiftStat")
                    .navigationBarTitleDisplayMode(.large)
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button {
                                showProfile = true
                            } label: {
                                Image(systemName: "person.crop.circle")
                            }
                        }
                    }
                    .safeAreaInset(edge: .bottom) {
                        Button {
                            showWorkoutSheet = true
                        } label: {
                            Label("Start Workout", systemImage: "plus.circle.fill")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)
                        .padding()
                    }
                    .sheet(isPresented: $showProfile) {
                        ProfileTabView()
                    }
                    .sheet(isPresented: $showWorkoutSheet) {
                        WorkoutShelfView()
                            .presentationDetents([.medium])
                            .presentationDragIndicator(.visible)
                    }
            }
        }
    }
}

#Preview("HomeView – idle") {
    let container = PreviewHelper.makeContainer()
    let store = ActiveWorkoutStore()
    return HomeView()
        .modelContainer(container)
        .environment(store)
}

#Preview("HomeView – active") {
    let container = PreviewHelper.makeContainer()
    let store = PreviewHelper.makeActiveStore(container: container)
    return HomeView()
        .modelContainer(container)
        .environment(store)
}
