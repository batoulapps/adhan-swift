//
//  ElevationTests.swift
//  Adhan
//
//  Copyright © 2026 Batoul Apps. All rights reserved.
//

import XCTest
@testable import Adhan

class ElevationTests: XCTestCase {

    // Antalya, Turkey (the region discussed in adhan-js issue #146)
    private let antalya = Coordinates(latitude: 36.3, longitude: 30.1)
    private let equinox = date(year: 2024, month: 3, day: 20)

    private func unroundedParams(_ elevation: ElevationFromHorizon? = nil, method: CalculationMethod = .muslimWorldLeague) -> CalculationParameters {
        var params = method.params
        params.rounding = .none
        if let elevation {
            params.elevationFromHorizon = elevation
        }
        return params
    }

    private func prayerTimes(_ params: CalculationParameters, date: DateComponents? = nil, file: StaticString = #filePath, line: UInt = #line) throws -> PrayerTimes {
        return try XCTUnwrap(PrayerTimes(coordinates: antalya, date: date ?? equinox, calculationParameters: params), file: file, line: line)
    }

    private func solarTime(_ elevation: ElevationFromHorizon = ElevationFromHorizon(both: 0), file: StaticString = #filePath, line: UInt = #line) throws -> SolarTime {
        return try XCTUnwrap(SolarTime(date: equinox, coordinates: antalya, elevationFromHorizon: elevation), file: file, line: line)
    }

    private func utcDate(_ components: DateComponents?, file: StaticString = #filePath, line: UInt = #line) throws -> Date {
        let components = try XCTUnwrap(components, file: file, line: line)
        return try XCTUnwrap(Calendar.gregorianUTC.date(from: components), file: file, line: line)
    }

    private func minutes(from start: Date, to end: Date) -> Double {
        return end.timeIntervalSince(start) / 60
    }

    // MARK: - Astronomical.elevationCorrection

    func testElevationCorrectionIsZeroAtOrBelowTheHorizon() {
        XCTAssertEqual(Astronomical.elevationCorrection(0).degrees, 0)
        XCTAssertEqual(Astronomical.elevationCorrection(-100).degrees, 0)
    }

    func testElevationCorrectionMatchesOdehEquation8() {
        for h in [1.5, 100, 450, 1600, 3000] {
            XCTAssertEqual(Astronomical.elevationCorrection(h).degrees, 0.035333 * h.squareRoot(), accuracy: 1e-12)
        }
    }

    func testElevationCorrectionIsTheDipPlusTheAdditionalRefraction() {
        // dip 0.02917 * sqrt(h) and refraction 0.00617 * sqrt(h), which Odeh
        // rounds to a total of 0.035333 * sqrt(h)
        let h = 450.0
        let components = (0.02917 + 0.00617) * h.squareRoot()
        XCTAssertEqual(Astronomical.elevationCorrection(h).degrees, components, accuracy: 1e-3)
    }

    func testElevationCorrectionReproducesOdehWorkedExample() {
        // Odeh's zenith angle of 91.948° at 1000 meters
        let horizontalParallax = 0.0024
        let zenith = 90 + 16.0 / 60 + 34.0 / 60 + Astronomical.elevationCorrection(1000).degrees - horizontalParallax
        XCTAssertEqual(zenith, 91.948, accuracy: 1e-3)
    }

    // MARK: - ElevationFromHorizon

    func testDefaultsToZeroForSunriseAndSunset() {
        let params = CalculationParameters(fajrAngle: 18, ishaAngle: 18)
        XCTAssertEqual(params.elevationFromHorizon, ElevationFromHorizon(sunrise: 0, sunset: 0))
    }

    func testSingleValueAppliesToSunriseAndSunset() {
        XCTAssertEqual(ElevationFromHorizon(both: 250), ElevationFromHorizon(sunrise: 250, sunset: 250))
        XCTAssertEqual(ElevationFromHorizon(both: 250.5), ElevationFromHorizon(sunrise: 250.5, sunset: 250.5))
    }

    func testAcceptsSeparateSunriseAndSunsetValues() {
        let elevation = ElevationFromHorizon(sunrise: 500, sunset: 0)
        XCTAssertEqual(elevation.sunrise, 500)
        XCTAssertEqual(elevation.sunset, 0)
    }

