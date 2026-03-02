import SwiftUI
import SwiftData

@Observable
class ActiveWorkoutStore {
    var currentWorkout: Workout?
    var elapsedSeconds: Int = 0
    var newPRExercise: Exercise? = nil

    private var timerTask: Task<Void, Never>?
    private var celebrationTask: Task<Void, Never>?

    func startWorkout(_ workout: Workout, context: ModelContext) {
        currentWorkout = workout
        elapsedSeconds = 0
        context.insert(workout)
        try? context.save()
        startTimer()
    }

    func resumeWorkout(_ workout: Workout) {
        currentWorkout = workout
        elapsedSeconds = max(0, Int(Date().timeIntervalSince(workout.startDate)))
        startTimer()
    }

    func endWorkout(context: ModelContext) {
        guard let workout = currentWorkout else { return }
        workout.endDate = Date()
        workout.isActive = false
        stopTimer()
        try? context.save()
        currentWorkout = nil
    }

    func cancelWorkout(context: ModelContext) {
        guard let workout = currentWorkout else { return }
        stopTimer()
        currentWorkout = nil
        context.delete(workout)
        try? context.save()
    }

    func triggerPRCelebration(for exercise: Exercise) {
        celebrationTask?.cancel()
        withAnimation {
            newPRExercise = exercise
        }
        celebrationTask = Task {
            try? await Task.sleep(for: .seconds(2))
            guard !Task.isCancelled else { return }
            withAnimation {
                newPRExercise = nil
            }
        }
    }

    private func startTimer() {
        stopTimer()
        timerTask = Task {
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(1))
                guard !Task.isCancelled else { break }
                elapsedSeconds += 1
            }
        }
    }

    private func stopTimer() {
        timerTask?.cancel()
        timerTask = nil
    }
}
