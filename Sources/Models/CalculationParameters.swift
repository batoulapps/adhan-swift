//
//  CalculationParameters.swift
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

/**
  Customizable parameters for calculating prayer times
 */
public struct CalculationParameters: Codable, Equatable {
    public var method: CalculationMethod = .other
    public var fajrAngle: Double
    public var maghribAngle: Double?
    public var ishaAngle: Double
    public var ishaInterval: Minute = 0
    public var madhab: Madhab = .shafi
    public var highLatitudeRule: HighLatitudeRule? = nil
    public var adjustments: PrayerAdjustments = PrayerAdjustments()
    public var rounding: Rounding = .nearest
    public var shafaq: Shafaq = .general
    var methodAdjustments: PrayerAdjustments = PrayerAdjustments()

    init(fajrAngle: Double, ishaAngle: Double) {
        self.fajrAngle = fajrAngle
        self.ishaAngle = ishaAngle
    }

    init(fajrAngle: Double, ishaInterval: Minute) {
        self.init(fajrAngle: fajrAngle, ishaAngle: 0)
        self.ishaInterval = ishaInterval
    }

    init(fajrAngle: Double, ishaAngle: Double, method: CalculationMethod) {
        self.init(fajrAngle: fajrAngle, ishaAngle: ishaAngle)
        self.method = method
    }

    init(fajrAngle: Double, ishaInterval: Minute, method: CalculationMethod) {
        self.init(fajrAngle: fajrAngle, ishaInterval: ishaInterval)
        self.method = method
    }
    
    init(fajrAngle: Double, maghribAngle: Double, ishaAngle: Double, method: CalculationMethod) {
        self.init(fajrAngle: fajrAngle, ishaAngle: ishaAngle, method: method)
        self.maghribAngle = maghribAngle
    }

    func nightPortions(using coordinates: Coordinates) -> (fajr: Double, isha: Double) {
        let currentHighLatitudeRule = highLatitudeRule ?? .recommended(for: coordinates)

        switch currentHighLatitudeRule {
        case .middleOfTheNight:
            return (1/2, 1/2)
        case .seventhOfTheNight:
            return (1/7, 1/7)
        case .twilightAngle:
            return (self.fajrAngle / 60, self.ishaAngle / 60)
        }
    }
}
