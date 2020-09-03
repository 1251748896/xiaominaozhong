//
//  TrafficLimitAlarm.m
//  XMAlarm
//
//  Created by bo.chen on 17/9/22.
//  Copyright © 2017年 com.xmm. All rights reserved.
//

#import "TrafficLimitAlarm.h"
#import "AlarmManager.h"

#define kSpliterStr @","

@implementation ChinaDistrict

+ (NSValueTransformer *)JSONTransformerForKey:(NSString *)key {
    if ([key isEqualToString:@"createTime"] || [key isEqualToString:@"updateTime"]) {
        return [MTLValueTransformer reversibleTransformerWithForwardBlock:^NSDate *(NSNumber *seconds) {
            return [NSDate dateWithTimeIntervalSince1970:seconds.doubleValue/1000];
        }                                                    reverseBlock:^NSNumber *(NSDate *date) {
            return @(date.timeIntervalSince1970*1000);
        }];
    }
    return [super JSONTransformerForKey:key];
}

@end

@implementation LimitPeriod

- (instancetype)init {
    self = [super init];
    if (self) {
        self.time1 = [NSDateFormatter dateFromString:@"7:30" formatStr:kTimeFormatStr];
        self.time2 = [NSDateFormatter dateFromString:@"19:30" formatStr:kTimeFormatStr];
    }
    return self;
}

+ (NSValueTransformer *)JSONTransformerForKey:(NSString *)key {
    if ([key isEqualToString:@"time1"] || [key isEqualToString:@"time2"]) {
        return [MTLValueTransformer reversibleTransformerWithForwardBlock:^NSDate *(NSNumber *seconds) {
            return [NSDate dateWithTimeIntervalSince1970:seconds.doubleValue/1000];
        }                                                    reverseBlock:^NSNumber *(NSDate *date) {
            return @(date.timeIntervalSince1970*1000);
        }];
    }
    return [super JSONTransformerForKey:key];
}

- (NSString *)formatPeriodStr {
    return [NSString stringWithFormat:@"%@-%@", [NSDateFormatter stringFromDate:self.time1 formatStr:kTimeFormatStr], [NSDateFormatter stringFromDate:self.time2 formatStr:kTimeFormatStr]];
}

@end

@implementation TrafficLimitRule

- (id)copyWithZone:(NSZone *)zone {
    //copy数组里面的每个元素
    NSArray *limitPeriods = [self.limitPeriods copySelfAndElement];
    
    //需要先移除字典里的数组元素，然后在通过initWithDictionary来创建对象，不然在32位机器上会出现内存错误
    NSDictionary *newDict = [self.dictionaryValue removeArrayValues];
    
    TrafficLimitRule *newObj = [[self.class allocWithZone:zone] initWithDictionary:newDict error:NULL];
    newObj.limitPeriods = limitPeriods;
    
    //对象需要copy
    
    return newObj;
}

+ (NSValueTransformer *)JSONTransformerForKey:(NSString *)key {
    if ([key isEqualToString:@"shiftStartDate"]) {
        return [MTLValueTransformer reversibleTransformerWithForwardBlock:^NSDate *(NSNumber *seconds) {
            return [NSDate dateWithTimeIntervalSince1970:seconds.doubleValue/1000];
        }                                                    reverseBlock:^NSNumber *(NSDate *date) {
            return @(date.timeIntervalSince1970*1000);
        }];
    }
    return [super JSONTransformerForKey:key];
}

+ (NSValueTransformer *)limitPeriodsJSONTransformer {
    return [NSValueTransformer mtl_JSONArrayTransformerWithModelClass:[LimitPeriod class]];
}

+ (NSValueTransformer *)limitPeriodsFMDBTransformer {
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^NSArray *(NSData *data) {
        return [LimitPeriod modelsFromJSONArray:[data objectFromJSONData_JSONKit]];
    } reverseBlock:^NSData *(NSArray *array) {
        return [[LimitPeriod JSONArrayFromModels:array] JSONData_JSONKit];
    }];
}

- (NSString *)formatPeriodStr {
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:self.periodsCount.integerValue];
    for (NSInteger i = 0; i < self.periodsCount.integerValue; i++) {
        LimitPeriod *period = safeGetArrayObject(self.limitPeriods, i);
        if (period) {
            [array addObject:[period formatPeriodStr]];
        }
    }
    return [array componentsJoinedByString:@"\n"];
}

