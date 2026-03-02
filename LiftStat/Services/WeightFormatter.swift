import Foundation

private let useKilogramsKey = "useKilograms"

extension Double {
    var displayWeight: String {
        let useKg = UserDefaults.standard.bool(forKey: useKilogramsKey)
        if useKg {
            return String(format: "%.1f kg", self * 0.453592)
        } else {
            return String(format: "%.1f lbs", self)
        }
    }

    var displayWeightValue: Double {
        UserDefaults.standard.bool(forKey: useKilogramsKey) ? self * 0.453592 : self
    }

    static var weightUnit: String {
        UserDefaults.standard.bool(forKey: useKilogramsKey) ? "kg" : "lbs"
    }
}
