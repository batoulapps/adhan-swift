//
//  AdhanTests.swift
//  AdhanTests
//
//  Created by Ameir Al-Zoubi on 2/21/16.
//  Copyright © 2016 Batoul Apps. All rights reserved.
//

import XCTest
@testable import Adhan

func date(year: Int, month: Int, day: Int, hours: Double = 0) -> DateComponents {
    var cal = Calendar(identifier: Calendar.Identifier.gregorian)
    cal.timeZone = TimeZone(identifier: "UTC")!
    var comps = DateComponents()
    (comps as NSDateComponents).calendar = cal
    comps.year = year
    comps.month = month
    comps.day = day
    comps.hour = Int(hours)
    comps.minute = Int((hours - floor(hours)) * 60)
    return comps
}


class AdhanTests: XCTestCase {
    
    func testNightPortion() {
        let coordinates = Coordinates(latitude: 0, longitude: 0)

        var p1 = CalculationParameters(fajrAngle: 18, ishaAngle: 18)
        p1.highLatitudeRule = .middleOfTheNight
        XCTAssertEqual(p1.nightPortions(using: coordinates).fajr, 0.5)
        XCTAssertEqual(p1.nightPortions(using: coordinates).isha, 0.5)
        
        var p2 = CalculationParameters(fajrAngle: 18, ishaAngle: 18)
        p2.highLatitudeRule = .seventhOfTheNight
        XCTAssertEqual(p2.nightPortions(using: coordinates).fajr, 1/7)
        XCTAssertEqual(p2.nightPortions(using: coordinates).isha, 1/7)
        
        var p3 = CalculationParameters(fajrAngle: 10, ishaAngle: 15)
        p3.highLatitudeRule = .twilightAngle
        XCTAssertEqual(p3.nightPortions(using: coordinates).fajr, 10/60)
        XCTAssertEqual(p3.nightPortions(using: coordinates).isha, 15/60)
    }
    
    func testCalculationMethods() {
        let p1 = CalculationMethod.muslimWorldLeague.params
        XCTAssertEqual(p1.fajrAngle, 18)
        XCTAssertEqual(p1.ishaAngle, 17)
        XCTAssertEqual(p1.ishaInterval, 0)
        XCTAssertEqual(p1.method, CalculationMethod.muslimWorldLeague)
        
        let p2 = CalculationMethod.egyptian.params
        XCTAssertEqual(p2.fajrAngle, 19.5)
        XCTAssertEqual(p2.ishaAngle, 17.5)
        XCTAssertEqual(p2.ishaInterval, 0)
        XCTAssertEqual(p2.method, CalculationMethod.egyptian)
        
        let p3 = CalculationMethod.karachi.params
        XCTAssertEqual(p3.fajrAngle, 18)
        XCTAssertEqual(p3.ishaAngle, 18)
        XCTAssertEqual(p3.ishaInterval, 0)
        XCTAssertEqual(p3.method, CalculationMethod.karachi)
        
        let p4 = CalculationMethod.ummAlQura.params
        XCTAssertEqual(p4.fajrAngle, 18.5)
        XCTAssertEqual(p4.ishaAngle, 0)
        XCTAssertEqual(p4.ishaInterval, 90)
        XCTAssertEqual(p4.method, CalculationMethod.ummAlQura)
        
        let p5 = CalculationMethod.dubai.params
        XCTAssertEqual(p5.fajrAngle, 18.2)
        XCTAssertEqual(p5.ishaAngle, 18.2)
        XCTAssertEqual(p5.ishaInterval, 0)
        XCTAssertEqual(p5.method, CalculationMethod.dubai)
        
        let p6 = CalculationMethod.moonsightingCommittee.params
        XCTAssertEqual(p6.fajrAngle, 18)
        XCTAssertEqual(p6.ishaAngle, 18)
        XCTAssertEqual(p6.ishaInterval, 0)
        XCTAssertEqual(p6.method, CalculationMethod.moonsightingCommittee)
        
        let p7 = CalculationMethod.northAmerica.params
        XCTAssertEqual(p7.fajrAngle, 15)
        XCTAssertEqual(p7.ishaAngle, 15)
        XCTAssertEqual(p7.ishaInterval, 0)
        XCTAssertEqual(p7.method, CalculationMethod.northAmerica)
        
        let p8 = CalculationMethod.other.params
        XCTAssertEqual(p8.fajrAngle, 0)
        XCTAssertEqual(p8.ishaAngle, 0)
        XCTAssertEqual(p8.ishaInterval, 0)
        XCTAssertEqual(p8.method, CalculationMethod.other)
        
        let p9 = CalculationMethod.kuwait.params
        XCTAssertEqual(p9.fajrAngle, 18)
        XCTAssertEqual(p9.ishaAngle, 17.5)
        XCTAssertEqual(p9.ishaInterval, 0)
        XCTAssertEqual(p9.method, CalculationMethod.kuwait)
        
        let p10 = CalculationMethod.qatar.params
        XCTAssertEqual(p10.fajrAngle, 18)
        XCTAssertEqual(p10.ishaAngle, 0)
        XCTAssertEqual(p10.ishaInterval, 90)
        XCTAssertEqual(p10.method, CalculationMethod.qatar)
        
        let p11 = CalculationMethod.singapore.params
        XCTAssertEqual(p11.fajrAngle, 20)
        XCTAssertEqual(p11.ishaAngle, 18)
        XCTAssertEqual(p11.ishaInterval, 0)
        XCTAssertEqual(p11.method, CalculationMethod.singapore)
        
        let p12 = CalculationMethod.tehran.params
        XCTAssertEqual(p12.fajrAngle, 17.7)
        XCTAssertEqual(p12.maghribAngle, 4.5)
        XCTAssertEqual(p12.ishaAngle, 14)
        XCTAssertEqual(p12.ishaInterval, 0)
        XCTAssertEqual(p12.method, CalculationMethod.tehran)
    }
    
