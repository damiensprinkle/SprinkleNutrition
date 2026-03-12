import XCTest
@testable import Soleus

final class ColorManagerTests: XCTestCase {
    var sut: ColorManager!

    override func setUp() {
        super.setUp()
        sut = ColorManager()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    // MARK: - colorNames

    func testColorNames_IsNotEmpty() {
        XCTAssertFalse(sut.colorNames.isEmpty)
    }

    func testColorNames_ContainsExpectedColors() {
        let expected = ["MyBabyBlue", "MyLightBlue", "MyBlue", "MyOrchid", "MyPurple",
                        "MyTan", "MyGreyBlue", "MyLightBrown", "MyBrown"]
        XCTAssertEqual(sut.colorNames, expected)
    }

    func testColorNames_HasNinePalette() {
        XCTAssertEqual(sut.colorNames.count, 9)
    }

    // MARK: - getRandomColor

    func testGetRandomColor_ReturnsValueFromPalette() {
        let color = sut.getRandomColor()
        XCTAssertTrue(sut.colorNames.contains(color),
                      "'\(color)' should be one of the defined color names")
    }

    func testGetRandomColor_NeverReturnsEmpty() {
        for _ in 0..<20 {
            XCTAssertFalse(sut.getRandomColor().isEmpty)
        }
    }

    func testGetRandomColor_AlwaysReturnsValidColor() {
        for _ in 0..<50 {
            let color = sut.getRandomColor()
            XCTAssertTrue(sut.colorNames.contains(color))
        }
    }

    func testGetRandomColor_EventuallyReturnsMultipleColors() {
        var seen = Set<String>()
        for _ in 0..<100 {
            seen.insert(sut.getRandomColor())
        }
        // With 9 colors and 100 draws, we should see more than 1 unique color
        XCTAssertGreaterThan(seen.count, 1, "Random color should not always return the same value")
    }
}
