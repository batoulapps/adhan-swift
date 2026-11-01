//
//  ElevationFromHorizon.swift
//  Adhan
//
//  Copyright © 2026 Batoul Apps. All rights reserved.
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

/**
 Height in meters of the observer above the horizon they are looking at, used
 to calculate sunrise and Maghrib.

 An observer who is higher than their horizon sees the sun rise earlier and set
 later. `sunrise` describes the eastern horizon and `sunset` describes the
 western horizon. A single value applies to both:

 ```swift
 params.elevationFromHorizon = ElevationFromHorizon(both: 450)
 params.elevationFromHorizon = ElevationFromHorizon(sunrise: 450, sunset: 0)
 ```

 - Important: This is **not** the observer's elevation above sea level. A city
   on a plateau is at the same elevation as its horizon, so the value should be
   `0`. Don't use the altitude reported by a device's GPS or an elevation lookup
   for the user's coordinates. A negative value, such as in a valley where the
   horizon is above the observer, is treated as `0`. See ELEVATION.md for
   details.
 */
public struct ElevationFromHorizon: Codable, Equatable {
    /// Height in meters of the observer above the eastern horizon, used for sunrise.
    public var sunrise: Double

    /// Height in meters of the observer above the western horizon, used for Maghrib.
    public var sunset: Double

    /// Creates an elevation with separate heights in meters above the eastern and western horizons.
    public init(sunrise: Double, sunset: Double) {
        self.sunrise = sunrise
        self.sunset = sunset
    }

    /// Creates an elevation with the same height in meters above both horizons.
    public init(both meters: Double) {
        self.init(sunrise: meters, sunset: meters)
    }

    /// Both heights are finite numbers that can be used in calculations.
    var isFinite: Bool {
        return sunrise.isFinite && sunset.isFinite
    }
}
