//
//  WorkoutProgram.swift
//  LiftStat
//
//  Created by Rob Schmidt on 3/9/26.
//

import SwiftData

@Model
class WorkoutProgram {
    var name: String
    var note: String
    
    @Relationship(deleteRule: .cascade, inverse: \WorkoutProgramDay.program)
    var days: [WorkoutProgramDay]?
    
    init(name: String, note: String = "") {
        self.name = name
        self.note = note
    }
    
    var getDaysSorted: [WorkoutProgramDay] {
        (days ?? []).sorted { $0.order < $1.order }
    }
}

@Model
class WorkoutProgramDay {
    var order: Int
    var name: String
    
    var program: WorkoutProgram?
    
    @Relationship(deleteRule: .cascade, inverse: \WorkoutProgramExercise.day)
    var exercises: [WorkoutProgramExercise]?
    
    init(order: Int, name: String) {
        self.name = name
        self.order = order
    }
}

@Model
class WorkoutProgramExercise {
    var order: Int
    var name: String
    var sets: Int
    var reps: Int
    
    var day: WorkoutProgramDay?
    
    init(order: Int, name: String, sets: Int, reps: Int) {
        self.order = order
        self.name = name
        self.sets = sets
        self.reps = reps
    }
}