    func testPrayerTimes() {
        var comps = DateComponents()
        comps.year = 2015
        comps.month = 7
        comps.day = 12
        var params = CalculationMethod.northAmerica.params
        params.madhab = .hanafi
        let p = PrayerTimes(coordinates: Coordinates(latitude: 35.7750, longitude: -78.6336), date: comps, calculationParameters: params)!
        
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(identifier: "America/New_York")!
        dateFormatter.dateStyle = .none
        dateFormatter.timeStyle = .short
        
        XCTAssertEqual(dateFormatter.string(from: p.fajr), "4:42 AM")
        XCTAssertEqual(dateFormatter.string(from: p.sunrise), "6:08 AM")
        XCTAssertEqual(dateFormatter.string(from: p.dhuhr), "1:21 PM")
        XCTAssertEqual(dateFormatter.string(from: p.asr), "6:22 PM")
        XCTAssertEqual(dateFormatter.string(from: p.maghrib), "8:32 PM")
        XCTAssertEqual(dateFormatter.string(from: p.isha), "9:57 PM")
    }
    
    func testOffsets() {
        
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(identifier: "America/New_York")!
        dateFormatter.dateStyle = .none
        dateFormatter.timeStyle = .short
        
        var comps = DateComponents()
        comps.year = 2015
        comps.month = 12
        comps.day = 1
        
        var params = CalculationMethod.muslimWorldLeague.params
        params.madhab = .shafi
        if let p = PrayerTimes(coordinates: Coordinates(latitude: 35.7750, longitude: -78.6336), date: comps, calculationParameters: params) {
            XCTAssertEqual(dateFormatter.string(from: p.fajr), "5:35 AM")
            XCTAssertEqual(dateFormatter.string(from: p.sunrise), "7:06 AM")
            XCTAssertEqual(dateFormatter.string(from: p.dhuhr), "12:05 PM")
            XCTAssertEqual(dateFormatter.string(from: p.asr), "2:42 PM")
            XCTAssertEqual(dateFormatter.string(from: p.maghrib), "5:01 PM")
            XCTAssertEqual(dateFormatter.string(from: p.isha), "6:26 PM")
        } else {
            XCTAssert(false)
        }
        
        params.adjustments.fajr = 10
        params.adjustments.sunrise = 10
        params.adjustments.dhuhr = 10
        params.adjustments.asr = 10
        params.adjustments.maghrib = 10
        params.adjustments.isha = 10
        if let p2 = PrayerTimes(coordinates: Coordinates(latitude: 35.7750, longitude: -78.6336), date: comps, calculationParameters: params) {
            XCTAssertEqual(dateFormatter.string(from: p2.fajr), "5:45 AM")
            XCTAssertEqual(dateFormatter.string(from: p2.sunrise), "7:16 AM")
            XCTAssertEqual(dateFormatter.string(from: p2.dhuhr), "12:15 PM")
            XCTAssertEqual(dateFormatter.string(from: p2.asr), "2:52 PM")
            XCTAssertEqual(dateFormatter.string(from: p2.maghrib), "5:11 PM")
            XCTAssertEqual(dateFormatter.string(from: p2.isha), "6:36 PM")
        } else {
            XCTAssert(false)
        }
        
        params.adjustments = PrayerAdjustments()
        if let p3 = PrayerTimes(coordinates: Coordinates(latitude: 35.7750, longitude: -78.6336), date: comps, calculationParameters: params) {
            XCTAssertEqual(dateFormatter.string(from: p3.fajr), "5:35 AM")
            XCTAssertEqual(dateFormatter.string(from: p3.sunrise), "7:06 AM")
            XCTAssertEqual(dateFormatter.string(from: p3.dhuhr), "12:05 PM")
            XCTAssertEqual(dateFormatter.string(from: p3.asr), "2:42 PM")
            XCTAssertEqual(dateFormatter.string(from: p3.maghrib), "5:01 PM")
            XCTAssertEqual(dateFormatter.string(from: p3.isha), "6:26 PM")
        } else {
            XCTAssert(false)
        }
    }
    
