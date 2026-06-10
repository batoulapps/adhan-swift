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
    
    func prayerName(for prayer: Prayer) -> String {
        switch prayer {
        case .fajr:
            "Fajr"
        case .sunrise:
            "Sunrise"
        case .dhuhr:
            "Dhuhr"
        case .asr:
            "Asr"
        case .maghrib:
            "Maghrib"
        case .isha:
            "Isha"
        }
    }
    
    var body: some View {
        VStack {
            if let prayerTimes {
                ForEach(Prayer.allCases, id: \.self) { prayer in
                    HStack {
                        Text(prayerName(for: prayer))
                        Spacer()
                        Text(prayerTimes.time(for: prayer).formatted(date: .omitted, time: .shortened))
                    }
                    Divider()
                    .padding(.bottom, 4)
                }
                if let sunnahTimes = SunnahTimes(from: prayerTimes) {
                    HStack {
                        Text("Last third of the night")
                        Spacer()
                        Text(sunnahTimes.lastThirdOfTheNight.formatted(date: .omitted, time: .shortened))
                    }
                    .padding(.top, 12)
                    
                    HStack {
                        Text("Middle of the night")
                        Spacer()
                        Text(sunnahTimes.middleOfTheNight.formatted(date: .omitted, time: .shortened))
                    }
                    .padding(.top, 12)
                }
            }
            
            Divider()
            
            HStack(spacing: 0) {
                Text("Qibla")
                Spacer()
                Image(systemName: "arrow.up")
                    .rotationEffect(.degrees(qibla))
                Spacer()
                Text("\(qibla.formatted(.number.precision(.fractionLength(1))))\u{00B0}")
            }
            .padding(.top, 12)
        }
        .frame(width: 250)
    }
}

#Preview {
    ContentView()
}
