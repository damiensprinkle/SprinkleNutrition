import Foundation

struct WorkoutTemplate {
    struct TemplateExercise {
        let name: String
        let sets: Int
        let reps: Int32
        let weight: Float
    }

    let name: String
    let exercises: [TemplateExercise]

    func toWorkoutDetails() -> [WorkoutDetailInput] {
        exercises.enumerated().map { index, exercise in
            let setInputs = (0..<exercise.sets).map { setIndex in
                SetInput(
                    id: UUID(),
                    reps: exercise.reps,
                    weight: exercise.weight,
                    time: 0,
                    distance: 0,
                    isCompleted: false,
                    setIndex: Int32(setIndex),
                    exerciseQuantifier: "Reps",
                    exerciseMeasurement: "Weight"
                )
            }
            return WorkoutDetailInput(
                id: UUID(),
                exerciseId: UUID(),
                exerciseName: exercise.name,
                notes: nil,
                orderIndex: Int32(index),
                sets: setInputs,
                exerciseQuantifier: "Reps",
                exerciseMeasurement: "Weight"
            )
        }
    }

    static let allTemplates: [WorkoutTemplate] = [
        WorkoutTemplate(name: "Push", exercises: [
            TemplateExercise(name: "Barbell Bench Press",      sets: 4, reps: 8,  weight: 135),
            TemplateExercise(name: "Incline Dumbbell Press",   sets: 3, reps: 10, weight: 40),
            TemplateExercise(name: "Dumbbell Shoulder Press",  sets: 3, reps: 8,  weight: 35),
            TemplateExercise(name: "Dumbbell Lateral Raise",   sets: 3, reps: 12, weight: 15),
            TemplateExercise(name: "Tricep Rope Pushdown",     sets: 3, reps: 10, weight: 50),
        ]),
        WorkoutTemplate(name: "Pull", exercises: [
            TemplateExercise(name: "Lat Pulldown",             sets: 4, reps: 8,  weight: 120),
            TemplateExercise(name: "Barbell Bent Over Row",    sets: 4, reps: 8,  weight: 115),
            TemplateExercise(name: "Seated Cable Row",         sets: 3, reps: 10, weight: 110),
            TemplateExercise(name: "Face Pull",                sets: 3, reps: 12, weight: 40),
            TemplateExercise(name: "Dumbbell Bicep Curl",      sets: 3, reps: 10, weight: 25),
        ]),
        WorkoutTemplate(name: "Legs", exercises: [
            TemplateExercise(name: "Barbell Squat",            sets: 4, reps: 8,  weight: 185),
            TemplateExercise(name: "Romanian Deadlift",        sets: 3, reps: 8,  weight: 155),
            TemplateExercise(name: "Leg Press",                sets: 3, reps: 10, weight: 270),
            TemplateExercise(name: "Leg Curl",                 sets: 3, reps: 12, weight: 90),
            TemplateExercise(name: "Standing Calf Raise",      sets: 4, reps: 12, weight: 140),
        ]),
        WorkoutTemplate(name: "Chest", exercises: [
            TemplateExercise(name: "Barbell Bench Press",      sets: 4, reps: 8,  weight: 135),
            TemplateExercise(name: "Incline Dumbbell Press",   sets: 3, reps: 10, weight: 40),
            TemplateExercise(name: "Dumbbell Chest Fly",       sets: 3, reps: 10, weight: 25),
            TemplateExercise(name: "Push Ups",                 sets: 3, reps: 12, weight: 0),
        ]),
        WorkoutTemplate(name: "Back", exercises: [
            TemplateExercise(name: "Deadlift",                 sets: 4, reps: 5,  weight: 225),
            TemplateExercise(name: "Lat Pulldown",             sets: 4, reps: 8,  weight: 120),
            TemplateExercise(name: "Barbell Row",              sets: 3, reps: 8,  weight: 115),
            TemplateExercise(name: "Face Pull",                sets: 3, reps: 12, weight: 40),
        ]),
        WorkoutTemplate(name: "Shoulders", exercises: [
            TemplateExercise(name: "Overhead Barbell Press",   sets: 4, reps: 6,  weight: 95),
            TemplateExercise(name: "Dumbbell Lateral Raise",   sets: 3, reps: 12, weight: 15),
            TemplateExercise(name: "Rear Delt Fly",            sets: 3, reps: 12, weight: 15),
            TemplateExercise(name: "Arnold Press",             sets: 3, reps: 8,  weight: 30),
        ]),
        WorkoutTemplate(name: "Arms", exercises: [
            TemplateExercise(name: "Barbell Curl",             sets: 3, reps: 8,  weight: 65),
            TemplateExercise(name: "Hammer Curl",              sets: 3, reps: 10, weight: 30),
            TemplateExercise(name: "Tricep Dips",              sets: 3, reps: 10, weight: 0),
            TemplateExercise(name: "Rope Pushdown",            sets: 3, reps: 10, weight: 50),
            TemplateExercise(name: "Overhead Tricep Extension",sets: 3, reps: 10, weight: 35),
        ]),
        WorkoutTemplate(name: "Total Body I", exercises: [
            TemplateExercise(name: "Barbell Squat",            sets: 4, reps: 8,  weight: 185),
            TemplateExercise(name: "Bench Press",              sets: 3, reps: 8,  weight: 135),
            TemplateExercise(name: "Lat Pulldown",             sets: 3, reps: 10, weight: 120),
            TemplateExercise(name: "Dumbbell Shoulder Press",  sets: 3, reps: 10, weight: 35),
            TemplateExercise(name: "Plank",                    sets: 3, reps: 30, weight: 0),
        ]),
        WorkoutTemplate(name: "Total Body II", exercises: [
            TemplateExercise(name: "Deadlift",                 sets: 4, reps: 5,  weight: 225),
            TemplateExercise(name: "Incline Dumbbell Press",   sets: 3, reps: 10, weight: 40),
            TemplateExercise(name: "Seated Cable Row",         sets: 3, reps: 10, weight: 110),
            TemplateExercise(name: "Dumbbell Lateral Raise",   sets: 3, reps: 12, weight: 15),
            TemplateExercise(name: "Hanging Leg Raise",        sets: 3, reps: 10, weight: 0),
        ]),
    ]
}