    func testMoonsightingMethod() {
        // Values from http://www.moonsighting.com/pray.php
        var comps = DateComponents()
        comps.year = 2016
        comps.month = 1
        comps.day = 31
        let p = PrayerTimes(coordinates: Coordinates(latitude: 35.7750, longitude: -78.6336), date: comps, calculationParameters: CalculationMethod.moonsightingCommittee.params)!
        
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(identifier: "America/New_York")!
        dateFormatter.dateStyle = .none
        dateFormatter.timeStyle = .short
        
        XCTAssertEqual(dateFormatter.string(from: p.fajr), "5:48 AM")
        XCTAssertEqual(dateFormatter.string(from: p.sunrise), "7:16 AM")
        XCTAssertEqual(dateFormatter.string(from: p.dhuhr), "12:33 PM")
        XCTAssertEqual(dateFormatter.string(from: p.asr), "3:20 PM")
        XCTAssertEqual(dateFormatter.string(from: p.maghrib), "5:43 PM")
        XCTAssertEqual(dateFormatter.string(from: p.isha), "7:05 PM")
    }
    
    func testMoonsightingMethodHighLat() {
        // Values from http://www.moonsighting.com/pray.php
        var comps = DateComponents()
        comps.year = 2016
        comps.month = 1
        comps.day = 1
        var params = CalculationMethod.moonsightingCommittee.params
        params.madhab = .hanafi
        let p = PrayerTimes(coordinates: Coordinates(latitude: 59.9094, longitude: 10.7349), date: comps, calculationParameters: params)!
        
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(identifier: "Europe/Oslo")!
        dateFormatter.dateStyle = .none
        dateFormatter.timeStyle = .short
        
        XCTAssertEqual(dateFormatter.string(from: p.fajr), "7:34 AM")
        XCTAssertEqual(dateFormatter.string(from: p.sunrise), "9:19 AM")
        XCTAssertEqual(dateFormatter.string(from: p.dhuhr), "12:25 PM")
        XCTAssertEqual(dateFormatter.string(from: p.asr), "1:36 PM")
        XCTAssertEqual(dateFormatter.string(from: p.maghrib), "3:25 PM")
        XCTAssertEqual(dateFormatter.string(from: p.isha), "5:02 PM")
    }
    
    func testTehranMethod() {
        // Values from http://praytimes.org/code/
        var comps = DateComponents()
        comps.year = 2016
        comps.month = 12
        comps.day = 15
        let p = PrayerTimes(coordinates: Coordinates(latitude: 35.715298, longitude: 51.404343), date: comps, calculationParameters: CalculationMethod.tehran.params)!
        
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(identifier: "Asia/Tehran")!
        dateFormatter.dateStyle = .none
        dateFormatter.timeStyle = .short
        
        XCTAssertEqual(dateFormatter.string(from: p.fajr), "5:37 AM")
        XCTAssertEqual(dateFormatter.string(from: p.sunrise), "7:07 AM")
        XCTAssertEqual(dateFormatter.string(from: p.dhuhr), "12:00 PM")
        XCTAssertEqual(dateFormatter.string(from: p.asr), "2:34 PM")
        XCTAssertEqual(dateFormatter.string(from: p.maghrib), "5:13 PM")
        XCTAssertEqual(dateFormatter.string(from: p.isha), "6:03 PM")
        
        var comps2 = DateComponents()
        comps2.year = 2019
        comps2.month = 6
        comps2.day = 16
        let p2 = PrayerTimes(coordinates: Coordinates(latitude: 35.715298, longitude: 51.404343), date: comps2, calculationParameters: CalculationMethod.tehran.params)!
        
        XCTAssertEqual(dateFormatter.string(from: p2.fajr), "4:01 AM")
        XCTAssertEqual(dateFormatter.string(from: p2.sunrise), "5:48 AM")
        XCTAssertEqual(dateFormatter.string(from: p2.dhuhr), "1:05 PM")
        XCTAssertEqual(dateFormatter.string(from: p2.asr), "4:54 PM")
        XCTAssertEqual(dateFormatter.string(from: p2.maghrib), "8:43 PM")
        XCTAssertEqual(dateFormatter.string(from: p2.isha), "9:43 PM")
    }

