import XCTest

final class HistoryViewTests: SoleusUITestBase {

    func testNavigateToHistoryView() {
        tapNavBarButton(TestID.navHistoryButton)

        // History view should show empty state on fresh install
        let emptyText = app.staticTexts[TestID.historyEmptyStateText]
        XCTAssertTrue(emptyText.waitForExistence(timeout: 5), "History empty state should be visible")
    }

    func testHistoryEmptyStateContent() {
        tapNavBarButton(TestID.navHistoryButton)

        let emptyText = app.staticTexts[TestID.historyEmptyStateText]
        XCTAssertTrue(emptyText.waitForExistence(timeout: 5))
        XCTAssertEqual(emptyText.label, "No workout history yet")
    }

    func testTimePeriodButtonsExist() {
        tapNavBarButton(TestID.navHistoryButton)

        let monthlyButton = app.buttons[TestID.historyTimePeriodMonthly]
        let allTimeButton = app.buttons[TestID.historyTimePeriodAllTime]

        XCTAssertTrue(monthlyButton.waitForExistence(timeout: 5), "Monthly time period button should exist")
        XCTAssertTrue(allTimeButton.waitForExistence(timeout: 5), "All Time time period button should exist")
    }
}
