//
//  RepeatRemind.h
//  XMAlarm
//
//  Created by bo.chen on 17/9/10.
//  Copyright © 2017年 com.xmm. All rights reserved.
//

#import "BaseAlarm.h"

/**
 * 周期性提醒
 */
@interface RepeatRemind : BaseAlarm
@property (nonatomic, strong) NSDate *time;//时间，不带日期 H:mm
@property (nonatomic, strong) NSNumber *calendarUnit;
@property (nonatomic, strong) NSNumber *weekday;//周几 1-7
@property (nonatomic, strong) NSNumber *day;//哪一天 1-31
@property (nonatomic, strong) NSNumber *month;//几月 1-12
@property (nonatomic, strong) NSNumber *monthDay;//几号 根据每月的天数来决定范围 2月取29最大天数
- (NSString *)formatRepeatStr;
- (NSDate *)getAlarmDate;
@end
