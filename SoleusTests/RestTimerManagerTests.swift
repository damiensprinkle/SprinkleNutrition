import XCTest
import Combine
@testable import Soleus

final class RestTimerManagerTests: XCTestCase {
    var sut: RestTimerManager!
    var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        sut = RestTimerManager()
        cancellables = []
    }

    override func tearDown() {
        sut.skipRest() // ensure any running timer is cancelled
        cancellables = nil
        sut = nil
        super.tearDown()
    }

    // MARK: - startRest

    func testStartRest_SetsIsResting() {
        sut.startRest(duration: 60)
        XCTAssertTrue(sut.isResting)
    }

    func testStartRest_SetsRemainingTime() {
        sut.startRest(duration: 90)
        XCTAssertEqual(sut.remainingTime, 90)
    }

    func testStartRest_SetsTotalRestTime() {
        sut.startRest(duration: 120)
        XCTAssertEqual(sut.totalRestTime, 120)
    }

    func testStartRest_WithZeroDuration_DoesNotStart() {
        sut.startRest(duration: 0)
        XCTAssertFalse(sut.isResting)
        XCTAssertEqual(sut.remainingTime, 0)
    }

    func testStartRest_WithNegativeDuration_DoesNotStart() {
        sut.startRest(duration: -10)
        XCTAssertFalse(sut.isResting)
    }

    func testStartRest_ReplacesExistingTimer() {
        sut.startRest(duration: 30)
        XCTAssertEqual(sut.totalRestTime, 30)

        sut.startRest(duration: 60)
        XCTAssertEqual(sut.totalRestTime, 60)
        XCTAssertEqual(sut.remainingTime, 60)
    }

    // MARK: - pauseRest

    func testPauseRest_KeepsIsRestingTrue() {
        sut.startRest(duration: 60)
        sut.pauseRest()
        // pauseRest stops the countdown timer but does NOT set isResting = false
        XCTAssertTrue(sut.isResting)
    }

    func testPauseRest_PreservesRemainingTime() {
        sut.startRest(duration: 60)
        sut.pauseRest()
        XCTAssertEqual(sut.remainingTime, 60)
    }

    func testPauseRest_WhenNotResting_DoesNotCrash() {
        XCTAssertFalse(sut.isResting)
        sut.pauseRest() // should not crash
        XCTAssertFalse(sut.isResting)
    }

    // MARK: - resumeRest

    func testResumeRest_WhenPaused_KeepsIsResting() {
        sut.startRest(duration: 60)
        sut.pauseRest()
        sut.resumeRest()
        XCTAssertTrue(sut.isResting)
        XCTAssertEqual(sut.remainingTime, 60)
    }

    func testResumeRest_WhenRemainingTimeIsZero_DoesNothing() {
        // remainingTime starts at 0, should not start
        sut.resumeRest()
        XCTAssertFalse(sut.isResting)
    }

    func testResumeRest_PreservesRemainingTime() {
        sut.startRest(duration: 45)
        sut.pauseRest()
        sut.resumeRest()
        XCTAssertEqual(sut.remainingTime, 45)
    }

    // MARK: - skipRest

    func testSkipRest_SetsIsRestingFalse() {
        sut.startRest(duration: 60)
        sut.skipRest()
        XCTAssertFalse(sut.isResting)
    }

    func testSkipRest_ClearsRemainingTime() {
        sut.startRest(duration: 60)
        sut.skipRest()
        XCTAssertEqual(sut.remainingTime, 0)
    }

    func testSkipRest_ClearsTotalRestTime() {
        sut.startRest(duration: 60)
        sut.skipRest()
        XCTAssertEqual(sut.totalRestTime, 0)
    }

    func testSkipRest_WhenNotResting_DoesNotCrash() {
        sut.skipRest() // should not crash when already idle
        XCTAssertFalse(sut.isResting)
        XCTAssertEqual(sut.remainingTime, 0)
    }

    // MARK: - addTime

    func testAddTime_IncreasesRemainingTime() {
        sut.startRest(duration: 30)
        sut.addTime(15)
        XCTAssertEqual(sut.remainingTime, 45)
    }

    func testAddTime_IncreasesTotalRestTime() {
        sut.startRest(duration: 30)
        sut.addTime(15)
        XCTAssertEqual(sut.totalRestTime, 45)
    }

    func testAddTime_WhenNotResting_DoesNothing() {
        sut.addTime(30)
        XCTAssertEqual(sut.remainingTime, 0)
        XCTAssertEqual(sut.totalRestTime, 0)
    }

    func testAddTime_MultipleCalls_Accumulate() {
        sut.startRest(duration: 30)
        sut.addTime(10)
        sut.addTime(10)
        XCTAssertEqual(sut.remainingTime, 50)
        XCTAssertEqual(sut.totalRestTime, 50)
    }

    // MARK: - subtractTime

    func testSubtractTime_DecreasesRemainingTime() {
        sut.startRest(duration: 60)
        sut.subtractTime(15)
        XCTAssertEqual(sut.remainingTime, 45)
    }

    func testSubtractTime_DecreasesTotalRestTime() {
        sut.startRest(duration: 60)
        sut.subtractTime(15)
        XCTAssertEqual(sut.totalRestTime, 45)
    }

    func testSubtractTime_ClampsRemainingAtZero() {
        sut.startRest(duration: 10)
        sut.subtractTime(50) // subtract more than available
        XCTAssertEqual(sut.remainingTime, 0)
    }

    func testSubtractTime_WhenNotResting_DoesNothing() {
        sut.subtractTime(15)
        XCTAssertEqual(sut.remainingTime, 0)
    }

    func testSubtractTime_WhenExceedsRemaining_CompletesRest() {
        sut.startRest(duration: 5)
        sut.subtractTime(10) // triggers completeRest
        XCTAssertFalse(sut.isResting)
        XCTAssertEqual(sut.remainingTime, 0)
        XCTAssertEqual(sut.totalRestTime, 0)
    }

    func testSubtractTime_OnlySubtractsActualAmount() {
        // If remaining is 10 and we subtract 15, totalRestTime should decrease by 10 (not 15)
        sut.startRest(duration: 30)
        sut.subtractTime(25) // remaining goes 30→5, totalRestTime→5
        XCTAssertEqual(sut.remainingTime, 5)
        XCTAssertEqual(sut.totalRestTime, 5)
    }

    // MARK: - formattedTime

    func testFormattedTime_WhenZero_ShowsZeroSeconds() {
        XCTAssertEqual(sut.formattedTime, "0s")
    }

    func testFormattedTime_WhenUnder60Seconds_ShowsSecondsOnly() {
        sut.startRest(duration: 45)
        XCTAssertEqual(sut.formattedTime, "45s")
    }

    func testFormattedTime_WhenExactly60Seconds_ShowsMinutes() {
        sut.startRest(duration: 60)
        XCTAssertEqual(sut.formattedTime, "1:00")
    }

    func testFormattedTime_WhenOver60Seconds_ShowsMinutesAndSeconds() {
        sut.startRest(duration: 90)
        XCTAssertEqual(sut.formattedTime, "1:30")
    }

    func testFormattedTime_PadsSecondsWithLeadingZero() {
        sut.startRest(duration: 65)
        XCTAssertEqual(sut.formattedTime, "1:05")
    }

    func testFormattedTime_LargeDuration() {
        sut.startRest(duration: 3661) // 1h 1m 1s → 61:01
        XCTAssertEqual(sut.formattedTime, "61:01")
    }

    func testFormattedTime_ExactlyOneSecond() {
        sut.startRest(duration: 1)
        XCTAssertEqual(sut.formattedTime, "1s")
    }

    // MARK: - progressPercentage

    func testProgressPercentage_WhenNoRestTime_ReturnsZero() {
        XCTAssertEqual(sut.progressPercentage, 0.0)
    }

    func testProgressPercentage_AtStart_ReturnsOne() {
        sut.startRest(duration: 60)
        XCTAssertEqual(sut.progressPercentage, 1.0, accuracy: 0.001)
    }

    func testProgressPercentage_HalfwayThrough() {
        // subtractTime decrements both remainingTime and totalRestTime, keeping ratio at 1.0.
        // To simulate mid-timer progress, directly set remainingTime (as the Combine timer would).
        sut.startRest(duration: 60)
        sut.remainingTime = 30 // simulate 30s elapsed
        XCTAssertEqual(sut.progressPercentage, 0.5, accuracy: 0.001)
    }

    func testProgressPercentage_SubtractTimePreservesRatio() {
        // subtractTime reduces both remaining and total by the same amount → ratio stays 1.0
        sut.startRest(duration: 60)
        sut.subtractTime(30)
        XCTAssertEqual(sut.remainingTime, 30)
        XCTAssertEqual(sut.totalRestTime, 30)
        XCTAssertEqual(sut.progressPercentage, 1.0, accuracy: 0.001)
    }

    func testProgressPercentage_AfterAddingTime_RecalculatesCorrectly() {
        sut.startRest(duration: 30)
        sut.addTime(30) // now remaining=60, total=60
        XCTAssertEqual(sut.progressPercentage, 1.0, accuracy: 0.001)
    }

    func testProgressPercentage_AfterSkip_ReturnsZero() {
        sut.startRest(duration: 60)
        sut.skipRest()
        XCTAssertEqual(sut.progressPercentage, 0.0)
    }
}