@end

@implementation TrafficLimitAlarm

- (NSNumber *)classSortValue {
    return @6;
}

- (NSComparisonResult)inlineCompare:(TrafficLimitAlarm *)otherAlarm {
    return NSOrderedSame;
}

- (id)copyWithZone:(NSZone *)zone {
    //copy数组里面的每个元素
    NSArray *remindSettings = [self.remindSettings copySelfAndElement];
    
    //需要先移除字典里的数组元素，然后在通过initWithDictionary来创建对象，不然在32位机器上会出现内存错误
    NSDictionary *newDict = [self.dictionaryValue removeArrayValues];
    
    TrafficLimitAlarm *newObj = [[self.class allocWithZone:zone] initWithDictionary:newDict error:NULL];
    newObj.remindSettings = remindSettings;
    
    //对象需要copy
    newObj.city = [self.city copy];
    newObj.limitRule = [self.limitRule copy];
    
    return newObj;
}

+ (NSValueTransformer *)cityJSONTransformer {
    return [NSValueTransformer mtl_JSONDictionaryTransformerWithModelClass:[ChinaDistrict class]];
}

+ (NSValueTransformer *)cityFMDBTransformer {
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^ChinaDistrict *(NSData *data) {
        return [ChinaDistrict modelFromJSONDictionary:[data objectFromJSONData_JSONKit]];
    } reverseBlock:^NSData *(ChinaDistrict *city) {
        return [[city JSONDictionary] JSONData_JSONKit];
    }];
}

+ (NSValueTransformer *)limitRuleJSONTransformer {
    return [NSValueTransformer mtl_JSONDictionaryTransformerWithModelClass:[TrafficLimitRule class]];
}

+ (NSValueTransformer *)limitRuleFMDBTransformer {
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^TrafficLimitRule *(NSData *data) {
        return [TrafficLimitRule modelFromJSONDictionary:[data objectFromJSONData_JSONKit]];
    } reverseBlock:^NSData *(TrafficLimitRule *limitRule) {
        return [[limitRule JSONDictionary] JSONData_JSONKit];
    }];
}

+ (NSValueTransformer *)remindSettingsJSONTransformer {
    return [NSValueTransformer mtl_JSONArrayTransformerWithModelClass:[RemindSetting class]];
}

+ (NSValueTransformer *)remindSettingsFMDBTransformer {
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^NSArray *(NSData *data) {
        return [RemindSetting modelsFromJSONArray:[data objectFromJSONData_JSONKit]];
    } reverseBlock:^NSData *(NSArray *array) {
        return [[RemindSetting JSONArrayFromModels:array] JSONData_JSONKit];
    }];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.name = @"限行提醒";
        self.syncAlarm = @YES;
        self.timeAfterAlarm = @10;
        self.plateNumber = @"";
        /* 限行的提醒设置为响铃1次，默认时间为对应的城市当日限行时段开始时间前20分钟
        {
            RemindSetting *setting1 = [[RemindSetting alloc] init];
            setting1.preDay = @1;
            setting1.time = [NSDateFormatter dateFromString:@"22:00" formatStr:kTimeFormatStr];
            
            RemindSetting *setting2 = [[RemindSetting alloc] init];
            setting2.time = [NSDateFormatter dateFromString:@"6:50" formatStr:kTimeFormatStr];
            
            self.remindSettings = @[setting1, setting2];
        }
         */
        self.ringName = @"初醒天籁.m4r";
    }
    return self;
}

- (void)resetRemindSettings {
    //限行的提醒设置为响铃1次，默认时间为对应的城市当日限行时段开始时间前20分钟
    if (!self.limitRule) {
        return;
    }
    LimitPeriod *firstPeriod = [self.limitRule.limitPeriods firstObject];
    
    RemindSetting *setting1 = [[RemindSetting alloc] init];
    setting1.time = [firstPeriod.time1 dateBySubtractingMinutes:20];
    self.remindSettings = @[setting1];
}

- (NSString *)timeStringWithDate:(NSDate *)date {
    NSDateFormatter *matter = [[NSDateFormatter alloc] init];
    matter.dateFormat = @"yyyy-MM-dd";
    matter.dateStyle = NSDateFormatterMediumStyle;
    [matter setLocale:[NSLocale currentLocale]];
    NSString *time = [matter stringFromDate:date];
    return time;
}

