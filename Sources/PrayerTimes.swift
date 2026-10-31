//
//  PrayerTimes.swift
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
  Prayer times for a location and date using the given calculation parameters.

  All prayer times are in UTC and should be displayed using a DateFormatter that
  has the correct timezone set.

  Near the polar circles the sun may not rise or set, or may not reach the
  angle required for a given prayer, on certain days of the year. By default
  `calculationParameters.polarCircleResolution` is `aqrabBalad`, which
  automatically substitutes the closest usable latitude in these cases. If a
  substitute can't be found (or `polarCircleResolution` is `unresolved`),
  initialization fails and returns nil.
 */
public struct PrayerTimes {
    public let fajr: Date
    public let sunrise: Date
    public let dhuhr: Date
    public let asr: Date
    public let maghrib: Date
    public let isha: Date

    public let coordinates: Coordinates
    public let date: DateComponents
    public let calculationParameters: CalculationParameters

    public init?(coordinates: Coordinates, date: DateComponents, calculationParameters: CalculationParameters) {
        // Latitude must be within ±90° and the date must include a year, month and day
        // that can form a valid calendar date
        guard abs(coordinates.latitude) <= 90,
            date.year != nil,
            date.month != nil,
            date.day != nil,
            date.isValidDate(in: .gregorianUTC) else {
            return nil
        }

        // Compute times for the requested location and date. This only fails near the
        // polar circles during extreme situations like midnight sun or polar night.
        var result = PrayerTimes.computeForDay(coordinates: coordinates, date: date, calculationParameters: calculationParameters)

        // If the initial calculation failed, attempt polar circle resolution.
        // aqrabBalad uses the nearest latitude that works,
        // aqrabYaum uses the nearest day that works,
        // and unresolved leaves the result nil.
        if result == nil {
            result = calculationParameters.polarCircleResolution.resolve(coordinates: coordinates, date: date, calculationParameters: calculationParameters)
        }

        // Prayer times can't be determined for this location and date. Either
        // polarCircleResolution is unresolved or was unable to find valid times
        // for the given parameters.
        guard let result else {
            return nil
        }

        self.coordinates = coordinates
        self.date = date
        self.calculationParameters = calculationParameters
        self.fajr = result.fajr
        self.sunrise = result.sunrise
        self.dhuhr = result.dhuhr
        self.asr = result.asr
        self.maghrib = result.maghrib
        self.isha = result.isha
    }

    /// Prayer times computed for a single day of solar geometry
    struct DayResult: Equatable {
        let fajr: Date
        let sunrise: Date
        let dhuhr: Date
        let asr: Date
        let maghrib: Date
        let isha: Date

        /// Shifts every time by a whole number of calendar days. Used to relabel a polar
        /// circle resolved result onto the originally requested date.
        func shifted(byDays days: Int) -> DayResult? {
            guard days != 0 else {
                return self
            }

            let cal: Calendar = .gregorianUTC
            guard let fajr = cal.date(byAdding: .day, value: days, to: fajr),
                let sunrise = cal.date(byAdding: .day, value: days, to: sunrise),
                let dhuhr = cal.date(byAdding: .day, value: days, to: dhuhr),
                let asr = cal.date(byAdding: .day, value: days, to: asr),
                let maghrib = cal.date(byAdding: .day, value: days, to: maghrib),
                let isha = cal.date(byAdding: .day, value: days, to: isha) else {
                return nil
            }

            return DayResult(fajr: fajr, sunrise: sunrise, dhuhr: dhuhr, asr: asr, maghrib: maghrib, isha: isha)
        }
    }

