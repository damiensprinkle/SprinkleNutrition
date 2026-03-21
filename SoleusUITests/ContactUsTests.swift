import XCTest

final class ContactUsTests: SoleusUITestBase {

    override func setUpWithError() throws {
        try super.setUpWithError()
        tapTab(TestID.tabSettings)
        // The Contact Us button is below the fold — scroll down to bring it into view.
        app.collectionViews.firstMatch.swipeUp()
        app.collectionViews.firstMatch.swipeUp()
    }

    // MARK: - Navigation

    func testContactUsButtonExistsInSettings() {
        let button = app.buttons[TestID.settingsContactUsButton]
        XCTAssertTrue(button.waitForExistence(timeout: 5), "Contact Us button should exist in Settings")
    }

    func testTappingContactUsOpensSheet() {
        app.buttons[TestID.settingsContactUsButton].tap()

        let navBar = app.navigationBars["Contact Us"]
        XCTAssertTrue(navBar.waitForExistence(timeout: 5), "Contact Us sheet should open with correct navigation title")
    }

    // MARK: - Sheet Content

    func testBugReportRowExists() {
        openContactUs()

        let button = app.buttons[TestID.contactUsBugReportButton]
        XCTAssertTrue(button.waitForExistence(timeout: 5), "Report a Bug row should be visible")
    }

    func testFeatureRequestRowExists() {
        openContactUs()

        let button = app.buttons[TestID.contactUsFeatureRequestButton]
        XCTAssertTrue(button.waitForExistence(timeout: 5), "Request a Feature row should be visible")
    }

    func testAttachLogsToggleExists() {
        openContactUs()

        let toggle = app.switches[TestID.contactUsAttachLogsToggle]
        XCTAssertTrue(toggle.waitForExistence(timeout: 5), "Attach logs toggle should be visible")
    }

    func testAttachLogsToggleIsOnByDefault() {
        openContactUs()

        let toggle = app.switches[TestID.contactUsAttachLogsToggle]
        XCTAssertTrue(toggle.waitForExistence(timeout: 5))
        XCTAssertEqual(toggle.value as? String, "1", "Attach logs toggle should be on by default")
    }

    func testAttachLogsToggleCanBeDisabled() {
        openContactUs()

        let toggle = app.switches[TestID.contactUsAttachLogsToggle]
        XCTAssertTrue(toggle.waitForExistence(timeout: 5))
        // Tap the right side of the switch handle to avoid hitting the list cell row
        toggle.coordinate(withNormalizedOffset: CGVector(dx: 0.9, dy: 0.5)).tap()
        XCTAssertEqual(toggle.value as? String, "0", "Attach logs toggle should be off after tapping")
    }

    func testSupportEmailIsVisible() {
        openContactUs()

        let emailLabel = app.staticTexts["SoleusApp@gmail.com"]
        XCTAssertTrue(emailLabel.waitForExistence(timeout: 5), "Support email address should be visible")
    }

    // MARK: - Mail Unavailable Alert (simulators cannot send mail)

    func testTappingBugReportShowsMailUnavailableAlert() {
        openContactUs()

        app.buttons[TestID.contactUsBugReportButton].tap()

        let alert = app.alerts["Mail Not Available"]
        XCTAssertTrue(alert.waitForExistence(timeout: 5), "Mail Not Available alert should appear on simulator")
    }

    func testTappingFeatureRequestShowsMailUnavailableAlert() {
        openContactUs()

        app.buttons[TestID.contactUsFeatureRequestButton].tap()

        let alert = app.alerts["Mail Not Available"]
        XCTAssertTrue(alert.waitForExistence(timeout: 5), "Mail Not Available alert should appear on simulator")
    }

    func testMailUnavailableAlertHasOKButton() {
        openContactUs()
        app.buttons[TestID.contactUsBugReportButton].tap()

        let alert = app.alerts["Mail Not Available"]
        XCTAssertTrue(alert.waitForExistence(timeout: 5))
        XCTAssertTrue(alert.buttons["OK"].exists, "Alert should have an OK button")
    }

    func testDismissingMailAlertReturnsToContactUs() {
        openContactUs()
        app.buttons[TestID.contactUsBugReportButton].tap()

        let alert = app.alerts["Mail Not Available"]
        XCTAssertTrue(alert.waitForExistence(timeout: 5))
        alert.buttons["OK"].tap()

        // Sheet should still be open after dismissing the alert
        let navBar = app.navigationBars["Contact Us"]
        XCTAssertTrue(navBar.waitForExistence(timeout: 5), "Contact Us sheet should remain open after dismissing alert")
    }

    func testBugReportAndFeatureRequestBothShowAlert() {
        openContactUs()

        // Bug report
        app.buttons[TestID.contactUsBugReportButton].tap()
        var alert = app.alerts["Mail Not Available"]
        XCTAssertTrue(alert.waitForExistence(timeout: 5))
        alert.buttons["OK"].tap()

        // Feature request
        app.buttons[TestID.contactUsFeatureRequestButton].tap()
        alert = app.alerts["Mail Not Available"]
        XCTAssertTrue(alert.waitForExistence(timeout: 5), "Feature Request should also show Mail Not Available alert")
        alert.buttons["OK"].tap()
    }

    // MARK: - Dismiss Sheet

    func testDoneButtonDismissesSheet() {
        openContactUs()

        app.navigationBars["Contact Us"].buttons["Done"].tap()

        let navBar = app.navigationBars["Contact Us"]
        XCTAssertFalse(navBar.waitForExistence(timeout: 3), "Contact Us sheet should be dismissed after tapping Done")
    }

    // MARK: - Helper

    private func openContactUs() {
        let button = app.buttons[TestID.settingsContactUsButton]
        XCTAssertTrue(button.waitForExistence(timeout: 5))
        button.tap()
        XCTAssertTrue(app.navigationBars["Contact Us"].waitForExistence(timeout: 5))
    }
}