- (NSArray *)formatDataSource {
    [self updateLimitDay];
    
    NSMutableArray *dataSource = [NSMutableArray array];
    
    [dataSource addObject:@{@"cell": @"AsyncDataCell"}];
    NSString *yearCheckDate = [self timeStringWithDate:self.yearCheckDate];
    [dataSource addObject:@{@"cell": @"TwoTitleCell", @"data": @{@"title1": @"车辆注册日期", @"title2": yearCheckDate}, @"tag": @(TwoTitleCellTag_yearCheckDate)}];
    [dataSource addObject:@{@"cell": @"TwoTitleCell", @"data": @{@"title1": @"限行城市", @"title2": self.city.name}, @"tag": @(TwoTitleCellTag_City)}];
    [dataSource addObject:@{@"cell": @"TwoTitleCell", @"data": @{@"title1": @"限行车牌", @"title2": [self formatPlateNumberStr]}, @"tag": @(TwoTitleCellTag_PlateNumber)}];
    [dataSource addObject:@{@"cell": @"TwoTitleCell", @"data": @{@"title1": @"限行时段", @"title2": [self.limitRule formatPeriodStr], @"hideArrow": @YES}}];
    NSString *infoStr = @"";
    if ([self needShowOtherCity] && self.limitRule.limitMode.integerValue == 1) {
        infoStr = @"其它工作日早晚高峰限行";
    } else if (self.city.mid.integerValue == 2929) {
        //兰州
        infoStr = @"(自动跳过节假日)";
    }
    [dataSource addObject:@{@"cell": @"TrafficLimitDayCell", @"data": @{@"title1": @"限行日", @"title2": [self formatLimitDayStr], @"info": infoStr, @"hideArrow": @YES}}];
    if (1 == self.limitRule.limitMode.integerValue) {
        [dataSource addObject:@{@"cell": @"TwoTitleCell", @"data": @{@"title1": @"轮换周期", @"title2": [NSString stringWithFormat:@"%@周", self.limitRule.shiftWeeks], @"hideArrow": @YES}}];
        [dataSource addObject:@{@"cell": @"TwoTitleCell", @"data": @{@"title1": @"本轮结束日期", @"title2": [self formatShiftEndDateStr], @"hideArrow": @YES}}];
    }
    [dataSource addObject:@{@"cell": @"TwoTitleCell", @"data": @{@"title1": @"提醒设置", @"title2": [NSString stringWithFormat:@"响铃%d次", (int)self.remindSettings.count]}, @"tag": @(TwoTitleCellTag_RemindSetting)}];
    [dataSource addObject:@{@"cell": @"TrafficRemindAllCell"}];
    [dataSource addObject:@{@"cell": @"TwoTitleCell", @"data": @{@"title1": @"铃声选择", @"title2": [[AlarmManager sharedInstance] nameByRingFileName:self.ringName]}, @"tag": @(TwoTitleCellTag_RingName)}];
    [dataSource addObject:@{@"cell": @"TrafficSwitchCell", @"data": @{@"title1": @"同步起床闹钟提醒", @"title2": @"此功能在限行当日的起床闹钟响铃并点击起床后，自动生成一次限行提醒", @"open": self.syncAlarm}, @"tag": @(TwoTitleCellTag_SwitchSyncAlarm)}];
    if (self.syncAlarm.boolValue) {
        [dataSource addObject:@{@"cell": @"TwoTitleCell", @"data": @{@"title1": @"提醒时间", @"title2": [NSString stringWithFormat:@"起床闹钟后%@分钟", self.timeAfterAlarm]}, @"tag": @(TwoTitleCellTag_TimeAfterAlarm)}];
    }
    
    return dataSource;
}