    func testTreatsNegativeValuesAsZero() throws {
        let base = try prayerTimes(unroundedParams())
        let valley = try prayerTimes(unroundedParams(ElevationFromHorizon(both: -200)))
        XCTAssertEqual(valley.sunrise, base.sunrise)
        XCTAssertEqual(valley.maghrib, base.maghrib)

        let mixed = try prayerTimes(unroundedParams(ElevationFromHorizon(sunrise: 100, sunset: -5)))
        let sunriseOnly = try prayerTimes(unroundedParams(ElevationFromHorizon(sunrise: 100, sunset: 0)))
        XCTAssertEqual(mixed.sunrise, sunriseOnly.sunrise)
        XCTAssertEqual(mixed.maghrib, base.maghrib)
    }

    func testRejectsNonFiniteValues() {
        let invalid: [ElevationFromHorizon] = [
            ElevationFromHorizon(both: .nan),
            ElevationFromHorizon(both: .infinity),
            ElevationFromHorizon(both: -.infinity),
            ElevationFromHorizon(sunrise: .nan, sunset: 100),
            ElevationFromHorizon(sunrise: 100, sunset: .infinity),
        ]
        for elevation in invalid {
            XCTAssertFalse(elevation.isFinite)
            XCTAssertNil(PrayerTimes(coordinates: antalya, date: equinox, calculationParameters: unroundedParams(elevation)),
                         "\(elevation) should be rejected")
        }
    }

    // MARK: - SolarTime

    func testSolarTimeUsesTheStandardAltitudeLoweredByTheElevationCorrection() throws {
        let elevation = 450.0
        let solar = try solarTime(ElevationFromHorizon(both: elevation))
        let altitude = Angle(-50.0 / 60) - Astronomical.elevationCorrection(elevation)
        XCTAssertEqual(try utcDate(solar.sunrise), try utcDate(solar.timeForSolarAngle(altitude, afterTransit: false)))
        XCTAssertEqual(try utcDate(solar.sunset), try utcDate(solar.timeForSolarAngle(altitude, afterTransit: true)))
    }

    func testSolarTimeIsUnchangedWithoutElevation() throws {
        let standard = try XCTUnwrap(SolarTime(date: equinox, coordinates: antalya))
        let zero = try solarTime(ElevationFromHorizon(both: 0))
        XCTAssertEqual(zero.sunrise, standard.sunrise)
        XCTAssertEqual(zero.sunset, standard.sunset)
        XCTAssertEqual(try utcDate(standard.sunrise), try utcDate(standard.timeForSolarAngle(Angle(-50.0 / 60), afterTransit: false)))
    }

    // MARK: - PrayerTimes

    func testDefaultAndExplicitZeroProduceIdenticalTimes() throws {
        let base = try prayerTimes(unroundedParams())
        for elevation in [ElevationFromHorizon(both: 0), ElevationFromHorizon(sunrise: 0, sunset: 0)] {
            let times = try prayerTimes(unroundedParams(elevation))
            XCTAssertEqual(times.fajr, base.fajr)
            XCTAssertEqual(times.sunrise, base.sunrise)
            XCTAssertEqual(times.dhuhr, base.dhuhr)
            XCTAssertEqual(times.asr, base.asr)
            XCTAssertEqual(times.maghrib, base.maghrib)
            XCTAssertEqual(times.isha, base.isha)
        }
    }

    func testMovesSunriseEarlierAndSunsetAndMaghribLaterAt450Meters() throws {
        let base = try prayerTimes(unroundedParams())
        let elevated = try prayerTimes(unroundedParams(ElevationFromHorizon(both: 450)))
        let baseSunset = try utcDate(try solarTime().sunset)
        let elevatedSunset = try utcDate(try solarTime(ElevationFromHorizon(both: 450)).sunset)

        let sunriseShift = minutes(from: elevated.sunrise, to: base.sunrise)
        let sunsetShift = minutes(from: baseSunset, to: elevatedSunset)
        let maghribShift = minutes(from: base.maghrib, to: elevated.maghrib)

        XCTAssertGreaterThan(sunriseShift, 3)
        XCTAssertLessThan(sunriseShift, 4)
        XCTAssertGreaterThan(sunsetShift, 3)
        XCTAssertLessThan(sunsetShift, 4)
        XCTAssertEqual(maghribShift, sunsetShift, accuracy: 1e-10)
    }

    func testDoesNotChangeFajrDhuhrAsrOrIsha() throws {
        let base = try prayerTimes(unroundedParams())
        let elevated = try prayerTimes(unroundedParams(ElevationFromHorizon(both: 450)))
        XCTAssertEqual(elevated.fajr, base.fajr)
        XCTAssertEqual(elevated.dhuhr, base.dhuhr)
        XCTAssertEqual(elevated.asr, base.asr)
        XCTAssertEqual(elevated.isha, base.isha)
    }

