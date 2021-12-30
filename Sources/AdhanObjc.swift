//
//  AdhanObjc.swift
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

@objc public enum BAPrayer: Int {
    case fajr = 0
    case sunrise = 1
    case dhuhr = 2
    case asr = 3
    case maghrib = 4
    case isha = 5
    case none = 6
}

@objcMembers open class BAPrayerTimes: NSObject {
    open var fajr: Date?
    open var sunrise: Date?
    open var dhuhr: Date?
    open var asr: Date?
    open var maghrib: Date?
    open var isha: Date?
    
    private let prayerTimes: PrayerTimes?
    
    public init(coordinates: BACoordinates, date: DateComponents, calculationParameters: BACalculationParameters) {
        prayerTimes = PrayerTimes(coordinates: Coordinates(latitude: coordinates.latitude, longitude: coordinates.longitude), date: date, calculationParameters: calculationParameters.calculationParameters())
        if let prayerTimes = prayerTimes {
            self.fajr = prayerTimes.fajr as Date
            self.sunrise = prayerTimes.sunrise as Date
            self.dhuhr = prayerTimes.dhuhr as Date
            self.asr = prayerTimes.asr as Date
            self.maghrib = prayerTimes.maghrib as Date
            self.isha = prayerTimes.isha as Date
        }
        super.init()
    }
    
    open func currentPrayer(_ time: Date?) -> BAPrayer {
        guard let prayerTimes = prayerTimes else {
            return .none
        }
        
        let _time = time ?? Date()
        return BAPrayerForPrayer(prayerTimes.currentPrayer(at: _time))
    }
    
    open func nextPrayer(_ time: Date?) -> BAPrayer {
        guard let prayerTimes = prayerTimes else {
            return .none
        }
        
        let _time = time ?? Date()
        return BAPrayerForPrayer(prayerTimes.nextPrayer(at: _time))
    }
    
    open func timeForPrayer(_ prayer: BAPrayer) -> Date? {
        guard let swiftPrayer = prayerForBAPrayer(prayer) else {
            return nil
        }
        return prayerTimes?.time(for: swiftPrayer)
    }
    
    private func prayerForBAPrayer(_ baPrayer: BAPrayer) -> Prayer? {
        switch baPrayer {
        case BAPrayer.none:
            return nil
        case BAPrayer.fajr:
            return Prayer.fajr
        case BAPrayer.sunrise:
            return Prayer.sunrise
        case BAPrayer.dhuhr:
            return Prayer.dhuhr
        case BAPrayer.asr:
            return Prayer.asr
        case BAPrayer.maghrib:
            return Prayer.maghrib
        case BAPrayer.isha:
            return Prayer.isha
        }
    }
    
    private func BAPrayerForPrayer(_ prayer: Prayer?) -> BAPrayer {
        guard let prayer = prayer else {
            return BAPrayer.none
        }
        switch prayer {
        case Prayer.fajr:
            return BAPrayer.fajr
        case Prayer.sunrise:
            return BAPrayer.sunrise
        case Prayer.dhuhr:
            return BAPrayer.dhuhr
        case Prayer.asr:
            return BAPrayer.asr
        case Prayer.maghrib:
            return BAPrayer.maghrib
        case Prayer.isha:
            return BAPrayer.isha
        }
    }
}

@objcMembers open class BACalculationParameters: NSObject {
    open var method: BACalculationMethod = .other
    open var fajrAngle: Double
    open var maghribAngle: Double = 0
    open var ishaAngle: Double
    open var ishaInterval: Int = 0
    open var madhab: BAMadhab = .shafi
    open var highLatitudeRule: BAHighLatitudeRule = .middleOfTheNight
    open var adjustments: BAPrayerAdjustments = BAPrayerAdjustments()
    open var shafaq: BAShafaq = .general
    open var rounding: BARounding = .nearest
    private var methodAdjustments: BAPrayerAdjustments = BAPrayerAdjustments()
    
    public init(fajrAngle: Double, maghribAngle: Double, ishaAngle: Double, ishaInterval: Int) {
        self.fajrAngle = fajrAngle
        self.maghribAngle = maghribAngle
        self.ishaAngle = ishaAngle
        self.ishaInterval = ishaInterval
        super.init()
    }
    
    public convenience init(method: BACalculationMethod) {
        let params = BACalculationParameters.calculationMethodForBACalculationMethod(method).params
        self.init(fajrAngle: params.fajrAngle, maghribAngle: params.maghribAngle ?? 0, ishaAngle: params.ishaAngle, ishaInterval: params.ishaInterval)
        self.method = method
        self.methodAdjustments = BAPrayerAdjustments(fajr: params.methodAdjustments.fajr, sunrise: params.methodAdjustments.sunrise, dhuhr: params.methodAdjustments.dhuhr, asr: params.methodAdjustments.asr, maghrib: params.methodAdjustments.maghrib, isha: params.methodAdjustments.isha)
        
        switch params.rounding {
        case .nearest:
            self.rounding = .nearest
        case .up:
            self.rounding = .up
        case .none:
            self.rounding = .none
        }
    }
    
