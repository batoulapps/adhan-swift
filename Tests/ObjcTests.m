//
//  ObjcTests.m
//  Adhan
//
//  Created by Ameir Al-Zoubi on 4/28/16.
//  Copyright © 2016 Batoul Apps. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <Adhan/Adhan-Swift.h>
#import <CoreLocation/CoreLocation.h>

@interface ObjcTests : XCTestCase

@end

@implementation ObjcTests

- (void)testObjcInterface {
    NSDateComponents *date = [[NSDateComponents alloc] init];
    date.year = 2015;
    date.month = 7;
    date.day = 12;
    
    BACalculationParameters *params = [[BACalculationParameters alloc] initWithMethod:BACalculationMethodNorthAmerica];
    params.madhab = BAMadhabHanafi;
    
    BAPrayerTimes *p = [[BAPrayerTimes alloc] initWithCoordinates:[[BACoordinates alloc] initWithLatitude:35.7750 longitude:-78.6389] date:date calculationParameters:params];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.timeZone = [[NSTimeZone alloc] initWithName:@"America/New_York"];
    formatter.timeStyle = NSDateFormatterShortStyle;
    
    XCTAssertEqualObjects([formatter stringFromDate:p.fajr], @"4:42 AM");
    XCTAssertEqualObjects([formatter stringFromDate:p.sunrise], @"6:08 AM");
    XCTAssertEqualObjects([formatter stringFromDate:p.dhuhr], @"1:21 PM");
    XCTAssertEqualObjects([formatter stringFromDate:p.asr], @"6:22 PM");
    XCTAssertEqualObjects([formatter stringFromDate:p.maghrib], @"8:32 PM");
    XCTAssertEqualObjects([formatter stringFromDate:p.isha], @"9:57 PM");
}

- (void)testShafaqInterface {
    NSDateComponents *date = [[NSDateComponents alloc] init];
    date.year = 2021;
    date.month = 1;
    date.day = 1;
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.timeZone = [[NSTimeZone alloc] initWithName:@"America/New_York"];
    formatter.timeStyle = NSDateFormatterShortStyle;
    
    BACalculationParameters *params = [[BACalculationParameters alloc] initWithMethod:BACalculationMethodMoonsightingCommittee];
    params.shafaq = BAShafaqGeneral;
    
    BAPrayerTimes *p1 = [[BAPrayerTimes alloc] initWithCoordinates:[[BACoordinates alloc] initWithLatitude:43.494 longitude:-79.844] date:date calculationParameters:params];
    
    XCTAssertEqualObjects([formatter stringFromDate:p1.isha], @"6:27 PM");
    
    params.shafaq = BAShafaqAhmer;
    
    BAPrayerTimes *p2 = [[BAPrayerTimes alloc] initWithCoordinates:[[BACoordinates alloc] initWithLatitude:43.494 longitude:-79.844] date:date calculationParameters:params];
    
    XCTAssertEqualObjects([formatter stringFromDate:p2.isha], @"6:07 PM");
    
    params.shafaq = BAShafaqAbyad;
    
    BAPrayerTimes *p3 = [[BAPrayerTimes alloc] initWithCoordinates:[[BACoordinates alloc] initWithLatitude:43.494 longitude:-79.844] date:date calculationParameters:params];
    
    XCTAssertEqualObjects([formatter stringFromDate:p3.isha], @"6:28 PM");
}

