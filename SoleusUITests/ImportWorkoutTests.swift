import XCTest

final class ImportWorkoutTests: SoleusUITestBase {

    // MARK: - Helpers

    /// Builds a minimal ShareableWorkout JSON string for test injection.
    private func makeWorkoutJSON(name: String = "Imported Push Day", exerciseCount: Int = 2) -> String {
        let exercises = (0..<exerciseCount).map { i in
            """
            {
              "name": "Exercise \(i + 1)",
              "orderIndex": \(i),
              "quantifier": "Reps",
              "measurement": "Weight",
              "sets": [
                { "setIndex": 0, "reps": 10, "weight": 135.0, "time": 0, "distance": 0.0 },
                { "setIndex": 1, "reps": 8,  "weight": 145.0, "time": 0, "distance": 0.0 }
              ],
              "notes": null
            }
            """
        }.joined(separator: ",")

        return """
        {
          "version": "1.0",
          "workoutName": "\(name)",
          "workoutColor": null,
          "exercises": [\(exercises)],
          "exportDate": "2025-01-01T12:00:00Z"
        }
        """
    }

    /// Launches the app with a pre-loaded import workout for testing the preview sheet.
    private func launchWithImportWorkout(name: String = "Imported Push Day", exerciseCount: Int = 2) {
        app.terminate()
        app.launchEnvironment["UI_TEST_IMPORT_WORKOUT"] = makeWorkoutJSON(name: name, exerciseCount: exerciseCount)
        app.launch()
    }

    // MARK: - Import Button State Tests

    func testImportButtonExists() {
        let button = app.buttons[TestID.navImportButton]
        XCTAssertTrue(waitForElement(button), "Import button should exist in the nav bar")
    }

    func testImportButtonIsEnabledByDefault() {
        let button = app.buttons[TestID.navImportButton]
        XCTAssertTrue(waitForElement(button))
        XCTAssertTrue(button.isEnabled, "Import button should be enabled by default")
    }

    func testImportButtonIsDisabledInEditMode() {
        tapNavBarButton(TestID.navReorderButton)

        let importButton = app.buttons[TestID.navImportButton]
        XCTAssertTrue(waitForElement(importButton))
        XCTAssertFalse(importButton.isEnabled, "Import button should be disabled while in reorder/edit mode")
    }

    func testImportButtonReEnabledAfterExitingEditMode() {
        // Enter edit mode
        tapNavBarButton(TestID.navReorderButton)

        let importButton = app.buttons[TestID.navImportButton]
        XCTAssertTrue(waitForElement(importButton))
        XCTAssertFalse(importButton.isEnabled)

        // Exit edit mode
        tapNavBarButton(TestID.navReorderButton)

        XCTAssertTrue(importButton.isEnabled, "Import button should be re-enabled after exiting edit mode")
    }

    // MARK: - Document Picker Tests

    func testTappingImportOpensDocumentPicker() {
        tapNavBarButton(TestID.navImportButton)

        // The document picker appears as a system sheet with a Cancel button
        let cancelButton = app.buttons["Cancel"]
        XCTAssertTrue(cancelButton.waitForExistence(timeout: 5), "Document picker should appear with a Cancel button")
    }

    // MARK: - Import Preview Tests

    func testImportPreviewShowsWorkoutNameField() {
        launchWithImportWorkout(name: "Imported Push Day")

        let nameField = app.textFields[TestID.importPreviewNameField]
        XCTAssertTrue(nameField.waitForExistence(timeout: 5), "Workout name field should be visible in import preview")
    }

    func testImportPreviewPopulatesWorkoutName() {
        launchWithImportWorkout(name: "Imported Push Day")

        let nameField = app.textFields[TestID.importPreviewNameField]
        XCTAssertTrue(nameField.waitForExistence(timeout: 5))
        XCTAssertEqual(nameField.value as? String, "Imported Push Day", "Name field should be pre-populated with the workout name")
    }

    func testImportPreviewShowsCancelButton() {
        launchWithImportWorkout()

        let cancelButton = app.buttons[TestID.importPreviewCancelButton]
        XCTAssertTrue(cancelButton.waitForExistence(timeout: 5), "Cancel button should be visible in import preview")
    }

    func testImportPreviewShowsImportButton() {
        launchWithImportWorkout()

        let importButton = app.buttons[TestID.importPreviewImportButton]
        XCTAssertTrue(importButton.waitForExistence(timeout: 5), "Import button should be visible in import preview")
    }

    func testImportPreviewShowsNavigationTitle() {
        launchWithImportWorkout()

        let title = app.navigationBars["Import Workout"]
        XCTAssertTrue(title.waitForExistence(timeout: 5), "Navigation title should read 'Import Workout'")
    }

    func testImportPreviewShowsExercisesSection() {
        launchWithImportWorkout(exerciseCount: 2)

        let exercisesHeader = app.staticTexts["Exercises (2)"]
        XCTAssertTrue(exercisesHeader.waitForExistence(timeout: 5), "Exercises section header should show the correct count")
    }

    func testImportPreviewShowsExerciseNames() {
        launchWithImportWorkout(exerciseCount: 1)

        let exerciseText = app.staticTexts["Exercise 1"]
        XCTAssertTrue(exerciseText.waitForExistence(timeout: 5), "Exercise name should be visible in the exercise list")
    }

