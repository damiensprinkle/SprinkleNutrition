import XCTest

final class ActiveWorkoutTests: SoleusUITestBase {

    // MARK: - Setup Helpers

    private func launchWithWorkout(name: String = "Test Workout") {
        app.terminate()
        app.launchEnvironment["UI_TEST_PRE_CREATE_WORKOUT"] = name
        app.launch()
    }

    /// Taps the play button on the workout card to navigate to ActiveWorkoutView.
    private func openActiveWorkoutView(workoutName: String = "Test Workout") {
        let playButton = app.buttons["Start \(workoutName)"]
        XCTAssertTrue(playButton.waitForExistence(timeout: 5), "Play button for '\(workoutName)' should exist")
        playButton.tap()
    }

    /// Taps the start button then confirms the dialog. Waits until the workout
    /// is running (button transitions from "Start Workout" label to a timer label).
    private func startWorkout() {
        let startWorkoutButton = app.buttons[TestID.startWorkoutButton]
        XCTAssertTrue(startWorkoutButton.waitForExistence(timeout: 5))
        startWorkoutButton.tap()

        // Confirm the dialog
        let confirmButton = app.buttons["Start"]
        XCTAssertTrue(confirmButton.waitForExistence(timeout: 3))
        confirmButton.tap()
    }

    // MARK: - Navigation / Button Tests

    func testStartWorkoutButtonExists() {
        launchWithWorkout()
        openActiveWorkoutView()

        let button = app.buttons[TestID.startWorkoutButton]
        XCTAssertTrue(button.waitForExistence(timeout: 5), "Start workout button should be visible")
    }

    func testStartWorkoutShowsConfirmationDialog() {
        launchWithWorkout()
        openActiveWorkoutView()

        app.buttons[TestID.startWorkoutButton].tap()

        let confirmButton = app.buttons["Start"]
        XCTAssertTrue(confirmButton.waitForExistence(timeout: 3), "Confirmation 'Start' button should appear")
    }

    func testAfterStarting_RepsFieldVisible() {
        launchWithWorkout()
        openActiveWorkoutView()
        startWorkout()

        let repsField = app.textFields[TestID.repsField(set: 1)]
        XCTAssertTrue(repsField.waitForExistence(timeout: 5), "Reps field for set 1 should be visible after starting")
    }

    func testAfterStarting_WeightFieldVisible() {
        launchWithWorkout()
        openActiveWorkoutView()
        startWorkout()

        let weightField = app.textFields[TestID.weightField(set: 1)]
        XCTAssertTrue(weightField.waitForExistence(timeout: 5), "Weight field for set 1 should be visible after starting")
    }

    func testAfterStarting_CompletionToggleVisible() {
        launchWithWorkout()
        openActiveWorkoutView()
        startWorkout()

        let toggle = app.switches[TestID.setToggle(set: 1)]
        XCTAssertTrue(toggle.waitForExistence(timeout: 5), "Completion toggle for set 1 should be visible after starting")
    }

    // MARK: - Auto-Complete Tests

    /// When the user enters both a weight and a reps value, the set completion
    /// toggle should flip on automatically (checkAutoComplete).
    func testAutoComplete_TriggersWhenBothRepsAndWeightEntered() {
        launchWithWorkout()
        openActiveWorkoutView()
        startWorkout()

        // Enter weight
        let weightField = app.textFields[TestID.weightField(set: 1)]
        XCTAssertTrue(weightField.waitForExistence(timeout: 5))
        weightField.tap()
        weightField.typeText("155")

        // Enter reps — this triggers checkAutoComplete after both fields are modified
        let repsField = app.textFields[TestID.repsField(set: 1)]
        repsField.tap()
        repsField.typeText("12")

        // Dismiss keyboard so the toggle is accessible
        app.swipeDown()

        let toggle = app.switches[TestID.setToggle(set: 1)]
        XCTAssertTrue(toggle.waitForExistence(timeout: 3))
        let isOn = (toggle.value as? String) == "1" || (toggle.value as? String) == "Completed"
        XCTAssertTrue(isOn, "Toggle should be auto-completed after entering both reps and weight")
    }

    /// Only entering weight (not reps) should NOT auto-complete the set.
    func testAutoComplete_DoesNotTriggerWithOnlyWeightEntered() {
        launchWithWorkout()
        openActiveWorkoutView()
        startWorkout()

        let weightField = app.textFields[TestID.weightField(set: 1)]
        XCTAssertTrue(weightField.waitForExistence(timeout: 5))
        weightField.tap()
        weightField.typeText("155")

        // Dismiss keyboard without entering reps
        app.swipeDown()

        let toggle = app.switches[TestID.setToggle(set: 1)]
        XCTAssertTrue(toggle.waitForExistence(timeout: 3))
        let isOff = (toggle.value as? String) == "0" || (toggle.value as? String) == "Not completed"
        XCTAssertTrue(isOff, "Toggle should NOT auto-complete when only weight is entered")
    }

    // MARK: - Value Persistence Tests

    /// Entering a weight value, switching fields to trigger save, then navigating
    /// away and resuming the workout should show the saved value.
    func testWeightValue_PersistedAfterNavigationAway() {
        launchWithWorkout()
        openActiveWorkoutView()
        startWorkout()

        // Enter a distinctive weight
        let weightField = app.textFields[TestID.weightField(set: 1)]
        XCTAssertTrue(weightField.waitForExistence(timeout: 5))
        weightField.tap()
        weightField.typeText("225")

        // Tap reps field to trigger focus change and save
        let repsField = app.textFields[TestID.repsField(set: 1)]
        repsField.tap()

        // Navigate back to the workout list
        app.buttons["Back"].tap()

        // The active session banner should appear
        let banner = app.buttons[TestID.activeSessionBanner]
        XCTAssertTrue(banner.waitForExistence(timeout: 5), "Active session banner should be visible after navigating back")
        banner.tap()

        // Verify the weight value survived the round-trip through CoreData
        let weightFieldReloaded = app.textFields[TestID.weightField(set: 1)]
        XCTAssertTrue(weightFieldReloaded.waitForExistence(timeout: 5))
        let savedValue = weightFieldReloaded.value as? String ?? ""
        XCTAssertTrue(
            savedValue.hasPrefix("225"),
            "Weight value should persist after navigating away and back (got '\(savedValue)')"
        )
    }

    /// Entering a reps value and switching focus should save that value.
    func testRepsValue_PersistedAfterNavigationAway() {
        launchWithWorkout()
        openActiveWorkoutView()
        startWorkout()

        // Enter reps
        let repsField = app.textFields[TestID.repsField(set: 1)]
        XCTAssertTrue(repsField.waitForExistence(timeout: 5))
        repsField.tap()
        repsField.typeText("15")

        // Switch to weight field to trigger save
        let weightField = app.textFields[TestID.weightField(set: 1)]
        weightField.tap()

        // Navigate back
        app.buttons["Back"].tap()

        let banner = app.buttons[TestID.activeSessionBanner]
        XCTAssertTrue(banner.waitForExistence(timeout: 5))
        banner.tap()

        let repsReloaded = app.textFields[TestID.repsField(set: 1)]
        XCTAssertTrue(repsReloaded.waitForExistence(timeout: 5))
        // .value returns the accessibilityValue, which is formatted as "<reps> reps"
        XCTAssertEqual(repsReloaded.value as? String, "15 reps", "Reps value should persist after navigating away and back")
    }
}
