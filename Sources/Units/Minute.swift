//
//  Minute.swift
//  Adhan iOS
//
//  Created by Ameir Al-Zoubi on 9/13/18.
//  Copyright © 2018 Batoul Apps. All rights reserved.
//

import Foundation

public typealias Minute = Int

extension Minute {
    var timeInterval: TimeInterval {
        return TimeInterval(self * 60)
    }
}
