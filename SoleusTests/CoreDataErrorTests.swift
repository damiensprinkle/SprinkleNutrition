import XCTest
@testable import Soleus

final class CoreDataErrorTests: XCTestCase {

    // MARK: - errorDescription

    func testContextNotAvailable_ErrorDescription() {
        let error = CoreDataError.contextNotAvailable
        XCTAssertEqual(error.errorDescription, "Database is not available. Please restart the app.")
    }

    func testSaveFailed_ErrorDescription_ContainsUnderlyingMessage() {
        let underlying = NSError(domain: "TestDomain", code: 1, userInfo: [NSLocalizedDescriptionKey: "disk full"])
        let error = CoreDataError.saveFailed(underlying)
        XCTAssertTrue(error.errorDescription?.contains("disk full") == true)
        XCTAssertTrue(error.errorDescription?.contains("Failed to save") == true)
    }

    func testFetchFailed_ErrorDescription_ContainsUnderlyingMessage() {
        let underlying = NSError(domain: "TestDomain", code: 2, userInfo: [NSLocalizedDescriptionKey: "network error"])
        let error = CoreDataError.fetchFailed(underlying)
        XCTAssertTrue(error.errorDescription?.contains("network error") == true)
        XCTAssertTrue(error.errorDescription?.contains("Failed to load") == true)
    }

    func testDeleteFailed_ErrorDescription_ContainsUnderlyingMessage() {
        let underlying = NSError(domain: "TestDomain", code: 3, userInfo: [NSLocalizedDescriptionKey: "locked"])
        let error = CoreDataError.deleteFailed(underlying)
        XCTAssertTrue(error.errorDescription?.contains("locked") == true)
        XCTAssertTrue(error.errorDescription?.contains("Failed to delete") == true)
    }

    func testWorkoutNotFound_ErrorDescription_ContainsId() {
        let id = UUID()
        let error = CoreDataError.workoutNotFound(id)
        XCTAssertTrue(error.errorDescription?.contains(id.uuidString) == true)
        XCTAssertTrue(error.errorDescription?.contains("not found") == true)
    }

    func testInvalidData_ErrorDescription_ContainsMessage() {
        let error = CoreDataError.invalidData("missing required field")
        XCTAssertTrue(error.errorDescription?.contains("missing required field") == true)
        XCTAssertTrue(error.errorDescription?.contains("Invalid data") == true)
    }

    // MARK: - recoverySuggestion

    func testContextNotAvailable_RecoverySuggestion_MentionsRestart() {
        let error = CoreDataError.contextNotAvailable
        XCTAssertTrue(error.recoverySuggestion?.contains("restart") == true)
    }

    func testSaveFailed_RecoverySuggestion_MentionsTryAgain() {
        let underlying = NSError(domain: "test", code: 0)
        let error = CoreDataError.saveFailed(underlying)
        XCTAssertTrue(error.recoverySuggestion?.contains("try again") == true)
    }

    func testFetchFailed_RecoverySuggestion_MentionsConnection() {
        let underlying = NSError(domain: "test", code: 0)
        let error = CoreDataError.fetchFailed(underlying)
        XCTAssertTrue(error.recoverySuggestion?.contains("connection") == true)
    }

    func testDeleteFailed_RecoverySuggestion_MentionsTryAgain() {
        let underlying = NSError(domain: "test", code: 0)
        let error = CoreDataError.deleteFailed(underlying)
        XCTAssertTrue(error.recoverySuggestion?.contains("try again") == true)
    }

    func testWorkoutNotFound_RecoverySuggestion_MentionsRefresh() {
        let error = CoreDataError.workoutNotFound(UUID())
        XCTAssertTrue(error.recoverySuggestion?.contains("refresh") == true)
    }

    func testInvalidData_RecoverySuggestion_MentionsInput() {
        let error = CoreDataError.invalidData("bad")
        XCTAssertTrue(error.recoverySuggestion?.contains("input") == true)
    }

    // MARK: - All cases have non-nil descriptions

    func testAllCases_HaveNonNilErrorDescription() {
        let cases: [CoreDataError] = [
            .contextNotAvailable,
            .saveFailed(NSError(domain: "t", code: 0)),
            .fetchFailed(NSError(domain: "t", code: 0)),
            .deleteFailed(NSError(domain: "t", code: 0)),
            .workoutNotFound(UUID()),
            .invalidData("x")
        ]
        for error in cases {
            XCTAssertNotNil(error.errorDescription, "\(error) should have a non-nil errorDescription")
        }
    }

    func testAllCases_HaveNonNilRecoverySuggestion() {
        let cases: [CoreDataError] = [
            .contextNotAvailable,
            .saveFailed(NSError(domain: "t", code: 0)),
            .fetchFailed(NSError(domain: "t", code: 0)),
            .deleteFailed(NSError(domain: "t", code: 0)),
            .workoutNotFound(UUID()),
            .invalidData("x")
        ]
        for error in cases {
            XCTAssertNotNil(error.recoverySuggestion, "\(error) should have a non-nil recoverySuggestion")
        }
    }
}
