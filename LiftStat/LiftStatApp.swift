import SwiftUI
import SwiftData

@main
struct LiftStatApp: App {
    let sharedModelContainer: ModelContainer
    @State private var store = ActiveWorkoutStore()

    init() {
        let schema = Schema([
            Exercise.self,
            Program.self,
            ProgramDay.self,
            ProgramExercise.self,
            Workout.self,
            WorkoutExercise.self,
            LoggedSet.self,
            PersonalRecord.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            sharedModelContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            DashboardView()
                .environment(store)

        }
        .modelContainer(sharedModelContainer)
    }

    private func recoverActiveWorkout(context: ModelContext) {
        let descriptor = FetchDescriptor<Workout>(
            predicate: #Predicate { $0.isActive }
        )
        guard let activeWorkout = try? context.fetch(descriptor).first else { return }
        store.resumeWorkout(activeWorkout)
    }
}
