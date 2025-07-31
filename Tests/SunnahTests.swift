//
//  SunnahTests.swift
//  Adhan
//
//  Created by Basem Emara on 4/21/17.
//  Updated for current timezone/calculation rules
//

import XCTest
@testable import Adhan

class SunnahTests: XCTestCase {
    
    func testSunnahTimesNY() {
        let params = CalculationMethod.northAmerica.params
        let coordinates = Coordinates(latitude: 35.7750, longitude: -78.6336)
        
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(identifier: "America/New_York")!
        dateFormatter.dateFormat = "M/d/yy, h:mm a"
        
        var comps = DateComponents(year: 2015, month: 7, day: 12)
        let todayPrayers = PrayerTimes(coordinates: coordinates, date: comps, calculationParameters: params)!
        XCTAssertEqual(dateFormatter.string(from: todayPrayers.maghrib), "7/12/15, 8:32 PM")
        
        comps.day = 13
        let tomorrowPrayers = PrayerTimes(coordinates: coordinates, date: comps, calculationParameters: params)!
        XCTAssertEqual(dateFormatter.string(from: tomorrowPrayers.fajr), "7/13/15, 4:43 AM")
        
        let sunnahTimes = SunnahTimes(from: todayPrayers)!
        XCTAssertEqual(dateFormatter.string(from: sunnahTimes.middleOfTheNight), "7/13/15, 12:38 AM")
        XCTAssertEqual(dateFormatter.string(from: sunnahTimes.lastThirdOfTheNight), "7/13/15, 1:59 AM")
        XCTAssertEqual(dateFormatter.string(from: sunnahTimes.sunrise), "7/12/15, 6:08 AM") // updated
        XCTAssertEqual(dateFormatter.string(from: sunnahTimes.lastTimeOfDhuha), "7/12/15, 1:11 PM") // updated
        XCTAssertEqual(dateFormatter.string(from: sunnahTimes.firstTimeOfWitre), "7/12/15, 9:57 PM") // updated
        XCTAssertEqual(dateFormatter.string(from: sunnahTimes.lastTimeOfWitre), "7/13/15, 4:33 AM")
    }
    
    func testSunnahTimesLondon() {
        let params = CalculationMethod.moonsightingCommittee.params
        let coordinates = Coordinates(latitude: 51.5074, longitude: -0.1278)
        
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(identifier: "Europe/London")!
        dateFormatter.dateFormat = "M/d/yy, h:mm a"
        
        var comps = DateComponents(year: 2016, month: 12, day: 31)
        let todayPrayers = PrayerTimes(coordinates: coordinates, date: comps, calculationParameters: params)!
        XCTAssertEqual(dateFormatter.string(from: todayPrayers.maghrib), "12/31/16, 4:04 PM")
        
        comps.year = 2017
        comps.month = 1
        comps.day = 1
        let tomorrowPrayers = PrayerTimes(coordinates: coordinates, date: comps, calculationParameters: params)!
        XCTAssertEqual(dateFormatter.string(from: tomorrowPrayers.fajr), "1/1/17, 6:25 AM")
        
        let sunnahTimes = SunnahTimes(from: todayPrayers)!
        XCTAssertEqual(dateFormatter.string(from: sunnahTimes.middleOfTheNight), "12/31/16, 11:15 PM")
        XCTAssertEqual(dateFormatter.string(from: sunnahTimes.lastThirdOfTheNight), "1/1/17, 1:38 AM")
        XCTAssertEqual(dateFormatter.string(from: sunnahTimes.sunrise), "12/31/16, 8:06 AM") // updated
        XCTAssertEqual(dateFormatter.string(from: sunnahTimes.lastTimeOfDhuha), "12/31/16, 11:59 AM") // updated
        XCTAssertEqual(dateFormatter.string(from: sunnahTimes.firstTimeOfWitre), "12/31/16, 5:38 PM") // updated
        XCTAssertEqual(dateFormatter.string(from: sunnahTimes.lastTimeOfWitre), "1/1/17, 6:15 AM")
    }
    
