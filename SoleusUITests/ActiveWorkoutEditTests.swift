import XCTest

/// Tests for modifying an active workout via edit mode:
/// adding an exercise, adding a set, adding a note, reordering, and deleting.
final class ActiveWorkoutEditTests: SoleusUITestBase {

    // MARK: - Setup

    private func launchWithWorkout(name: String = "Edit Test Workout") {
        app.terminate()
        app.launchEnvironment["UI_TEST_PRE_CREATE_WORKOUT"] = name
        app.launch()
    }

    private func openActiveWorkoutView(workoutName: String = "Edit Test Workout") {
        let playButton = app.buttons["Start \(workoutName)"]
        XCTAssertTrue(playButton.waitForExistence(timeout: 5), "Play button for '\(workoutName)' should exist")
        playButton.tap()
    }

    private func startWorkout() {
        let startButton = app.buttons[TestID.startWorkoutButton]
        XCTAssertTrue(startButton.waitForExistence(timeout: 5))
        startButton.tap()

        let confirmButton = app.buttons["Start"]
        XCTAssertTrue(confirmButton.waitForExistence(timeout: 3))
        confirmButton.tap()
    }

    private func enterEditMode() {
        let editButton = app.buttons[TestID.activeEditModeButton]
        XCTAssertTrue(editButton.waitForExistence(timeout: 5), "Edit mode button should be visible")
        editButton.tap()
    }

    /// Returns the exercise section header button (label begins with the exercise name).
    /// The header HStack uses .accessibilityLabel("Name, expanded/collapsed") + .isButton trait.
    private func exerciseHeaderButton(name: String) -> XCUIElement {
        let predicate = NSPredicate(format: "label BEGINSWITH %@", name)
        return app.buttons.matching(predicate).firstMatch
    }

    /// Opens the add-exercise dialog, types the name, taps Add, and waits for the dialog to fully dismiss.
    @discardableResult
    private func addExerciseViaDialog(name: String) -> Bool {
        app.buttons[TestID.activeAddExerciseButton].tap()

        let nameField = app.textFields[TestID.exerciseNameField]
        guard nameField.waitForExistence(timeout: 5) else { return false }
        nameField.tap()
        nameField.typeText(name)

        app.buttons[TestID.exerciseDialogAddButton].tap()

        // Wait for the dialog to fully dismiss before continuing
        let cancelButton = app.buttons[TestID.exerciseDialogCancelButton]
        _ = cancelButton.waitForNonExistence(timeout: 5)

        // Exercise header is a button with accessibilityLabel "Name, expanded" or "Name, collapsed"
        return exerciseHeaderButton(name: name).waitForExistence(timeout: 8)
    }

    // MARK: - Add Exercise

    func testEditMode_AddExercise() {
        launchWithWorkout()
        openActiveWorkoutView()
        startWorkout()
        enterEditMode()

        XCTAssertTrue(
            addExerciseViaDialog(name: "Bench Press"),
            "Newly added exercise 'Bench Press' should appear in the workout"
        )
    }

    // MARK: - Add Set

    func testEditMode_AddSet() {
        launchWithWorkout()
        openActiveWorkoutView()
        startWorkout()
        enterEditMode()

        // Exercise 0 ("Placeholder") has 1 set — add a second
        let addSetButton = app.buttons[TestID.addSetButton(exercise: 0)]
        XCTAssertTrue(addSetButton.waitForExistence(timeout: 3), "Add Set button should be visible in edit mode")
        addSetButton.tap()

        // Set 2 fields should now exist
        let repsField2 = app.textFields[TestID.repsField(set: 2)]
        XCTAssertTrue(repsField2.waitForExistence(timeout: 3), "Reps field for set 2 should appear after adding a set")
    }

    // MARK: - Add Note

    func testEditMode_AddNote() {
        launchWithWorkout()
        openActiveWorkoutView()
        startWorkout()
        enterEditMode()

        let noteButton = app.buttons[TestID.noteButton(exercise: 0)]
        XCTAssertTrue(noteButton.waitForExistence(timeout: 3), "Note button should be visible in edit mode")
        noteButton.tap()

        let notesField = app.textViews[TestID.notesField(exercise: 0)]
            .firstMatch
        // Fall back to textField if textView not found (axis: .vertical renders as textView in UIKit)
        let field = notesField.exists ? notesField : app.textFields[TestID.notesField(exercise: 0)]
        XCTAssertTrue(field.waitForExistence(timeout: 3), "Notes input field should appear after tapping note button")

        field.tap()
        field.typeText("Keep back flat")

        // Dismiss via toolbar Done button
        let doneButton = app.toolbars.buttons["Done"]
        if doneButton.waitForExistence(timeout: 2) {
            doneButton.tap()
        } else {
            app.swipeDown()
        }

        // Note text should be visible below the exercise header
        XCTAssertTrue(
            app.staticTexts["Keep back flat"].waitForExistence(timeout: 3),
            "Saved note should be visible below the exercise"
        )
    }

    // MARK: - Reorder Exercise

    func testEditMode_ReorderExercise() {
        launchWithWorkout()
        openActiveWorkoutView()
        startWorkout()
        enterEditMode()

        // Add a second exercise so reordering is possible
        XCTAssertTrue(addExerciseViaDialog(name: "Squat"), "Squat exercise should be added")

        // Open the ··· menu for exercise 0 and move it down
        let menu = app.buttons[TestID.exerciseMenu(exercise: 0)]
        XCTAssertTrue(menu.waitForExistence(timeout: 3), "Exercise menu should exist for exercise 0")
        menu.tap()

        let moveDownButton = app.buttons["Move Down"]
        XCTAssertTrue(moveDownButton.waitForExistence(timeout: 2), "Move Down should appear in the exercise menu")
        moveDownButton.tap()

        // Both exercises should still be present after reordering
        XCTAssertTrue(exerciseHeaderButton(name: "Placeholder").waitForExistence(timeout: 3))
        XCTAssertTrue(exerciseHeaderButton(name: "Squat").waitForExistence(timeout: 3))
    }

    // MARK: - Delete Exercise

    func testEditMode_DeleteExercise() {
        launchWithWorkout()
        openActiveWorkoutView()
        startWorkout()
        enterEditMode()

        // Add a second exercise so we have something to delete without emptying the workout
        XCTAssertTrue(addExerciseViaDialog(name: "Deadlift"), "Deadlift exercise should be added")

        // Delete exercise 1 ("Deadlift")
        let menu = app.buttons[TestID.exerciseMenu(exercise: 1)]
        XCTAssertTrue(menu.waitForExistence(timeout: 3), "Exercise menu should exist for exercise 1")
        menu.tap()

        let deleteButton = app.buttons["Delete Exercise"]
        XCTAssertTrue(deleteButton.waitForExistence(timeout: 2), "Delete Exercise should appear in the menu")
        deleteButton.tap()

        // Confirm the alert
        let confirmDelete = app.buttons["Delete"]
        XCTAssertTrue(confirmDelete.waitForExistence(timeout: 2), "Delete confirmation button should appear")
        confirmDelete.tap()

        // "Deadlift" should no longer be present
        XCTAssertFalse(
            exerciseHeaderButton(name: "Deadlift").waitForExistence(timeout: 2),
            "Deleted exercise should no longer be visible"
        )
        // "Placeholder" should still be there
        XCTAssertTrue(exerciseHeaderButton(name: "Placeholder").exists)
    }
}
