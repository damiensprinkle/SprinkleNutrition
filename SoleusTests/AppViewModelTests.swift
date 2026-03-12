import XCTest
import Combine
@testable import Soleus

final class AppViewModelTests: XCTestCase {
    var sut: AppViewModel!
    var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        sut = AppViewModel()
        cancellables = []
    }

    override func tearDown() {
        cancellables = nil
        sut = nil
        super.tearDown()
    }

    // Flush DispatchQueue.main.async calls
    private func flushMain() {
        RunLoop.main.run(until: Date(timeIntervalSinceNow: 0.05))
    }

    // MARK: - Initial State

    func testInitialCurrentView_IsMain() {
        XCTAssertEqual(sut.currentView, .main)
    }

    func testInitialCurrentTab_IsHome() {
        XCTAssertEqual(sut.currentTab, .home)
    }

    // MARK: - navigateTo

    func testNavigateTo_WorkoutHistoryView_UpdatesCurrentView() {
        sut.navigateTo(.workoutHistoryView)
        flushMain()
        XCTAssertEqual(sut.currentView, .workoutHistoryView)
    }

    func testNavigateTo_WorkoutActiveView_UpdatesCurrentView() {
        let id = UUID()
        sut.navigateTo(.workoutActiveView(id))
        flushMain()
        XCTAssertEqual(sut.currentView, .workoutActiveView(id))
    }

    func testNavigateTo_WorkoutOverview_UpdatesCurrentView() {
        let id = UUID()
        sut.navigateTo(.workoutOverview(id, "00:30:00"))
        flushMain()
        XCTAssertEqual(sut.currentView, .workoutOverview(id, "00:30:00"))
    }

    func testNavigateTo_CustomizeCardView_UpdatesCurrentView() {
        let id = UUID()
        sut.navigateTo(.customizeCardView(id))
        flushMain()
        XCTAssertEqual(sut.currentView, .customizeCardView(id))
    }

    func testNavigateTo_AchievementsView_UpdatesCurrentView() {
        sut.navigateTo(.achievementsView)
        flushMain()
        XCTAssertEqual(sut.currentView, .achievementsView)
    }

    func testNavigateTo_Main_UpdatesCurrentView() {
        sut.navigateTo(.workoutHistoryView)
        flushMain()
        sut.navigateTo(.main)
        flushMain()
        XCTAssertEqual(sut.currentView, .main)
    }

    func testNavigateTo_PublishesChange() {
        let expectation = expectation(description: "currentView published")
        sut.$currentView
            .dropFirst() // skip initial value
            .sink { view in
                if view == .workoutHistoryView {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        sut.navigateTo(.workoutHistoryView)
        waitForExpectations(timeout: 1)
    }

    // MARK: - resetToWorkoutMainView

    func testResetToWorkoutMainView_SetsCurrentViewToMain() {
        sut.navigateTo(.workoutHistoryView)
        flushMain()
        sut.resetToWorkoutMainView()
        flushMain()
        XCTAssertEqual(sut.currentView, .main)
    }

    func testResetToWorkoutMainView_SetsCurrentTabToWorkout() {
        sut.resetToWorkoutMainView()
        flushMain()
        XCTAssertEqual(sut.currentTab, .workout)
    }

    func testResetToWorkoutMainView_FromAnyView_ResetsToMain() {
        let id = UUID()
        sut.navigateTo(.workoutActiveView(id))
        flushMain()
        XCTAssertNotEqual(sut.currentView, .main)

        sut.resetToWorkoutMainView()
        flushMain()
        XCTAssertEqual(sut.currentView, .main)
    }

    // MARK: - ContentViewType Equatable

    func testContentViewType_MainEquality() {
        XCTAssertEqual(AppViewModel.ContentViewType.main, .main)
    }

    func testContentViewType_WorkoutHistoryViewEquality() {
        XCTAssertEqual(AppViewModel.ContentViewType.workoutHistoryView, .workoutHistoryView)
    }

    func testContentViewType_WorkoutActiveView_SameId_Equal() {
        let id = UUID()
        XCTAssertEqual(AppViewModel.ContentViewType.workoutActiveView(id), .workoutActiveView(id))
    }

    func testContentViewType_WorkoutActiveView_DifferentId_NotEqual() {
        XCTAssertNotEqual(AppViewModel.ContentViewType.workoutActiveView(UUID()), .workoutActiveView(UUID()))
    }

    func testContentViewType_WorkoutOverview_SameParams_Equal() {
        let id = UUID()
        XCTAssertEqual(AppViewModel.ContentViewType.workoutOverview(id, "30:00"), .workoutOverview(id, "30:00"))
    }

    func testContentViewType_AchievementsView_Equal() {
        XCTAssertEqual(AppViewModel.ContentViewType.achievementsView, .achievementsView)
    }
}
