import Foundation
import SwiftData

@Model
class Program {
    var name: String

    @Relationship(deleteRule: .cascade, inverse: \ProgramDay.program)
    var days: [ProgramDay]?

    init(name: String) {
        self.name = name
    }

    var sortedDays: [ProgramDay] {
        (days ?? []).sorted { $0.order < $1.order }
    }
}

@Model
class ProgramDay {
    var name: String
    var order: Int
    var program: Program?

    @Relationship(deleteRule: .cascade, inverse: \ProgramExercise.day)
    var exercises: [ProgramExercise]?

    @Relationship(deleteRule: .nullify, inverse: \Workout.programDay)
    var workouts: [Workout]?

    init(name: String, order: Int) {
        self.name = name
        self.order = order
    }

    var sortedExercises: [ProgramExercise] {
        (exercises ?? []).sorted { $0.order < $1.order }
    }
}

@Model
class ProgramExercise {
    var targetSets: Int
    var targetReps: Int
    var order: Int
    var exercise: Exercise?
    var day: ProgramDay?

    init(targetSets: Int, targetReps: Int, order: Int) {
        self.targetSets = targetSets
        self.targetReps = targetReps
        self.order = order
    }
}
