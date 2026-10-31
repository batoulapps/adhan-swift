//
//  PolarCircleResolution.swift
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
  Strategy used to resolve prayer times for locations inside the polar circles,
  where daylight or night may persist for more than 24 hours depending on the season.

  *Values*

  **aqrabBalad**

  Finds the closest location (moving toward the equator at the same longitude)
  for which prayer times can be computed. This is the default value.

  **aqrabYaum**

  Finds the closest date (forward or backward) for which prayer times can be computed.

  **unresolved**

  Leaves prayer times unresolved, `PrayerTimes` initialization fails when they can't be computed.
 */
public enum PolarCircleResolution: String, Codable, CaseIterable {
    case aqrabBalad
    case aqrabYaum
    case unresolved
}

extension PolarCircleResolution {
    // Degrees to add/remove at each resolution step
    static let latitudeVariationStep: Double = 0.5

    // Maximum number of days to search in each direction
    static let maximumDaysSearched = Int((365.0 / 2).rounded(.up))

    func resolve(coordinates: Coordinates, date: DateComponents, calculationParameters: CalculationParameters) -> PrayerTimes.DayResult? {
        switch self {
        case .aqrabYaum:
            return PolarCircleResolution.nearestDay(coordinates: coordinates, date: date, calculationParameters: calculationParameters)
        case .aqrabBalad:
            return PolarCircleResolution.nearestLatitude(coordinates: coordinates, date: date, calculationParameters: calculationParameters)
        case .unresolved:
            return nil
        }
    }

    private static func nearestDay(coordinates: Coordinates, date: DateComponents, calculationParameters: CalculationParameters) -> PrayerTimes.DayResult? {
        let cal: Calendar = .gregorianUTC
        guard let requestedDate = cal.date(from: date) else {
            return nil
        }

        // Alternate forward and backward: +1, -1, +2, -2, ...
        for daysAdded in 1...maximumDaysSearched {
            for direction in [1, -1] {
                let offset = direction * daysAdded
                guard let testDate = cal.date(byAdding: .day, value: offset, to: requestedDate) else {
                    continue
                }

                let testComponents = cal.dateComponents([.year, .month, .day], from: testDate)
                if let result = PrayerTimes.computeForDay(coordinates: coordinates, date: testComponents, calculationParameters: calculationParameters) {
                    // Relabel the candidate day's times onto the requested date
                    return result.shifted(byDays: -offset)
                }
            }
        }

        return nil
    }

    private static func nearestLatitude(coordinates: Coordinates, date: DateComponents, calculationParameters: CalculationParameters) -> PrayerTimes.DayResult? {
        // The equator is the terminal search value: moving past it would flip
        // into the other hemisphere, which has the wrong season's solar
        // geometry for the requested date.
        let candidateLatitudes = sequence(first: nextLatitude(after: coordinates.latitude)) { latitude in
            latitude == 0 ? nil : nextLatitude(after: latitude)
        }

        return candidateLatitudes.lazy
            .compactMap { latitude in
                PrayerTimes.computeForDay(
                    coordinates: Coordinates(latitude: latitude, longitude: coordinates.longitude),
                    date: date,
                    calculationParameters: calculationParameters)
            }
            .first
    }

    // Steps one increment toward the equator without ever crossing it
    private static func nextLatitude(after latitude: Double) -> Double {
        return Double(signOf: latitude, magnitudeOf: max(0, abs(latitude) - latitudeVariationStep))
    }
}
