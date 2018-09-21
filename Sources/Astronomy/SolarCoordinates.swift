//
//  SolarCoordinates.swift
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

struct SolarCoordinates {
    
    /* The declination of the sun, the angle between
     the rays of the Sun and the plane of the Earth's equator. */
    let declination: Angle
    
    /* Right ascension of the Sun, the angular distance on the
     celestial equator from the vernal equinox to the hour circle. */
    let rightAscension: Angle
    
    /* Apparent sidereal time, the hour angle of the vernal equinox. */
    let apparentSiderealTime: Angle
    
    init(julianDay: Double) {
        let T = Astronomical.julianCentury(julianDay: julianDay)
        let L0 = Astronomical.meanSolarLongitude(julianCentury: T)
        let Lp = Astronomical.meanLunarLongitude(julianCentury: T)
        let Ω = Astronomical.ascendingLunarNodeLongitude(julianCentury: T)
        let λ = Astronomical.apparentSolarLongitude(julianCentury: T, meanLongitude: L0).radians
        
        let θ0 = Astronomical.meanSiderealTime(julianCentury: T)
        let ΔΨ = Astronomical.nutationInLongitude(solarLongitude: L0, lunarLongitude: Lp, ascendingNode: Ω)
        let Δε = Astronomical.nutationInObliquity(solarLongitude: L0, lunarLongitude: Lp, ascendingNode: Ω)
        
        let ε0 = Astronomical.meanObliquityOfTheEcliptic(julianCentury: T)
        let εapp = Astronomical.apparentObliquityOfTheEcliptic(julianCentury: T, meanObliquityOfTheEcliptic: ε0).radians
        
        /* Equation from Astronomical Algorithms page 165 */
        self.declination = Angle(radians: asin(sin(εapp) * sin(λ)))
        
        /* Equation from Astronomical Algorithms page 165 */
        self.rightAscension = Angle(radians: atan2(cos(εapp) * sin(λ), cos(λ))).unwound()
        
        /* Equation from Astronomical Algorithms page 88 */
        self.apparentSiderealTime = Angle(θ0.degrees + (((ΔΨ * 3600) * cos(Angle(ε0.degrees + Δε).radians)) / 3600))
    }
}