    /// Computes prayer times for a single day of solar geometry with no awareness of
    /// polar circle resolution. Returns nil if any time can't be computed or the times
    /// end up out of order.
    static func computeForDay(
        coordinates: Coordinates,
        date: DateComponents,
        calculationParameters: CalculationParameters
    ) -> DayResult? {

        var tempFajr: Date? = nil
        var tempSunrise: Date? = nil
        var tempDhuhr: Date? = nil
        var tempAsr: Date? = nil
        var tempMaghrib: Date? = nil
        var tempIsha: Date? = nil
        let cal: Calendar = .gregorianUTC

        guard let prayerDate = cal.date(from: date),
            let tomorrowDate = cal.date(byAdding: .day, value: 1, to: prayerDate),
            let year = date.year,
            let dayOfYear = cal.ordinality(of: .day, in: .year, for: prayerDate) else {
            return nil
        }

        let tomorrow = cal.dateComponents([.year, .month, .day], from: tomorrowDate)

        guard let solarTime = SolarTime(date: date, coordinates: coordinates),
            let tomorrowSolarTime = SolarTime(date: tomorrow, coordinates: coordinates),
            let sunriseDate = cal.date(from: solarTime.sunrise),
            let sunsetDate = cal.date(from: solarTime.sunset),
            let tomorrowSunrise = cal.date(from: tomorrowSolarTime.sunrise) else {
                // unable to determine transit, sunrise or sunset aborting calculations
                return nil
        }

        tempSunrise = cal.date(from: solarTime.sunrise)
        tempMaghrib = cal.date(from: solarTime.sunset)
        tempDhuhr = cal.date(from: solarTime.transit)

        if let asrComponents = solarTime.afternoon(shadowLength: calculationParameters.madhab.shadowLength) {
            tempAsr = cal.date(from: asrComponents)
        }

        // get night length
        let night = tomorrowSunrise.timeIntervalSince(sunsetDate)

        if let fajrComponents = solarTime.timeForSolarAngle(Angle(-calculationParameters.fajrAngle), afterTransit: false) {
            tempFajr = cal.date(from: fajrComponents)
        }

        // special case for moonsighting committee at or above latitude 55
        if calculationParameters.method == .moonsightingCommittee && coordinates.latitude >= 55 {
            let nightFraction = night / 7
            tempFajr = sunriseDate.addingTimeInterval(-nightFraction)
        }

        let safeFajr: Date = {
            guard calculationParameters.method != .moonsightingCommittee else {
                return Astronomical.seasonAdjustedMorningTwilight(latitude: coordinates.latitude, day: dayOfYear, year: year, sunrise: sunriseDate)
            }

            let portion = calculationParameters.nightPortions(using: coordinates).fajr
            let nightFraction = portion * night

            return sunriseDate.addingTimeInterval(-nightFraction)
        }()

        if tempFajr == nil || tempFajr?.compare(safeFajr) == .orderedAscending || !PrayerTimes.timesInOrder(tempFajr, tempSunrise) {
            tempFajr = safeFajr
        }

        // Isha calculation with check against safe value
        if calculationParameters.ishaInterval > 0 {
            tempIsha = tempMaghrib?.addingTimeInterval(calculationParameters.ishaInterval.timeInterval)
        } else {
            if let ishaComponents = solarTime.timeForSolarAngle(Angle(-calculationParameters.ishaAngle), afterTransit: true) {
                tempIsha = cal.date(from: ishaComponents)
            }

            // special case for moonsighting committee at or above latitude 55
            if calculationParameters.method == .moonsightingCommittee && coordinates.latitude >= 55 {
                let nightFraction = night / 7
                tempIsha = sunsetDate.addingTimeInterval(nightFraction)
            }

            let safeIsha: Date = {
                guard calculationParameters.method != .moonsightingCommittee else {
                    return Astronomical.seasonAdjustedEveningTwilight(latitude: coordinates.latitude, day: dayOfYear, year: year, sunset: sunsetDate, shafaq: calculationParameters.shafaq)
                }

                let portion = calculationParameters.nightPortions(using: coordinates).isha
                let nightFraction = portion * night

                return sunsetDate.addingTimeInterval(nightFraction)
            }()

            if tempIsha == nil || !PrayerTimes.timesInOrder(tempMaghrib, tempIsha) || tempIsha?.compare(safeIsha) == .orderedDescending {
                tempIsha = safeIsha
            }
        }
        
        // Maghrib calculation with check against safe value
        if let maghribAngle = calculationParameters.maghribAngle,
            let maghribComponents = solarTime.timeForSolarAngle(Angle(-maghribAngle), afterTransit: true),
            let maghribDate = cal.date(from: maghribComponents),
            // maghrib is considered safe if it falls between sunset and isha
            sunsetDate < maghribDate, (tempIsha?.compare(maghribDate) == .orderedDescending || tempIsha == nil) {
                tempMaghrib = maghribDate
        }

        // Ensure all prayer times are in the correct order and that there is
        // at least a 5 minute time difference. This prevents invalid prayer times
        // for locations inside the polar circle on dates where the sun rises
        // but never leaves the horizon.
        guard PrayerTimes.timesInOrder(tempFajr, tempSunrise),
            PrayerTimes.timesInOrder(tempSunrise, tempDhuhr),
            PrayerTimes.timesInOrder(tempDhuhr, tempAsr),
            PrayerTimes.timesInOrder(tempAsr, tempMaghrib),
            PrayerTimes.timesInOrder(tempMaghrib, tempIsha) else {
                return nil
        }

        // if we don't have all prayer times then initialization failed
        guard let fajr = tempFajr,
            let sunrise = tempSunrise,
            let dhuhr = tempDhuhr,
            let asr = tempAsr,
            let maghrib = tempMaghrib,
            let isha = tempIsha else {
                return nil
        }

        // Apply all offsets and rounding to the final times
        return DayResult(
            fajr: fajr.addingTimeInterval(calculationParameters.adjustments.fajr.timeInterval)
                .addingTimeInterval(calculationParameters.methodAdjustments.fajr.timeInterval)
                .roundedMinute(rounding: calculationParameters.rounding),
            sunrise: sunrise.addingTimeInterval(calculationParameters.adjustments.sunrise.timeInterval)
                .addingTimeInterval(calculationParameters.methodAdjustments.sunrise.timeInterval)
                .roundedMinute(rounding: calculationParameters.rounding),
            dhuhr: dhuhr.addingTimeInterval(calculationParameters.adjustments.dhuhr.timeInterval)
                .addingTimeInterval(calculationParameters.methodAdjustments.dhuhr.timeInterval)
                .roundedMinute(rounding: calculationParameters.rounding),
            asr: asr.addingTimeInterval(calculationParameters.adjustments.asr.timeInterval)
                .addingTimeInterval(calculationParameters.methodAdjustments.asr.timeInterval)
                .roundedMinute(rounding: calculationParameters.rounding),
            maghrib: maghrib.addingTimeInterval(calculationParameters.adjustments.maghrib.timeInterval)
                .addingTimeInterval(calculationParameters.methodAdjustments.maghrib.timeInterval)
                .roundedMinute(rounding: calculationParameters.rounding),
            isha: isha.addingTimeInterval(calculationParameters.adjustments.isha.timeInterval)
                .addingTimeInterval(calculationParameters.methodAdjustments.isha.timeInterval)
                .roundedMinute(rounding: calculationParameters.rounding))
    }

