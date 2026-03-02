import SwiftUI
import SwiftData

struct WorkoutTabView: View {
    @Environment(ActiveWorkoutStore.self) private var store
    @State private var completedWorkout: Workout? = nil

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
                IdleView()
            }
        }
    }
}

#Preview("WorkoutTab – idle") {
    let container = PreviewHelper.makeContainer()
    let store = ActiveWorkoutStore()
    return WorkoutTabView()
        .modelContainer(container)
        .environment(store)
}

#Preview("WorkoutTab – active") {
    let container = PreviewHelper.makeContainer()
    let store = PreviewHelper.makeActiveStore(container: container)
    return WorkoutTabView()
        .modelContainer(container)
        .environment(store)
}
