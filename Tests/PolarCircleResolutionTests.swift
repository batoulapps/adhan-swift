//
//  PolarCircleResolutionTests.swift
//  Adhan
//
//  Copyright © 2018 Batoul Apps. All rights reserved.
//

import XCTest
@testable import Adhan

class PolarCircleResolutionTests: XCTestCase {

    private let regularDate = date(year: 2020, month: 5, day: 15)
    private let dateAffectedByPolarNight = date(year: 2020, month: 12, day: 21)
    private let dateAffectedByMidnightSun = date(year: 2020, month: 6, day: 21)
    private let regularCoordinates = Coordinates(latitude: 31.947351, longitude: 35.227163)
    private let arjeplogSweden = Coordinates(latitude: 66.7222444, longitude: 17.7189)
    private let amundsenScottAntarctic = Coordinates(latitude: -84.996, longitude: 0.01013)

    private func params(_ resolution: PolarCircleResolution) -> CalculationParameters {
        var params = CalculationMethod.muslimWorldLeague.params
        params.polarCircleResolution = resolution
        return params
    }

    // A misconfigured ishaInterval (< the 5 minute minimum gap) makes maghrib and
    // isha collide everywhere, at any latitude or date - including the equator.
    // This is used to force a search to exhaust every candidate.
    private func impossibleParams() -> CalculationParameters {
        var params = CalculationMethod.muslimWorldLeague.params
        params.ishaInterval = 1
        return params
    }

    private func assertOrdered(_ p: PrayerTimes, file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertLessThan(p.fajr, p.sunrise, file: file, line: line)
        XCTAssertLessThan(p.sunrise, p.dhuhr, file: file, line: line)
        XCTAssertLessThan(p.dhuhr, p.asr, file: file, line: line)
        XCTAssertLessThan(p.asr, p.maghrib, file: file, line: line)
        XCTAssertLessThan(p.maghrib, p.isha, file: file, line: line)
    }

    // AqrabYaum borrows another day's solar geometry, but must always relabel the
    // result onto the originally requested calendar date. Dhuhr (solar noon) is
    // used since it's the field least likely to sit near a UTC day boundary.
    private func assertDhuhrOnRequestedDate(_ p: PrayerTimes, _ date: DateComponents, file: StaticString = #filePath, line: UInt = #line) {
        let comps = Calendar.gregorianUTC.dateComponents([.year, .month, .day], from: p.dhuhr)
        XCTAssertEqual(comps.year, date.year, file: file, line: line)
        XCTAssertEqual(comps.month, date.month, file: file, line: line)
        XCTAssertEqual(comps.day, date.day, file: file, line: line)
    }

    func testDefaultPolarCircleResolutionIsAqrabBalad() {
        XCTAssertEqual(CalculationParameters(fajrAngle: 18, ishaAngle: 18).polarCircleResolution, .aqrabBalad)
        for method in CalculationMethod.allCases {
            XCTAssertEqual(method.params.polarCircleResolution, .aqrabBalad, "\(method)")
        }
    }

    // MARK: - Regular computation

    func testNoResolutionWhenDateIsUnaffected() {
        let expected = PrayerTimes.computeForDay(coordinates: arjeplogSweden, date: regularDate, calculationParameters: params(.unresolved))
        XCTAssertNotNil(expected)

        for resolution in PolarCircleResolution.allCases {
            let p = PrayerTimes(coordinates: arjeplogSweden, date: regularDate, calculationParameters: params(resolution))
            XCTAssertEqual(p?.fajr, expected?.fajr, "\(resolution)")
            XCTAssertEqual(p?.isha, expected?.isha, "\(resolution)")
        }
    }

    func testNoResolutionOutsidePolarCircle() {
        let expected = PrayerTimes.computeForDay(coordinates: regularCoordinates, date: dateAffectedByPolarNight, calculationParameters: params(.unresolved))
        XCTAssertNotNil(expected)

        for resolution in PolarCircleResolution.allCases {
            let p = PrayerTimes(coordinates: regularCoordinates, date: dateAffectedByPolarNight, calculationParameters: params(resolution))
            XCTAssertEqual(p?.fajr, expected?.fajr, "\(resolution)")
            XCTAssertEqual(p?.isha, expected?.isha, "\(resolution)")
        }
    }

    // MARK: - Midnight sun

    func testMidnightSunUnresolved() {
        XCTAssertNil(PrayerTimes(coordinates: arjeplogSweden, date: dateAffectedByMidnightSun, calculationParameters: params(.unresolved)))
    }

    func testMidnightSunAqrabBalad() {
        guard let p = PrayerTimes(coordinates: arjeplogSweden, date: dateAffectedByMidnightSun, calculationParameters: params(.aqrabBalad)) else {
            return XCTFail("Expected aqrabBalad to resolve prayer times")
        }
        assertOrdered(p)
        XCTAssertEqual(p.coordinates, arjeplogSweden)
    }

    func testMidnightSunAqrabYaum() {
        guard let p = PrayerTimes(coordinates: arjeplogSweden, date: dateAffectedByMidnightSun, calculationParameters: params(.aqrabYaum)) else {
            return XCTFail("Expected aqrabYaum to resolve prayer times")
        }
        assertOrdered(p)
        assertDhuhrOnRequestedDate(p, dateAffectedByMidnightSun)
        XCTAssertEqual(p.date, dateAffectedByMidnightSun)
    }

    // MARK: - Polar night

    func testPolarNightUnresolved() {
        XCTAssertNil(PrayerTimes(coordinates: amundsenScottAntarctic, date: dateAffectedByPolarNight, calculationParameters: params(.unresolved)))
    }

