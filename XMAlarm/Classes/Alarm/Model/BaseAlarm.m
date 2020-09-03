//
//  BaseAlarm.m
//  XMAlarm
//
//  Created by bo.chen on 17/9/5.
//  Copyright © 2017年 com.xmm. All rights reserved.
//

#import "BaseAlarm.h"

@implementation BaseAlarm

+ (NSArray *)allForUser {
    NSString *whereStr = [NSString stringWithFormat:@" userId is null or userId = '%@'", SSJKString(TheUser.id)];
    
    return [[self class] where:whereStr];
}

- (NSComparisonResult)compare:(BaseAlarm *)otherAlarm {
    NSDate *date = [NSDate date];
    NSTimeInterval time1 = [self howLongRing:date];
    NSTimeInterval time2 = [otherAlarm howLongRing:date];
    if (time1 == 0) {
        //为0 时间已过 排后面
        time1 = kMaxRingTime;
    }
    if (time2 == 0) {
        time2 = kMaxRingTime;
    }
    if (time1 == kMaxRingTime && time2 == kMaxRingTime) {
        if ([self isMemberOfClass:[otherAlarm class]]) {
            //类相同
            return [self inlineCompare:otherAlarm];
        } else {
            return [[self classSortValue] compare:[otherAlarm classSortValue]];
        }
    } else {
        return [@(time1) compare:@(time2)];
    }
}

- (NSNumber *)classSortValue {
    return @0;
}

- (NSComparisonResult)inlineCompare:(BaseAlarm *)otherAlarm {
    return NSOrderedSame;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.serverId = [NSString uuid];
        self.userId = SSJKString(TheUser.id);
        self.createTime = [NSDate date];
        self.updateTime = [NSDate date];
        self.enabled = @(YES);
        self.ringName = @"薄雾清晨.m4r";
    }
    return self;
}

+ (NSValueTransformer *)JSONTransformerForKey:(NSString *)key {
    if ([key isEqualToString:@"createTime"] || [key isEqualToString:@"updateTime"]) {
        return [MTLValueTransformer reversibleTransformerWithForwardBlock:^NSDate *(NSNumber *seconds) {
            return [NSDate dateWithTimeIntervalSince1970:seconds.doubleValue];
        }                                                    reverseBlock:^NSNumber *(NSDate *date) {
            return @(date.timeIntervalSince1970);
        }];
    }
    return [super JSONTransformerForKey:key];
}

- (NSString *)formatAlarmTimeStr {
    return @"";
}

- (NSArray *)formatDataSource {
    return @[];
}

- (void)addNotification {
}

/**
 * more: YES，在添加响铃数据时不会移除稍后提醒那些
 */
- (void)addNotification:(BOOL)more {
}

- (NSArray *)deleteNotification:(BOOL)immediately {
    return [self deleteNotification:immediately includeLater:YES];
}

- (NSArray *)deleteNotification:(BOOL)immediately includeLater:(BOOL)includeLater {
    DEBUG_LOG(@"LocalNotifications = %@", @([UIApplication sharedApplication].scheduledLocalNotifications.count));
    
    NSMutableArray *removedUuids = [NSMutableArray array];
    NSArray *tmp = includeLater ? [self queryAllLog] : [self queryAllLogNotLater];
    NSMutableArray *removedLogArray = [NSMutableArray arrayWithArray:tmp];
    if (!includeLater) {
        //如果是在调整更多闹钟时，不要删除时间已过的闹钟
        NSDate *nowDate = [NSDate date];
        NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
        for (NSInteger i = 0; i < removedLogArray.count; i++) {
            AlarmLog *log = removedLogArray[i];
            if ([log.fireDate compare:nowDate] == NSOrderedAscending) {
                //已过
                [indexSet addIndex:i];
            }
        }
        [removedLogArray removeObjectsAtIndexes:indexSet];
    }
    for (AlarmLog *log in removedLogArray) {
        [removedUuids addObject:log.serverId];
    }
    for (AlarmLog *log in removedLogArray) {
        [log remove];
    }
//    NSString *sqlStr = [NSString stringWithFormat:@"delete from %@ where relateUuid = '%@'%@", [AlarmLog FMDBTableName], self.serverId, includeLater ? @"" : @" and isLaterRemind = 0"];
//    [AlarmLog excuteSql:sqlStr];
    
    if (immediately) {
        NSMutableArray *notiArray = [NSMutableArray arrayWithArray:[UIApplication sharedApplication].scheduledLocalNotifications];
        NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
        for (NSInteger i = 0; i < notiArray.count; i++) {
            UILocalNotification *noti = notiArray[i];
            NSInteger index = [removedUuids indexOfObjectPassingTest:^BOOL(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                return noti.userInfo[@"uuid"] && [noti.userInfo[@"uuid"] isEqualToString:obj];
            }];
            if (index != NSNotFound) {
                [indexSet addIndex:i];
            }
        }
        [notiArray removeObjectsAtIndexes:indexSet];
        [UIApplication sharedApplication].scheduledLocalNotifications = notiArray;
        DEBUG_LOG(@"LocalNotifications = %@", @([UIApplication sharedApplication].scheduledLocalNotifications.count));
    }
    
    return removedUuids;
}

