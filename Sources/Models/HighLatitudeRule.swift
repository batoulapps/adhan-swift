//
//  HighLatitudeRule.swift
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
  Rule for approximating Fajr and Isha at high latitudes

  *Values*

  **middleOfTheNight**

  Fajr won't be earlier than the midpoint of the night and isha won't be later than the midpoint of the night. This is the default
  value to prevent fajr and isha crossing boundaries.

  **seventhOfTheNight**

  Fajr will never be earlier than the beginning of the last seventh of the night and Isha will never be later than the end of the first seventh of the night.
  This is recommended to use for locations above 48° latitude to prevent prayer times that would be difficult to perform.

  **twilightAngle**

  The night is divided into portions of roughly 1/3. The exact value is derived by dividing the fajr/isha angles by 60.
  This can be used to prevent difficult fajr and isha times at certain locations.
 */
public enum HighLatitudeRule: String, Codable, CaseIterable {
    case middleOfTheNight
    case seventhOfTheNight
    case twilightAngle

    /// Returns the recommended High Latitude Rule for the specified location.
    public static func recommended(for coordinates: Coordinates) -> HighLatitudeRule {
        if coordinates.latitude > 48 {
            return .seventhOfTheNight
        } else {
            return .middleOfTheNight
        }
    }
}
