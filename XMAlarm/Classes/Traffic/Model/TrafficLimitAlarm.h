//
//  TrafficLimitAlarm.h
//  XMAlarm
//
//  Created by bo.chen on 17/9/22.
//  Copyright © 2017年 com.xmm. All rights reserved.
//

#import "BaseAlarm.h"
#import "RemindSetting.h"

/**
 * 区域
 */
@interface ChinaDistrict : BaseModel
//{"code":"110000","id":1,"superCode":null,"level":1,"name":"北京","isLeaf":0}
@property (nonatomic, strong) NSString *code;
@property (nonatomic, strong) NSNumber *mid;
@property (nonatomic, strong) NSString *superCode;
@property (nonatomic, strong) NSNumber *level;//1省 2市 3区
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSDate *createTime;
@property (nonatomic, strong) NSDate *updateTime;
@end

/**
 * 限行时段
 */
@interface LimitPeriod : BaseModel
@property (nonatomic, strong) NSDate *time1;//开始时间
@property (nonatomic, strong) NSDate *time2;//结束时间

- (NSString *)formatPeriodStr;

@end

@interface TrafficLimitRule : BaseModel
@property (nonatomic, strong) NSNumber *limitMode;//限行模式
@property (nonatomic, strong) NSDate *shiftStartDate;//轮换开始日期
@property (nonatomic, strong) NSNumber *shiftStartNumber;//轮换开始的尾号
@property (nonatomic, strong) NSNumber *shiftWeeks;//多少周一轮 仅针对模式一 目前是13周

@property (nonatomic, strong) NSNumber *letterRule;//车票尾号为英文的处理方式 1 按某个数字处理 2 取最后一位数字
@property (nonatomic, strong) NSNumber *letterNumber;//当letterRule为1时，英文按哪个数字处理 (0-9)

@property (nonatomic, strong) NSNumber *periodsCount;//1 全天限行 2 早晚限行
@property (nonatomic, strong) NSArray *limitPeriods;//限行时段的数组<time1:开始时间, time2:结束时间>

@property (nonatomic, strong) NSNumber *weekday;//每周几限行 1-7
@property (nonatomic, strong) NSString *daysStr;//每月的多少号  英文逗号连接的字符串
@property (nonatomic, strong) NSNumber *holidayNeedLimit;//节假日和周末是否限行 (只有长春要限行)

@property (nonatomic, strong) NSString *plateNumberPre; //车牌前缀，用于判断是否是外地车
@property (nonatomic, strong) NSNumber *limitOtherCity; // 本地车和外地车b是否相同
@property (nonatomic, strong) NSString *limitTip; //限行提示文案
@property (nonatomic, strong) NSString *otherTip; //比如贵阳本地尾号为字母的不能驶入一环   长春外地车不限行

- (NSString *)formatPeriodStr;

@end

@interface TrafficLimitAlarm : BaseAlarm

@property (nonatomic, strong) ChinaDistrict *city;//城市
@property (nonatomic, strong) NSDate *yearCheckDate;//年检时间
@property (nonatomic, strong) NSString *plateNumber;//车牌号
@property (nonatomic, strong) TrafficLimitRule *limitRule;//限行规则
@property (nonatomic, strong) NSArray *remindSettings;//提醒设置 (RemindSetting)数组
@property (nonatomic, strong) NSNumber *syncAlarm;//是否同步起床闹钟
@property (nonatomic, strong) NSNumber *timeAfterAlarm;//闹钟后几分钟响铃
@property (nonatomic, strong) NSNumber *showState; //

- (void)resetRemindSettings;
- (NSString *)formatShiftEndDateStr;
/**
 @return 返回模式1的城市轮换日;
 例如：2018.7.8北京所有车辆的限行星期整体轮换一次
 
 
 
 */
- (NSDate *)shiftEndDate;
- (NSString *)formatLimitDayStr;
- (NSString *)plateNumberForShow;
/**
 * 是否需要显示外埠
 */
- (BOOL)needShowOtherCity;
- (NSAttributedString *)formatPlateNumberStr;
- (NSAttributedString *)formatPlateNumberStr2;
/**
 * 同步起床闹钟
 */
- (void)syncShiftAlarm;

@end
