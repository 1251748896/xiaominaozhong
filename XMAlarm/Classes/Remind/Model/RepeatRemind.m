//
//  RepeatRemind.m
//  XMAlarm
//
//  Created by bo.chen on 17/9/10.
//  Copyright © 2017年 com.xmm. All rights reserved.
//

#import "RepeatRemind.h"
#import "AlarmManager.h"

@implementation RepeatRemind

- (instancetype)init {
    self = [super init];
    if (self) {
        self.name = @"周期性提醒";
        self.time = [NSDateFormatter dateFromString:@"9:00" formatStr:kTimeFormatStr];
        self.calendarUnit = @(NSCalendarUnitWeekOfYear);
        NSDate *date = [NSDate date];
        self.weekday = @(date.weekday);
        self.day = @(date.day);
        self.month = @(date.month);
        self.monthDay = @(date.day);
        self.ringName = @"黎明旋律.m4r";
    }
    return self;
}

- (NSNumber *)classSortValue {
    return @4;
}

- (NSComparisonResult)inlineCompare:(RepeatRemind *)otherAlarm {
    return NSOrderedSame;
}

+ (NSValueTransformer *)JSONTransformerForKey:(NSString *)key {
    if ([key isEqualToString:@"time"]) {
        return [MTLValueTransformer reversibleTransformerWithForwardBlock:^NSDate *(NSNumber *seconds) {
            return [NSDate dateWithTimeIntervalSince1970:seconds.doubleValue];
        }                                                    reverseBlock:^NSNumber *(NSDate *date) {
            return @(date.timeIntervalSince1970);
        }];
    }
    return [super JSONTransformerForKey:key];
}

- (NSString *)formatAlarmTimeStr {
    return [NSDateFormatter stringFromDate:self.time formatStr:kTimeFormatStr];
}

- (NSString *)formatRepeatStr {
    NSCalendarUnit unit = self.calendarUnit.integerValue;
    if (NSCalendarUnitWeekOfYear == unit) {
        static NSString *strs[] = {@"日", @"一", @"二", @"三", @"四", @"五", @"六"};
        return [NSString stringWithFormat:@"每周%@", strs[self.weekday.integerValue-1]];
    } else if (NSCalendarUnitMonth == unit) {
        return [NSString stringWithFormat:@"每月%@号", self.day];
    } else {
        return [NSString stringWithFormat:@"每年%@月%@号", self.month, self.monthDay];
    }
}

- (NSString *)formatEditTimeStr {
    return [NSString stringWithFormat:@"%@ %@", [self formatRepeatStr], [self formatAlarmTimeStr]];
}

- (NSArray *)formatDataSource {
    NSMutableArray *dataSource = [NSMutableArray array];
    
    NSCalendarUnit unit = self.calendarUnit.integerValue;
    if (NSCalendarUnitWeekOfYear == unit) {
        [dataSource addObject:@{@"cell": @"RepeatWeekdayCell"}];
    } else if (NSCalendarUnitMonth == unit) {
        [dataSource addObject:@{@"cell": @"RepeatMonthCell"}];
    } else {
        [dataSource addObject:@{@"cell": @"RepeatYearCell"}];
    }
    [dataSource addObject:@{@"cell": @"TwoTitleCell", @"data": @{@"title1": @"提醒标题", @"title2": self.name}, @"tag": @(TwoTitleCellTag_Name)}];
    [dataSource addObject:@{@"cell": @"TwoTitleCell", @"data": @{@"title1": @"响铃时间", @"title2": [self formatEditTimeStr]}, @"tag": @(TwoTitleCellTag_RepeatRemindTime)}];
    [dataSource addObject:@{@"cell": @"TwoTitleCell", @"data": @{@"title1": @"铃声选择", @"title2": [[AlarmManager sharedInstance] nameByRingFileName:self.ringName]}, @"tag": @(TwoTitleCellTag_RingName)}];
    
    return dataSource;
}

- (void)addNotification {
    [self addNotification:NO];
}

- (void)addNotification:(BOOL)more {
    //不是添加更多通知时，删除就包括稍后提醒
    NSArray *removedUuids = [self deleteNotification:NO includeLater:!more];
    
    NSMutableArray *logArray = [NSMutableArray array];
    
    NSDate *alarmDate = [self getAlarmDate];
    AlarmLog *alarmLog = [self addAlarmLog:AppNotiType_RepeatRemind fireDate:alarmDate repeat:0];
    if (alarmLog) {
        [logArray addObject:alarmLog];
    }
    
    [self removeNotiAndSaveLog:removedUuids logArray:logArray];
}

- (NSDate *)getAlarmDate {
    NSDate *alarmDate = nil;
    NSDate *nowDate = [NSDate date];
    
    NSCalendarUnit unit = self.calendarUnit.integerValue;
    if (NSCalendarUnitWeekOfYear == unit) {
        do {
            alarmDate = [[[nowDate dateAtStartOfDay] dateByAddingHours:self.time.hour] dateByAddingMinutes:self.time.minute];
            alarmDate = [alarmDate dateBySubtractingDays:alarmDate.weekday-self.weekday.integerValue];
            //判断时间是否已过
            if ([nowDate compare:alarmDate] == NSOrderedAscending) {
                break;
            }
            alarmDate = [alarmDate dateByAddingDays:7];
        } while (0);
    } else if (NSCalendarUnitMonth == unit) {
        do {
            NSInteger maxDay = nowDate.maxDay;
            NSInteger shouldDay = self.day.integerValue;
            if (shouldDay > maxDay) {
                shouldDay = maxDay;
            }
            alarmDate = [[[[nowDate dateAtStartOfMonth] dateByAddingDays:shouldDay-1] dateByAddingHours:self.time.hour] dateByAddingMinutes:self.time.minute];
            //判断时间是否已过
            if ([nowDate compare:alarmDate] == NSOrderedAscending) {
                break;
            }
            
            //找下一个月
            NSDate *nextMonthDate = [nowDate dateByAddingMonths:1];
            maxDay = nextMonthDate.maxDay;
            shouldDay = self.day.integerValue;
            if (shouldDay > maxDay) {
                shouldDay = maxDay;
            }
            alarmDate = [[[[nextMonthDate dateAtStartOfMonth] dateByAddingDays:shouldDay-1] dateByAddingHours:self.time.hour] dateByAddingMinutes:self.time.minute];
        } while (0);
    } else {
        do {
            NSDate *yearDate = [[nowDate dateAtStartOfYear] dateByAddingMonths:self.month.integerValue-1];
            NSInteger maxDay = yearDate.maxDay;
            NSInteger shouldDay = self.monthDay.integerValue;
            if (shouldDay > maxDay) {
                shouldDay = maxDay;
            }
            alarmDate = [[[[yearDate dateAtStartOfMonth] dateByAddingDays:shouldDay-1] dateByAddingHours:self.time.hour] dateByAddingMinutes:self.time.minute];
            //判断时间是否已过
            if ([nowDate compare:alarmDate] == NSOrderedAscending) {
                break;
            }
            
            //找下一个年
            NSDate *nextYearDate = [yearDate dateByAddingYears:1];
            maxDay = nextYearDate.maxDay;
            shouldDay = self.monthDay.integerValue;
            if (shouldDay > maxDay) {
                shouldDay = maxDay;
            }
            alarmDate = [[[[nextYearDate dateAtStartOfMonth] dateByAddingDays:shouldDay-1] dateByAddingHours:self.time.hour] dateByAddingMinutes:self.time.minute];
        } while (0);
    }
    
    return alarmDate;
    
}

@end
