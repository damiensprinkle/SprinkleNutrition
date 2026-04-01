import XCTest
@testable import Soleus

final class TimeHelperTests: XCTestCase {

    // MARK: - formatTimeFromSeconds

    func testFormatTimeFromSeconds_Zero() {
        XCTAssertEqual(formatTimeFromSeconds(totalSeconds: 0), "00:00:00")
    }

    func testFormatTimeFromSeconds_SecondsOnly() {
        XCTAssertEqual(formatTimeFromSeconds(totalSeconds: 45), "00:00:45")
    }

    func testFormatTimeFromSeconds_MinutesAndSeconds() {
        XCTAssertEqual(formatTimeFromSeconds(totalSeconds: 125), "00:02:05")
    }

    func testFormatTimeFromSeconds_HoursMinutesSeconds() {
        XCTAssertEqual(formatTimeFromSeconds(totalSeconds: 3661), "01:01:01")
    }

    func testFormatTimeFromSeconds_ExactHour() {
        XCTAssertEqual(formatTimeFromSeconds(totalSeconds: 3600), "01:00:00")
    }

    func testFormatTimeFromSeconds_LargeValue() {
        XCTAssertEqual(formatTimeFromSeconds(totalSeconds: 36000), "10:00:00")
    }

    // MARK: - formatToHHMMSS

    func testFormatToHHMMSS_MatchesFormatTimeFromSeconds() {
        // Both functions should produce identical output
        let values = [0, 1, 59, 60, 3599, 3600, 7261]
        for value in values {
            XCTAssertEqual(
                formatToHHMMSS(value),
                formatTimeFromSeconds(totalSeconds: value),
                "Mismatch for \(value) seconds"
            )
        }
    }

    // MARK: - convertToSeconds

    func testConvertToSeconds_Zero() {
        XCTAssertEqual(convertToSeconds("000000"), 0)
    }

    func testConvertToSeconds_SecondsOnly() {
        XCTAssertEqual(convertToSeconds("000030"), 30)
    }

    func testConvertToSeconds_MinutesAndSeconds() {
        XCTAssertEqual(convertToSeconds("000205"), 125)
    }

    func testConvertToSeconds_HoursMinutesSeconds() {
        XCTAssertEqual(convertToSeconds("010101"), 3661)
    }

    func testConvertToSeconds_ShortInput_PadsWithZeros() {
        // Input "30" becomes "000030" (0 hours, 0 min, 30 sec)
        XCTAssertEqual(convertToSeconds("30"), 30)
    }

    func testConvertToSeconds_EmptyString() {
        XCTAssertEqual(convertToSeconds(""), 0)
    }

    // MARK: - Round-trip

    func testRoundTrip_FormatThenParse() {
        let originalSeconds = 5432
        let formatted = formatTimeFromSeconds(totalSeconds: originalSeconds)
        // formatted = "01:30:32", strip colons -> "013032"
        let stripped = formatted.replacingOccurrences(of: ":", with: "")
        let parsed = convertToSeconds(stripped)
        XCTAssertEqual(parsed, originalSeconds)
    }
}
