import XCTest

final class SettingsTests: SoleusUITestBase {

    override func setUpWithError() throws {
        try super.setUpWithError()
        tapTab(TestID.tabSettings)
    }

    func testSettingsViewLoads() {
        let navBar = app.navigationBars["Settings"]
        XCTAssertTrue(navBar.waitForExistence(timeout: 5), "Settings navigation bar should be visible")
    }

    func testPreferencesSectionExists() {
        let weightPicker = app.buttons[TestID.settingsWeightPicker]
        let distancePicker = app.buttons[TestID.settingsDistancePicker]

        XCTAssertTrue(weightPicker.waitForExistence(timeout: 5), "Weight preference picker should exist")
        XCTAssertTrue(distancePicker.waitForExistence(timeout: 5), "Distance preference picker should exist")
    }

    func testRestTimerToggleExists() {
        let toggle = app.switches[TestID.settingsRestTimerToggle]
        XCTAssertTrue(toggle.waitForExistence(timeout: 5), "Rest timer toggle should exist")
    }

    func testHelpButtonExists() {
        let helpButton = app.buttons[TestID.settingsHelpButton]
        XCTAssertTrue(helpButton.waitForExistence(timeout: 5), "Help & FAQ button should exist")
    }

    func testPrivacyButtonExists() {
        app.collectionViews.firstMatch.swipeUp()
        let privacyButton = app.buttons[TestID.settingsPrivacyButton]
        XCTAssertTrue(privacyButton.waitForExistence(timeout: 5), "Privacy Policy button should exist")
    }
}