    internal func calculationParameters() -> CalculationParameters {
        var params = CalculationParameters(fajrAngle: self.fajrAngle, ishaAngle: self.ishaAngle)
        params.method = BACalculationParameters.calculationMethodForBACalculationMethod(self.method)
        params.maghribAngle = self.maghribAngle == 0 ? nil : self.maghribAngle
        params.ishaInterval = self.ishaInterval
        params.adjustments = self.adjustments.prayerAdjustments()
        params.methodAdjustments = self.methodAdjustments.prayerAdjustments()
        
        switch self.madhab {
        case BAMadhab.shafi:
            params.madhab = Madhab.shafi
        case BAMadhab.hanafi:
            params.madhab = Madhab.hanafi
        }
        
        switch self.highLatitudeRule {
        case BAHighLatitudeRule.middleOfTheNight:
            params.highLatitudeRule = HighLatitudeRule.middleOfTheNight
        case BAHighLatitudeRule.seventhOfTheNight:
            params.highLatitudeRule = HighLatitudeRule.seventhOfTheNight
        case BAHighLatitudeRule.twilightAngle:
            params.highLatitudeRule = HighLatitudeRule.twilightAngle
        }
        
        switch self.shafaq {
        case BAShafaq.general:
            params.shafaq = Shafaq.general
        case BAShafaq.ahmer:
            params.shafaq = Shafaq.ahmer
        case BAShafaq.abyad:
            params.shafaq = Shafaq.abyad
        }
        
        switch self.rounding {
        case BARounding.nearest:
            params.rounding = Rounding.nearest
        case BARounding.up:
            params.rounding = Rounding.up
        case BARounding.none:
            params.rounding = Rounding.none
        }
        
        return params
    }
    
    private static func calculationMethodForBACalculationMethod(_ baMethod: BACalculationMethod) -> CalculationMethod {
        switch baMethod {
        case .muslimWorldLeague:
            return CalculationMethod.muslimWorldLeague
        case .egyptian:
            return CalculationMethod.egyptian
        case .karachi:
            return CalculationMethod.karachi
        case .ummAlQura:
            return CalculationMethod.ummAlQura
        case .dubai:
            return CalculationMethod.dubai
        case .moonsightingCommittee:
            return CalculationMethod.moonsightingCommittee
        case .northAmerica:
            return CalculationMethod.northAmerica
        case .kuwait:
            return CalculationMethod.kuwait
        case .qatar:
            return CalculationMethod.qatar
        case .tehran:
            return CalculationMethod.tehran
        case .other:
            return CalculationMethod.other
        case .singapore:
            return CalculationMethod.singapore
        case .turkey:
            return CalculationMethod.turkey
        }
    }
}

@objc public enum BACalculationMethod: Int {
    case muslimWorldLeague
    case egyptian
    case karachi
    case ummAlQura
    case dubai
    case moonsightingCommittee
    case northAmerica
    case kuwait
    case qatar
    case other
    case singapore
    case tehran
    case turkey
}

@objc public enum BAMadhab: Int {
    case shafi
    case hanafi
}

@objc public enum BAShafaq: Int {
    case general
    case ahmer
    case abyad
}

@objc public enum BARounding: Int {
    case nearest
    case up
    case none
}

@objc public enum BAHighLatitudeRule: Int {
    case middleOfTheNight
    case seventhOfTheNight
    case twilightAngle
}

@objcMembers open class BAPrayerAdjustments: NSObject {
    open var fajr: Int = 0
    open var sunrise: Int = 0
    open var dhuhr: Int = 0
    open var asr: Int = 0
    open var maghrib: Int = 0
    open var isha: Int = 0
    
    public init(fajr: Int = 0, sunrise: Int = 0, dhuhr: Int = 0, asr: Int = 0, maghrib: Int = 0, isha: Int = 0) {
        self.fajr = fajr
        self.sunrise = sunrise
        self.dhuhr = dhuhr
        self.asr = asr
        self.maghrib = maghrib
        self.isha = isha
        super.init()
    }
    
    internal func prayerAdjustments() -> PrayerAdjustments {
        return PrayerAdjustments(fajr: self.fajr, sunrise: self.sunrise, dhuhr: self.dhuhr, asr: self.asr, maghrib: self.maghrib, isha: self.isha)
    }
}

@objcMembers open class BACoordinates: NSObject {
    open var latitude: Double
    open var longitude: Double
    
    public init(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
        super.init()
    }
}

@objcMembers open class BAQibla: NSObject {
    open var direction: Double = 0
    
    public init(coordinates: BACoordinates) {
        let qibla = Qibla(coordinates: Coordinates(latitude: coordinates.latitude, longitude: coordinates.longitude))
        self.direction = qibla.direction
    }
}
