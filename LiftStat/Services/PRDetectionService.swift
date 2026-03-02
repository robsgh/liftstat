import Foundation
import SwiftData

struct PRDetectionService {
    // Epley formula: e1RM = weight × (1 + reps / 30)
    static func estimatedOneRepMax(weight: Double, reps: Int) -> Double {
        guard reps > 0 else { return weight }
        return weight * (1.0 + Double(reps) / 30.0)
    }

    @discardableResult
    static func checkAndRecordPR(
        exercise: Exercise,
        weight: Double,
        reps: Int,
        context: ModelContext
    ) -> Bool {
        guard weight > 0, reps > 0 else { return false }
        let e1RM = estimatedOneRepMax(weight: weight, reps: reps)
        let existingBest = (exercise.personalRecords ?? [])
            .map { $0.estimatedOneRepMax }
            .max() ?? 0
        guard e1RM > existingBest else { return false }
        let pr = PersonalRecord(weight: weight, reps: reps, estimatedOneRepMax: e1RM)
        pr.exercise = exercise
        context.insert(pr)
        return true
    }
}
