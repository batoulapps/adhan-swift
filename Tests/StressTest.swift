//
//  StressTest.swift
//  Adhan
//
//  Copyright © 2018 Batoul Apps. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import XCTest
@testable import Adhan

class StressTest: XCTestCase {

    private static let polarCircleLatitude = 66.55

    // Sweeps every 5 degrees latitude x every 10 degrees longitude x every day of 2025 and
    // verifies two things:
    //
    // 1. Outside the polar circle (|lat| <= 66.55 degrees): prayer times must always be
    //    computable. A failure here indicates the sun geometry is broken for a location
    //    where valid times should always exist.
    //
    // 2. Everywhere: when prayer times are returned, all six must be in strictly ascending
    //    order. Inside the polar circle, failure to compute is acceptable (the sun may not
    //    rise or set), but any times that are returned must still be ordered correctly.
    func testPrayerTimesOrderedAcrossGlobalCoordinatesAndAllDaysOf2025() {
        let params = CalculationMethod.muslimWorldLeague.params
        var violations: [String] = []
        let cal: Calendar = .gregorianUTC

        var startComponents = DateComponents()
        startComponents.year = 2025
        startComponents.month = 1
        startComponents.day = 1
        guard let startDate = cal.date(from: startComponents) else {
            XCTFail("Unable to construct start date")
            return
        }

        for lat in stride(from: -90, through: 90, by: 5) {
            for lon in stride(from: -180, through: 180, by: 10) {
                let coordinates = Coordinates(latitude: Double(lat), longitude: Double(lon))
                let inPolarCircle = Double(abs(lat)) > StressTest.polarCircleLatitude

                var currentDate = startDate
                for _ in 0..<365 {
                    let date = cal.dateComponents([.year, .month, .day], from: currentDate)
                    currentDate = cal.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate

                    let loc = "(\(lat), \(lon)) \(date.year ?? 0)-\(date.month ?? 0)-\(date.day ?? 0)"

                    guard let p = PrayerTimes(coordinates: coordinates, date: date, calculationParameters: params) else {
                        if !inPolarCircle {
                            violations.append("\(loc): unexpected failure outside polar circle")
                        }
                        continue
                    }

                    if p.fajr >= p.sunrise { violations.append("\(loc): fajr >= sunrise") }
                    if p.sunrise >= p.dhuhr { violations.append("\(loc): sunrise >= dhuhr") }
                    if p.dhuhr >= p.asr { violations.append("\(loc): dhuhr >= asr") }
                    if p.asr >= p.maghrib { violations.append("\(loc): asr >= maghrib") }
                    if p.maghrib >= p.isha { violations.append("\(loc): maghrib >= isha") }
                }
            }
        }

        XCTAssertTrue(violations.isEmpty, "Violations found:\n\(violations.joined(separator: "\n"))")
    }
}
