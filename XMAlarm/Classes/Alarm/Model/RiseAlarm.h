//
//  RiseAlarm.h
//  XMAlarm
//
//  Created by bo.chen on 17/9/5.
//  Copyright © 2017年 com.xmm. All rights reserved.
//

#import "BaseAlarm.h"

@interface RiseAlarm : BaseAlarm
@property (nonatomic, strong) NSDate *time;//时间，不带日期 H:mm
@property (nonatomic, strong) NSArray *repeatArray;//[@1, @3, @7] 表示选中星期日 二 六
@property (nonatomic, strong) NSNumber *sleepTime;//贪睡设置

- (NSString *)formatRepeatStr;
- (NSDate *)getAlarmDate;

@end
