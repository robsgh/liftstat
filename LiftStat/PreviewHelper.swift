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

        // Completed past workout: Bench 3×5 @185, Deadlift 2×5 @225
        let past = Workout(startDate: Date().addingTimeInterval(-7200), isActive: false)
        past.endDate = Date().addingTimeInterval(-3600)

        let weB = WorkoutExercise(order: 0); weB.exercise = bench; weB.workout = past
        let bSets: [LoggedSet] = [
            LoggedSet(weight: 185, reps: 5, isCompleted: true, order: 0),
            LoggedSet(weight: 185, reps: 5, isCompleted: true, order: 1),
            LoggedSet(weight: 185, reps: 4, isCompleted: true, order: 2)
        ]
        bSets.forEach { $0.workoutExercise = weB; ctx.insert($0) }
        weB.sets = bSets

        let weD = WorkoutExercise(order: 1); weD.exercise = deadlift; weD.workout = past
        let dSets: [LoggedSet] = [
            LoggedSet(weight: 225, reps: 5, isCompleted: true, order: 0),
            LoggedSet(weight: 225, reps: 5, isCompleted: true, order: 1)
        ]
        dSets.forEach { $0.workoutExercise = weD; ctx.insert($0) }
        weD.sets = dSets

        past.exercises = [weB, weD]
        ctx.insert(past); ctx.insert(weB); ctx.insert(weD)

        // PR for Bench
        let pr = PersonalRecord(weight: 185, reps: 5, estimatedOneRepMax: 208.3)
        pr.exercise = bench
        ctx.insert(pr)

        try? ctx.save()
        return container
    }

    /// Returns an ActiveWorkoutStore with a live active workout in the given container.
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
        store.resumeWorkout(workout)
        return store
    }
}
#endif
