//
//  UILocalNotification+Ext.m
//  XMAlarm
//
//  Created by bo.chen on 17/9/15.
//  Copyright © 2017年 com.xmm. All rights reserved.
//

#import "UILocalNotification+Ext.h"

@implementation UILocalNotification (Ext)

//- (NSTimeInterval)howLongRing:(NSDate *)date {
//    NSDate *nextFireDate = self.fireDate;
//    while (nextFireDate.timeIntervalSince1970 < date.timeIntervalSince1970) {
//        if (self.repeatInterval == NSCalendarUnitWeekOfYear) {
//            nextFireDate = [nextFireDate dateByAddingDays:7];
//        } else if (self.repeatInterval == NSCalendarUnitMonth) {
//            nextFireDate = [nextFireDate dateByAddingMonths:1];
//        } else if (self.repeatInterval == NSCalendarUnitYear) {
//            nextFireDate = [nextFireDate dateByAddingYears:1];
//        } else if (self.repeatInterval == NSCalendarUnitDay) {
//            nextFireDate = [nextFireDate dateByAddingDays:1];
//        } else if (self.repeatInterval == NSCalendarUnitHour) {
//            nextFireDate = [nextFireDate dateByAddingMinutes:60];
//        } else if (self.repeatInterval == NSCalendarUnitMinute) {
//            nextFireDate = [nextFireDate dateByAddingMinutes:1];
//        } else if (self.repeatInterval == NSCalendarUnitSecond) {
//            nextFireDate = [nextFireDate dateByAddingSeconds:1];
//        } else {
//            nextFireDate = date;
//        }
//    }
//    return [nextFireDate timeIntervalSinceDate:date];
//}

@end
