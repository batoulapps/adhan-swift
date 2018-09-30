import XCTest
import Tests

extension AdhanTests {
    static var allTests = [
        ("testNightPortion", testNightPortion),
//        ("testCalculationMethods", testCalculationMethods),
//        ("testPrayerTimes", testPrayerTimes)]
    ]
}

var tests = [XCTestCaseEntry]()
tests += AdhanTests.allTests()
XCTMain(tests)
