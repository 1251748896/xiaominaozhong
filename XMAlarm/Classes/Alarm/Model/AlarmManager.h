//
//  AlarmManager.h
//  XMAlarm
//
//  Created by bo.chen on 17/9/12.
//  Copyright © 2017年 com.xmm. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RiseAlarm.h"
#import "ShiftAlarm.h"
#import "CustomAlarm.h"
#import "RepeatRemind.h"
#import "TempRemind.h"
#import "Schedule.h"
#import "TrafficLimitAlarm.h"

@class BaseViewController;

@interface AlarmManager : NSObject

@property (nonatomic, assign) BOOL shouldCheckPromitAlert;// 是否展示静音提示的弹窗

+ (instancetype)sharedInstance;
@property (nonatomic, strong) NSMutableDictionary *ringConfigDict;
- (NSString *)nameByRingFileName:(NSString *)fileName;
- (void)refreshAlarmEnabled;
- (void)bindAlarmData;
- (void)stopPlay;
- (void)uploadAlarmNum;
- (void)adjustMoreAlarm;
/**
 * 在节假日和限行规则变化后调整限行闹钟，但不能移除稍后提醒
 */
- (void)adjustLimitAlarm;

- (BOOL)checkDateIsHoliday:(NSDate *)date;
- (void)initHoliday;
- (void)updateHoliday:(ObjectBlock)block;

/**
 * 弹框一天弹一次（第一次设置好闹钟／提醒／限行条目后），如果点击了不再提醒，则不再弹出，app升级后再重复上述逻辑。
 */
- (void)checkDisclaimerAlert;
@end
