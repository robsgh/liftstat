import Foundation

struct DashboardStatsService {
    /// Consecutive calendar weeks (ending at the current week) with at least one workout.
    static func currentStreak(workouts: [Workout]) -> Int {
        guard !workouts.isEmpty else { return 0 }

        let calendar = Calendar.current
        let today = Date()

        // Build a set of (year, weekOfYear) pairs for all workouts
        var weekSet = Set<DateComponents>()
        for w in workouts {
            let comps = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: w.startDate)
            weekSet.insert(comps)
        }

        // Walk backwards from the current week
        var streak = 0
        var checkDate = today
        while true {
            let comps = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: checkDate)
            if weekSet.contains(comps) {
                streak += 1
                checkDate = calendar.date(byAdding: .weekOfYear, value: -1, to: checkDate)!
            } else {
                break
            }
        }
        return streak
    }

    /// Exercises sorted by number of PRs (descending), limited to `limit`.
    static func topExercisesByPRCount(prs: [PersonalRecord], limit: Int = 3) -> [Exercise] {
        var counts: [Exercise: Int] = [:]
        for pr in prs {
            guard let exercise = pr.exercise else { continue }
            counts[exercise, default: 0] += 1
        }
        return counts.sorted { $0.value > $1.value }
            .prefix(limit)
            .map { $0.key }
    }

    /// e1RM timeline for a single exercise within a date window.
    static func e1RMTimeline(for exercise: Exercise, prs: [PersonalRecord], days: Int = 90) -> [(date: Date, e1RM: Double)] {
        let cutoff = Calendar.current.date(byAdding: .day, value: -days, to: Date()) ?? Date()
        return prs
            .filter { $0.exercise === exercise && $0.date >= cutoff }
            .sorted { $0.date < $1.date }
            .map { (date: $0.date, e1RM: $0.estimatedOneRepMax) }
    }
}
