import XCTest

final class CreateWorkoutFlowTests: SoleusUITestBase {

    func testEmptyStateVisible() {
        let title = app.staticTexts[TestID.emptyStateTitle]
        XCTAssertTrue(waitForElement(title), "Empty state title should be visible on fresh launch")
    }

    func testEmptyStateCreateButtonExists() {
        let button = app.buttons[TestID.emptyStateCreateButton]
        XCTAssertTrue(waitForElement(button), "Empty state create button should exist")
    }

    func testNavAddButtonExists() {
        let button = app.buttons[TestID.navAddWorkoutButton]
        XCTAssertTrue(waitForElement(button), "Nav bar add button should exist")
    }

    func testNavAddButtonOpensCreateSheet() {
        tapNavBarButton(TestID.navAddWorkoutButton)

        let titleField = app.textFields[TestID.addWorkoutTitleField]
        XCTAssertTrue(titleField.waitForExistence(timeout: 5), "Workout title field should appear in create sheet")
    }

    func testEmptyStateButtonOpensCreateSheet() {
        let createButton = app.buttons[TestID.emptyStateCreateButton]
        XCTAssertTrue(waitForElement(createButton))
        createButton.tap()

        let titleField = app.textFields[TestID.addWorkoutTitleField]
        XCTAssertTrue(titleField.waitForExistence(timeout: 5), "Workout title field should appear in create sheet")
    }

    func testCreateSheetHasCancelAndSave() {
        tapNavBarButton(TestID.navAddWorkoutButton)

        let cancelButton = app.buttons[TestID.addWorkoutCancelButton]
        let saveButton = app.buttons[TestID.addWorkoutSaveButton]

        XCTAssertTrue(cancelButton.waitForExistence(timeout: 5), "Cancel button should exist")
        XCTAssertTrue(saveButton.waitForExistence(timeout: 5), "Save button should exist")
    }

    func testCreateWorkoutFullFlow() {
        tapNavBarButton(TestID.navAddWorkoutButton)

        // Type workout title
        let titleField = app.textFields[TestID.addWorkoutTitleField]
        XCTAssertTrue(titleField.waitForExistence(timeout: 5))
        titleField.tap()
        titleField.typeText("Test Workout")

        // Dismiss keyboard by tapping the non-interactive label above the field.
        // The Add Exercise button is hidden while any text field is focused.
        app.staticTexts["Workout Title"].tap()

        // Tap Add Exercise button
        let addExerciseButton = app.buttons[TestID.addWorkoutAddExerciseButton]
        XCTAssertTrue(addExerciseButton.waitForExistence(timeout: 5), "Add Exercise button should appear after keyboard dismisses")
        addExerciseButton.tap()

        // Fill exercise name
        let exerciseNameField = app.textFields[TestID.exerciseNameField]
        XCTAssertTrue(exerciseNameField.waitForExistence(timeout: 5))
        exerciseNameField.tap()
        exerciseNameField.typeText("Bench Press")

        // Add the exercise
        let addButton = app.buttons[TestID.exerciseDialogAddButton]
        XCTAssertTrue(addButton.waitForExistence(timeout: 5))
        addButton.tap()

        // Verify exercise card appeared by checking for the exercise name text
        let exerciseLabel = app.staticTexts["Bench Press"]
        XCTAssertTrue(exerciseLabel.waitForExistence(timeout: 5), "Exercise card should appear after adding")

        // Save workout
        let saveButton = app.buttons[TestID.addWorkoutSaveButton]
        XCTAssertTrue(saveButton.waitForExistence(timeout: 5))
        saveButton.tap()

        // Verify we're back on main view and empty state is gone
        let emptyState = app.staticTexts[TestID.emptyStateTitle]
        XCTAssertFalse(emptyState.waitForExistence(timeout: 3), "Empty state should no longer be visible")
    }
}
