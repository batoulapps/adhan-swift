//
//  Date+Extension.swift
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

internal extension Date {

    func roundedMinute(rounding: Rounding = .nearest) -> Date {
        let cal: Calendar = .gregorianUTC
        var components = cal.dateComponents([.year, .month, .day, .hour, .minute, .second], from: self)

        let minute: Double = Double(components.minute ?? 0)
        let second: Double = Double(components.second ?? 0)

        switch rounding {
        case .nearest:
            components.minute = Int(minute + round(second/60))
            components.second = 0
        case .up:
            components.minute = Int(minute + ceil(second/60))
            components.second = 0
        case .none:
            components.minute = Int(minute)
            components.second = Int(second)
        }

        return cal.date(from: components) ?? self
    }
}

internal extension DateComponents {
    
    func settingHour(_ value: Double) -> DateComponents? {
        guard value.isNormal else {
            return nil
        }
        
        let calculatedHours = floor(value)
        let calculatedMinutes = floor((value - calculatedHours) * 60)
        let calculatedSeconds = floor((value - (calculatedHours + calculatedMinutes/60)) * 60 * 60)
        
        var components = self
        components.hour = Int(calculatedHours)
        components.minute = Int(calculatedMinutes)
        components.second = Int(calculatedSeconds)
        
        return components
    }
}

internal extension Calendar {
    
    /// All calculations are done using a gregorian calendar with the UTC timezone
    static let gregorianUTC: Calendar = {
        guard let utc = TimeZone(identifier: "UTC") else {
            fatalError("Unable to instantiate UTC TimeZone.")
        }

        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = utc
        return cal
    }()
}
