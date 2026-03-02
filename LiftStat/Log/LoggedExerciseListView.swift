import SwiftUI
import SwiftData

struct LoggedExerciseListView: View {
    @Query(filter: #Predicate<Workout> { !$0.isActive }) private var workouts: [Workout]

    private var exercisesByMuscleGroup: [MuscleGroup: [Exercise]] {
        var seen = Set<PersistentIdentifier>()
        var result: [MuscleGroup: [Exercise]] = [:]
        for workout in workouts {
            for we in workout.sortedExercises {
                guard let exercise = we.exercise else { continue }
                let hasCompletedSet = (we.sets ?? []).contains { $0.isCompleted }
                guard hasCompletedSet else { continue }
                guard seen.insert(exercise.persistentModelID).inserted else { continue }
                result[exercise.muscleGroup, default: []].append(exercise)
            }
        }
        // Sort exercises within each group by name
        for key in result.keys {
            result[key]?.sort { $0.name < $1.name }
        }
        return result
    }

    var body: some View {
        let grouped = exercisesByMuscleGroup
        if grouped.isEmpty {
            ContentUnavailableView(
                "No Workouts Yet",
                systemImage: "clock.arrow.circlepath",
                description: Text("Start your first workout to see your history here.")
            )
        } else {
            List {
                ForEach(MuscleGroup.orderedCases, id: \.self) { muscle in
                    if let exercises = grouped[muscle], !exercises.isEmpty {
                        Section(muscle.displayName) {
                            ForEach(exercises) { exercise in
                                NavigationLink(destination: ExerciseHistoryView(exercise: exercise)) {
                                    Text(exercise.name)
                                }
                            }
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
        }
    }
}
