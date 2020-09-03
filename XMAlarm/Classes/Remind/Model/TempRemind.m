//
//  TempRemind.m
//  XMAlarm
//
//  Created by bo.chen on 17/9/10.
//  Copyright © 2017年 com.xmm. All rights reserved.
//

#import "TempRemind.h"
#import "AlarmManager.h"

@implementation TempRemind

- (instancetype)init {
    self = [super init];
    if (self) {
        self.name = @"临时提醒";
        NSDate *date = [NSDate date];
        self.datetime = [[date dateBySubtractingSeconds:date.seconds] dateByAddingMinutes:1];
        self.ringName = @"破晓之音.m4r";
    }
    return self;
}

- (NSNumber *)classSortValue {
    return @5;
}

- (NSComparisonResult)inlineCompare:(TempRemind *)otherAlarm {
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

- (NSString *)formatEditTimeStr {
    return [NSDateFormatter stringFromDate:self.datetime formatStr:@"yyyy年M月d日 HH:mm"];
}

- (NSArray *)formatDataSource {
    NSMutableArray *dataSource = [NSMutableArray array];
    
    [dataSource addObject:@{@"cell": @"AlarmTimeCell", @"data": self.datetime}];
    [dataSource addObject:@{@"cell": @"TwoTitleCell", @"data": @{@"title1": @"提醒标题", @"title2": self.name}, @"tag": @(TwoTitleCellTag_Name)}];
    [dataSource addObject:@{@"cell": @"TwoTitleCell", @"data": @{@"title1": @"提醒日期", @"title2": [self formatDateStr]}, @"tag": @(TwoTitleCellTag_CustomAlarmDate)}];
    [dataSource addObject:@{@"cell": @"TwoTitleCell", @"data": @{@"title1": @"铃声选择", @"title2": [[AlarmManager sharedInstance] nameByRingFileName:self.ringName]}, @"tag": @(TwoTitleCellTag_RingName)}];
    
    return dataSource;
}

- (void)addNotification {
    NSArray *removedUuids = [self deleteNotification:NO];
    
    NSMutableArray *logArray = [NSMutableArray array];
    AlarmLog *alarmLog = [self addAlarmLog:AppNotiType_TempRemind fireDate:self.datetime repeat:0];
    if (alarmLog) {
        [logArray addObject:alarmLog];
    }
    [self removeNotiAndSaveLog:removedUuids logArray:logArray];
}

- (BOOL)shouldCheckEnabled {
    return YES;
}

@end
