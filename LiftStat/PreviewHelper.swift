#if DEBUG
import SwiftUI
import SwiftData

@MainActor
struct PreviewHelper {
    /// Creates a fresh in-memory ModelContainer seeded with sample data.
    /// Call once per #Preview and share the result with makeActiveStore(container:).
    static func makeContainer() -> ModelContainer {
        let schema = Schema([
            Exercise.self,
            Program.self, ProgramDay.self, ProgramExercise.self,
            Workout.self, WorkoutExercise.self, LoggedSet.self,
            PersonalRecord.self
        ])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: schema, configurations: [config])
        let ctx = container.mainContext

        // Exercises
        let squat    = Exercise(name: "Barbell Squat", muscleGroup: .legs,  equipmentType: .barbell)
        let bench    = Exercise(name: "Bench Press",   muscleGroup: .chest, equipmentType: .barbell)
        let deadlift = Exercise(name: "Deadlift",      muscleGroup: .back,  equipmentType: .barbell)
        ctx.insert(squat); ctx.insert(bench); ctx.insert(deadlift)

        // Program: PPL > Push Day > Bench 3×5
        let program = Program(name: "PPL")
        let pushDay = ProgramDay(name: "Push Day", order: 0)
        pushDay.program = program
        let pe = ProgramExercise(targetSets: 3, targetReps: 5, order: 0)
        pe.exercise = bench; pe.day = pushDay
        pushDay.exercises = [pe]
        program.days = [pushDay]
        ctx.insert(program); ctx.insert(pushDay); ctx.insert(pe)

        // Workout 1: 3 weeks ago — Bench 3×5 @175, Squat 3×5 @225
        let w1Date = Date().addingTimeInterval(-21 * 86400)
        let w1 = Workout(startDate: w1Date, isActive: false)
        w1.endDate = w1Date.addingTimeInterval(3600)

        let w1Bench = WorkoutExercise(order: 0); w1Bench.exercise = bench; w1Bench.workout = w1
        let w1BenchSets: [LoggedSet] = [
            LoggedSet(weight: 175, reps: 5, isCompleted: true, order: 0),
            LoggedSet(weight: 175, reps: 5, isCompleted: true, order: 1),
            LoggedSet(weight: 175, reps: 5, isCompleted: true, order: 2)
        ]
        w1BenchSets.forEach { $0.workoutExercise = w1Bench; ctx.insert($0) }
        w1Bench.sets = w1BenchSets

        let w1Squat = WorkoutExercise(order: 1); w1Squat.exercise = squat; w1Squat.workout = w1
        let w1SquatSets: [LoggedSet] = [
            LoggedSet(weight: 225, reps: 5, isCompleted: true, order: 0),
            LoggedSet(weight: 225, reps: 5, isCompleted: true, order: 1),
            LoggedSet(weight: 225, reps: 5, isCompleted: true, order: 2)
        ]
        w1SquatSets.forEach { $0.workoutExercise = w1Squat; ctx.insert($0) }
        w1Squat.sets = w1SquatSets

        w1.exercises = [w1Bench, w1Squat]
        ctx.insert(w1); ctx.insert(w1Bench); ctx.insert(w1Squat)

        // Workout 2: 2 weeks ago — Bench 3×5 @180, Deadlift 2×5 @275
        let w2Date = Date().addingTimeInterval(-14 * 86400)
        let w2 = Workout(startDate: w2Date, isActive: false)
        w2.endDate = w2Date.addingTimeInterval(3600)

        let w2Bench = WorkoutExercise(order: 0); w2Bench.exercise = bench; w2Bench.workout = w2
        let w2BenchSets: [LoggedSet] = [
            LoggedSet(weight: 180, reps: 5, isCompleted: true, order: 0),
            LoggedSet(weight: 180, reps: 5, isCompleted: true, order: 1),
            LoggedSet(weight: 180, reps: 5, isCompleted: true, order: 2)
        ]
        w2BenchSets.forEach { $0.workoutExercise = w2Bench; ctx.insert($0) }
        w2Bench.sets = w2BenchSets

        let w2Dead = WorkoutExercise(order: 1); w2Dead.exercise = deadlift; w2Dead.workout = w2
        let w2DeadSets: [LoggedSet] = [
            LoggedSet(weight: 275, reps: 5, isCompleted: true, order: 0),
            LoggedSet(weight: 275, reps: 5, isCompleted: true, order: 1)
        ]
        w2DeadSets.forEach { $0.workoutExercise = w2Dead; ctx.insert($0) }
        w2Dead.sets = w2DeadSets

        w2.exercises = [w2Bench, w2Dead]
        ctx.insert(w2); ctx.insert(w2Bench); ctx.insert(w2Dead)

        // Workout 3: yesterday — Bench 3×5 @185, Deadlift 2×5 @285, Squat 3×5 @245
        let w3Date = Date().addingTimeInterval(-86400)
        let w3 = Workout(startDate: w3Date, isActive: false)
        w3.endDate = w3Date.addingTimeInterval(4200)

