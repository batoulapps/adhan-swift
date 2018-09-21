//
//  Angle.swift
//  Adhan iOS
//
//  Created by Ameir Al-Zoubi on 9/12/18.
//  Copyright © 2018 Batoul Apps. All rights reserved.
//

import Foundation

struct Angle: ExpressibleByFloatLiteral, ExpressibleByIntegerLiteral {
    var degrees: Double
    
    init(_ value: Double) {
        self.degrees = value
    }
    
    init(radians: Double) {
        self.degrees = (radians * 180.0) / .pi
    }
    
    init(floatLiteral value: Double) {
        self.degrees = value
    }
    
    init(integerLiteral value: Int) {
        self.degrees = Double(value)
    }
    
    var radians: Double {
        return (degrees * .pi) / 180.0
    }
    
    func unwound() -> Angle {
        return Angle(degrees.normalizedToScale(360))
    }
    
    func quadrantShifted() -> Angle {
        if degrees >= -180 && degrees <= 180 {
            return self
        }
        
        return Angle(degrees - (360 * (degrees/360).rounded()))
    }
}

func +(left: Angle, right: Angle) -> Angle {
    return Angle(left.degrees + right.degrees)
}

func -(left: Angle, right: Angle) -> Angle {
    return Angle(left.degrees - right.degrees)
}

func *(left: Angle, right: Angle) -> Angle {
    return Angle(left.degrees * right.degrees)
}

func /(left: Angle, right: Angle) -> Angle {
    return Angle(left.degrees / right.degrees)
}
