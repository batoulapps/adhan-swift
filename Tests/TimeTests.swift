//
//  TimeTests.swift
//  Adhan
//
//  Created by Ameir Al-Zoubi on 4/2/16.
//  Copyright © 2016 Batoul Apps. All rights reserved.
//

import XCTest
@testable import Adhan

class TimeTests: XCTestCase {

    func parseParams(_ data: NSDictionary) -> CalculationParameters {
        var params: CalculationParameters!

        let method = data["method"] as! String
        
        if method == "MuslimWorldLeague" {
            params = CalculationMethod.muslimWorldLeague.params
        } else if method == "Egyptian" {
            params = CalculationMethod.egyptian.params
        } else if method == "Karachi" {
            params = CalculationMethod.karachi.params
        } else if method == "UmmAlQura" {
            params = CalculationMethod.ummAlQura.params
        } else if method == "Dubai" {
            params = CalculationMethod.dubai.params
        } else if method == "MoonsightingCommittee" {
            params = CalculationMethod.moonsightingCommittee.params
        } else if method == "NorthAmerica" {
            params = CalculationMethod.northAmerica.params
        } else if method == "Kuwait" {
            params = CalculationMethod.kuwait.params
        } else if method == "Qatar" {
            params = CalculationMethod.qatar.params
        } else if method == "Tehran" {
            params = CalculationMethod.tehran.params
        } else if method == "Singapore" {
            params = CalculationMethod.singapore.params
        } else if method == "Turkey" {
            params = CalculationMethod.turkey.params
        } else {
            params = CalculationMethod.other.params
        }
        
        let madhab = data["madhab"] as! String
        
        if madhab == "Shafi" {
            params.madhab = .shafi
        } else if madhab == "Hanafi" {
            params.madhab = .hanafi
        }
        
        let highLatRule = data["highLatitudeRule"] as! String
        
        if highLatRule == "SeventhOfTheNight" {
            params.highLatitudeRule = .seventhOfTheNight
        } else if highLatRule == "TwilightAngle" {
            params.highLatitudeRule = .twilightAngle
        } else {
            params.highLatitudeRule = .middleOfTheNight
        }
        
        return params
    }
    
