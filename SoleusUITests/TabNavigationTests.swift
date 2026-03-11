import XCTest

final class TabNavigationTests: SoleusUITestBase {

    func testAppLaunches() {
        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 10))
    }

    func testWorkoutTabExists() {
        let tab = app.buttons[TestID.tabWorkout]
        XCTAssertTrue(waitForElement(tab))
    }

    func testDashboardTabExists() {
        let tab = app.buttons[TestID.tabDashboard]
        XCTAssertTrue(waitForElement(tab))
    }

    func testSettingsTabExists() {
        let tab = app.buttons[TestID.tabSettings]
        XCTAssertTrue(waitForElement(tab))
    }

    func testSwitchToSettingsTab() {
        tapTab(TestID.tabSettings)
        let settingsTitle = app.navigationBars["Settings"]
        XCTAssertTrue(settingsTitle.waitForExistence(timeout: 5), "Settings navigation title should appear")
    }

    func testSwitchToDashboardTab() {
        tapTab(TestID.tabDashboard)
        let dashboardTitle = app.navigationBars["Dashboard"]
        XCTAssertTrue(dashboardTitle.waitForExistence(timeout: 5), "Dashboard navigation title should appear")
    }
}
