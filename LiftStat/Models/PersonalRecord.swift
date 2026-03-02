import Foundation
import SwiftData

@Model
class PersonalRecord {
    var weight: Double
    var reps: Int
    var estimatedOneRepMax: Double
    var date: Date
    var exercise: Exercise?

    init(weight: Double, reps: Int, estimatedOneRepMax: Double, date: Date = Date()) {
        self.weight = weight
        self.reps = reps
        self.estimatedOneRepMax = estimatedOneRepMax
        self.date = date
    }
}