- (NSArray *)queryAllLog {
    return [AlarmLog where:[NSString stringWithFormat:@"relateUuid = '%@'", self.serverId]];
}

- (NSArray *)queryAllLogNotLater {
    return [AlarmLog where:[NSString stringWithFormat:@"relateUuid = '%@' and isLaterRemind = 0", self.serverId]];
}

- (AlarmLog *)addAlarmLog:(AppNotiType)type fireDate:(NSDate *)fireDate repeat:(NSCalendarUnit)interval {
    NSDate *nowDate = [NSDate date];
    //调整fireDate为将来时间
    while (fireDate.timeIntervalSince1970 < nowDate.timeIntervalSince1970) {
        if (interval == NSCalendarUnitWeekOfYear) {
            fireDate = [fireDate dateByAddingDays:7];
        } else if (interval == NSCalendarUnitMonth) {
            fireDate = [fireDate dateByAddingMonths:1];
        } else if (interval == NSCalendarUnitYear) {
            fireDate = [fireDate dateByAddingYears:1];
        } else if (interval == NSCalendarUnitDay) {
            fireDate = [fireDate dateByAddingDays:1];
        } else if (interval == NSCalendarUnitHour) {
            fireDate = [fireDate dateByAddingMinutes:60];
        } else if (interval == NSCalendarUnitMinute) {
            fireDate = [fireDate dateByAddingMinutes:1];
        } else if (interval == NSCalendarUnitSecond) {
            fireDate = [fireDate dateByAddingSeconds:1];
        } else {
            return nil;
        }
    }
    
    //对重复提醒调整后，修改interval为0，以后interval都为0，但是在adjustMoreAlarm里面添加更多
    interval = 0;
    
    //生成AlarmLog
    AlarmLog *alarmLog = [[AlarmLog alloc] init];
    alarmLog.fireDate = fireDate;
    alarmLog.repeatInterval = @(interval);
    alarmLog.alertBody = self.name;
    alarmLog.ringName = self.ringName;
    alarmLog.relateUuid = self.serverId;
    alarmLog.type = @(type);
    return alarmLog;
}

- (void)removeNotiAndSaveLog:(NSArray *)removedUuids logArray:(NSArray *)logArray {
    NSMutableArray *notiArray = [NSMutableArray arrayWithArray:[UIApplication sharedApplication].scheduledLocalNotifications];
    if (removedUuids.count > 0) {
        NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
        for (NSInteger i = 0; i < notiArray.count; i++) {
            UILocalNotification *noti = notiArray[i];
            NSInteger index = [removedUuids indexOfObjectPassingTest:^BOOL(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                return noti.userInfo[@"uuid"] && [noti.userInfo[@"uuid"] isEqualToString:obj];
            }];
            if (index != NSNotFound) {
                [indexSet addIndex:i];
            }
        }
        [notiArray removeObjectsAtIndexes:indexSet];
    }
    
    if (logArray.count > 0) {
        [AlarmLog insertBatchModels:logArray];
        for (AlarmLog *log in logArray) {
            [notiArray addObjectsFromArray:[log createLocalNoti]];
        }
    }
    
    //系统最多支持64个通知，把后添加的丢掉
    [UIApplication sharedApplication].scheduledLocalNotifications = notiArray.count > 64 ? [notiArray subarrayWithRange:NSMakeRange(0, 64)] : notiArray;
    DEBUG_LOG(@"LocalNotifications = %@", @([UIApplication sharedApplication].scheduledLocalNotifications.count));
    if (notiArray.count > 64) {
        AsyncRunAfter(^{
            AlertWarning(@"检测到当前通知数量超过64个，刚才添加的部分通知可能不会响铃");
        }, 0.3);
    }
}

/**
 * 单次闹钟或者提醒都应该检查
 */
- (BOOL)shouldCheckEnabled {
    return NO;
}

- (NSTimeInterval)howLongRing:(NSDate *)date {
    NSTimeInterval howLong = kMaxRingTime;
    
    for (AlarmLog *log in [self queryAllLog]) {
        howLong = MIN(howLong, [log howLongRing:date]);
    }
    return howLong;
}

@end
