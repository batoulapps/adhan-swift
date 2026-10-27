//
//  PrayerTimesOrderingTests.swift
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

import XCTest
@testable import Adhan

class PrayerTimesOrderingTests: XCTestCase {

    private let gap = PrayerTimes.minimumPrayerGap

    private func t(_ offset: TimeInterval) -> Date {
        return Date(timeIntervalSince1970: 1_000_000_000 + offset)
    }

    func testTimesInOrderExactGapReturnsTrue() {
        XCTAssertTrue(PrayerTimes.timesInOrder(t(0), t(gap)))
    }

    func testTimesInOrderMoreThanGapReturnsTrue() {
        XCTAssertTrue(PrayerTimes.timesInOrder(t(0), t(gap + 1)))
    }

    func testTimesInOrderLessThanGapReturnsFalse() {
        XCTAssertFalse(PrayerTimes.timesInOrder(t(0), t(gap - 1)))
    }

    func testTimesInOrderEqualReturnsFalse() {
        XCTAssertFalse(PrayerTimes.timesInOrder(t(0), t(0)))
    }

    func testTimesInOrderReversedReturnsFalse() {
        XCTAssertFalse(PrayerTimes.timesInOrder(t(gap), t(0)))
    }

    func testTimesInOrderFirstNilReturnsFalse() {
        XCTAssertFalse(PrayerTimes.timesInOrder(nil, t(0)))
    }

    func testTimesInOrderSecondNilReturnsFalse() {
        XCTAssertFalse(PrayerTimes.timesInOrder(t(0), nil))
    }

    func testTimesInOrderBothNilReturnsFalse() {
        XCTAssertFalse(PrayerTimes.timesInOrder(nil, nil))
    }
}