        let w3Bench = WorkoutExercise(order: 0); w3Bench.exercise = bench; w3Bench.workout = w3
        let w3BenchSets: [LoggedSet] = [
            LoggedSet(weight: 185, reps: 5, isCompleted: true, order: 0),
            LoggedSet(weight: 185, reps: 5, isCompleted: true, order: 1),
            LoggedSet(weight: 185, reps: 5, isCompleted: true, order: 2)
        ]
        w3BenchSets.forEach { $0.workoutExercise = w3Bench; ctx.insert($0) }
        w3Bench.sets = w3BenchSets

        let w3Dead = WorkoutExercise(order: 1); w3Dead.exercise = deadlift; w3Dead.workout = w3
        let w3DeadSets: [LoggedSet] = [
            LoggedSet(weight: 285, reps: 5, isCompleted: true, order: 0),
            LoggedSet(weight: 285, reps: 5, isCompleted: true, order: 1)
        ]
        w3DeadSets.forEach { $0.workoutExercise = w3Dead; ctx.insert($0) }
        w3Dead.sets = w3DeadSets

        let w3Squat = WorkoutExercise(order: 2); w3Squat.exercise = squat; w3Squat.workout = w3
        let w3SquatSets: [LoggedSet] = [
            LoggedSet(weight: 245, reps: 5, isCompleted: true, order: 0),
            LoggedSet(weight: 245, reps: 5, isCompleted: true, order: 1),
            LoggedSet(weight: 245, reps: 5, isCompleted: true, order: 2)
        ]
        w3SquatSets.forEach { $0.workoutExercise = w3Squat; ctx.insert($0) }
        w3Squat.sets = w3SquatSets

        w3.exercises = [w3Bench, w3Dead, w3Squat]
        ctx.insert(w3); ctx.insert(w3Bench); ctx.insert(w3Dead); ctx.insert(w3Squat)

        // PRs across exercises and dates
        let prBench1 = PersonalRecord(weight: 175, reps: 5, estimatedOneRepMax: 204.2, date: w1Date)
        prBench1.exercise = bench; ctx.insert(prBench1)

        let prBench2 = PersonalRecord(weight: 180, reps: 5, estimatedOneRepMax: 210.0, date: w2Date)
        prBench2.exercise = bench; ctx.insert(prBench2)

        let prBench3 = PersonalRecord(weight: 185, reps: 5, estimatedOneRepMax: 215.8, date: w3Date)
        prBench3.exercise = bench; ctx.insert(prBench3)

        let prSquat1 = PersonalRecord(weight: 225, reps: 5, estimatedOneRepMax: 262.5, date: w1Date)
        prSquat1.exercise = squat; ctx.insert(prSquat1)

        let prSquat2 = PersonalRecord(weight: 245, reps: 5, estimatedOneRepMax: 285.8, date: w3Date)
        prSquat2.exercise = squat; ctx.insert(prSquat2)

        let prDead1 = PersonalRecord(weight: 275, reps: 5, estimatedOneRepMax: 320.8, date: w2Date)
        prDead1.exercise = deadlift; ctx.insert(prDead1)

        let prDead2 = PersonalRecord(weight: 285, reps: 5, estimatedOneRepMax: 332.5, date: w3Date)
        prDead2.exercise = deadlift; ctx.insert(prDead2)

        bench.personalRecords = [prBench1, prBench2, prBench3]
        squat.personalRecords = [prSquat1, prSquat2]
        deadlift.personalRecords = [prDead1, prDead2]

        try? ctx.save()
        return container
    }

    /// Returns an ActiveWorkoutStore with a currentWorkout set (no live timer — avoids leaking background tasks in previews).
    /// The workout contains Barbell Squat (1 completed set + 1 empty) and Bench Press (1 empty set).
    static func makeActiveStore(container: ModelContainer) -> ActiveWorkoutStore {
        let ctx = container.mainContext
        let squat = try? ctx.fetch(FetchDescriptor<Exercise>(predicate: #Predicate { $0.name == "Barbell Squat" })).first
        let bench = try? ctx.fetch(FetchDescriptor<Exercise>(predicate: #Predicate { $0.name == "Bench Press" })).first

        let workout = Workout(startDate: Date().addingTimeInterval(-1200), isActive: true)

        let weS = WorkoutExercise(order: 0); weS.exercise = squat; weS.workout = workout
        let sSets: [LoggedSet] = [
            LoggedSet(weight: 135, reps: 5, isCompleted: true, order: 0),
            LoggedSet(order: 1)
        ]
        sSets.forEach { $0.workoutExercise = weS; ctx.insert($0) }
        weS.sets = sSets

        let weB = WorkoutExercise(order: 1); weB.exercise = bench; weB.workout = workout
        let bSet = LoggedSet(order: 0); bSet.workoutExercise = weB; ctx.insert(bSet)
        weB.sets = [bSet]

        workout.exercises = [weS, weB]
        ctx.insert(workout); ctx.insert(weS); ctx.insert(weB)
        try? ctx.save()

        let store = ActiveWorkoutStore()
        store.currentWorkout = workout
        store.elapsedSeconds = 1200
        return store
    }
}
#endif
