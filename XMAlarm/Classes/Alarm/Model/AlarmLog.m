//
//  AlarmLog.m
//  XMAlarm
//
//  Created by bo.chen on 17/10/30.
//  Copyright © 2017年 com.xmm. All rights reserved.
//

#import "AlarmLog.h"
#import "VoicePlayer.h"

@implementation AlarmLog

- (instancetype)init {
    self = [super init];
    if (self) {
        self.serverId = [NSString uuid];
        self.isLaterRemind = @NO;
    }
    return self;
}

+ (NSValueTransformer *)JSONTransformerForKey:(NSString *)key {
    if ([key isEqualToString:@"fireDate"]) {
        return [MTLValueTransformer reversibleTransformerWithForwardBlock:^NSDate *(NSNumber *seconds) {
            return [NSDate dateWithTimeIntervalSince1970:seconds.doubleValue];
        }                                                    reverseBlock:^NSNumber *(NSDate *date) {
            return @(date.timeIntervalSince1970);
        }];
    }
    return [super JSONTransformerForKey:key];
}

- (NSTimeInterval)howLongRing:(NSDate *)date {
    NSDate *nextFireDate = self.fireDate;
    NSCalendarUnit interval = self.repeatInterval.integerValue;
    while (nextFireDate.timeIntervalSince1970 < date.timeIntervalSince1970) {
        if (interval == NSCalendarUnitWeekOfYear) {
            nextFireDate = [nextFireDate dateByAddingDays:7];
        } else if (interval == NSCalendarUnitMonth) {
            nextFireDate = [nextFireDate dateByAddingMonths:1];
        } else if (interval == NSCalendarUnitYear) {
            nextFireDate = [nextFireDate dateByAddingYears:1];
        } else if (interval == NSCalendarUnitDay) {
            nextFireDate = [nextFireDate dateByAddingDays:1];
        } else if (interval == NSCalendarUnitHour) {
            nextFireDate = [nextFireDate dateByAddingMinutes:60];
        } else if (interval == NSCalendarUnitMinute) {
            nextFireDate = [nextFireDate dateByAddingMinutes:1];
        } else if (interval == NSCalendarUnitSecond) {
            nextFireDate = [nextFireDate dateByAddingSeconds:1];
        } else {
            nextFireDate = date;
        }
    }
    return [nextFireDate timeIntervalSinceDate:date];
}

- (void)ring {
    if (![self.ringName isEqualToString:DontRingName]) {
        [[VoicePlayer sharedInstance] stop];
#ifdef UseBundleRing
        NSURL *fileUrl = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:self.ringName ofType:@""]];
#else
        NSURL *fileUrl = [[NSURL URLWithString:@"file:///Library/Ringtones/"] URLByAppendingPathComponent:self.ringName];
#endif
        [[VoicePlayer sharedInstance] playUrl:fileUrl loops:-1];
    }
}

- (NSArray *)createLocalNoti {
    AppNotiType type = self.type.integerValue;
    NSInteger interval = self.repeatInterval.integerValue;
    NSInteger repeatNum = interval == 0 ? 2 : 2;
    NSInteger offset = interval == 0 ? 30 : 5*60;
    
    NSMutableArray *notiArray = [NSMutableArray array];
    for (NSInteger i = 0; i < repeatNum; i++) {
        UILocalNotification *noti = [[UILocalNotification alloc] init];
        noti.userInfo = @{@"uuid": self.serverId};
        noti.fireDate = [self.fireDate dateByAddingSeconds:offset*i];
        noti.alertBody = self.alertBody;
        noti.soundName = self.ringName;
        noti.repeatInterval = interval == 0 ? NSCalendarUnitMinute : interval;
        noti.applicationIconBadgeNumber = 1;
        [notiArray addObject:noti];
    }
    return notiArray;
}

- (void)removeNotification {
    NSMutableArray *notis = [NSMutableArray arrayWithArray:[UIApplication sharedApplication].scheduledLocalNotifications];
    NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
    for (NSInteger i = 0; i < notis.count; i++) {
        UILocalNotification *noti = notis[i];
        if ([noti.userInfo[@"uuid"] isEqualToString:self.serverId]) {
            [indexSet addIndex:i];
        }
    }
    [notis removeObjectsAtIndexes:indexSet];
    [UIApplication sharedApplication].scheduledLocalNotifications = notis;
    DEBUG_LOG(@"LocalNotifications = %@", @([UIApplication sharedApplication].scheduledLocalNotifications.count));
}

- (void)refreshNotification {
    NSMutableArray *notiArray = [NSMutableArray arrayWithArray:[UIApplication sharedApplication].scheduledLocalNotifications];
    NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
    for (NSInteger i = 0; i < notiArray.count; i++) {
        UILocalNotification *noti = notiArray[i];
        if ([noti.userInfo[@"uuid"] isEqualToString:self.serverId]) {
            [indexSet addIndex:i];
        }
    }
    [notiArray removeObjectsAtIndexes:indexSet];
    
    [notiArray addObjectsFromArray:[self createLocalNoti]];
    
    //系统最多支持64个通知，把后添加的丢掉
    [UIApplication sharedApplication].scheduledLocalNotifications = notiArray.count > 64 ? [notiArray subarrayWithRange:NSMakeRange(0, 64)] : notiArray;
    DEBUG_LOG(@"LocalNotifications = %@", @([UIApplication sharedApplication].scheduledLocalNotifications.count));
    if (notiArray.count > 64) {
        AsyncRunAfter(^{
            AlertWarning(@"检测到当前通知数量超过64个，刚才添加的部分通知可能不会响铃");
        }, 0.3);
    }
}

@end
