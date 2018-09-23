//
//  CalculationMethod.swift
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

/* Preset calculation parameters */
public enum CalculationMethod {

    // Muslim World League
    case muslimWorldLeague

    //Egyptian General Authority of Survey
    case egyptian

    // University of Islamic Sciences, Karachi
    case karachi

    // Umm al-Qura University, Makkah
    case ummAlQura

    // The Gulf Region
    case dubai

    // Moonsighting Committee
    case moonsightingCommittee

    // ISNA
    case northAmerica

    // Kuwait
    case kuwait

    // Qatar
    case qatar

    // Singapore
    case singapore

    // Other
    case other

    public var params: CalculationParameters {
        switch(self) {
        case .muslimWorldLeague:
            return CalculationParameters(fajrAngle: 18, ishaAngle: 17, method: self)
        case .egyptian:
            return CalculationParameters(fajrAngle: 19.5, ishaAngle: 17.5, method: self)
        case .karachi:
            return CalculationParameters(fajrAngle: 18, ishaAngle: 18, method: self)
        case .ummAlQura:
            var params = CalculationParameters(fajrAngle: 18.5, ishaInterval: 90, method: self)
            params.methodAdjustments = PrayerAdjustments(dhuhr: -1)
            return params
        case .dubai:
            var params = CalculationParameters(fajrAngle: 18.2, ishaAngle: 18.2, method: self)
            params.methodAdjustments = PrayerAdjustments(sunrise: -3, dhuhr: 2, asr: 3, maghrib: 3)
            return params
        case .moonsightingCommittee:
            var params = CalculationParameters(fajrAngle: 18, ishaAngle: 18, method: self)
            params.methodAdjustments = PrayerAdjustments(dhuhr: 4, maghrib: 3)
            return params
        case .northAmerica:
            return CalculationParameters(fajrAngle: 15, ishaAngle: 15, method: self)
        case .kuwait:
            var params = CalculationParameters(fajrAngle: 18, ishaAngle: 17.5, method: self)
            params.methodAdjustments = PrayerAdjustments(dhuhr: -1)
            return params
        case .qatar:
            var params = CalculationParameters(fajrAngle: 18, ishaInterval: 90, method: self)
            params.methodAdjustments = PrayerAdjustments(dhuhr: -1)
            return params
        case .singapore:
            return CalculationParameters(fajrAngle: 20, ishaAngle: 18, method: self)
        case .other:
            return CalculationParameters(fajrAngle: 0, ishaAngle: 0, method: self)
        }
    }
}
