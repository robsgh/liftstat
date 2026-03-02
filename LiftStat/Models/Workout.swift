import Foundation
import SwiftData

@Model
class Workout {
    var startDate: Date
    var endDate: Date?
    var isActive: Bool
    var programDay: ProgramDay?
    var programDayName: String?

    @Relationship(deleteRule: .cascade, inverse: \WorkoutExercise.workout)
    var exercises: [WorkoutExercise]?

    init(startDate: Date = Date(), isActive: Bool = true) {
        self.startDate = startDate
        self.isActive = isActive
    }

    var sortedExercises: [WorkoutExercise] {
        (exercises ?? []).sorted { $0.order < $1.order }
    }

    var duration: TimeInterval {
        (endDate ?? Date()).timeIntervalSince(startDate)
    }

    var totalVolume: Double {
        (exercises ?? []).flatMap { $0.sets ?? [] }
            .filter { $0.isCompleted }
            .reduce(0) { $0 + $1.weight * Double($1.reps) }
    }
}

@Model
class WorkoutExercise {
    var order: Int
    var exercise: Exercise?
    var workout: Workout?

    @Relationship(deleteRule: .cascade, inverse: \LoggedSet.workoutExercise)
    var sets: [LoggedSet]?

    init(order: Int) {
        self.order = order
    }

    var sortedSets: [LoggedSet] {
        (sets ?? []).sorted { $0.order < $1.order }
    }
}

@Model
class LoggedSet {
    var weight: Double
    var reps: Int
    var isCompleted: Bool
    var order: Int
    var workoutExercise: WorkoutExercise?

    init(weight: Double = 0, reps: Int = 0, isCompleted: Bool = false, order: Int) {
        self.weight = weight
        self.reps = reps
        self.isCompleted = isCompleted
        self.order = order
    }
}
