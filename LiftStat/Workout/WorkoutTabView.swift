import SwiftUI

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
