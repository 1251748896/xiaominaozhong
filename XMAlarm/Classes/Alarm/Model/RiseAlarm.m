//
//  RiseAlarm.m
//  XMAlarm
//
//  Created by bo.chen on 17/9/5.
//  Copyright © 2017年 com.xmm. All rights reserved.
//

#import "RiseAlarm.h"
#import "AlarmManager.h"

@implementation RiseAlarm

- (instancetype)init {
    self = [super init];
    if (self) {
        self.name = @"起床闹钟";
        self.time = [NSDateFormatter dateFromString:@"7:30" formatStr:kTimeFormatStr];
        self.repeatArray = @[@2, @3, @4, @5, @6];//默认工作日
        self.sleepTime = @5;//5分钟
        self.ringName = @"竹林鸟语.m4r";
    }
    return self;
}

- (NSNumber *)classSortValue {
    return @1;
}

- (NSComparisonResult)inlineCompare:(RiseAlarm *)otherAlarm {
    return [self.time compareIgnoringDate:otherAlarm.time];
}

- (id)copyWithZone:(NSZone *)zone {
    //copy数组里面的每个元素
    NSArray *repeatArray = [self.repeatArray copySelfAndElement];
    
    //需要先移除字典里的数组元素，然后在通过initWithDictionary来创建对象，不然在32位机器上会出现内存错误
    NSDictionary *newDict = [self.dictionaryValue removeArrayValues];
    
    RiseAlarm *newObj = [[self.class allocWithZone:zone] initWithDictionary:newDict error:NULL];
    newObj.repeatArray = repeatArray;
    
    //对象需要copy
    
    return newObj;
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

+ (NSValueTransformer *)repeatArrayFMDBTransformer {
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^NSArray *(NSData *data) {
        return [data objectFromJSONData_JSONKit];
    } reverseBlock:^NSData *(NSArray *array) {
        return [array JSONData_JSONKit];
    }];
}

- (NSString *)formatAlarmTimeStr {
    return [NSDateFormatter stringFromDate:self.time formatStr:kTimeFormatStr];
}

- (NSString *)formatRepeatStr {
    NSArray *days = @[@"星期日", @"星期一", @"星期二", @"星期三", @"星期四", @"星期五", @"星期六"];
    
    if (self.repeatArray.count == 0) {
        return @"只响一次";
    }
    
    //只有 周一 到 周五  如果都为 “工作日”
    //只有 周六 到 周日  如果都为 “周末”
    //  全部         “每天”
    //都没有        仅一次
    
    BOOL allDay = YES;
    for (int i = 1; i <= 7; i++) {
        NSInteger index = [self.repeatArray indexOfObject:@(i)];
        if (index == NSNotFound) {
            allDay = NO;
            break;
        }
    }
    if (allDay) return @"每天";
    
    NSMutableArray *converDay = [NSMutableArray array];
    
    //处理工作日
    BOOL allWorkDay = YES;
    for (int i = 2; i <= 6; i++) {
        NSInteger index = [self.repeatArray indexOfObject:@(i)];
        if (index == NSNotFound) {
            allWorkDay = NO;
            break;
        }
    }
    if (allWorkDay) {
        [converDay addObject:@"工作日"];
    } else {
        for (int i = 2; i <= 6; i++) {
            NSInteger index = [self.repeatArray indexOfObject:@(i)];
            if (index != NSNotFound) {
                [converDay addObject:days[i-1]];
            }
        }
    }
    
    //处理周末
    BOOL weekend = YES;
    do {
        NSInteger index = [self.repeatArray indexOfObject:@1];
        if (index == NSNotFound) {
            weekend = NO;
            break;
        }
        
        index = [self.repeatArray indexOfObject:@7];
        if (index == NSNotFound) {
            weekend = NO;
            break;
        }
    } while (0);
    
    if (weekend) {
        [converDay addObject:@"周末"];
    } else {
        NSInteger index = [self.repeatArray indexOfObject:@1];
        if (index != NSNotFound) {
            //找到周日
            [converDay addObject:days[0]];
        }
        
        index = [self.repeatArray indexOfObject:@7];
        if (index != NSNotFound) {
            //找到周六
            [converDay addObject:days[6]];
        }
    }
    
    return [converDay componentsJoinedByString:@","];
}

- (NSArray *)formatDataSource {
    NSMutableArray *dataSource = [NSMutableArray array];
    
    [dataSource addObject:@{@"cell": @"AlarmTimeCell", @"data": self.time}];
    [dataSource addObject:@{@"cell": @"TwoTitleCell", @"data": @{@"title1": @"闹钟名", @"title2": self.name}, @"tag": @(TwoTitleCellTag_Name)}];
    [dataSource addObject:@{@"cell": @"TwoTitleCell", @"data": @{@"title1": @"响铃周期", @"title2": [self formatRepeatStr]}, @"tag": @(TwoTitleCellTag_RiseAlarmPeriod)}];
    [dataSource addObject:@{@"cell": @"TwoTitleCell", @"data": @{@"title1": @"贪睡设置", @"title2": [NSString stringWithFormat:@"%@分钟", self.sleepTime]}, @"tag": @(TwoTitleCellTag_RiseAlarmSleep)}];
    [dataSource addObject:@{@"cell": @"TwoTitleCell", @"data": @{@"title1": @"铃声选择", @"title2": [[AlarmManager sharedInstance] nameByRingFileName:self.ringName]}, @"tag": @(TwoTitleCellTag_RingName)}];
    
    return dataSource;
}

- (void)addNotification {
    [self addNotification:NO];
}

- (void)addNotification:(BOOL)more {
    //单次不需要添加更多
    if (0 == self.repeatArray.count && more) {
        return;
    }
    //不是添加更多通知时，删除就包括稍后提醒
    NSArray *removedUuids = [self deleteNotification:NO includeLater:!more];
    
    NSMutableArray *logArray = [NSMutableArray array];
    
    NSDate *alarmDate = [self getAlarmDate];
    AlarmLog *alarmLog = [self addAlarmLog:AppNotiType_RiseAlarm fireDate:alarmDate repeat:0];
    if (alarmLog) {
        [logArray addObject:alarmLog];
    }
    
    [self removeNotiAndSaveLog:removedUuids logArray:logArray];
}

- (NSDate *)getAlarmDate {
    NSDate *alarmDate = nil;
    
    NSDate *nowDate = [NSDate date];
    NSDate *baseDate = [[[nowDate dateAtStartOfDay] dateByAddingHours:self.time.hour] dateByAddingMinutes:self.time.minute];
    if (0 == self.repeatArray.count) {
        alarmDate = baseDate;
        if ([alarmDate compare:nowDate] == NSOrderedAscending) {
            //响铃已过，加一天
            alarmDate = [alarmDate dateByAddingDays:1];
        }
    } else {
        for (NSNumber *num in self.repeatArray) {
            NSDate *tmpDate = [baseDate dateBySubtractingDays:baseDate.weekday-num.integerValue];
            if ([tmpDate compare:nowDate] == NSOrderedAscending) {
                //时间已过加7天
                tmpDate = [tmpDate dateByAddingDays:7];
            }
            
            if (!alarmDate) {
                alarmDate = tmpDate;
            } else if (tmpDate.timeIntervalSince1970 < alarmDate.timeIntervalSince1970) {
                alarmDate = tmpDate;
            }
        }
    }
    
    return alarmDate;
}

- (BOOL)shouldCheckEnabled {
    return 0 == self.repeatArray.count;
}

@end
