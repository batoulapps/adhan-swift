import XCTest

extension AdhanTests {
    static let __allTests = [
        ("testCalculationMethods", testCalculationMethods),
        ("testCurrentPrayer", testCurrentPrayer),
        ("testMoonsightingMethod", testMoonsightingMethod),
        ("testMoonsightingMethodHighLat", testMoonsightingMethodHighLat),
        ("testNextPrayer", testNextPrayer),
        ("testNightPortion", testNightPortion),
        ("testOffsets", testOffsets),
        ("testPrayerTimes", testPrayerTimes),
        ("testTimeForPrayer", testTimeForPrayer),
    ]
}

extension AstronomicalTests {
    static let __allTests = [
        ("testAltitudeOfCelestialBody", testAltitudeOfCelestialBody),
        ("testAngleInterpolation", testAngleInterpolation),
        ("testCalendricalDate", testCalendricalDate),
        ("testDaysSinceSolstice", testDaysSinceSolstice),
        ("testInterpolation", testInterpolation),
        ("testJulianDay", testJulianDay),
        ("testJulianHours", testJulianHours),
        ("testLeapYear", testLeapYear),
        ("testRightAscensionEdgeCase", testRightAscensionEdgeCase),
        ("testSolarCoordinates", testSolarCoordinates),
        ("testSolarTime", testSolarTime),
        ("testTransitAndHourAngle", testTransitAndHourAngle),
    ]
}

extension MathTests {
    static let __allTests = [
        ("testAngleConversion", testAngleConversion),
        ("testClosestAngle", testClosestAngle),
        ("testMinuteRounding", testMinuteRounding),
        ("testNormalizing", testNormalizing),
        ("testTimeComponents", testTimeComponents),
    ]
}

extension QiblaTests {
    static let __allTests = [
        ("testAsia", testAsia),
        ("testEurope", testEurope),
        ("testNorthAmerica", testNorthAmerica),
        ("testSouthPacific", testSouthPacific),
    ]
}

extension SunnahTests {
    static let __allTests = [
        ("testSunnahTimesDST1", testSunnahTimesDST1),
        ("testSunnahTimesDST2", testSunnahTimesDST2),
        ("testSunnahTimesLondon", testSunnahTimesLondon),
        ("testSunnahTimesNY", testSunnahTimesNY),
        ("testSunnahTimesOslo", testSunnahTimesOslo),
    ]
}

extension TimeTests {
    static let __allTests = [
        ("testTimes", testTimes),
    ]
}

#if !os(macOS)
public func __allTests() -> [XCTestCaseEntry] {
    return [
        testCase(AdhanTests.__allTests),
        testCase(AstronomicalTests.__allTests),
        testCase(MathTests.__allTests),
        testCase(QiblaTests.__allTests),
        testCase(SunnahTests.__allTests),
        testCase(TimeTests.__allTests),
    ]
}
#endif