    func testDiyanet() {
        // values from https://namazvakitleri.diyanet.gov.tr/en-US/9541/prayer-time-for-istanbul
        let coords = Coordinates(latitude: 41.005616, longitude: 28.976380)
        let params = CalculationMethod.turkey.params


        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(identifier: "Europe/Istanbul")!
        dateFormatter.dateStyle = .none
        dateFormatter.timeStyle = .short

        var comps1 = DateComponents()
        comps1.year = 2020
        comps1.month = 4
        comps1.day = 16

        let p1 = PrayerTimes(coordinates: coords, date: comps1, calculationParameters: params)!

        XCTAssertEqual(dateFormatter.string(from: p1.fajr), "4:44 AM")
        XCTAssertEqual(dateFormatter.string(from: p1.sunrise), "6:16 AM")
        XCTAssertEqual(dateFormatter.string(from: p1.dhuhr), "1:09 PM")
        XCTAssertEqual(dateFormatter.string(from: p1.asr), "4:53 PM") // original time 4:52 PM
        XCTAssertEqual(dateFormatter.string(from: p1.maghrib), "7:52 PM")
        XCTAssertEqual(dateFormatter.string(from: p1.isha), "9:19 PM") // original time 9:18 PM
    }

    func testEgyptian() {
        let coords = Coordinates(latitude: 30.028703, longitude: 31.249528)
        let params = CalculationMethod.egyptian.params


        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(identifier: "Africa/Cairo")!
        dateFormatter.dateStyle = .none
        dateFormatter.timeStyle = .short

        var comps1 = DateComponents()
        comps1.year = 2020
        comps1.month = 1
        comps1.day = 1

        let p1 = PrayerTimes(coordinates: coords, date: comps1, calculationParameters: params)!

        XCTAssertEqual(dateFormatter.string(from: p1.fajr), "5:18 AM")
        XCTAssertEqual(dateFormatter.string(from: p1.sunrise), "6:51 AM")
        XCTAssertEqual(dateFormatter.string(from: p1.dhuhr), "11:59 AM")
        XCTAssertEqual(dateFormatter.string(from: p1.asr), "2:47 PM")
        XCTAssertEqual(dateFormatter.string(from: p1.maghrib), "5:06 PM")
        XCTAssertEqual(dateFormatter.string(from: p1.isha), "6:29 PM")
    }
    
    func testTimeForPrayer() {
        var comps = DateComponents()
        comps.year = 2016
        comps.month = 7
        comps.day = 1
        var params = CalculationMethod.muslimWorldLeague.params
        params.madhab = .hanafi
        params.highLatitudeRule = .twilightAngle
        let p = PrayerTimes(coordinates: Coordinates(latitude: 59.9094, longitude: 10.7349), date: comps, calculationParameters: params)!
        XCTAssertEqual(p.fajr, p.time(for: .fajr))
        XCTAssertEqual(p.sunrise, p.time(for: .sunrise))
        XCTAssertEqual(p.dhuhr, p.time(for: .dhuhr))
        XCTAssertEqual(p.asr, p.time(for: .asr))
        XCTAssertEqual(p.maghrib, p.time(for: .maghrib))
        XCTAssertEqual(p.isha, p.time(for: .isha))
    }
    
