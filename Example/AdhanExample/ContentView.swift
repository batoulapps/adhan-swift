//
//  ContentView.swift
//  AdhanExample
//
//  Created by Ameir Al-Zoubi on 6/8/26.
//

import SwiftUI
import Adhan

struct ContentView: View {
    
    var coordinates: Coordinates {
        Coordinates(latitude: 35.78056, longitude: -78.6389)
    }
    
    var prayerTimes: PrayerTimes? {
        let cal = Calendar(identifier: Calendar.Identifier.gregorian)
        let date = cal.dateComponents([.year, .month, .day], from: Date())
        let params = CalculationMethod.northAmerica.params
        
        return PrayerTimes(
            coordinates: coordinates,
            date: date,
            calculationParameters: params
        )
    }
    
    var qibla: Double {
        Qibla(coordinates: coordinates).direction
    }
    
    let formatter = {
        let new = DateFormatter()
        new.timeStyle = .medium
        new.timeZone = TimeZone(identifier: "America/New_York")!
        return new
    }()
    
    var body: some View {
        VStack {
            if let prayerTimes {
                Text("Fajr: \(formatter.string(from: prayerTimes.fajr))")
                Text("Sunrise: \(formatter.string(from: prayerTimes.sunrise))")
                Text("Dhuhr: \(formatter.string(from: prayerTimes.dhuhr))")
                Text("Asr: \(formatter.string(from: prayerTimes.asr))")
                Text("Maghrib: \(formatter.string(from: prayerTimes.maghrib))")
                Text("Isha: \(formatter.string(from: prayerTimes.isha))")
                
                if let sunnahTimes = SunnahTimes(from: prayerTimes) {
                    Text("Last third of the night: \(formatter.string(from: sunnahTimes.lastThirdOfTheNight))")
                    
                    Text("Middle of the night: \(formatter.string(from: sunnahTimes.middleOfTheNight))")
                }
            }
            
            Text("Qibla: \(qibla)")
        }
    }
}

#Preview {
    ContentView()
}