    func testImportPreviewShowsDetailsSection() {
        launchWithImportWorkout()

        let detailsHeader = app.staticTexts["Details"]
        XCTAssertTrue(detailsHeader.waitForExistence(timeout: 5), "Details section should be visible in import preview")
    }

    func testImportPreviewShowsExportedLabel() {
        launchWithImportWorkout()

        let exportedLabel = app.staticTexts["Exported"]
        XCTAssertTrue(exportedLabel.waitForExistence(timeout: 5), "Exported date label should be visible in Details section")
    }

    func testImportPreviewCancelDismissesSheet() {
        launchWithImportWorkout()

        let cancelButton = app.buttons[TestID.importPreviewCancelButton]
        XCTAssertTrue(cancelButton.waitForExistence(timeout: 5))
        cancelButton.tap()

        // After cancel the import preview should be gone
        let nameField = app.textFields[TestID.importPreviewNameField]
        XCTAssertFalse(nameField.waitForExistence(timeout: 3), "Import preview should be dismissed after tapping Cancel")
    }

    func testImportPreviewAllowsRenamingWorkout() {
        launchWithImportWorkout(name: "Original Name")

        let nameField = app.textFields[TestID.importPreviewNameField]
        XCTAssertTrue(nameField.waitForExistence(timeout: 5))

        // Clear and type a new name
        nameField.tap()
        nameField.clearText()
        nameField.typeText("Renamed Workout")

        XCTAssertEqual(nameField.value as? String, "Renamed Workout", "Name field should reflect the updated name")
    }

    func testImportWorkoutSuccessfullyImports() {
        launchWithImportWorkout(name: "My Imported Workout")

        let importButton = app.buttons[TestID.importPreviewImportButton]
        XCTAssertTrue(importButton.waitForExistence(timeout: 5))
        importButton.tap()

        // Preview sheet should be dismissed
        let nameField = app.textFields[TestID.importPreviewNameField]
        XCTAssertFalse(nameField.waitForExistence(timeout: 3), "Import preview should close after successful import")

        // The imported workout card should appear on the main view
        let workoutCard = app.staticTexts["My Imported Workout"]
        XCTAssertTrue(workoutCard.waitForExistence(timeout: 5), "Imported workout should appear on the main workout list")
    }

    func testImportWorkoutWithEmptyNameShowsAlert() {
        launchWithImportWorkout(name: "Push Day")

        let nameField = app.textFields[TestID.importPreviewNameField]
        XCTAssertTrue(nameField.waitForExistence(timeout: 5))

        // Clear the name
        nameField.tap()
        nameField.clearText()

        // Attempt to import
        let importButton = app.buttons[TestID.importPreviewImportButton]
        XCTAssertTrue(importButton.waitForExistence(timeout: 5))
        importButton.tap()

        // Alert should appear
        let alert = app.alerts["Import Failed"]
        XCTAssertTrue(alert.waitForExistence(timeout: 5), "Alert should appear when importing with an empty name")
        alert.buttons["OK"].tap()

        // Preview should still be visible
        XCTAssertTrue(nameField.waitForExistence(timeout: 3), "Import preview should remain open after failed import")
    }

    func testImportDuplicateNameAutomaticallyRenames() {
        // Launch with a pre-existing "Leg Day" workout AND an import of the same name in one session
        app.terminate()
        app.launchEnvironment["UI_TEST_PRE_CREATE_WORKOUT"] = "Leg Day"
        app.launchEnvironment["UI_TEST_IMPORT_WORKOUT"] = makeWorkoutJSON(name: "Leg Day")
        app.launch()

        // Import the duplicate — should succeed by auto-renaming to "Leg Day-copy"
        let importButton = app.buttons[TestID.importPreviewImportButton]
        XCTAssertTrue(importButton.waitForExistence(timeout: 5))
        importButton.tap()

        // Preview should close (no error alert)
        let nameField = app.textFields[TestID.importPreviewNameField]
        XCTAssertFalse(nameField.waitForExistence(timeout: 3), "Import should succeed with auto-renamed duplicate")

        // The -copy variant should now appear on the main view
        let copyCard = app.staticTexts["Leg Day-copy"]
        XCTAssertTrue(copyCard.waitForExistence(timeout: 5), "Duplicate import should appear with -copy suffix")
    }

    func testExpandingExerciseShowsSetDetails() {
        launchWithImportWorkout(exerciseCount: 1)

        // Tap the exercise row to expand it
        let exerciseRow = app.staticTexts["Exercise 1"]
        XCTAssertTrue(exerciseRow.waitForExistence(timeout: 5))
        exerciseRow.tap()

        // Set details should now be visible
        let setLabel = app.staticTexts["Set 1"]
        XCTAssertTrue(setLabel.waitForExistence(timeout: 3), "Set details should be visible after expanding an exercise")
    }
}

// MARK: - XCUIElement helper

private extension XCUIElement {
    /// Clears the text in a text field.
    func clearText() {
        guard let currentValue = value as? String, !currentValue.isEmpty else { return }
        tap()
        let selectAllMenuItem = XCUIApplication().menuItems["Select All"]
        if selectAllMenuItem.waitForExistence(timeout: 1) {
            selectAllMenuItem.tap()
            typeText(XCUIKeyboardKey.delete.rawValue)
        } else {
            let deleteString = String(repeating: XCUIKeyboardKey.delete.rawValue, count: currentValue.count)
            typeText(deleteString)
        }
    }
}
