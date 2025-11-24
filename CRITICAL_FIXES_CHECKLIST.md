# FlexSprinkle - Critical Fixes Checklist

## CRITICAL (Must fix immediately - Crash & Data Loss Risk)

### [ ] 1. ActiveWorkoutViewModel.swift:88 - Force unwrap crash
```swift
// BEFORE (crashes if array is empty)
let activeSession = workoutController.workoutManager.getSessions().first!

// AFTER
guard let activeSession = workoutController.workoutManager.getSessions().first else {
    print("Error: Active session not found")
    workoutStarted = false
    return
}
```

### [ ] 2. ExerciseRowActive.swift:299 - Array index out of bounds
```swift
// BEFORE (unsafe array access with subtraction)
setInput = updatedWorkoutDetails.sets[setIndex - 1]

// AFTER
guard let updatedWorkoutDetails = workoutController.workoutDetails.first(where: { $0.id == workoutDetails.id }),
      let setIndexInt = Int(setIndex),
      setIndexInt > 0,
      setIndexInt - 1 < updatedWorkoutDetails.sets.count else {
    print("Error: Invalid set index")
    return
}
setInput = updatedWorkoutDetails.sets[setIndexInt - 1]
```

---

## HIGH PRIORITY (High crash/data loss risk)

### [ ] 3. WorkoutManager.swift:913-914 - Force unwrap date calculations
```swift
// BEFORE
let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: calendar.startOfDay(for: date)))!
let endOfMonth = calendar.date(byAdding: DateComponents(month: 1, second: -1), to: startOfMonth)!

// AFTER
guard let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: calendar.startOfDay(for: date))),
      let endOfMonth = calendar.date(byAdding: DateComponents(month: 1, second: -1), to: startOfMonth) else {
    print("Error: Failed to calculate month boundaries")
    return nil
}
```

### [ ] 4. ActiveWorkoutViewModel.swift:26-27 - Implicit unwrapping
```swift
// BEFORE (dangerous implicit unwrapping)
private var workoutController: WorkoutTrackerController!
private var appViewModel: AppViewModel!

// AFTER
private var workoutController: WorkoutTrackerController?
private var appViewModel: AppViewModel?

// Add guard checks in all methods:
guard let workoutController = workoutController else { 
    isLoading = false
    return 
}
```

### [ ] 5. WorkoutManager.swift:279-302 - NSBatchDeleteRequest data loss
```swift
// BEFORE (silent failure - data not deleted)
let result = try context.execute(deleteRequest) as? NSBatchDeleteResult
let objectIDArray = result?.result as? [NSManagedObjectID]
let changes = [NSDeletedObjectsKey: objectIDArray]

// AFTER
guard let result = try context.execute(deleteRequest) as? NSBatchDeleteResult,
      let objectIDArray = result.result as? [NSManagedObjectID], 
      !objectIDArray.isEmpty else {
    print("Warning: No temporary details to delete")
    return
}
let changes = [NSDeletedObjectsKey: objectIDArray]
```

### [ ] 6. ExerciseRowActive.swift:278-283 - Silent data loss
```swift
// BEFORE (silently fails to save, no user feedback)
func saveWorkoutDetail() {
    guard let exerciseId = workoutDetails.exerciseId else {
        print("Error: Cannot save workout detail - exerciseId is nil")
        return
    }
    // save...
}

// AFTER
func saveWorkoutDetail() {
    guard let exerciseId = workoutDetails.exerciseId else {
        DispatchQueue.main.async {
            self.focusManager.errorMessage = "Exercise not initialized. Try saving first."
        }
        return
    }
    // save...
}
```

### [ ] 7. WorkoutManager.swift:130, 177, 258 - Unsafe type casting
```swift
// BEFORE (fails silently, defaults to empty set)
if let tempDetails = workout.detailsTemp as? Set<TemporaryWorkoutDetail> {
    // ...
}

// AFTER
guard let tempDetails = workout.detailsTemp as? Set<TemporaryWorkoutDetail> else {
    print("Error: Failed to cast detailsTemp - possible data corruption")
    errorHandler?.handle(.invalidData("Corrupted workout details"))
    return
}
```