    func testTimes() {
        #if os(Linux)
        let fileManager = FileManager.default
        let currentDir = URL(fileURLWithPath: fileManager.currentDirectoryPath)
        let fixtureDir = currentDir.appendingPathComponent("Tests/Resources/Times")
        let paths = try! fileManager.contentsOfDirectory(at: fixtureDir, includingPropertiesForKeys: nil)
            .filter { $0.pathExtension == "json" }
        #elseif SWIFT_PACKAGE
        let paths = Bundle.module.paths(forResourcesOfType: "json", inDirectory: "Resources/Times")
            .compactMap(URL.init(fileURLWithPath:))
        #else
        let bundle = Bundle(for: type(of: self))
        let paths = bundle.paths(forResourcesOfType: "json", inDirectory: "Times")
            .compactMap(URL.init(fileURLWithPath:))
        #endif

        XCTAssert(paths.count > 0)

        for path in paths {
            let filename = path.lastPathComponent
            var output = "################\nTime Test Output\n"
            let data = try? Data(contentsOf: path)
            let json = try! JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! NSDictionary
            let params = json["params"] as! NSDictionary
            let lat = params["latitude"] as! NSNumber
            let lon = params["longitude"] as! NSNumber
            let zone = params["timezone"] as! String
            let timezone = TimeZone(identifier: zone)!
            
            let coordinates = Coordinates(latitude: lat.doubleValue, longitude: lon.doubleValue)
            let calculationParameters = parseParams(params)
            
            var cal = Calendar(identifier: Calendar.Identifier.gregorian)
            cal.timeZone = TimeZone(identifier: "UTC")!
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "YYYY-MM-dd"
            dateFormatter.timeZone = TimeZone(identifier: "UTC")!
            
            let timeFormatter = DateFormatter()
            timeFormatter.dateFormat = "h:mm a"
            timeFormatter.timeZone = timezone
            
            let dateTimeFormatter = DateFormatter()
            dateTimeFormatter.dateFormat = "YYYY-MM-dd h:mm a"
            dateTimeFormatter.timeZone = timezone
         
            let variance = json["variance"] as? Double ?? 0
            let times = json["times"] as! [NSDictionary]
            output += "Times for \(filename) - \(params["method"]!)\n"
            print("\(params["method"]!) Testing \(path.lastPathComponent) (\(times.count) days)")
            var totalDiff = 0.0
            var totalFajrVariance = 0.0
            var totalSunriseVariance = 0.0
            var totalDhuhrVariance = 0.0
            var totalAsrVariance = 0.0
            var totalMaghribVariance = 0.0
            var totalIshaVariance = 0.0

            var maxDiff = 0.0
            for time in times {
                let date = dateFormatter.date(from: time["date"] as! String)!
                let components = (cal as NSCalendar).components([.year, .month, .day], from: date)
                let prayerTimes = PrayerTimes(coordinates: coordinates, date: components, calculationParameters: calculationParameters)!
                
                let fajrDiff = prayerTimes.fajr.timeIntervalSince(dateTimeFormatter.date(from: "\(time["date"]!) \(time["fajr"]!)")!)/60
                let sunriseDiff = prayerTimes.sunrise.timeIntervalSince(dateTimeFormatter.date(from: "\(time["date"]!) \(time["sunrise"]!)")!)/60
                let dhuhrDiff = prayerTimes.dhuhr.timeIntervalSince(dateTimeFormatter.date(from: "\(time["date"]!) \(time["dhuhr"]!)")!)/60
                let asrDiff = prayerTimes.asr.timeIntervalSince(dateTimeFormatter.date(from: "\(time["date"]!) \(time["asr"]!)")!)/60
                let maghribDiff = prayerTimes.maghrib.timeIntervalSince(dateTimeFormatter.date(from: "\(time["date"]!) \(time["maghrib"]!)")!)/60
                let ishaDiff = prayerTimes.isha.timeIntervalSince(dateTimeFormatter.date(from: "\(time["date"]!) \(time["isha"]!)")!)/60
                
                XCTAssertLessThanOrEqual(fabs(fajrDiff), variance, "Fajr variance larger than accepted value of \(variance)")
                XCTAssertLessThanOrEqual(fabs(sunriseDiff), variance, "Sunrise variance larger than accepted value of \(variance)")
                XCTAssertLessThanOrEqual(fabs(dhuhrDiff), variance, "Dhuhr variance larger than accepted value of \(variance)")
                XCTAssertLessThanOrEqual(fabs(asrDiff), variance, "Asr variance larger than accepted value of \(variance)")
                XCTAssertLessThanOrEqual(fabs(maghribDiff), variance, "Maghrib variance larger than accepted value of \(variance)")
                XCTAssertLessThanOrEqual(fabs(ishaDiff), variance, "Isha variance larger than accepted value of \(variance)")

                totalFajrVariance += fajrDiff
                totalSunriseVariance += sunriseDiff
                totalDhuhrVariance += dhuhrDiff
                totalAsrVariance += asrDiff
                totalMaghribVariance += maghribDiff
                totalIshaVariance += ishaDiff

                totalDiff += fabs(fajrDiff)
                totalDiff += fabs(sunriseDiff)
                totalDiff += fabs(dhuhrDiff)
                totalDiff += fabs(asrDiff)
                totalDiff += fabs(maghribDiff)
                totalDiff += fabs(ishaDiff)
                maxDiff = max(fabs(fajrDiff), fabs(sunriseDiff), fabs(dhuhrDiff), fabs(asrDiff), fabs(maghribDiff), fabs(ishaDiff), maxDiff)

                output += "\(params["method"]!) \(components.year ?? 0)-\(components.month ?? 0)-\(components.day ?? 0)\n"
                let outputValues: [(Date, String, Double)] = [
                    (prayerTimes.fajr, "fajr", fajrDiff),
                    (prayerTimes.sunrise, "sunrise", sunriseDiff),
                    (prayerTimes.dhuhr, "dhuhr", dhuhrDiff),
                    (prayerTimes.asr, "asr", asrDiff),
                    (prayerTimes.maghrib, "maghrib", maghribDiff),
                    (prayerTimes.isha, "isha", ishaDiff)
                ]
                outputValues.forEach {
                    let paddingLength = 10
                    let jsonTime = time[$0.1]! as! String
                    output += "\(filename) \($0.1.prefix(1).capitalized): \(timeFormatter.string(from: $0.0).padding(toLength: paddingLength, withPad: " ", startingAt: 0)) JSON: \(jsonTime.padding(toLength: paddingLength, withPad: " ", startingAt: 0)) Diff: \(Int($0.2))\n"
                }
            }
            output += "\(filename) Average difference: \(totalDiff/Double(times.count * 6))\n"
            output += "\(filename) Max difference: \(maxDiff)\n"
            output += "\(filename) Fajr variance: \(totalFajrVariance/Double(times.count))\n"
            output += "\(filename) Sunrise variance: \(totalSunriseVariance/Double(times.count))\n"
            output += "\(filename) Dhuhr variance: \(totalDhuhrVariance/Double(times.count))\n"
            output += "\(filename) Asr variance: \(totalAsrVariance/Double(times.count))\n"
            output += "\(filename) Maghrib variance: \(totalMaghribVariance/Double(times.count))\n"
            output += "\(filename) Isha variance: \(totalIshaVariance/Double(times.count))\n"
            if maxDiff > 0 {
                print(output)
            }
        }
    }

}
