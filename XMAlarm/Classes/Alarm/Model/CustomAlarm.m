//
//  CustomAlarm.m
//  XMAlarm
//
//  Created by bo.chen on 17/9/5.
//  Copyright © 2017年 com.xmm. All rights reserved.
//

#import "CustomAlarm.h"
#import "AlarmManager.h"

@implementation CustomAlarm

- (instancetype)init {
    self = [super init];
    if (self) {
        self.name = @"自定义闹钟";
        self.sleepTime = @5;//5分钟
        NSDate *date = [NSDate date];
        self.datetime = [[date dateBySubtractingSeconds:date.seconds] dateByAddingMinutes:1];
        self.ringName = @"薄雾清晨.m4r";
    }
    return self;
}

- (NSNumber *)classSortValue {
    return @3;
}

- (NSComparisonResult)inlineCompare:(CustomAlarm *)otherAlarm {
    return [self.datetime compareIgnoringDate:otherAlarm.datetime];
}

+ (NSValueTransformer *)JSONTransformerForKey:(NSString *)key {
    if ([key isEqualToString:@"datetime"]) {
        return [MTLValueTransformer reversibleTransformerWithForwardBlock:^NSDate *(NSNumber *seconds) {
            return [NSDate dateWithTimeIntervalSince1970:seconds.doubleValue];
        }                                                    reverseBlock:^NSNumber *(NSDate *date) {
            return @(date.timeIntervalSince1970);
        }];
    }
    return [super JSONTransformerForKey:key];
}

- (NSString *)formatAlarmTimeStr {
    return [NSDateFormatter stringFromDate:self.datetime formatStr:kTimeFormatStr];
}

- (NSString *)formatDateStr {
    return [NSDateFormatter stringFromDate:self.datetime formatStr:kDateFormatStr];
}

- (NSArray *)formatDataSource {
    NSMutableArray *dataSource = [NSMutableArray array];
    
    [dataSource addObject:@{@"cell": @"AlarmTimeCell", @"data": self.datetime}];
    [dataSource addObject:@{@"cell": @"TwoTitleCell", @"data": @{@"title1": @"闹钟名", @"title2": self.name}, @"tag": @(TwoTitleCellTag_Name)}];
    [dataSource addObject:@{@"cell": @"TwoTitleCell", @"data": @{@"title1": @"响铃日期", @"title2": [self formatDateStr]}, @"tag": @(TwoTitleCellTag_CustomAlarmDate)}];
    [dataSource addObject:@{@"cell": @"TwoTitleCell", @"data": @{@"title1": @"贪睡设置", @"title2": [NSString stringWithFormat:@"%@分钟", self.sleepTime]}, @"tag": @(TwoTitleCellTag_RiseAlarmSleep)}];
    [dataSource addObject:@{@"cell": @"TwoTitleCell", @"data": @{@"title1": @"铃声选择", @"title2": [[AlarmManager sharedInstance] nameByRingFileName:self.ringName]}, @"tag": @(TwoTitleCellTag_RingName)}];
    
    return dataSource;
}

- (void)addNotification {
    NSArray *removedUuids = [self deleteNotification:NO];
    
    NSMutableArray *logArray = [NSMutableArray array];
    AlarmLog *alarmLog = [self addAlarmLog:AppNotiType_CustomAlarm fireDate:self.datetime repeat:0];
    if (alarmLog) {
        [logArray addObject:alarmLog];
    }
    [self removeNotiAndSaveLog:removedUuids logArray:logArray];
}

- (BOOL)shouldCheckEnabled {
    return YES;
}

@end
