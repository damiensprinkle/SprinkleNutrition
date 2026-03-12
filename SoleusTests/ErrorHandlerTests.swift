import XCTest
@testable import Soleus

final class ErrorHandlerTests: XCTestCase {
    var sut: ErrorHandler!

    override func setUp() {
        super.setUp()
        sut = ErrorHandler()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    private func flushMain() {
        RunLoop.main.run(until: Date(timeIntervalSinceNow: 0.05))
    }

    // MARK: - Initial State

    func testInitialCurrentError_IsNil() {
        XCTAssertNil(sut.currentError)
    }

    func testInitialShowError_IsFalse() {
        XCTAssertFalse(sut.showError)
    }

    // MARK: - handle

    func testHandle_SetsCurrentError() {
        sut.handle(.contextNotAvailable)
        flushMain()
        XCTAssertEqual(sut.currentError, .contextNotAvailable)
    }

    func testHandle_SetsShowErrorTrue() {
        sut.handle(.contextNotAvailable)
        flushMain()
        XCTAssertTrue(sut.showError)
    }

    func testHandle_SaveFailed_SetsCorrectError() {
        let underlying = NSError(domain: "test", code: 42)
        sut.handle(.saveFailed(underlying))
        flushMain()
        if case .saveFailed = sut.currentError! {
            // correct
        } else {
            XCTFail("Expected saveFailed error")
        }
    }

    func testHandle_OverwritesPreviousError() {
        sut.handle(.contextNotAvailable)
        flushMain()
        sut.handle(.invalidData("bad input"))
        flushMain()
        if case .invalidData = sut.currentError! {
            // correct
        } else {
            XCTFail("Expected invalidData to overwrite previous error")
        }
        XCTAssertTrue(sut.showError)
    }

    // MARK: - clearError

    func testClearError_NilsCurrentError() {
        sut.handle(.contextNotAvailable)
        flushMain()
        sut.clearError()
        XCTAssertNil(sut.currentError)
    }

    func testClearError_SetsShowErrorFalse() {
        sut.handle(.contextNotAvailable)
        flushMain()
        sut.clearError()
        XCTAssertFalse(sut.showError)
    }

    func testClearError_WhenNoError_DoesNotCrash() {
        sut.clearError() // no-op, should not crash
        XCTAssertNil(sut.currentError)
        XCTAssertFalse(sut.showError)
    }
}

// MARK: - CoreDataError Equatable helper for tests
extension CoreDataError: Equatable {
    public static func == (lhs: CoreDataError, rhs: CoreDataError) -> Bool {
        switch (lhs, rhs) {
        case (.contextNotAvailable, .contextNotAvailable): return true
        case (.saveFailed, .saveFailed): return true
        case (.fetchFailed, .fetchFailed): return true
        case (.deleteFailed, .deleteFailed): return true
        case (.workoutNotFound(let a), .workoutNotFound(let b)): return a == b
        case (.invalidData(let a), .invalidData(let b)): return a == b
        default: return false
        }
    }
}