    func testPolarNightAqrabBalad() {
        guard let p = PrayerTimes(coordinates: amundsenScottAntarctic, date: dateAffectedByPolarNight, calculationParameters: params(.aqrabBalad)) else {
            return XCTFail("Expected aqrabBalad to resolve prayer times")
        }
        assertOrdered(p)
    }

    func testPolarNightAqrabYaum() {
        guard let p = PrayerTimes(coordinates: amundsenScottAntarctic, date: dateAffectedByPolarNight, calculationParameters: params(.aqrabYaum)) else {
            return XCTFail("Expected aqrabYaum to resolve prayer times")
        }
        assertOrdered(p)
        assertDhuhrOnRequestedDate(p, dateAffectedByPolarNight)
    }

    func testAqrabYaumTimesForPolarCircle() {
        var params = params(.aqrabYaum)
        params.highLatitudeRule = .seventhOfTheNight

        guard let p = PrayerTimes(coordinates: arjeplogSweden, date: dateAffectedByMidnightSun, calculationParameters: params) else {
            return XCTFail("Expected aqrabYaum to resolve prayer times")
        }

        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(identifier: "Europe/Stockholm")!
        formatter.dateFormat = "MMMM dd, yyyy h:mm a"

        XCTAssertEqual(formatter.string(from: p.fajr), "June 21, 2020 12:48 AM")
        XCTAssertEqual(formatter.string(from: p.sunrise), "June 21, 2020 12:54 AM")
        XCTAssertEqual(formatter.string(from: p.dhuhr), "June 21, 2020 12:55 PM")
        XCTAssertEqual(formatter.string(from: p.asr), "June 21, 2020 5:49 PM")
        XCTAssertEqual(formatter.string(from: p.maghrib), "June 22, 2020 12:30 AM")
        XCTAssertEqual(formatter.string(from: p.isha), "June 22, 2020 12:37 AM")
    }

    func testAqrabYaumOrderedWhenSunCannotReachAsrAltitudeAt67N() {
        let coordinates = Coordinates(latitude: 67.37800510772394, longitude: -67.26246475893095)

        for day in 2...8 {
            guard let p = PrayerTimes(coordinates: coordinates, date: date(year: 2026, month: 1, day: day), calculationParameters: params(.aqrabYaum)) else {
                XCTFail("Expected aqrabYaum to resolve prayer times for January \(day)")
                continue
            }
            assertOrdered(p)
        }
    }

    // MARK: - Resolver boundaries

    func testImpossibleParamsAreInvalidAtEquator() {
        XCTAssertNil(PrayerTimes.computeForDay(coordinates: Coordinates(latitude: 0, longitude: 0), date: date(year: 2026, month: 1, day: 1), calculationParameters: impossibleParams()))
    }

    func testAqrabBaladSearchesToEquatorAndReturnsNil() {
        let resolved = PolarCircleResolution.aqrabBalad.resolve(coordinates: Coordinates(latitude: 70, longitude: 10), date: date(year: 2026, month: 1, day: 1), calculationParameters: impossibleParams())
        XCTAssertNil(resolved)
    }

    func testAqrabBaladNeverCrossesHemisphere() {
        // 0.3 is less than the 0.5 degree search step, so stepping toward the
        // equator must clamp to 0 and terminate rather than oscillate.
        for latitude in [0.3, -0.3, 0] {
            let resolved = PolarCircleResolution.aqrabBalad.resolve(coordinates: Coordinates(latitude: latitude, longitude: 10), date: date(year: 2026, month: 1, day: 1), calculationParameters: impossibleParams())
            XCTAssertNil(resolved, "\(latitude)")
        }
    }

    func testAqrabBaladResolvesRealPolarLocation() {
        let resolved = PolarCircleResolution.aqrabBalad.resolve(coordinates: amundsenScottAntarctic, date: dateAffectedByPolarNight, calculationParameters: CalculationMethod.muslimWorldLeague.params)
        XCTAssertNotNil(resolved)
    }

    func testAqrabYaumReturnsNilWhenNoDayIsValid() {
        let resolved = PolarCircleResolution.aqrabYaum.resolve(coordinates: Coordinates(latitude: 70, longitude: 10), date: date(year: 2026, month: 1, day: 1), calculationParameters: impossibleParams())
        XCTAssertNil(resolved)
    }

    func testUnresolvedReturnsNilWithoutSearching() {
        let resolved = PolarCircleResolution.unresolved.resolve(coordinates: Coordinates(latitude: 70, longitude: 10), date: date(year: 2026, month: 1, day: 1), calculationParameters: CalculationMethod.muslimWorldLeague.params)
        XCTAssertNil(resolved)
    }

    func testInvalidInputsAreNotResolved() {
        for resolution in PolarCircleResolution.allCases {
            XCTAssertNil(PrayerTimes(coordinates: Coordinates(latitude: 999, longitude: 999), date: dateAffectedByMidnightSun, calculationParameters: params(resolution)), "\(resolution)")
            XCTAssertNil(PrayerTimes(coordinates: arjeplogSweden, date: DateComponents(), calculationParameters: params(resolution)), "\(resolution)")
        }
    }

    func testShiftedByDays() {
        let base = Date(timeIntervalSince1970: 0)
        let result = PrayerTimes.DayResult(fajr: base, sunrise: base, dhuhr: base, asr: base, maghrib: base, isha: base)
        let cal: Calendar = .gregorianUTC
        XCTAssertEqual(result.shifted(byDays: 0), result)
        XCTAssertEqual(result.shifted(byDays: 2)?.dhuhr, cal.date(from: DateComponents(year: 1970, month: 1, day: 3)))
        XCTAssertEqual(result.shifted(byDays: -3)?.isha, cal.date(from: DateComponents(year: 1969, month: 12, day: 29)))
    }
}
