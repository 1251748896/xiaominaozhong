//
//  ShiftAlarm.h
//  XMAlarm
//
//  Created by bo.chen on 17/9/5.
//  Copyright © 2017年 com.xmm. All rights reserved.
//

#import "BaseAlarm.h"

@interface ShiftAlarm : BaseAlarm
@property (nonatomic, strong) NSDate *startDate;//开始日期
@property (nonatomic, strong) NSNumber *period;//周期 天数
@property (nonatomic, strong) NSArray *workInfos;
@property (nonatomic, strong) NSNumber *sleepTime;//贪睡设置
- (NSString *)formatPeriodStr;
- (NSString *)formatDateStr;

- (void)setupPeriod:(NSInteger)period;
- (BOOL)checkValid;

- (NSDate *)getAlarmDateAndShiftIndex:(NSInteger *)pIndex;

@end

@interface ShiftWorkInfo : BaseModel
@property (nonatomic, strong) NSNumber *index;
@property (nonatomic, strong) NSDate *time;//闹钟时间
@property (nonatomic, strong) NSNumber *needWork;//是否上班
+ (NSArray *)createWorkInfos:(NSInteger)num;
- (NSString *)formatTimeStr;
- (NSString *)formatIndexStr;
@end