- (void)updateLimitDay {
    if (!self.limitRule || self.plateNumber.length <= 0) {
        return;
    }
    NSInteger mode = self.limitRule.limitMode.integerValue;
    NSInteger lastNum = [self parseLastNumber];
    NSInteger maxDay = [NSDate date].maxDay;
    if (1 == mode) {
        //北京
        NSInteger shiftStartNumber = self.limitRule.shiftStartNumber.integerValue;
        NSDate *nextStartDate = [self.limitRule.shiftStartDate dateByAddingDays:self.limitRule.shiftWeeks.integerValue*7];
        NSDate *nowDate = [NSDate date];
        while (nextStartDate.timeIntervalSince1970 < nowDate.timeIntervalSince1970) {
            shiftStartNumber--;//一轮后(周一对应的限行号)减一
            if (shiftStartNumber < 0) {
                shiftStartNumber += 5;
            }
            nextStartDate = [nextStartDate dateByAddingDays:self.limitRule.shiftWeeks.integerValue*7];
        }
        shiftStartNumber = shiftStartNumber % 5;
        //已经得到周一限行的车牌号 1/2/3/4/0
        lastNum = lastNum % 5;
        
        lastNum = lastNum - shiftStartNumber + 1;
        if (lastNum <= 0) {
            lastNum += 5;
        }
        self.limitRule.weekday = @(lastNum+1);
    } else if (2 == mode) {
        //成都
        // 16 27 38 49 50
        lastNum = lastNum % 5;
        if (lastNum == 0) {
            lastNum += 5;
        }
        self.limitRule.weekday = @(lastNum+1);
    } else if (3 == mode) {
        //长春
        if (lastNum == 0) {
            lastNum += 10;
        }
        NSMutableArray *dayArray = [NSMutableArray array];
        for (NSInteger i = 0; i < 3; i++) {
            NSInteger day = lastNum + i*10;
            [dayArray addObject:@(day)];
            if (day <= maxDay) {
            }
        }
        self.limitRule.daysStr = [dayArray componentsJoinedByString:kSpliterStr];
    } else if (4 == mode) {
        // 1 6
        lastNum = lastNum % 5;
        if (lastNum == 0) {
            lastNum += 5;
        }
        NSMutableArray *dayArray = [NSMutableArray array];
        for (NSInteger i = 0; i < 7; i++) {
            NSInteger day = lastNum + i*5;
            if (day <= 31) {
                [dayArray addObject:@(day)];
            }
            if (day <= maxDay) {
            }
        }
        self.limitRule.daysStr = [dayArray componentsJoinedByString:kSpliterStr];
    } else if (5 == mode) {
        // 19 28 37 46 50
        if (lastNum > 5) {
            lastNum = 10 - lastNum;
        }
        if (lastNum == 0) {
            lastNum = 5;
        }
        self.limitRule.weekday = @(lastNum+1);
    }
}

- (NSInteger)parseLastNumber {
    if (!self.limitRule || self.plateNumber.length <= 0) {
        return 0;
    }
    for (NSInteger i = 6; i >= 2; i--) {
        char c = [self.plateNumber characterAtIndex:i];
        if (c >= '0' && c <= '9') {
            return c-'0';
        } else if (self.limitRule.letterRule.integerValue == 1) {
            return self.limitRule.letterNumber.integerValue;
        }
    }
    return 0;
}

- (NSString *)formatShiftEndDateStr {
    return [NSDateFormatter stringFromDate:[self shiftEndDate] formatStr:kDateFormatStr];
}

- (NSDate *)shiftEndDate {
    NSDate *nextStartDate = [[self.limitRule.shiftStartDate dateAtStartOfDay] dateByAddingDays:self.limitRule.shiftWeeks.integerValue*7];
    
    NSDate *nowDate = [NSDate date];
    while (nextStartDate.timeIntervalSince1970 < nowDate.timeIntervalSince1970) {
        nextStartDate = [nextStartDate dateByAddingDays:self.limitRule.shiftWeeks.integerValue*7];
    }
    return [nextStartDate dateBySubtractingDays:1];
}

- (NSString *)formatLimitDayStr {
    if (!self.limitRule || self.plateNumber.length <= 0) {
        return @"";
    }
    
    NSInteger mode = self.limitRule.limitMode.integerValue;
    if (3 == mode || 4 == mode) {
        return [NSString stringWithFormat:@"每月%@", self.limitRule.daysStr];
    } else {
        NSArray *days = @[@"日", @"一", @"二", @"三", @"四", @"五", @"六"];
        NSString *infoStr = [NSString stringWithFormat:@"每周%@", days[self.limitRule.weekday.integerValue-1]];
        return infoStr;
    }
}