- (void)testRoundingInterface {
    NSDateComponents *date = [[NSDateComponents alloc] init];
    date.year = 2015;
    date.month = 7;
    date.day = 12;
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.timeZone = [[NSTimeZone alloc] initWithName:@"America/New_York"];
    formatter.timeStyle = NSDateFormatterShortStyle;
    
    BACalculationParameters *params = [[BACalculationParameters alloc] initWithMethod:BACalculationMethodNorthAmerica];
    params.madhab = BAMadhabHanafi;
    
    BAPrayerTimes *p1 = [[BAPrayerTimes alloc] initWithCoordinates:[[BACoordinates alloc] initWithLatitude:35.7750 longitude:-78.6389] date:date calculationParameters:params];
    
    XCTAssertEqualObjects([formatter stringFromDate:p1.fajr], @"4:42 AM");
    XCTAssertEqualObjects([formatter stringFromDate:p1.sunrise], @"6:08 AM");
    XCTAssertEqualObjects([formatter stringFromDate:p1.dhuhr], @"1:21 PM");
    XCTAssertEqualObjects([formatter stringFromDate:p1.asr], @"6:22 PM");
    XCTAssertEqualObjects([formatter stringFromDate:p1.maghrib], @"8:32 PM");
    XCTAssertEqualObjects([formatter stringFromDate:p1.isha], @"9:57 PM");
    
    params.rounding = BARoundingUp;
    
    BAPrayerTimes *p2 = [[BAPrayerTimes alloc] initWithCoordinates:[[BACoordinates alloc] initWithLatitude:35.7750 longitude:-78.6389] date:date calculationParameters:params];
    
    XCTAssertEqualObjects([formatter stringFromDate:p2.fajr], @"4:43 AM");
    XCTAssertEqualObjects([formatter stringFromDate:p2.sunrise], @"6:08 AM");
    XCTAssertEqualObjects([formatter stringFromDate:p2.dhuhr], @"1:22 PM");
    XCTAssertEqualObjects([formatter stringFromDate:p2.asr], @"6:23 PM");
    XCTAssertEqualObjects([formatter stringFromDate:p2.maghrib], @"8:33 PM");
    XCTAssertEqualObjects([formatter stringFromDate:p2.isha], @"9:58 PM");
    
    params.rounding = BARoundingNone;
    
    BAPrayerTimes *p3 = [[BAPrayerTimes alloc] initWithCoordinates:[[BACoordinates alloc] initWithLatitude:35.7750 longitude:-78.6389] date:date calculationParameters:params];
    
    XCTAssertEqualObjects([formatter stringFromDate:p3.fajr], @"4:42 AM");
    XCTAssertEqualObjects([formatter stringFromDate:p3.sunrise], @"6:07 AM");
    XCTAssertEqualObjects([formatter stringFromDate:p3.dhuhr], @"1:21 PM");
    XCTAssertEqualObjects([formatter stringFromDate:p3.asr], @"6:22 PM");
    XCTAssertEqualObjects([formatter stringFromDate:p3.maghrib], @"8:32 PM");
    XCTAssertEqualObjects([formatter stringFromDate:p3.isha], @"9:57 PM");
}

- (void)testTimeForPrayer {
    NSDateComponents *date = [[NSDateComponents alloc] init];
    date.year = 2016;
    date.month = 7;
    date.day = 1;
    
    BACalculationParameters *params = [[BACalculationParameters alloc] initWithMethod:BACalculationMethodMuslimWorldLeague];
    params.madhab = BAMadhabHanafi;
    params.highLatitudeRule = BAHighLatitudeRuleTwilightAngle;
    BAPrayerTimes *p = [[BAPrayerTimes alloc] initWithCoordinates:[[BACoordinates alloc] initWithLatitude:59.9094 longitude:10.7349] date:date calculationParameters:params];
    XCTAssertEqualObjects(p.fajr, [p timeForPrayer:BAPrayerFajr]);
    XCTAssertEqualObjects(p.sunrise, [p timeForPrayer:BAPrayerSunrise]);
    XCTAssertEqualObjects(p.dhuhr, [p timeForPrayer:BAPrayerDhuhr]);
    XCTAssertEqualObjects(p.asr, [p timeForPrayer:BAPrayerAsr]);
    XCTAssertEqualObjects(p.maghrib, [p timeForPrayer:BAPrayerMaghrib]);
    XCTAssertEqualObjects(p.isha, [p timeForPrayer:BAPrayerIsha]);
    XCTAssertNil([p timeForPrayer:BAPrayerNone]);
}

- (void)testCurrentPrayer {
    NSDateComponents *date = [[NSDateComponents alloc] init];
    date.year = 2015;
    date.month = 9;
    date.day = 1;
    
    BACalculationParameters *params = [[BACalculationParameters alloc] initWithMethod:BACalculationMethodKarachi];
    params.madhab = BAMadhabHanafi;
    params.highLatitudeRule = BAHighLatitudeRuleTwilightAngle;
    BAPrayerTimes *p = [[BAPrayerTimes alloc] initWithCoordinates:[[BACoordinates alloc] initWithLatitude:33.720817 longitude:73.090032] date:date calculationParameters:params];
    XCTAssertEqual([p currentPrayer:[p.fajr dateByAddingTimeInterval:-1]], BAPrayerNone);
    XCTAssertEqual([p currentPrayer:[p.fajr dateByAddingTimeInterval:1]], BAPrayerFajr);
    XCTAssertEqual([p currentPrayer:[p.sunrise dateByAddingTimeInterval:1]], BAPrayerSunrise);
    XCTAssertEqual([p currentPrayer:[p.dhuhr dateByAddingTimeInterval:1]], BAPrayerDhuhr);
    XCTAssertEqual([p currentPrayer:[p.asr dateByAddingTimeInterval:1]], BAPrayerAsr);
    XCTAssertEqual([p currentPrayer:[p.maghrib dateByAddingTimeInterval:1]], BAPrayerMaghrib);
    XCTAssertEqual([p currentPrayer:[p.isha dateByAddingTimeInterval:1]], BAPrayerIsha);
}