---

## MEDIUM PRIORITY (Data consistency & edge cases)

### [ ] 8. AchievementManager.swift:191, 237, 240 - Unsafe array access
```swift
// BEFORE
var previousDate = histories[0].workoutDate
return components[0] * 3600 + components[1] * 60 + components[2]

// AFTER
guard !histories.isEmpty else { return WorkoutStats() }
var previousDate = histories[0].workoutDate

guard components.count >= 2 else { return 0 }
if components.count >= 3 {
    return components[0] * 3600 + components[1] * 60 + components[2]
}
return components[0] * 60 + components[1]
```

### [ ] 9. WorkoutTrackerController.swift:296-297 - Duplicate check
```swift
// BEFORE (copy-paste error)
guard !detail.exerciseName.isEmpty else { return false }
guard !detail.exerciseName.isEmpty else { return false }  // DUPLICATE!

// AFTER
guard !detail.exerciseName.isEmpty else { return false }
guard !detail.sets.isEmpty else { return false }
```

### [ ] 10. WorkoutTrackerController.swift:236-260 - Missing error handling
```swift
// Add error handling:
func loadTemporaryWorkoutDetails(for workoutId: UUID) {
    let temporaryDetails = workoutManager.loadTemporaryWorkoutData(for: workoutId)
    
    if temporaryDetails.isEmpty {
        print("Info: No temporary workout details found for \(workoutId)")
    }
    
    for tempDetail in temporaryDetails {
        // ... existing code
    }
}
```

### [ ] 11. ActiveWorkoutView.swift:246-249 - Race condition on notes update
```swift
// Add bounds re-validation before array access:
if let selectedIndex = selectedExerciseIndexForNotes,
   selectedIndex < workoutController.workoutDetails.count {
    // Re-validate before binding to ensure array hasn't changed
    if let detail = workoutController.workoutDetails[safe: selectedIndex] {
        exerciseNotes: $detail.notes
    }
}

// Add safe array extension:
extension Array {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
```

---

## LOW PRIORITY (Code quality & best practices)

### [ ] 12. WorkoutManager.swift:325 - Remove preconditionFailure
```swift
// BEFORE
preconditionFailure("CoreData context must be available when creating workouts")

// AFTER
errorHandler?.handle(.contextNotAvailable)
return
```

### [ ] 13. WorkoutDetailsInput.swift:21-49 - Add default values
```swift
struct SetInput: Identifiable, Equatable {
    var id: UUID? = nil
    var reps: Int32 = 0
    var weight: Float = 0.0
    var time: Int32 = 0
    var distance: Float = 0.0
    var isCompleted: Bool = false
    var setIndex: Int32 = 0
    var exerciseQuantifier: String = ""
    var exerciseMeasurement: String = ""
    // ...
}
```

---

## Testing Checklist

After implementing fixes, test these scenarios:

- [ ] Resume workout after 1+ minute in background
- [ ] Cancel workout with 0 sets
- [ ] Add exercise during active workout, then cancel
- [ ] Modify set reps/weight when exerciseId is nil
- [ ] Load history for dates at month boundaries
- [ ] Add/remove exercises while notes dialog is open
- [ ] Delete all temporary details while CoreData is busy
- [ ] Rapid navigation between views
- [ ] Complete workout with 100+ sets
- [ ] Sync temporary data with template after exercise added

---

## Monitoring Post-Fix

Add these crash monitoring hooks:

1. **Session recovery:** Log if `getSessions()` returns empty when expected active
2. **Array bounds:** Log all array access with calculated indices
3. **Data sync:** Log all temporary ↔ template syncs
4. **Silent failures:** Convert all `print()` errors to proper error handling with metrics