- (NSString *)plateNumberForShow {
    if (self.plateNumber.length >= 2) {
        return [self.plateNumber stringByReplacingCharactersInRange:NSMakeRange(2, 0) withString:@"："];
    }
    return SSJKString(self.plateNumber);
}

/**
 * 是否需要显示外埠
 */
- (BOOL)needShowOtherCity {
    return (self.limitRule.limitOtherCity.boolValue && ![self.plateNumber hasPrefix:self.limitRule.plateNumberPre]);
}

- (NSAttributedString *)formatPlateNumberStr {
    if (!self.limitRule || self.plateNumber.length <= 0) {
        return [[NSAttributedString alloc] init];
    }
    
    if ([self needShowOtherCity]) {
        NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:@"外埠   " attributes:@{NSForegroundColorAttributeName: [UIColor orangeColor]}];
        [attrStr appendAttributedString:[[NSAttributedString alloc] initWithString:[self plateNumberForShow]]];
        return attrStr;
    } else {
        return [[NSAttributedString alloc] initWithString:[self plateNumberForShow]];
    }
}

- (NSAttributedString *)formatPlateNumberStr2 {
    if (!self.limitRule) {
        if (self.plateNumber.length <= 0) {
            return [[NSAttributedString alloc] init];
        } else {
            //针对不限行车辆
            return [[NSAttributedString alloc] initWithString:[self plateNumberForShow]];
        }
    }
    
    if ([self needShowOtherCity]) {
        NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:@"外埠   " attributes:@{NSForegroundColorAttributeName: [UIColor orangeColor]}];
        [attrStr appendAttributedString:[[NSAttributedString alloc] initWithString:[self plateNumberForShow]]];
        return attrStr;
    } else if (self.city.mid.integerValue == 2929) {
        //兰州
        NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:[self plateNumberForShow]];
        [attrStr appendAttributedString:[[NSAttributedString alloc] initWithString:@"(自动跳过节假日)" attributes:@{NSForegroundColorAttributeName: [UIColor orangeColor]}]];
        return attrStr;
    } else {
        return [[NSAttributedString alloc] initWithString:[self plateNumberForShow]];
    }
}

- (void)addNotification {
    [self addNotification:NO];
}

- (void)addNotification:(BOOL)more {
    //不是添加更多通知时，删除就包括稍后提醒
    NSArray *removedUuids = [self deleteNotification:NO includeLater:!more];
    
    if (!self.limitRule || self.plateNumber.length <= 0) {
        [self removeNotiAndSaveLog:removedUuids logArray:@[]];
        return;
    }
    
    NSMutableArray *logArray = [NSMutableArray array];
    
    for (NSDate *limitDate in [self calcLimitDateArray]) {
        for (RemindSetting *remind in self.remindSettings) {
            NSDate *alarmDate = [[limitDate dateByAddingHours:remind.time.hour] dateByAddingMinutes:remind.time.minute];
            if (remind.preDay.integerValue > 0) {
                alarmDate = [alarmDate dateBySubtractingDays:remind.preDay.integerValue];
            }
            AlarmLog *alarmLog = [self addAlarmLog:AppNotiType_Traffic fireDate:alarmDate repeat:0];
            if (alarmLog) {
                alarmLog.extJsonStr = [@{@"limitDate": @(limitDate.timeIntervalSince1970)} JSONString_JSONKit];
                [logArray addObject:alarmLog];
            }
        }
    }
    
    [self removeNotiAndSaveLog:removedUuids logArray:logArray];
}

