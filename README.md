# Adhan Swift

![badge-languages][] ![badge-pms][] ![badge-platforms][]

[![badge-pod][]][cocoapods] [![badge-travis][]][travis] [![badge-cov][]][codecov]

Adhan Swift is a well tested and well documented library for calculating Islamic prayer times. Adhan Swift supports Swift 4.0, Swift 4.2, Swift 5.0 and Objective-C.

All astronomical calculations are high precision equations directly from the book [“Astronomical Algorithms” by Jean Meeus](http://www.willbell.com/math/mc1.htm). This book is recommended by the Astronomical Applications Department of the U.S. Naval Observatory and the Earth System Research Laboratory of the National Oceanic and Atmospheric Administration.

Implementations of Adhan in other languages can be found in the parent repo [Adhan](https://github.com/batoulapps/Adhan).

## Installation

### CocoaPods

Adhan supports [CocoaPods](https://cocoapods.org/). Simply add the following line to your [Podfile](https://guides.cocoapods.org/syntax/podfile.html):

```ruby
pod 'Adhan'
```

### Carthage

Adhan supports [Carthage](https://github.com/Carthage/Carthage). Simply add the following line to your [Cartfile](https://github.com/Carthage/Carthage/blob/master/Documentation/Artifacts.md#cartfile):

```ruby
github "batoulapps/adhan-swift" "master"
```

### Swift Package Manager

Adhan supports [SPM](https://swift.org/package-manager/). Simply add the following line to your dependencies value of your `Package.swift` file:

```swift
// swift-tools-version:4.2
dependencies: [
    .package(url: "https://github.com/batoulapps/adhan-swift", .branch("master")),
]
```

### Manual

You can also manually add Adhan.

- Download the source.
- Add Adhan.xcodeproj as a subproject in your app's project.
- Drag Adhan.framework to "Linked Frameworks and Libraries" in your app's target.


## Usage

To get prayer times initialize the `PrayerTimes` struct passing in coordinates,
date, and calculation parameters.

```swift
let prayers = PrayerTimes(coordinates: coordinates, date: date, calculationParameters: params)
```

### Initialization parameters

#### Coordinates

Create a `Coordinates` struct with the latitude and longitude for the location
you want prayer times for.

```swift
let coordinates = Coordinates(latitude: 35.78056, longitude: -78.6389)
```

#### Date

To avoid confusion with timezones the date parameter passed in should be an instance of
`DateComponents`. The year, month, and day components need to be populated. All other
components will be ignored. The year, month and day values should be for the local date
that you want prayer times for. These date components are expected to be for the Gregorian calendar.

```swift
let cal = Calendar(identifier: Calendar.Identifier.gregorian)
let date = cal.dateComponents([.year, .month, .day], from: Date())
```

#### Calculation parameters

The rest of the needed information is contained within the `CalculationParameters` struct.
Instead of manually initializing this struct it is recommended to use one of the pre-populated
instances by calling the `params` var on the `CalculationMethod` enum. You can then further
customize the calculation parameters if needed.

```swift
var params = CalculationMethod.moonsightingCommittee.params
params.madhab = .hanafi
params.adjustments.fajr = 2
```

| Parameter | Description |
| --------- | ----------- |
| method    | Member of CalculationMethod enum |
| fajrAngle | Angle of the sun used to calculate Fajr |
| maghribAngle | Angle of the sun used to calculate Maghrib, used for some Calculation Methods |
| ishaAngle | Angle of the sun used to calculate Isha |
| ishaInterval | Minutes after Maghrib (if set, the time for Isha will be Maghrib plus ishaInterval) |
| madhab | Member of the Madhab enum, used to calculate Asr |
| highLatitudeRule | Member of the HighLatitudeRule enum, used to set a minimum time for Fajr and a max time for Isha |
| adjustments | PrayerAdjustments struct with custom prayer time adjustments in minutes for each prayer time |

**CalculationMethod**

| Value | Description |
| ----- | ----------- |
| muslimWorldLeague | Muslim World League. Fajr angle: 18, Isha angle: 17 |
| egyptian | Egyptian General Authority of Survey. Fajr angle: 19.5, Isha angle: 17.5 |
| karachi | University of Islamic Sciences, Karachi. Fajr angle: 18, Isha angle: 18 |
| ummAlQura | Umm al-Qura University, Makkah. Fajr angle: 18.5, Isha interval: 90. *Note: you should add a +30 minute custom adjustment for Isha during Ramadan.* |
| dubai | Method used in UAE. Fajr angle: 18.2, Isha angle: 18.2. |
| qatar | Modified version of Umm al-Qura used in Qatar. Fajr angle: 18, Isha interval: 90. |
| kuwait | Method used by the country of Kuwait. Fajr angle: 18, Isha angle: 17.5 |
| moonsightingCommittee | Moonsighting Committee. Fajr angle: 18, Isha angle: 18. Also uses seasonal adjustment values. |
| singapore | Method used by Singapore. Fajr angle: 20, Isha angle: 18. |
| tehran | Institute of Geophysics, University of Tehran. Fajr angle: 17.7, Maghrib angle: 4.5, Isha angle: 14. |
| northAmerica | Referred to as the ISNA method. This method is included for completeness but is not recommended. Fajr angle: 15, Isha angle: 15 |
| other | Fajr angle: 0, Isha angle: 0. This is the default value for `method` when initializing a `CalculationParameters` struct. |

**Madhab**

| Value | Description |
| ----- | ----------- |
| shafi | Earlier Asr time (use for Shafi, Maliki, Hanbali, and Jafari) |
| hanafi | Later Asr time |

**HighLatitudeRule**

| Value | Description |
| ----- | ----------- |
| middleOfTheNight | Fajr will never be earlier than the middle of the night and Isha will never be later than the middle of the night |
| seventhOfTheNight | Fajr will never be earlier than the beginning of the last seventh of the night and Isha will never be later than the end of the first seventh of the night |
| twilightAngle | Similar to SeventhOfTheNight, but instead of 1/7, the fraction of the night used is fajrAngle/60 and ishaAngle/60 |


### Prayer Times

Once the `PrayerTimes` struct has been initialized it will contain members
for all five prayer times and the time for sunrise. The prayer times will be instances
of NSDate and as such will refer to a fixed point in universal time. To display these
times for the local timezone you will need to create a date formatter and set
the appropriate timezone.

```swift
let formatter = DateFormatter()
formatter.timeStyle = .medium
formatter.timeZone = TimeZone(identifier: "America/New_York")!

print("fajr \(formatter.string(from: prayers.fajr))")
```

## Full Example

```swift
let cal = Calendar(identifier: Calendar.Identifier.gregorian)
let date = cal.dateComponents([.year, .month, .day], from: Date())
let coordinates = Coordinates(latitude: 35.78056, longitude: -78.6389)
var params = CalculationMethod.moonsightingCommittee.params
params.madhab = .hanafi
if let prayers = PrayerTimes(coordinates: coordinates, date: date, calculationParameters: params) {
    let formatter = DateFormatter()
    formatter.timeStyle = .medium
    formatter.timeZone = TimeZone(identifier: "America/New_York")!

    print("fajr \(formatter.string(from: prayers.fajr))")
    print("sunrise \(formatter.string(from: prayers.sunrise))")
    print("dhuhr \(formatter.string(from: prayers.dhuhr))")
    print("asr \(formatter.string(from: prayers.asr))")
    print("maghrib \(formatter.string(from: prayers.maghrib))")
    print("isha \(formatter.string(from: prayers.isha))")
}
```

## Convenience Utilities

The `PrayerTimes` struct has functions for getting the current prayer and the next prayer. You can also get the time for a specified prayer, making it
easier to dynamically show countdowns until the next prayer.

```swift
let prayerTimes = PrayerTimes(coordinates: coordinates, date: date, calculationParameters: params)

let current = prayerTimes.currentPrayer()
let next = prayerTimes.nextPrayer()
let countdown = prayerTimes.time(for: next)
```

### Sunnah Times

The Adhan library can also calulate Sunnah times. Given an instance of `PrayerTimes`, you can get a `SunnahTimes` struct with the times for Qiyam.

```swift
if let sunnahTimes = SunnahTimes(from: todayPrayers) {
	print(dateFormatter.string(from: sunnahTimes.lastThirdOfTheNight)
	print(dateFormatter.string(from: sunnahTimes.middleOfTheNight)
}
```

### Qibla Direction

Get the direction, in degrees from North, of the Qibla from a given set of coordinates.

```swift
let nyc = Coordinates(latitude: 40.7128, longitude: -74.0059)
let qiblaDirection = Qibla(coordinates: nyc).direction
```

## Contributing

Adhan is made publicly available to provide a well tested and well documented library for Islamic prayer times to all
developers. We accept feature contributions provided that they are properly documented and include the appropriate
unit tests. We are also looking for contributions in the form of unit tests of of prayer times for different
locations, we do ask that the source of the comparison values be properly documented.

## License

Adhan is available under the MIT license. See the LICENSE file for more info.

[badge-pod]: https://img.shields.io/cocoapods/v/Adhan.svg?label=version
[badge-pms]: https://img.shields.io/badge/supports-CocoaPods%20%7C%20Carthage%20%7C%20SwiftPM-green.svg
[badge-languages]: https://img.shields.io/badge/languages-Swift%20%7C%20ObjC-orange.svg
[badge-platforms]: https://img.shields.io/badge/platforms-macOS%20%7C%20iOS%20%7C%20watchOS%20%7C%20tvOS-lightgrey.svg
[badge-travis]: https://travis-ci.org/batoulapps/adhan-swift.svg?branch=master
[badge-cov]: https://codecov.io/gh/batoulapps/adhan-swift/branch/master/graph/badge.svg
[travis]: https://travis-ci.org/batoulapps/adhan-swift
[cocoapods]: https://cocoapods.org/pods/Adhan
[codecov]: https://codecov.io/gh/batoulapps/adhan-swift
