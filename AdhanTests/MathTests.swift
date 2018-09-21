//
//  MathTests.swift
//  Adhan
//
//  Created by Ameir Al-Zoubi on 2/21/16.
//  Copyright © 2016 Batoul Apps. All rights reserved.
//

import XCTest
@testable import Adhan

class MathTests: XCTestCase {
    
    func testAngleConversion() {
        XCTAssertEqual(Angle(radians: Double.pi).degrees, 180.0)
        XCTAssertEqual(Angle(180).radians, Double.pi)
        XCTAssertEqual(Angle(radians: Double.pi / 2).degrees, 90.0)
        XCTAssertEqual(Angle(90).radians, (Double.pi / 2))
    }
    
    func testNormalizing() {
        XCTAssertEqual(2.0.normalizedToScale(-5), -3)
        XCTAssertEqual((-4.0).normalizedToScale(-5), -4)
        XCTAssertEqual((-6.0).normalizedToScale(-5), -1)
        
        XCTAssertEqual((-1.0).normalizedToScale(24), 23)
        XCTAssertEqual(1.0.normalizedToScale(24), 1)
        XCTAssertEqual(49.0.normalizedToScale(24), 1)
        
        XCTAssertEqual(361.0.normalizedToScale(360), 1)
        XCTAssertEqual(360.0.normalizedToScale(360), 0)
        XCTAssertEqual(259.0.normalizedToScale(360), 259)
        XCTAssertEqual(2592.0.normalizedToScale(360), 72)
        
        XCTAssertEqual(Angle(-45.0).unwound().degrees, 315)
        XCTAssertEqual(Angle(361.0).unwound().degrees, 1)
        XCTAssertEqual(Angle(360.0).unwound().degrees, 0)
        XCTAssertEqual(Angle(259.0).unwound().degrees, 259)
        XCTAssertEqual(Angle(2592.0).unwound().degrees, 72)
        
        XCTAssertEqual(360.1.normalizedToScale(360), 0.1, accuracy: 0.01)
    }
    
    func testClosestAngle() {
        XCTAssertEqual(Angle(360.0).quadrantShifted().degrees, 0)
        XCTAssertEqual(Angle(361.0).quadrantShifted().degrees, 1)
        XCTAssertEqual(Angle(1.0).quadrantShifted().degrees, 1)
        XCTAssertEqual(Angle(-1.0).quadrantShifted().degrees, -1)
        XCTAssertEqual(Angle(-181.0).quadrantShifted().degrees, 179)
        XCTAssertEqual(Angle(180.0).quadrantShifted().degrees, 180)
        XCTAssertEqual(Angle(359.0).quadrantShifted().degrees, -1)
        XCTAssertEqual(Angle(-359.0).quadrantShifted().degrees, 1)
        XCTAssertEqual(Angle(1261.0).quadrantShifted().degrees, -179)
        XCTAssertEqual(Angle(-360.1).quadrantShifted().degrees, -0.1, accuracy: 0.01)
    }
    
    func testTimeComponents() {
        let date = Calendar.gregorianUTC.dateComponents([.year, .month, .day], from: Date())

        let comps1 = date.settingHour(15.199)!
        XCTAssertEqual(comps1.hour, 15)
        XCTAssertEqual(comps1.minute, 11)
        XCTAssertEqual(comps1.second, 56)
        
        let comps2 = date.settingHour(1.0084)!
        XCTAssertEqual(comps2.hour, 1)
        XCTAssertEqual(comps2.minute, 0)
        XCTAssertEqual(comps2.second, 30)
        
        let comps3 = date.settingHour(1.0083)!
        XCTAssertEqual(comps3.hour, 1)
        XCTAssertEqual(comps3.minute, 0)
        
        let comps4 = date.settingHour(2.1)!
        XCTAssertEqual(comps4.hour, 2)
        XCTAssertEqual(comps4.minute, 6)
        
        let comps5 = date.settingHour(3.5)!
        XCTAssertEqual(comps5.hour, 3)
        XCTAssertEqual(comps5.minute, 30)
    }
    
    func testMinuteRounding() {
        let cal = Calendar(identifier: Calendar.Identifier.gregorian)
        
        let comps1 = DateComponents(year: 2015, month: 1, day: 1, hour: 10, minute: 2, second: 29)
        let date1 = cal.date(from: comps1)!.roundedMinute()
        XCTAssertEqual(cal.component(.minute, from: date1), 2)
        XCTAssertEqual(cal.component(.second, from: date1), 0)
        
        let comps2 = DateComponents(year: 2015, month: 1, day: 1, hour: 10, minute: 2, second: 31)
        let date2 = cal.date(from: comps2)!.roundedMinute()
        XCTAssertEqual(cal.component(.minute, from: date2), 3)
        XCTAssertEqual(cal.component(.second, from: date2), 0)
    }
}
