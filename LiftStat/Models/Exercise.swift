import Foundation
import SwiftData

@Model
class Exercise {
    var name: String
    var muscleGroupRaw: String
    var equipmentTypeRaw: String
    var isCustom: Bool

    @Relationship(deleteRule: .cascade, inverse: \ProgramExercise.exercise)
    var programExercises: [ProgramExercise]?

    @Relationship(deleteRule: .nullify, inverse: \WorkoutExercise.exercise)
    var workoutExercises: [WorkoutExercise]?

    @Relationship(deleteRule: .cascade, inverse: \PersonalRecord.exercise)
    var personalRecords: [PersonalRecord]?

    init(name: String, muscleGroup: MuscleGroup, equipmentType: EquipmentType, isCustom: Bool = false) {
        self.name = name
        self.muscleGroupRaw = muscleGroup.rawValue
        self.equipmentTypeRaw = equipmentType.rawValue
        self.isCustom = isCustom
    }

    var muscleGroup: MuscleGroup {
        MuscleGroup(rawValue: muscleGroupRaw) ?? .fullBody
    }

    var equipmentType: EquipmentType {
        EquipmentType(rawValue: equipmentTypeRaw) ?? .barbell
    }
}

enum MuscleGroup: String, CaseIterable {
    case chest, back, shoulders, legs, arms, core, fullBody

    var displayName: String {
        switch self {
        case .chest: "Chest"
        case .back: "Back"
        case .shoulders: "Shoulders"
        case .legs: "Legs"
        case .arms: "Arms"
        case .core: "Core"
        case .fullBody: "Full Body"
        }
    }

    // Ordered for display grouping
    static var orderedCases: [MuscleGroup] {
        [.chest, .back, .shoulders, .legs, .arms, .core, .fullBody]
    }
}

enum EquipmentType: String, CaseIterable {
    case barbell, dumbbell, cable, machine, bodyweight

    var displayName: String {
        switch self {
        case .barbell: "Barbell"
        case .dumbbell: "Dumbbell"
        case .cable: "Cable"
        case .machine: "Machine"
        case .bodyweight: "Bodyweight"
        }
    }

    // Display order per design doc: Barbell, Dumbbell, Cable, Machine, Bodyweight
    static var orderedCases: [EquipmentType] {
        [.barbell, .dumbbell, .cable, .machine, .bodyweight]
    }
}