- (NSArray *)calcLimitDateArray {
    NSMutableArray *dateArray = [NSMutableArray array];
    
    [self updateLimitDay];
    
    NSDate *nowDate = [NSDate date];
    NSDate *nowStartDate = [nowDate dateAtStartOfDay];
    
    NSInteger mode = self.limitRule.limitMode.integerValue;
    if (3 == mode || 4 == mode) {
        NSDate *monthStartDate = [nowDate dateAtStartOfMonth];
        NSInteger maxDay = monthStartDate.maxDay;
        NSInteger nextMaxDay = [monthStartDate dateByAddingMonths:1].maxDay;
        
        NSArray *daysArray = [self.limitRule.daysStr componentsSeparatedByString:kSpliterStr];
        for (NSString *dayStr in daysArray) {
            NSInteger day = [dayStr integerValue];
            if (day > maxDay) {
                continue;
            }
            //限行日期
            NSDate *limitDate = [monthStartDate dateByAddingDays:day-1];
            if ([limitDate compare:nowStartDate] == NSOrderedAscending) {
                //如果时间已过调整到下一月
                if (day > nextMaxDay) {
                    continue;
                }
                limitDate = [limitDate dateByAddingMonths:1];
            }
            
            DEBUG_LOG(@"预测的限行日期 %@", [NSDateFormatter stringFromDate:limitDate formatStr:@"yyyy-MM-dd"]);
            
            if (!self.limitRule.holidayNeedLimit.boolValue && [[AlarmManager sharedInstance] checkDateIsHoliday:limitDate]) {
                //节假日不需要限行，并且那天是节假日就跳过
                continue;
            }
            
            [dateArray addObject:limitDate];
        }
    } else {
        //限行日期
        NSDate *limitDate = [nowStartDate dateBySubtractingDays:nowDate.weekday-self.limitRule.weekday.integerValue];
        if ([limitDate compare:nowStartDate] == NSOrderedAscending) {
            //在今天之前就先加7天
            limitDate = [limitDate dateByAddingDays:7];
        }
        
        BOOL didAdjust = NO;
        //添加4周的限行数据
        for (NSInteger i = 0; i < 4; i++) {
            if (i > 0) {
                //调整到下一周
                limitDate = [limitDate dateByAddingDays:7];
                //如果是北京模式，在预测下次响铃时，要考虑是否跨过本轮结束日期
                if (1 == mode) {
                    if (!didAdjust && [[self shiftEndDate] compare:limitDate] == NSOrderedAscending) {
                        didAdjust = YES;
                        limitDate = [limitDate dateByAddingDays:1];
                        if (limitDate.weekday == 7) {
                            //如果是周5，可能被调整到周6了
                            limitDate = [limitDate dateBySubtractingDays:5];
                        }
                    }
                }
            }
            
            DEBUG_LOG(@"预测的限行日期 %@", [NSDateFormatter stringFromDate:limitDate formatStr:@"yyyy-MM-dd"]);
            
            if (!self.limitRule.holidayNeedLimit.boolValue && [[AlarmManager sharedInstance] checkDateIsHoliday:limitDate]) {
                //节假日不需要限行，并且那天是节假日就跳过
                continue;
            }
            
            [dateArray addObject:limitDate];
        }
    }
    //取最近的3个
    [dateArray sortUsingComparator:^NSComparisonResult(NSDate *  _Nonnull obj1, NSDate *  _Nonnull obj2) {
        return [obj1 compare:obj2];
    }];
    
    NSInteger keepNum = 3;
    if (dateArray.count > keepNum) {
        [dateArray removeObjectsInRange:NSMakeRange(keepNum, dateArray.count-keepNum)];
    }
    
    for (NSDate *date in dateArray) {
        DEBUG_LOG(@"使用的限行日期 %@", [NSDateFormatter stringFromDate:date formatStr:@"yyyy-MM-dd"]);
    }
    
    return dateArray;
}

/**
 * 同步起床闹钟
 */
- (void)syncShiftAlarm {
    if (!self.limitRule || self.plateNumber.length <= 0) {
        return;
    }
    
    if (!self.enabled.boolValue || !self.syncAlarm.boolValue) {
        //没有启用 没有开启同步
        return;
    }
    
    NSInteger index = [[self calcLimitDateArray] indexOfObjectPassingTest:^BOOL(NSDate *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        return [obj isEqualToDateIgnoringTime:[NSDate date]];
    }];
    
    if (index != NSNotFound) {
        //今天限行
        NSDate *alarmDate = [[NSDate date] dateByAddingTimeInterval:self.timeAfterAlarm.integerValue*60];
        AlarmLog *alarmLog = [self addAlarmLog:AppNotiType_Traffic fireDate:alarmDate repeat:0];
        alarmLog.isLaterRemind = @YES;
        alarmLog.extJsonStr = [@{@"limitDate": @([[NSDate date] dateAtStartOfDay].timeIntervalSince1970)} JSONString_JSONKit];
        [self removeNotiAndSaveLog:@[] logArray:@[alarmLog]];
    }
}

@end