- (void)testNextPrayer {
    NSDateComponents *date = [[NSDateComponents alloc] init];
    date.year = 2015;
    date.month = 9;
    date.day = 1;
    
    BACalculationParameters *params = [[BACalculationParameters alloc] initWithMethod:BACalculationMethodKarachi];
    params.madhab = BAMadhabHanafi;
    params.highLatitudeRule = BAHighLatitudeRuleTwilightAngle;
    BAPrayerTimes *p = [[BAPrayerTimes alloc] initWithCoordinates:[[BACoordinates alloc] initWithLatitude:33.720817 longitude:73.090032] date:date calculationParameters:params];
    XCTAssertEqual([p nextPrayer:[p.fajr dateByAddingTimeInterval:-1]], BAPrayerFajr);
    XCTAssertEqual([p nextPrayer:[p.fajr dateByAddingTimeInterval:1]], BAPrayerSunrise);
    XCTAssertEqual([p nextPrayer:[p.sunrise dateByAddingTimeInterval:1]], BAPrayerDhuhr);
    XCTAssertEqual([p nextPrayer:[p.dhuhr dateByAddingTimeInterval:1]], BAPrayerAsr);
    XCTAssertEqual([p nextPrayer:[p.asr dateByAddingTimeInterval:1]], BAPrayerMaghrib);
    XCTAssertEqual([p nextPrayer:[p.maghrib dateByAddingTimeInterval:1]], BAPrayerIsha);
    XCTAssertEqual([p nextPrayer:[p.isha dateByAddingTimeInterval:1]], BAPrayerNone);
}

- (void)testQibla {
    BACoordinates *washingtonDC = [[BACoordinates alloc] initWithLatitude:38.9072 longitude:-77.0369];
    BAQibla *qibla = [[BAQibla alloc] initWithCoordinates:washingtonDC];
    XCTAssertEqualWithAccuracy(qibla.direction, 56.560, 0.001);
}

- (void)testInvalidDate {
    NSDateComponents *date = [[NSDateComponents alloc] init];
    BACalculationParameters *params = [[BACalculationParameters alloc] initWithMethod:BACalculationMethodNorthAmerica];
    params.madhab = BAMadhabHanafi;

    BAPrayerTimes *p = [[BAPrayerTimes alloc] initWithCoordinates:[[BACoordinates alloc] initWithLatitude:35.7750 longitude:-78.6389] date:date calculationParameters:params];
    XCTAssertEqual([p nextPrayer:nil], BAPrayerNone);
    XCTAssertEqual([p currentPrayer:nil], BAPrayerNone);
    XCTAssertNil(p.fajr);
    XCTAssertNil(p.sunrise);
    XCTAssertNil(p.dhuhr);
    XCTAssertNil(p.asr);
    XCTAssertNil(p.maghrib);
    XCTAssertNil(p.isha);
}

- (BACalculationParameters *)parseParams:(NSDictionary *)dict {
    BACalculationParameters *params;
    
    NSString *method = dict[@"method"];
    
    if ([method isEqualToString:@"MuslimWorldLeague"]) {
        params = [[BACalculationParameters alloc] initWithMethod:BACalculationMethodMuslimWorldLeague];
    } else if ([method isEqualToString:@"Egyptian"]) {
        params = [[BACalculationParameters alloc] initWithMethod:BACalculationMethodEgyptian];
    } else if ([method isEqualToString:@"Karachi"]) {
        params = [[BACalculationParameters alloc] initWithMethod:BACalculationMethodKarachi];
    } else if ([method isEqualToString:@"UmmAlQura"]) {
        params = [[BACalculationParameters alloc] initWithMethod:BACalculationMethodUmmAlQura];
    } else if ([method isEqualToString:@"Dubai"]) {
        params = [[BACalculationParameters alloc] initWithMethod:BACalculationMethodDubai];
    } else if ([method isEqualToString:@"MoonsightingCommittee"]) {
        params = [[BACalculationParameters alloc] initWithMethod:BACalculationMethodMoonsightingCommittee];
    } else if ([method isEqualToString:@"NorthAmerica"]) {
        params = [[BACalculationParameters alloc] initWithMethod:BACalculationMethodNorthAmerica];
    } else if ([method isEqualToString:@"Kuwait"]) {
        params = [[BACalculationParameters alloc] initWithMethod:BACalculationMethodKuwait];
    } else if ([method isEqualToString:@"Qatar"]) {
        params = [[BACalculationParameters alloc] initWithMethod:BACalculationMethodQatar];
    } else if ([method isEqualToString:@"Tehran"]) {
        params = [[BACalculationParameters alloc] initWithMethod:BACalculationMethodTehran];
    } else if ([method isEqualToString:@"Singapore"]) {
        params = [[BACalculationParameters alloc] initWithMethod:BACalculationMethodSingapore];
    } else if ([method isEqualToString:@"Turkey"]) {
        params = [[BACalculationParameters alloc] initWithMethod:BACalculationMethodTurkey];
    } else {
        params = [[BACalculationParameters alloc] initWithMethod:BACalculationMethodOther];
    }
    
    NSString *madhab = dict[@"madhab"];
    
    if ([madhab isEqualToString:@"Shafi"]) {
        params.madhab = BAMadhabShafi;
    } else if ([madhab isEqualToString:@"Hanafi"]) {
        params.madhab = BAMadhabHanafi;
    }
    
    NSString *highLatRule = dict[@"highLatitudeRule"];
    
    if ([highLatRule isEqualToString:@"SeventhOfTheNight"]) {
        params.highLatitudeRule = BAHighLatitudeRuleSeventhOfTheNight;
    } else if ([highLatRule isEqualToString:@"TwilightAngle"]) {
        params.highLatitudeRule = BAHighLatitudeRuleTwilightAngle;
    } else {
        params.highLatitudeRule = BAHighLatitudeRuleMiddleOfTheNight;
    }
    
    return params;
}