    public func currentPrayer(at time: Date = Date()) -> Prayer? {
        if isha.timeIntervalSince(time) <= 0 {
            return .isha
        } else if maghrib.timeIntervalSince(time) <= 0 {
            return .maghrib
        } else if asr.timeIntervalSince(time) <= 0 {
            return .asr
        } else if dhuhr.timeIntervalSince(time) <= 0 {
            return .dhuhr
        } else if sunrise.timeIntervalSince(time) <= 0 {
            return .sunrise
        } else if fajr.timeIntervalSince(time) <= 0 {
            return .fajr
        }

        return nil
    }

    public func nextPrayer(at time: Date = Date()) -> Prayer? {
        if isha.timeIntervalSince(time) <= 0 {
            return nil
        } else if maghrib.timeIntervalSince(time) <= 0 {
            return .isha
        } else if asr.timeIntervalSince(time) <= 0 {
            return .maghrib
        } else if dhuhr.timeIntervalSince(time) <= 0 {
            return .asr
        } else if sunrise.timeIntervalSince(time) <= 0 {
            return .dhuhr
        } else if fajr.timeIntervalSince(time) <= 0 {
            return .sunrise
        }

        return .fajr
    }

    public func time(for prayer: Prayer) -> Date {
        switch prayer {
        case .fajr:
            return fajr
        case .sunrise:
            return sunrise
        case .dhuhr:
            return dhuhr
        case .asr:
            return asr
        case .maghrib:
            return maghrib
        case .isha:
            return isha
        }
    }

    static let minimumPrayerGap: TimeInterval = 5 * 60

    static func timesInOrder(_ first: Date?, _ second: Date?) -> Bool {
        guard let first = first, let second = second else {
            return false
        }

        return second.timeIntervalSince(first) >= PrayerTimes.minimumPrayerGap
    }
}
