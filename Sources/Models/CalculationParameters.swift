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

import CoreLocation
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

public extension CalculationParameters {
    /// Returns the recommended calculation parameters  for the specified geographic data.
    static func recommended(for placemark: CLPlacemark) -> CalculationParameters? {
        guard let countryCode = placemark.isoCountryCode else { return nil }
        return recommended(forCountryCode: countryCode)
    }

    /// Returns the recommended calculation parameters for the specified country code.
    static func recommended(forCountryCode code: String) -> CalculationParameters? {
        mapped.first { $0.value.contains(code) }?.key.params
    }

    private static let mapped: [CalculationMethod: [String]] = [
        .egyptian: ["EG", "LY", "SD"],
        .karachi: ["AF", "IN", "PK", "TN"],
        .ummAlQura: ["BH", "IQ", "OM", "SA", "SY", "YE"],
        .dubai: ["AE"],
        .moonsightingCommittee: ["CA", "GB"],
        .northAmerica: ["NO", "US"],
        .kuwait: ["KW"],
        .qatar: ["QA"],
        .singapore: ["SG"],
        .tehran: ["IR"],
        .turkey: ["TR"],
        .muslimWorldLeague: [
            "AL",
            "DZ",
            "AD",
            "AO",
            "AI",
            "AQ",
            "AG",
            "AR",
            "AM",
            "AW",
            "AT",
            "AU",
            "AT",
            "AZ",
            "BS",
            "BD",
            "BB",
            "BY",
            "BE",
            "BZ",
            "BJ",
            "BM",
            "BT",
            "BO",
            "BA",
            "BW",
            "BV",
            "BR",
            "IO",
            "VG",
            "BN",
            "BG",
            "BF",
            "MM",
            "BI",
            "KH",
            "CM",
            "CV",
            "KY",
            "CF",
            "TD",
            "CL",
            "CN",
            "CX",
            "CP",
            "CC",
            "CO",
            "KM",
            "CG",
            "CD",
            "CK",
            "CR",
            "CI",
            "HR",
            "CU",
            "CY",
            "CZ",
            "DK",
            "DJ",
            "DM",
            "DO",
            "TL",
            "EC",
            "SV",
            "GQ",
            "ER",
            "EE",
            "ET",
            "EU",
            "FK",
            "FO",
            "FJ",
            "FI",
            "FR",
            "GF",
            "PF",
            "TF",
            "GA",
            "GM",
            "GE",
            "DE",
            "GH",
            "GI",
            "GR",
            "GL",
            "GD",
            "GP",
            "GU",
            "GT",
            "GG",
            "GN",
            "GW",
            "GY",
            "HT",
            "HM",
            "HN",
            "HK",
            "HU",
            "IS",
            "ID",
            "IE",
            "IM",
            "IT",
            "JM",
            "SJ",
            "JP",
            "JE",
            "JO",
            "JU",
            "KZ",
            "KE",
            "KI",
            "KG",
            "LA",
            "LV",
            "LB",
            "LS",
            "LR",
            "LI",
            "LT",
            "LU",
            "MO",
            "MK",
            "MG",
            "MW",
            "MY",
            "MV",
            "ML",
            "MT",
            "MH",
            "MQ",
            "MR",
            "MU",
            "YT",
            "MX",
            "FM",
            "MD",
            "MC",
            "MN",
            "MS",
            "MA",
            "MZ",
            "NA",
            "NR",
            "NP",
            "NL",
            "AN",
            "NC",
            "NZ",
            "NI",
            "NE",
            "NG",
            "NU",
            "NF",
            "KP",
            "PW",
            "PS",
            "PA",
            "PG",
            "PY",
            "PE",
            "PH",
            "PN",
            "PL",
            "PT",
            "PR",
            "RE",
            "RO",
            "RU",
            "RW",
            "SH",
            "KN",
            "LC",
            "PM",
            "VC",
            "WS",
            "SM",
            "ST",
            "SN",
            "SC",
            "SL",
            "SK",
            "SI",
            "SB",
            "SO",
            "ZA",
            "GS",
            "KR",
            "ES",
            "LK",
            "SR",
            "SJ",
            "SZ",
            "SE",
            "CH",
            "TW",
            "TJ",
            "TZ",
            "TH",
            "TG",
            "TK",
            "TO",
            "TT",
            "TM",
            "TC",
            "TV",
            "UG",
            "UA",
            "UY",
            "VI",
            "UZ",
            "VU",
            "VA",
            "VE",
            "VN",
            "WF",
            "YU",
            "ZM",
            "ZW"
        ]
    ]
}