    func testCurrentPrayer() {
        var comps = DateComponents()
        comps.year = 2015
        comps.month = 9
        comps.day = 1
        var params = CalculationMethod.karachi.params
        params.madhab = .hanafi
        params.highLatitudeRule = .twilightAngle
        let p = PrayerTimes(coordinates: Coordinates(latitude: 33.720817, longitude: 73.090032), date: comps, calculationParameters: params)!
        XCTAssertNil(p.currentPrayer(at: p.fajr.addingTimeInterval(-1)))
        XCTAssertEqual(p.currentPrayer(at: p.fajr), Prayer.fajr)
        XCTAssertEqual(p.currentPrayer(at: p.fajr.addingTimeInterval(1)), Prayer.fajr)
        XCTAssertEqual(p.currentPrayer(at: p.sunrise.addingTimeInterval(1)), Prayer.sunrise)
        XCTAssertEqual(p.currentPrayer(at: p.dhuhr.addingTimeInterval(1)), Prayer.dhuhr)
        XCTAssertEqual(p.currentPrayer(at: p.asr.addingTimeInterval(1)), Prayer.asr)
        XCTAssertEqual(p.currentPrayer(at: p.maghrib.addingTimeInterval(1)), Prayer.maghrib)
        XCTAssertEqual(p.currentPrayer(at: p.isha.addingTimeInterval(1)), Prayer.isha)
    }
    
    func testNextPrayer() {
        var comps = DateComponents()
        comps.year = 2015
        comps.month = 9
        comps.day = 1
        var params = CalculationMethod.karachi.params
        params.madhab = .hanafi
        params.highLatitudeRule = .twilightAngle
        let p = PrayerTimes(coordinates: Coordinates(latitude: 33.720817, longitude: 73.090032), date: comps, calculationParameters: params)!
        XCTAssertEqual(p.nextPrayer(at: p.fajr.addingTimeInterval(-1)), Prayer.fajr)
        XCTAssertEqual(p.nextPrayer(at: p.fajr), Prayer.sunrise)
        XCTAssertEqual(p.nextPrayer(at: p.fajr.addingTimeInterval(1)), Prayer.sunrise)
        XCTAssertEqual(p.nextPrayer(at: p.sunrise.addingTimeInterval(1)), Prayer.dhuhr)
        XCTAssertEqual(p.nextPrayer(at: p.dhuhr.addingTimeInterval(1)), Prayer.asr)
        XCTAssertEqual(p.nextPrayer(at: p.asr.addingTimeInterval(1)), Prayer.maghrib)
        XCTAssertEqual(p.nextPrayer(at: p.maghrib.addingTimeInterval(1)), Prayer.isha)
        XCTAssertNil(p.nextPrayer(at: p.isha.addingTimeInterval(1)))
    }

    func testInvalidDate() {
        let comps1 = DateComponents()
        let p1 = PrayerTimes(coordinates: Coordinates(latitude: 33.720817, longitude: 73.090032), date: comps1, calculationParameters: CalculationMethod.muslimWorldLeague.params)
        XCTAssertNil(p1)

        var comps2 = DateComponents()
        comps2.year = -1
        comps2.month = 99
        comps2.day = 99
        let p2 = PrayerTimes(coordinates: Coordinates(latitude: 33.720817, longitude: 73.090032), date: comps1, calculationParameters: CalculationMethod.muslimWorldLeague.params)
        XCTAssertNil(p2)
    }

    func testInvalidLocation() {
        var comps = DateComponents()
        comps.year = 2019
        comps.month = 1
        comps.day = 1
        let p1 = PrayerTimes(coordinates: Coordinates(latitude: 999, longitude: 999), date: comps, calculationParameters: CalculationMethod.muslimWorldLeague.params)
        XCTAssertNil(p1)
    }

    func testExtremeLocation() {
        var comps1 = DateComponents()
        comps1.year = 2018
        comps1.month = 1
        comps1.day = 1
        let p1 = PrayerTimes(coordinates: Coordinates(latitude: 71.275009, longitude: -156.761368), date: comps1, calculationParameters: CalculationMethod.muslimWorldLeague.params)
        XCTAssertNil(p1)

        var comps2 = DateComponents()
        comps2.year = 2018
        comps2.month = 3
        comps2.day = 1
        let p2 = PrayerTimes(coordinates: Coordinates(latitude: 71.275009, longitude: -156.761368), date: comps2, calculationParameters: CalculationMethod.muslimWorldLeague.params)
        XCTAssertNotNil(p2)
    }

