# Calculation Parameters Guide

## Calculation parameters

To calculate Prayer Times, a CalculatonParameters struct is required.
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
| method    | Which preset from the CalculationMethod enum was used. Default value is `other`. |
| fajrAngle | Angle of the sun below the horizon used to calculate Fajr. |
| maghribAngle | Angle of the sun below the horizon used to calculate Maghrib, used for some Calculation Methods. |
| ishaAngle | Angle of the sun below the horizon used to calculate Isha. |
| ishaInterval | Minutes after Maghrib (if set, the time for Isha will be Maghrib plus ishaInterval). |
| madhab | Which setting from the Madhab enum to use for calculating Asr. |
| highLatitudeRule | Which setting from the HighLatitudeRule enum to use for calculating the minimum time for Fajr and the maximum time for Isha. |
| adjustments | PrayerAdjustments struct with custom prayer time adjustments in minutes for each prayer time. |
| rounding | The behavior for rounding prayer times. Either to nearest minute, to the higher minute, or none.  |
| shafaq | Used by the MoonsightingCommittee method to determine how to calculate Isha. See explanation of values below. |

## CalculationMethod

Preset calculation parameters for different regions.

| Value | Description |
| ----- | ----------- |
| muslimWorldLeague | Muslim World League. Standard Fajr time with an angle of 18°. Earlier Isha time with an angle of 17°. |
| egyptian | Egyptian General Authority of Survey. Early Fajr time using an angle 19.5° and a slightly earlier Isha time using an angle of 17.5°. |
| karachi | University of Islamic Sciences, Karachi. A generally applicable method that uses standard Fajr and Isha angles of 18°. |
| ummAlQura | Umm al-Qura University, Makkah. Uses a fixed interval of 90 minutes from maghrib to calculate Isha. And a slightly earlier Fajr time with an angle of 18.5°. *Note: you should add a +30 minute custom adjustment for Isha during Ramadan.* |
| dubai | Used in the UAE. Slightly earlier Fajr time and slightly later Isha time with angles of 18.2° for Fajr and Isha in addition to 3 minute offsets for sunrise, Dhuhr, Asr, and Maghrib. |
| qatar | Same Isha interval as `ummAlQura` but with the standard Fajr time using an angle of 18°. |
| kuwait | Standard Fajr time with an angle of 18°. Slightly earlier Isha time with an angle of 17.5°. |
| moonsightingCommittee | Method developed by Khalid Shaukat, founder of Moonsighting Committee Worldwide. Uses standard 18° angles for Fajr and Isha in addition to seasonal adjustment values. This method automatically applies the 1/7 approximation rule for locations above 55° latitude. Recommended for North America and the UK. |
| singapore | Used in Singapore, Malaysia, and Indonesia. Early Fajr time with an angle of 20° and standard Isha time with an angle of 18°. |
| turkey | An approximation of the Diyanet method used in Turkey. This approximation is less accurate outside the region of Turkey. |
| tehran | Institute of Geophysics, University of Tehran. Early Isha time with an angle of 14°. Slightly later Fajr time with an angle of 17.7°. Calculates Maghrib based on the sun reaching an angle of 4.5° below the horizon. |
| northAmerica | Also known as the ISNA method. Can be used for North America, but the moonsightingCommittee method is preferable. Gives later Fajr times and early Isha times with angles of 15°. |
| other | Defaults to angles of 0°, should generally be used for making a custom method and setting your own values. |

## Madhab

Rule for calculating the time for Asr.

| Value | Description |
| ----- | ----------- |
| shafi | Earlier Asr time (use for Shafi, Maliki, Hanbali, and Jafari). |
| hanafi | Later Asr time. |

## HighLatitudeRule

Rule for approximating Fajr and Isha at high latitudes.

| Value | Description |
| ----- | ----------- |
| middleOfTheNight | Fajr won't be earlier than the midpoint of the night and isha won't be later than the midpoint of the night. This is the default value to prevent fajr and isha crossing boundaries. |
| seventhOfTheNight | Fajr will never be earlier than the beginning of the last seventh of the night and Isha will never be later than the end of the first seventh of the night. This is recommended to use for locations above 48° latitude to prevent prayer times that would be difficult to perform. |
| twilightAngle | The night is divided into portions of roughly 1/3. The exact value is derived by dividing the fajr/isha angles by 60. This can be used to prevent difficult fajr and isha times at certain locations. |

You can get the recommended High Latitude Rule for a location by calling the `recommended(for:)` function and passing in the coordinates for the location.

```
let myCoordinates = Coordinates(latitude: 48.983226, longitude: -3.216649)
let highLatRule = HighLatitudeRule.recommended(for: myCoordinates)
```

#### Shafaq

Shafaq is used by the MoonsightingCommittee method to determine what type of twilight to use in order to determine the time for Isha.

| Value | Description |
| ----- | ----------- |
| general | General is a combination of Ahmer and Abyad. This is the defualt value and will provide more reasonable times for locations at higher latitudes. |
| ahmer | Ahmer means the twilight is the red glow in the sky. Used by the Shafi, Maliki, and Hanbali madhabs. This generally produces an earlier Isha time. |
| abyad | Abyad means the twilight is the white glow in the sky. Used by the Hanafi madhab. This generally produces a later Isha time. |
