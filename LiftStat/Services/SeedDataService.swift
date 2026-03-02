import Foundation
import SwiftData

struct SeedDataService {
    private static let seedKey = "seedDataLoaded"

    static func seedIfNeeded(context: ModelContext) {
        guard !UserDefaults.standard.bool(forKey: seedKey) else { return }
        seedExercises(context: context)
        UserDefaults.standard.set(true, forKey: seedKey)
    }

    private static func seedExercises(context: ModelContext) {
        let exercises: [(String, MuscleGroup, EquipmentType)] = [
            // Barbell
            ("Bench Press", .chest, .barbell),
            ("Incline Bench Press", .chest, .barbell),
            ("Squat", .legs, .barbell),
            ("Romanian Deadlift", .legs, .barbell),
            ("Deadlift", .back, .barbell),
            ("Barbell Row", .back, .barbell),
            ("Overhead Press", .shoulders, .barbell),
            ("Barbell Curl", .arms, .barbell),

            // Dumbbell
            ("DB Bench Press", .chest, .dumbbell),
            ("Incline DB Press", .chest, .dumbbell),
            ("DB Row", .back, .dumbbell),
            ("DB Lunge", .legs, .dumbbell),
            ("DB Shoulder Press", .shoulders, .dumbbell),
            ("Lateral Raise", .shoulders, .dumbbell),
            ("DB Curl", .arms, .dumbbell),
            ("Skull Crusher", .arms, .dumbbell),

            // Cable
            ("Lat Pulldown", .back, .cable),
            ("Cable Row", .back, .cable),
            ("Face Pull", .shoulders, .cable),
            ("Tricep Pushdown", .arms, .cable),
            ("Cable Fly", .chest, .cable),

            // Machine
            ("Leg Press", .legs, .machine),
            ("Chest Fly", .chest, .machine),
            ("Seated Row", .back, .machine),
            ("Leg Curl", .legs, .machine),
            ("Leg Extension", .legs, .machine),

            // Bodyweight
            ("Pull-up", .back, .bodyweight),
            ("Push-up", .chest, .bodyweight),
            ("Dip", .arms, .bodyweight),
            ("Plank", .core, .bodyweight),
            ("Lunge", .legs, .bodyweight),
        ]

        for (name, muscle, equipment) in exercises {
            let exercise = Exercise(name: name, muscleGroup: muscle, equipmentType: equipment)
            context.insert(exercise)
        }

        try? context.save()
    }
}