    func testHighLatitudeRule() {
        let coords = Coordinates(latitude: 55.983226, longitude: -3.216649)
        var params = CalculationMethod.muslimWorldLeague.params

        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(identifier: "Europe/London")!
        dateFormatter.dateStyle = .none
        dateFormatter.timeStyle = .short

        var comps1 = DateComponents()
        comps1.year = 2020
        comps1.month = 6
        comps1.day = 15

        params.highLatitudeRule = .middleOfTheNight
        let p1 = PrayerTimes(coordinates: coords, date: comps1, calculationParameters: params)!

        XCTAssertEqual(dateFormatter.string(from: p1.fajr), "1:14 AM")
        XCTAssertEqual(dateFormatter.string(from: p1.sunrise), "4:26 AM")
        XCTAssertEqual(dateFormatter.string(from: p1.dhuhr), "1:14 PM")
        XCTAssertEqual(dateFormatter.string(from: p1.asr), "5:46 PM")
        XCTAssertEqual(dateFormatter.string(from: p1.maghrib), "10:01 PM")
        XCTAssertEqual(dateFormatter.string(from: p1.isha), "1:14 AM")

        params.highLatitudeRule = .seventhOfTheNight
        let p2 = PrayerTimes(coordinates: coords, date: comps1, calculationParameters: params)!

        XCTAssertEqual(dateFormatter.string(from: p2.fajr), "3:31 AM")
        XCTAssertEqual(dateFormatter.string(from: p2.sunrise), "4:26 AM")
        XCTAssertEqual(dateFormatter.string(from: p2.dhuhr), "1:14 PM")
        XCTAssertEqual(dateFormatter.string(from: p2.asr), "5:46 PM")
        XCTAssertEqual(dateFormatter.string(from: p2.maghrib), "10:01 PM")
        XCTAssertEqual(dateFormatter.string(from: p2.isha), "10:56 PM")

        params.highLatitudeRule = .twilightAngle
        let p3 = PrayerTimes(coordinates: coords, date: comps1, calculationParameters: params)!

        XCTAssertEqual(dateFormatter.string(from: p3.fajr), "2:31 AM")
        XCTAssertEqual(dateFormatter.string(from: p3.sunrise), "4:26 AM")
        XCTAssertEqual(dateFormatter.string(from: p3.dhuhr), "1:14 PM")
        XCTAssertEqual(dateFormatter.string(from: p3.asr), "5:46 PM")
        XCTAssertEqual(dateFormatter.string(from: p3.maghrib), "10:01 PM")
        XCTAssertEqual(dateFormatter.string(from: p3.isha), "11:50 PM")

        params.highLatitudeRule = nil
        let pAuto = PrayerTimes(coordinates: coords, date: comps1, calculationParameters: params)!
        let expectedAuto = p2

        XCTAssertEqual(pAuto.fajr, expectedAuto.fajr)
        XCTAssertEqual(pAuto.sunrise, expectedAuto.sunrise)
        XCTAssertEqual(pAuto.dhuhr, expectedAuto.dhuhr)
        XCTAssertEqual(pAuto.asr, expectedAuto.asr)
        XCTAssertEqual(pAuto.maghrib, expectedAuto.maghrib)
        XCTAssertEqual(pAuto.isha, expectedAuto.isha)
    }

    func testRecommendedHighLatitudeRule() {
        let coords1 = Coordinates(latitude: 45.983226, longitude: -3.216649)
        XCTAssertEqual(HighLatitudeRule.recommended(for: coords1), .middleOfTheNight)

        let coords2 = Coordinates(latitude: 48.983226, longitude: -3.216649)
        XCTAssertEqual(HighLatitudeRule.recommended(for: coords2), .seventhOfTheNight)
    }
    