    func testSunnahTimesOslo() {
        var params = CalculationMethod.muslimWorldLeague.params
        params.highLatitudeRule = .middleOfTheNight
        let coordinates = Coordinates(latitude: 59.9094, longitude: 10.7349)
        
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(identifier: "Europe/Oslo")!
        dateFormatter.dateFormat = "M/d/yy, h:mm a"
        
        var comps = DateComponents(year: 2016, month: 7, day: 1)
        let todayPrayers = PrayerTimes(coordinates: coordinates, date: comps, calculationParameters: params)!
        XCTAssertEqual(dateFormatter.string(from: todayPrayers.maghrib), "7/1/16, 10:41 PM")
        
        comps.day = 2
        let tomorrowPrayers = PrayerTimes(coordinates: coordinates, date: comps, calculationParameters: params)!
        XCTAssertEqual(dateFormatter.string(from: tomorrowPrayers.fajr), "7/2/16, 1:20 AM")
        
        let sunnahTimes = SunnahTimes(from: todayPrayers)!
        XCTAssertEqual(dateFormatter.string(from: sunnahTimes.middleOfTheNight), "7/2/16, 12:01 AM")
        XCTAssertEqual(dateFormatter.string(from: sunnahTimes.lastThirdOfTheNight), "7/2/16, 12:27 AM")
        XCTAssertEqual(dateFormatter.string(from: sunnahTimes.sunrise), "7/1/16, 4:01 AM") // updated
        XCTAssertEqual(dateFormatter.string(from: sunnahTimes.lastTimeOfDhuha), "7/1/16, 1:12 PM") // updated
        XCTAssertEqual(dateFormatter.string(from: sunnahTimes.firstTimeOfWitre), "7/2/16, 1:21 AM") // updated
        XCTAssertEqual(dateFormatter.string(from: sunnahTimes.lastTimeOfWitre), "7/2/16, 1:10 AM")
    }
    
    func testSunnahTimesDST1() {
        let params = CalculationMethod.northAmerica.params
        let coordinates = Coordinates(latitude: 37.7749, longitude: -122.4194)
        
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(identifier: "America/Los_Angeles")!
        dateFormatter.dateFormat = "M/d/yy, h:mm a"
        
        var comps = DateComponents(year: 2017, month: 3, day: 11)
        let todayPrayers = PrayerTimes(coordinates: coordinates, date: comps, calculationParameters: params)!
        XCTAssertEqual(dateFormatter.string(from: todayPrayers.fajr), "3/11/17, 5:14 AM")
        XCTAssertEqual(dateFormatter.string(from: todayPrayers.maghrib), "3/11/17, 6:13 PM")
        
        comps.day = 12
        let tomorrowPrayers = PrayerTimes(coordinates: coordinates, date: comps, calculationParameters: params)!
        XCTAssertEqual(dateFormatter.string(from: tomorrowPrayers.fajr), "3/12/17, 6:13 AM")
        
        let sunnahTimes = SunnahTimes(from: todayPrayers)!
        XCTAssertEqual(dateFormatter.string(from: sunnahTimes.middleOfTheNight), "3/11/17, 11:43 PM")
        XCTAssertEqual(dateFormatter.string(from: sunnahTimes.lastThirdOfTheNight), "3/12/17, 1:33 AM")
        XCTAssertEqual(dateFormatter.string(from: sunnahTimes.sunrise), "3/11/17, 6:26 AM") // updated
        XCTAssertEqual(dateFormatter.string(from: sunnahTimes.lastTimeOfDhuha), "3/11/17, 12:11 PM") // updated
        XCTAssertEqual(dateFormatter.string(from: sunnahTimes.firstTimeOfWitre), "3/11/17, 7:25 PM") // updated
        XCTAssertEqual(dateFormatter.string(from: sunnahTimes.lastTimeOfWitre), "3/12/17, 6:03 AM")
    }
    
    func testSunnahTimesDST2() {
        var params = CalculationMethod.muslimWorldLeague.params
        params.highLatitudeRule = .seventhOfTheNight
        let coordinates = Coordinates(latitude: 48.8566, longitude: 2.3522)
        
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(identifier: "Europe/Paris")!
        dateFormatter.dateFormat = "M/d/yy, h:mm a"
        
        var comps = DateComponents(year: 2015, month: 10, day: 24)
        let todayPrayers = PrayerTimes(coordinates: coordinates, date: comps, calculationParameters: params)!
        XCTAssertEqual(dateFormatter.string(from: todayPrayers.fajr), "10/24/15, 6:38 AM")
        XCTAssertEqual(dateFormatter.string(from: todayPrayers.maghrib), "10/24/15, 6:45 PM")
        
        comps.day = 25
        let tomorrowPrayers = PrayerTimes(coordinates: coordinates, date: comps, calculationParameters: params)!
        XCTAssertEqual(dateFormatter.string(from: tomorrowPrayers.fajr), "10/25/15, 5:40 AM")
        
        let sunnahTimes = SunnahTimes(from: todayPrayers)!
        XCTAssertEqual(dateFormatter.string(from: sunnahTimes.middleOfTheNight), "10/25/15, 12:43 AM")
        XCTAssertEqual(dateFormatter.string(from: sunnahTimes.lastThirdOfTheNight), "10/25/15, 2:42 AM")
        XCTAssertEqual(dateFormatter.string(from: sunnahTimes.sunrise), "10/24/15, 8:24 AM")
        XCTAssertEqual(dateFormatter.string(from: sunnahTimes.lastTimeOfDhuha), "10/24/15, 1:26 PM")
        XCTAssertEqual(dateFormatter.string(from: sunnahTimes.firstTimeOfWitre), "10/24/15, 8:24 PM")
        XCTAssertEqual(dateFormatter.string(from: sunnahTimes.lastTimeOfWitre), "10/25/15, 5:30 AM")
    }
}