    func testDoesNotChangeAnAngleBasedMaghrib() throws {
        let base = try prayerTimes(unroundedParams(method: .tehran))
        let elevated = try prayerTimes(unroundedParams(ElevationFromHorizon(both: 450), method: .tehran))
        XCTAssertGreaterThan(try utcDate(try solarTime(ElevationFromHorizon(both: 450)).sunset), try utcDate(try solarTime().sunset))
        XCTAssertEqual(elevated.maghrib, base.maghrib)
        XCTAssertEqual(elevated.fajr, base.fajr)
        XCTAssertEqual(elevated.isha, base.isha)
    }

    func testShiftsIntervalBasedIshaAlongWithSunset() throws {
        let base = try prayerTimes(unroundedParams(method: .ummAlQura))
        let elevated = try prayerTimes(unroundedParams(ElevationFromHorizon(both: 450), method: .ummAlQura))
        let sunsetShift = minutes(from: try utcDate(try solarTime().sunset), to: try utcDate(try solarTime(ElevationFromHorizon(both: 450)).sunset))
        XCTAssertGreaterThan(sunsetShift, 0)
        XCTAssertEqual(minutes(from: base.isha, to: elevated.isha), sunsetShift, accuracy: 1e-10)
    }

    func testAppliesSeparateSunriseAndSunsetElevationsIndependently() throws {
        let base = try prayerTimes(unroundedParams())
        let sunriseOnly = try prayerTimes(unroundedParams(ElevationFromHorizon(sunrise: 450, sunset: 0)))
        let sunsetOnly = try prayerTimes(unroundedParams(ElevationFromHorizon(sunrise: 0, sunset: 450)))
        let both = try prayerTimes(unroundedParams(ElevationFromHorizon(both: 450)))

        XCTAssertEqual(sunriseOnly.sunrise, both.sunrise)
        XCTAssertEqual(sunriseOnly.maghrib, base.maghrib)
        XCTAssertEqual(sunsetOnly.sunrise, base.sunrise)
        XCTAssertEqual(sunsetOnly.maghrib, both.maghrib)
    }

    func testShiftIncreasesWithElevation() throws {
        let base = try prayerTimes(unroundedParams())
        var previous = 0.0
        for h in [10.0, 100, 500, 1000, 2000] {
            let elevated = try prayerTimes(unroundedParams(ElevationFromHorizon(both: h)))
            let shift = minutes(from: base.maghrib, to: elevated.maghrib)
            XCTAssertGreaterThan(shift, previous)
            previous = shift
        }
    }

    func testIsUsedBySunnahTimes() throws {
        let params = unroundedParams(ElevationFromHorizon(both: 450))
        let today = try prayerTimes(params)
        let tomorrow = try prayerTimes(params, date: date(year: 2024, month: 3, day: 21))
        let sunnah = try XCTUnwrap(SunnahTimes(from: today))
        let night = tomorrow.fajr.timeIntervalSince(today.maghrib)

        // Rounding.none still truncates times to whole seconds
        XCTAssertEqual(sunnah.middleOfTheNight.timeIntervalSince1970,
                       today.maghrib.addingTimeInterval(night / 2).timeIntervalSince1970, accuracy: 1)
        XCTAssertEqual(sunnah.lastThirdOfTheNight.timeIntervalSince1970,
                       today.maghrib.addingTimeInterval(night * 2 / 3).timeIntervalSince1970, accuracy: 1)

        // A later maghrib with an unchanged fajr shortens the night, moving both
        // times later.
        let base = try XCTUnwrap(SunnahTimes(from: try prayerTimes(unroundedParams())))
        XCTAssertGreaterThan(sunnah.middleOfTheNight, base.middleOfTheNight)
        XCTAssertGreaterThan(sunnah.lastThirdOfTheNight, base.lastThirdOfTheNight)
    }

    func testStillResolvesPolarCircleLocations() throws {
        // Arjeplog, Sweden during midnight sun
        let arjeplog = Coordinates(latitude: 66.7222444, longitude: 17.7189)
        let times = PrayerTimes(coordinates: arjeplog, date: date(year: 2020, month: 6, day: 21), calculationParameters: unroundedParams(ElevationFromHorizon(both: 300)))
        XCTAssertNotNil(times)
    }
}