    func testShafaqGeneral() {
        let coords = Coordinates(latitude: 43.494, longitude: -79.844)
        var params = CalculationMethod.moonsightingCommittee.params
        params.shafaq = .general
        params.madhab = .hanafi
        
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(identifier: "America/New_York")!
        dateFormatter.dateStyle = .none
        dateFormatter.timeStyle = .short

        var comps = DateComponents()
        comps.year = 2021
        comps.month = 1
        comps.day = 1
        
        var p = PrayerTimes(coordinates: coords, date: comps, calculationParameters: params)!

        XCTAssertEqual(dateFormatter.string(from: p.fajr), "6:16 AM")
        XCTAssertEqual(dateFormatter.string(from: p.sunrise), "7:52 AM")
        XCTAssertEqual(dateFormatter.string(from: p.dhuhr), "12:28 PM")
        XCTAssertEqual(dateFormatter.string(from: p.asr), "3:12 PM")
        XCTAssertEqual(dateFormatter.string(from: p.maghrib), "4:57 PM")
        XCTAssertEqual(dateFormatter.string(from: p.isha), "6:27 PM")
        
        comps.year = 2021
        comps.month = 4
        comps.day = 1
        p = PrayerTimes(coordinates: coords, date: comps, calculationParameters: params)!

        XCTAssertEqual(dateFormatter.string(from: p.fajr), "5:28 AM")
        XCTAssertEqual(dateFormatter.string(from: p.sunrise), "7:01 AM")
        XCTAssertEqual(dateFormatter.string(from: p.dhuhr), "1:28 PM")
        XCTAssertEqual(dateFormatter.string(from: p.asr), "5:53 PM")
        XCTAssertEqual(dateFormatter.string(from: p.maghrib), "7:49 PM")
        XCTAssertEqual(dateFormatter.string(from: p.isha), "9:01 PM")
        
        comps.year = 2021
        comps.month = 7
        comps.day = 1
        p = PrayerTimes(coordinates: coords, date: comps, calculationParameters: params)!

        XCTAssertEqual(dateFormatter.string(from: p.fajr), "3:52 AM")
        XCTAssertEqual(dateFormatter.string(from: p.sunrise), "5:42 AM")
        XCTAssertEqual(dateFormatter.string(from: p.dhuhr), "1:28 PM")
        XCTAssertEqual(dateFormatter.string(from: p.asr), "6:42 PM")
        XCTAssertEqual(dateFormatter.string(from: p.maghrib), "9:07 PM")
        XCTAssertEqual(dateFormatter.string(from: p.isha), "10:22 PM")
        
        comps.year = 2021
        comps.month = 11
        comps.day = 1
        p = PrayerTimes(coordinates: coords, date: comps, calculationParameters: params)!

        XCTAssertEqual(dateFormatter.string(from: p.fajr), "6:22 AM")
        XCTAssertEqual(dateFormatter.string(from: p.sunrise), "7:55 AM")
        XCTAssertEqual(dateFormatter.string(from: p.dhuhr), "1:08 PM")
        XCTAssertEqual(dateFormatter.string(from: p.asr), "4:26 PM")
        XCTAssertEqual(dateFormatter.string(from: p.maghrib), "6:13 PM")
        XCTAssertEqual(dateFormatter.string(from: p.isha), "7:35 PM")
    }
    
    func testShafaqAhmer() {
        let coords = Coordinates(latitude: 43.494, longitude: -79.844)
        var params = CalculationMethod.moonsightingCommittee.params
        params.shafaq = .ahmer
        
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(identifier: "America/New_York")!
        dateFormatter.dateStyle = .none
        dateFormatter.timeStyle = .short

        var comps = DateComponents()
        comps.year = 2021
        comps.month = 1
        comps.day = 1
        
        var p = PrayerTimes(coordinates: coords, date: comps, calculationParameters: params)!

        XCTAssertEqual(dateFormatter.string(from: p.fajr), "6:16 AM")
        XCTAssertEqual(dateFormatter.string(from: p.sunrise), "7:52 AM")
        XCTAssertEqual(dateFormatter.string(from: p.dhuhr), "12:28 PM")
        XCTAssertEqual(dateFormatter.string(from: p.asr), "2:37 PM")
        XCTAssertEqual(dateFormatter.string(from: p.maghrib), "4:57 PM")
        XCTAssertEqual(dateFormatter.string(from: p.isha), "6:07 PM") // value from source is 6:08 PM
        
        comps.year = 2021
        comps.month = 4
        comps.day = 1
        p = PrayerTimes(coordinates: coords, date: comps, calculationParameters: params)!

        XCTAssertEqual(dateFormatter.string(from: p.fajr), "5:28 AM")
        XCTAssertEqual(dateFormatter.string(from: p.sunrise), "7:01 AM")
        XCTAssertEqual(dateFormatter.string(from: p.dhuhr), "1:28 PM")
        XCTAssertEqual(dateFormatter.string(from: p.asr), "4:59 PM")
        XCTAssertEqual(dateFormatter.string(from: p.maghrib), "7:49 PM")
        XCTAssertEqual(dateFormatter.string(from: p.isha), "8:45 PM")
        
        comps.year = 2021
        comps.month = 7
        comps.day = 1
        p = PrayerTimes(coordinates: coords, date: comps, calculationParameters: params)!

        XCTAssertEqual(dateFormatter.string(from: p.fajr), "3:52 AM")
        XCTAssertEqual(dateFormatter.string(from: p.sunrise), "5:42 AM")
        XCTAssertEqual(dateFormatter.string(from: p.dhuhr), "1:28 PM")
        XCTAssertEqual(dateFormatter.string(from: p.asr), "5:29 PM")
        XCTAssertEqual(dateFormatter.string(from: p.maghrib), "9:07 PM")
        XCTAssertEqual(dateFormatter.string(from: p.isha), "10:19 PM")
        
        comps.year = 2021
        comps.month = 11
        comps.day = 1
        p = PrayerTimes(coordinates: coords, date: comps, calculationParameters: params)!

        XCTAssertEqual(dateFormatter.string(from: p.fajr), "6:22 AM")
        XCTAssertEqual(dateFormatter.string(from: p.sunrise), "7:55 AM")
        XCTAssertEqual(dateFormatter.string(from: p.dhuhr), "1:08 PM")
        XCTAssertEqual(dateFormatter.string(from: p.asr), "3:45 PM")
        XCTAssertEqual(dateFormatter.string(from: p.maghrib), "6:13 PM")
        XCTAssertEqual(dateFormatter.string(from: p.isha), "7:15 PM")
    }
    
