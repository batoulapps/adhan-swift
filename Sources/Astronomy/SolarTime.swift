//
//  SolarTime.swift
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

import Foundation

struct SolarTime {
    let date: DateComponents
    let observer: Coordinates
    let solar: SolarCoordinates
    let transit: DateComponents
    let sunrise: DateComponents
    let sunset: DateComponents

    private let prevSolar: SolarCoordinates
    private let nextSolar: SolarCoordinates
    private let approxTransit: Double

    init?(date: DateComponents, coordinates: Coordinates) {
        // calculations need to occur at 0h0m UTC
        var date = date
        date.hour = 0
        date.minute = 0

        let julianDay = Astronomical.julianDay(dateComponents: date)
        let prevSolar = SolarCoordinates(julianDay: julianDay - 1)
        let solar = SolarCoordinates(julianDay: julianDay)
        let nextSolar = SolarCoordinates(julianDay: julianDay + 1)

        let m0 = Astronomical.approximateTransit(longitude: coordinates.longitudeAngle, siderealTime: solar.apparentSiderealTime, rightAscension: solar.rightAscension)
        let solarAltitude = Angle(-50.0 / 60.0)

        self.date = date
        self.observer = coordinates
        self.solar = solar
        self.prevSolar = prevSolar
        self.nextSolar = nextSolar
        self.approxTransit = m0


        let transitTime = Astronomical.correctedTransit(approximateTransit: m0, longitude: coordinates.longitudeAngle, siderealTime: solar.apparentSiderealTime,
                                                     rightAscension: solar.rightAscension, previousRightAscension: prevSolar.rightAscension, nextRightAscension: nextSolar.rightAscension)
        let sunriseTime = Astronomical.correctedHourAngle(approximateTransit: m0, angle: solarAltitude, coordinates: coordinates, afterTransit: false, siderealTime: solar.apparentSiderealTime,
                                                       rightAscension: solar.rightAscension, previousRightAscension: prevSolar.rightAscension, nextRightAscension: nextSolar.rightAscension,
                                                       declination: solar.declination, previousDeclination: prevSolar.declination, nextDeclination: nextSolar.declination)
        let sunsetTime = Astronomical.correctedHourAngle(approximateTransit: m0, angle: solarAltitude, coordinates: coordinates, afterTransit: true, siderealTime: solar.apparentSiderealTime,
                                                      rightAscension: solar.rightAscension, previousRightAscension: prevSolar.rightAscension, nextRightAscension: nextSolar.rightAscension,
                                                      declination: solar.declination, previousDeclination: prevSolar.declination, nextDeclination: nextSolar.declination)

        guard let transitDate = date.settingHour(transitTime), let sunriseDate = date.settingHour(sunriseTime), let sunsetDate = date.settingHour(sunsetTime) else {
            return nil
        }

        self.transit = transitDate
        self.sunrise = sunriseDate
        self.sunset = sunsetDate
    }

    func timeForSolarAngle(_ angle: Angle, afterTransit: Bool) -> DateComponents? {
        let hours = Astronomical.correctedHourAngle(approximateTransit: approxTransit, angle: angle, coordinates: observer, afterTransit: afterTransit, siderealTime: solar.apparentSiderealTime,
                                               rightAscension: solar.rightAscension, previousRightAscension: prevSolar.rightAscension, nextRightAscension: nextSolar.rightAscension,
                                               declination: solar.declination, previousDeclination: prevSolar.declination, nextDeclination: nextSolar.declination)
        return date.settingHour(hours)
    }

    // hours from transit
    func afternoon(shadowLength: Double) -> DateComponents? {
        // TODO source shadow angle calculation
        let tangent = Angle(fabs(observer.latitude - solar.declination.degrees))
        let inverse = shadowLength + tan(tangent.radians)
        let angle = Angle(radians: atan(1.0 / inverse))

        return timeForSolarAngle(angle, afterTransit: true)
    }
}