- (void)testTimes {
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    for (NSString *path in [bundle pathsForResourcesOfType:@"json" inDirectory:@"Times"]) {
        NSData *data = [NSData dataWithContentsOfFile:path];
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        NSDictionary *params = json[@"params"];
        NSNumber *lat = params[@"latitude"];
        NSNumber *lon = params[@"longitude"];
        NSString *zone = params[@"timezone"];
        NSTimeZone *timezone = [NSTimeZone timeZoneWithName:zone];
        
        BACoordinates *coordinates = [[BACoordinates alloc] initWithLatitude:lat.doubleValue longitude:lon.doubleValue];
        
        NSCalendar *cal = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
        cal.timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"YYYY-MM-dd";
        dateFormatter.timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
        
        NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
        timeFormatter.dateFormat = @"h:mm a";
        timeFormatter.timeZone = timezone;
        
        NSDateFormatter *dateTimeFormatter = [[NSDateFormatter alloc] init];
        dateTimeFormatter.dateFormat = @"YYYY-MM-dd h:mm a";
        dateTimeFormatter.timeZone = timezone;
        
        NSArray *times = json[@"times"];
        double variance = [json[@"variance"] doubleValue];
        NSLog(@"Testing %@ (%lu) days", path, (unsigned long)times.count);
        
        for (NSDictionary *time in times) {
            NSDate *date = [dateFormatter dateFromString:time[@"date"]];
            NSDateComponents *components = [cal components:NSCalendarUnitDay|NSCalendarUnitMonth|NSCalendarUnitYear fromDate:date];
            BAPrayerTimes *prayerTimes = [[BAPrayerTimes alloc] initWithCoordinates:coordinates date:components calculationParameters:[self parseParams:params]];
            NSString *fajrString = [NSString stringWithFormat:@"%@ %@", time[@"date"], time[@"fajr"]];
            NSString *sunriseString = [NSString stringWithFormat:@"%@ %@", time[@"date"], time[@"sunrise"]];
            NSString *dhuhrString = [NSString stringWithFormat:@"%@ %@", time[@"date"], time[@"dhuhr"]];
            NSString *asrString = [NSString stringWithFormat:@"%@ %@", time[@"date"], time[@"asr"]];
            NSString *maghribString = [NSString stringWithFormat:@"%@ %@", time[@"date"], time[@"maghrib"]];
            NSString *ishaString = [NSString stringWithFormat:@"%@ %@", time[@"date"], time[@"isha"]];
            XCTAssertLessThanOrEqual(fabs([prayerTimes.fajr timeIntervalSinceDate:[dateTimeFormatter dateFromString:fajrString]]) / 60, variance);
            XCTAssertLessThanOrEqual(fabs([prayerTimes.sunrise timeIntervalSinceDate:[dateTimeFormatter dateFromString:sunriseString]]) / 60, variance);
            XCTAssertLessThanOrEqual(fabs([prayerTimes.dhuhr timeIntervalSinceDate:[dateTimeFormatter dateFromString:dhuhrString]]) / 60, variance);
            XCTAssertLessThanOrEqual(fabs([prayerTimes.asr timeIntervalSinceDate:[dateTimeFormatter dateFromString:asrString]]) / 60, variance);
            XCTAssertLessThanOrEqual(fabs([prayerTimes.maghrib timeIntervalSinceDate:[dateTimeFormatter dateFromString:maghribString]]) / 60, variance);
            XCTAssertLessThanOrEqual(fabs([prayerTimes.isha timeIntervalSinceDate:[dateTimeFormatter dateFromString:ishaString]]) / 60, variance);
        }
    }
}

@end