    func testShafaqAbyad() {
        let coords = Coordinates(latitude: 43.494, longitude: -79.844)
        var params = CalculationMethod.moonsightingCommittee.params
        params.shafaq = .abyad
        params.madhab = .hanafi
        
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(identifier: "America/New_York")!
        dateFormatter.dateStyle = .none
        dateFormatter.timeStyle = .short

        var comps = DateComponents()
        comps.year = 2021
        comps.month = 1
        comps.day = 1
        
        var p = PrayerTimes(coordinates: coords, date: comps, calculationParameters: params)!

        XCTAssertEqual(dateFormatter.string(from: p.fajr), "6:16 AM")
        XCTAssertEqual(dateFormatter.string(from: p.sunrise), "7:52 AM")
        XCTAssertEqual(dateFormatter.string(from: p.dhuhr), "12:28 PM")
        XCTAssertEqual(dateFormatter.string(from: p.asr), "3:12 PM")
        XCTAssertEqual(dateFormatter.string(from: p.maghrib), "4:57 PM")
        XCTAssertEqual(dateFormatter.string(from: p.isha), "6:28 PM")
        
        comps.year = 2021
        comps.month = 4
        comps.day = 1
        p = PrayerTimes(coordinates: coords, date: comps, calculationParameters: params)!

        XCTAssertEqual(dateFormatter.string(from: p.fajr), "5:28 AM")
        XCTAssertEqual(dateFormatter.string(from: p.sunrise), "7:01 AM")
        XCTAssertEqual(dateFormatter.string(from: p.dhuhr), "1:28 PM")
        XCTAssertEqual(dateFormatter.string(from: p.asr), "5:53 PM")
        XCTAssertEqual(dateFormatter.string(from: p.maghrib), "7:49 PM")
        XCTAssertEqual(dateFormatter.string(from: p.isha), "9:12 PM")
        
        comps.year = 2021
        comps.month = 7
        comps.day = 1
        p = PrayerTimes(coordinates: coords, date: comps, calculationParameters: params)!

        XCTAssertEqual(dateFormatter.string(from: p.fajr), "3:52 AM")
        XCTAssertEqual(dateFormatter.string(from: p.sunrise), "5:42 AM")
        XCTAssertEqual(dateFormatter.string(from: p.dhuhr), "1:28 PM")
        XCTAssertEqual(dateFormatter.string(from: p.asr), "6:42 PM")
        XCTAssertEqual(dateFormatter.string(from: p.maghrib), "9:07 PM")
        XCTAssertEqual(dateFormatter.string(from: p.isha), "11:17 PM")
        
        comps.year = 2021
        comps.month = 11
        comps.day = 1
        p = PrayerTimes(coordinates: coords, date: comps, calculationParameters: params)!

        XCTAssertEqual(dateFormatter.string(from: p.fajr), "6:22 AM")
        XCTAssertEqual(dateFormatter.string(from: p.sunrise), "7:55 AM")
        XCTAssertEqual(dateFormatter.string(from: p.dhuhr), "1:08 PM")
        XCTAssertEqual(dateFormatter.string(from: p.asr), "4:26 PM")
        XCTAssertEqual(dateFormatter.string(from: p.maghrib), "6:13 PM")
        XCTAssertEqual(dateFormatter.string(from: p.isha), "7:37 PM")
    }
}
