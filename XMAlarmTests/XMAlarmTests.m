//
//  XMAlarmTests.m
//  XMAlarmTests
//
//  Created by bo.chen on 17/9/2.
//  Copyright © 2017年 com.xmm. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <Expecta.h>
#import "EnumDefine.h"
#import "SSKModel.h"
#import "SSKModel+JSONSerializing.h"
#import "SSKModel+PersistentStore.h"
#import "SSKModelPersistentStore.h"
#import "NSDate+Category.h"
#import "NSDateFormatter+Category.h"
#import "RiseAlarm.h"
#import "CustomAlarm.h"
#import "ShiftAlarm.h"
#import "RepeatRemind.h"
#import "TempRemind.h"
#import "TrafficLimitAlarm.h"

@interface XMAlarmTests : XCTestCase

@end

@implementation XMAlarmTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

- (void)testMakeDateByYearMonthDay {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [[NSDateComponents alloc] init];
    components.year = 2018;
    components.month = 2;
    components.day = 31;
    NSDate *date = [calendar dateFromComponents:components];
    expect([NSDateFormatter stringFromDate:date formatStr:@"yyyy-MM-dd"]).to.equal(@"2018-02-28");
    NSString *dateStr = @"2018-02-31";
    NSDate *date2 = [NSDateFormatter dateFromString:dateStr formatStr:@"yyyy-MM-dd"];
    expect([NSDateFormatter stringFromDate:date2 formatStr:@"yyyy-MM-dd"]).to.equal(@"2018-02-28");
}

- (void)testMonthMaxDay {
    NSString *dateStr = @"2018-02-01";
    NSDate *date = [NSDateFormatter dateFromString:dateStr formatStr:@"yyyy-MM-dd"];
    NSInteger maxDay = date.maxDay;
    expect(maxDay).to.equal(28);
    dateStr = @"2018-01-01";
    date = [NSDateFormatter dateFromString:dateStr formatStr:@"yyyy-MM-dd"];
    maxDay = date.maxDay;
    expect(maxDay).to.equal(31);
    dateStr = @"2018-03-01";
    date = [NSDateFormatter dateFromString:dateStr formatStr:@"yyyy-MM-dd"];
    maxDay = date.maxDay;
    expect(maxDay).to.equal(31);
    dateStr = @"2018-04-01";
    date = [NSDateFormatter dateFromString:dateStr formatStr:@"yyyy-MM-dd"];
    maxDay = date.maxDay;
    expect(maxDay).to.equal(30);
    dateStr = @"2016-02-01";
    date = [NSDateFormatter dateFromString:dateStr formatStr:@"yyyy-MM-dd"];
    maxDay = date.maxDay;
    expect(maxDay).to.equal(29);
}

- (void)testDateAtStartOfYear {
    NSString *dateStr = @"2018-02-01";
    NSDate *date = [NSDateFormatter dateFromString:dateStr formatStr:@"yyyy-MM-dd"];
    date = [date dateAtStartOfYear];
    expect([NSDateFormatter stringFromDate:date formatStr:@"yyyy-MM-dd"]).to.equal(@"2018-01-01");
}

- (void)testDateAtStartOfMonth {
    NSString *dateStr = @"2018-02-28";
    NSDate *date = [NSDateFormatter dateFromString:dateStr formatStr:@"yyyy-MM-dd"];
    date = [date dateAtStartOfMonth];
    expect([NSDateFormatter stringFromDate:date formatStr:@"yyyy-MM-dd"]).to.equal(@"2018-02-01");
    dateStr = @"2018-03-31";
    date = [NSDateFormatter dateFromString:dateStr formatStr:@"yyyy-MM-dd"];
    date = [date dateAtStartOfMonth];
    expect([NSDateFormatter stringFromDate:date formatStr:@"yyyy-MM-dd"]).to.equal(@"2018-03-01");
    dateStr = @"2018-11-28";
    date = [NSDateFormatter dateFromString:dateStr formatStr:@"yyyy-MM-dd"];
    date = [date dateAtStartOfMonth];
    expect([NSDateFormatter stringFromDate:date formatStr:@"yyyy-MM-dd"]).to.equal(@"2018-11-01");
}

- (void)testRepeatRemindAlarmDateWeekday {
    RepeatRemind *repeatRemind = [[RepeatRemind alloc] init];
    repeatRemind.calendarUnit = @(NSCalendarUnitWeekOfYear);
    repeatRemind.weekday = @1;//周日
    NSDate *alarmDate = [repeatRemind getAlarmDate];
    expect([NSDateFormatter stringFromDate:alarmDate formatStr:@"yyyy-MM-dd HH:mm"]).to.equal(@"2018-01-21 09:00");
    repeatRemind.weekday = @4;//周日
    alarmDate = [repeatRemind getAlarmDate];
    expect([NSDateFormatter stringFromDate:alarmDate formatStr:@"yyyy-MM-dd HH:mm"]).to.equal(@"2018-01-17 09:00");
}

- (void)testRepeatRemindAlarmDateMonth {
    RepeatRemind *repeatRemind = [[RepeatRemind alloc] init];
    repeatRemind.calendarUnit = @(NSCalendarUnitMonth);
    repeatRemind.day = @31;
    NSDate *alarmDate = [repeatRemind getAlarmDate];
    expect([NSDateFormatter stringFromDate:alarmDate formatStr:@"yyyy-MM-dd HH:mm"]).to.equal(@"2019-02-28 09:00");
}

- (void)testRepeatRemindAlarmDateYear {
    RepeatRemind *repeatRemind = [[RepeatRemind alloc] init];
    repeatRemind.calendarUnit = @(NSCalendarUnitYear);
    repeatRemind.month = @2;
    repeatRemind.monthDay = @29;
    NSDate *alarmDate = [repeatRemind getAlarmDate];
    expect([NSDateFormatter stringFromDate:alarmDate formatStr:@"yyyy-MM-dd HH:mm"]).to.equal(@"2018-02-28 09:00");
}

- (void)testShiftAlarm {
    ShiftAlarm *shiftAlarm = [[ShiftAlarm alloc] init];
    shiftAlarm.startDate = [NSDateFormatter dateFromString:@"2018-01-16" formatStr:@"yyyy-MM-dd"];
    NSInteger index = 0;
    NSDate *alarmDate = [shiftAlarm getAlarmDateAndShiftIndex:&index];
    expect([NSDateFormatter stringFromDate:alarmDate formatStr:@"yyyy-MM-dd HH:mm"]).to.equal(@"2018-01-17 09:00");
    expect(index).to.equal(1);
}

- (void)testRiseAlarm {
    RiseAlarm *riseAlarm = [[RiseAlarm alloc] init];
    NSDate *alarmDate = [riseAlarm getAlarmDate];
    expect([NSDateFormatter stringFromDate:alarmDate formatStr:@"yyyy-MM-dd HH:mm"]).to.equal(@"2018-01-17 07:30");
}

@end
