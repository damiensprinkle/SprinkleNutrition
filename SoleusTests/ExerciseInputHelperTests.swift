import XCTest
@testable import Soleus

final class ExerciseInputHelperTests: XCTestCase {

    // MARK: - validateAndSetInputFloat

    func testValidateFloat_ValidInteger_Unchanged() {
        var input = "42"
        var field: Float = 0
        validateAndSetInputFloat(&input, for: &field)
        XCTAssertEqual(input, "42")
        XCTAssertEqual(field, 42.0)
    }

    func testValidateFloat_ValidDecimal_Unchanged() {
        var input = "135.5"
        var field: Float = 0
        validateAndSetInputFloat(&input, for: &field)
        XCTAssertEqual(input, "135.5")
        XCTAssertEqual(field, 135.5)
    }

    func testValidateFloat_MaxTwoDecimals_Unchanged() {
        var input = "10.25"
        var field: Float = 0
        validateAndSetInputFloat(&input, for: &field)
        XCTAssertEqual(input, "10.25")
        XCTAssertEqual(field, 10.25, accuracy: 0.001)
    }

    func testValidateFloat_TrailingAlpha_DropsLastChar() {
        var input = "123a"
        var field: Float = 0
        validateAndSetInputFloat(&input, for: &field)
        XCTAssertEqual(input, "123")
        XCTAssertEqual(field, 123.0)
    }

    func testValidateFloat_TooManyDecimals_DropsLastChar() {
        var input = "1.234" // 3 decimals exceeds default max of 2
        var field: Float = 0
        validateAndSetInputFloat(&input, for: &field)
        XCTAssertEqual(input, "1.23")
        XCTAssertEqual(field, 1.23, accuracy: 0.001)
    }

    func testValidateFloat_ExceedsMaxLength_Truncated() {
        var input = "12345678901" // 11 chars, default max is 10
        var field: Float = 0
        validateAndSetInputFloat(&input, for: &field)
        XCTAssertEqual(input.count, 10)
    }

    func testValidateFloat_EmptyString_SetInputFieldIsZero() {
        var input = ""
        var field: Float = 99.0
        validateAndSetInputFloat(&input, for: &field)
        XCTAssertEqual(field, 0.0)
    }

    func testValidateFloat_Zero_Valid() {
        var input = "0"
        var field: Float = 0
        validateAndSetInputFloat(&input, for: &field)
        XCTAssertEqual(input, "0")
        XCTAssertEqual(field, 0.0)
    }

    func testValidateFloat_ZeroDecimal_Valid() {
        var input = "0.0"
        var field: Float = 99
        validateAndSetInputFloat(&input, for: &field)
        XCTAssertEqual(input, "0.0")
        XCTAssertEqual(field, 0.0)
    }

    func testValidateFloat_CustomMaxLength_Truncates() {
        var input = "123456" // 6 chars, maxLength = 4
        var field: Float = 0
        validateAndSetInputFloat(&input, for: &field, maxLength: 4)
        XCTAssertEqual(input.count, 4)
        XCTAssertEqual(input, "1234")
    }

    func testValidateFloat_CustomMaxDecimals_EnforcesLimit() {
        var input = "1.23" // 2 decimals, maxDecimals = 1
        var field: Float = 0
        validateAndSetInputFloat(&input, for: &field, maxDecimals: 1)
        XCTAssertEqual(input, "1.2")
    }

    func testValidateFloat_LeadingDot_IsValid() {
        var input = ".5"
        var field: Float = 0
        validateAndSetInputFloat(&input, for: &field)
        // Pattern allows zero leading digits, so ".5" is valid
        XCTAssertEqual(input, ".5")
        XCTAssertEqual(field, 0.5, accuracy: 0.001)
    }

    func testValidateFloat_NegativeSign_Invalid() {
        var input = "-5"
        var field: Float = 0
        validateAndSetInputFloat(&input, for: &field)
        XCTAssertEqual(input, "-") // drops "5", but "-" alone still invalid
        XCTAssertEqual(field, 0.0)
    }

    func testValidateFloat_UpdatesFieldOnValidInput() {
        var input = "250.75"
        var field: Float = 0
        validateAndSetInputFloat(&input, for: &field)
        XCTAssertEqual(field, 250.75, accuracy: 0.001)
    }

    // MARK: - validateAndSetInputInt

    func testValidateInt_ValidInteger_Unchanged() {
        var input = "10"
        var field: Int32 = 0
        validateAndSetInputInt(&input, for: &field)
        XCTAssertEqual(input, "10")
        XCTAssertEqual(field, 10)
    }

    func testValidateInt_Zero_Valid() {
        var input = "0"
        var field: Int32 = 99
        validateAndSetInputInt(&input, for: &field)
        XCTAssertEqual(input, "0")
        XCTAssertEqual(field, 0)
    }

    func testValidateInt_TrailingAlpha_DropsLastChar() {
        var input = "12a"
        var field: Int32 = 0
        validateAndSetInputInt(&input, for: &field)
        XCTAssertEqual(input, "12")
        XCTAssertEqual(field, 12)
    }

    func testValidateInt_Decimal_DropsLastChar() {
        var input = "5."
        var field: Int32 = 0
        validateAndSetInputInt(&input, for: &field)
        XCTAssertEqual(input, "5")
        XCTAssertEqual(field, 5)
    }

    func testValidateInt_DecimalValue_DropsDecimalChar() {
        var input = "3.5"
        var field: Int32 = 0
        validateAndSetInputInt(&input, for: &field)
        XCTAssertEqual(input, "3.")
        // Note: "3." is invalid so field = Int32("3.") ?? 0 = 0
        XCTAssertEqual(field, 0)
    }

    func testValidateInt_EmptyString_SetInputFieldIsZero() {
        var input = ""
        var field: Int32 = 99
        validateAndSetInputInt(&input, for: &field)
        XCTAssertEqual(field, 0)
    }

    func testValidateInt_ExceedsMaxLength_Truncated() {
        var input = "12345678901" // 11 chars, default max is 10
        var field: Int32 = 0
        validateAndSetInputInt(&input, for: &field)
        XCTAssertEqual(input.count, 10)
    }

    func testValidateInt_CustomMaxLength_Truncates() {
        var input = "99999" // 5 chars, maxLength = 3
        var field: Int32 = 0
        validateAndSetInputInt(&input, for: &field, maxLength: 3)
        XCTAssertEqual(input, "999")
        XCTAssertEqual(field, 999)
    }

    func testValidateInt_NegativeSign_Invalid() {
        var input = "-3"
        var field: Int32 = 0
        validateAndSetInputInt(&input, for: &field)
        XCTAssertEqual(input, "-")
        XCTAssertEqual(field, 0)
    }

    func testValidateInt_LargeValidNumber_Accepted() {
        var input = "9999999999"
        var field: Int32 = 0
        validateAndSetInputInt(&input, for: &field, maxLength: 10)
        XCTAssertEqual(input, "9999999999")
    }

    func testValidateInt_UpdatesFieldOnValidInput() {
        var input = "42"
        var field: Int32 = 0
        validateAndSetInputInt(&input, for: &field)
        XCTAssertEqual(field, 42)
    }
}
