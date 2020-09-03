//
//  ShiftAlarm.m
//  XMAlarm
//
//  Created by bo.chen on 17/9/5.
//  Copyright © 2017年 com.xmm. All rights reserved.
//

#import "ShiftAlarm.h"
#import "AlarmManager.h"

@implementation ShiftAlarm

- (instancetype)init {
    self = [super init];
    if (self) {
        self.name = @"倒班闹钟";
        self.sleepTime = @5;//5分钟
        self.startDate = [NSDate date];
        self.workInfos = @[];
        [self setupPeriod:6];
        //第5.6天改为休息
        for (NSInteger i = self.workInfos.count-2; i < self.workInfos.count; i++) {
            ShiftWorkInfo *workInfo = self.workInfos[i];
            workInfo.needWork = @NO;
        }
        self.ringName = @"和风送暖.m4r";
    }
    return self;
}

- (NSNumber *)classSortValue {
    return @2;
}

- (NSComparisonResult)inlineCompare:(ShiftAlarm *)otherAlarm {
    return [[self firstNeedWork].time compareIgnoringDate:[otherAlarm firstNeedWork].time];
}

- (id)copyWithZone:(NSZone *)zone {
    //copy数组里面的每个元素
    NSArray *workInfos = [self.workInfos copySelfAndElement];
    
    //需要先移除字典里的数组元素，然后在通过initWithDictionary来创建对象，不然在32位机器上会出现内存错误
    NSDictionary *newDict = [self.dictionaryValue removeArrayValues];
    
    ShiftAlarm *newObj = [[self.class allocWithZone:zone] initWithDictionary:newDict error:NULL];
    newObj.workInfos = workInfos;
    
    //对象需要copy
    
    return newObj;
}

+ (NSValueTransformer *)JSONTransformerForKey:(NSString *)key {
    if ([key isEqualToString:@"startDate"]) {
        return [MTLValueTransformer reversibleTransformerWithForwardBlock:^NSDate *(NSNumber *seconds) {
            return [NSDate dateWithTimeIntervalSince1970:seconds.doubleValue];
        }                                                    reverseBlock:^NSNumber *(NSDate *date) {
            return @(date.timeIntervalSince1970);
        }];
    }
    return [super JSONTransformerForKey:key];
}

+ (NSValueTransformer *)workInfosJSONTransformer {
    return [NSValueTransformer mtl_JSONArrayTransformerWithModelClass:[ShiftWorkInfo class]];
}

+ (NSValueTransformer *)workInfosFMDBTransformer {
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^NSArray *(NSData *data) {
        return [ShiftWorkInfo modelsFromJSONArray:[data objectFromJSONData_JSONKit]];
    } reverseBlock:^NSData *(NSArray *array) {
        return [[ShiftWorkInfo JSONArrayFromModels:array] JSONData_JSONKit];
    }];
}

- (NSString *)formatAlarmTimeStr {
    ShiftWorkInfo *workInfo = [self firstNeedWork];
    AlarmLog *alarmLog = [[AlarmLog where:[NSString stringWithFormat:@"relateUuid = '%@' order by fireDate asc limit 0,1", self.serverId]] firstObject];
    if (!alarmLog) {
        return [NSDateFormatter stringFromDate:workInfo.time formatStr:kTimeFormatStr];
    } else {
        NSInteger index = [[alarmLog.extJsonStr objectFromJSONString_JSONKit][@"shiftIndex"] integerValue];
        workInfo = safeGetArrayObject(self.workInfos, index);
        if (!workInfo) {
            workInfo = [self firstNeedWork];
        }
        return [NSDateFormatter stringFromDate:workInfo.time formatStr:kTimeFormatStr];
    }
}

- (ShiftWorkInfo *)firstNeedWork {
    for (ShiftWorkInfo *workInfo in self.workInfos) {
        if (workInfo.needWork.boolValue) {
            return workInfo;
        }
    }
    return nil;
}

- (NSString *)formatPeriodStr {
    return [NSString stringWithFormat:@"每一轮%@天", self.period];
}

- (NSString *)formatDateStr {
    return [NSDateFormatter stringFromDate:self.startDate formatStr:kDateFormatStr];
}

- (NSArray *)formatDataSource {
    NSMutableArray *dataSource = [NSMutableArray array];
    
    for (NSInteger i = 0; i < ceilf(self.workInfos.count/3.0); i++) {
        NSRange range = NSMakeRange(i*3, MIN(3, (self.workInfos.count-3*i)));
        [dataSource addObject:@{@"cell": @"ShiftWorkBtnCell", @"data": [self.workInfos subarrayWithRange:range]}];
    }
    [dataSource addObject:@{@"cell": @"ShiftBlankCell"}];
    [dataSource addObject:@{@"cell": @"TwoTitleCell", @"data": @{@"title1": @"闹钟名", @"title2": self.name}, @"tag": @(TwoTitleCellTag_Name)}];
    [dataSource addObject:@{@"cell": @"TwoTitleCell", @"data": @{@"title1": @"倒班周期", @"title2": [self formatPeriodStr]}, @"tag": @(TwoTitleCellTag_ShiftAlarmPeriod)}];
    [dataSource addObject:@{@"cell": @"TwoTitleCell", @"data": @{@"title1": @"开始日期", @"title2": [self formatDateStr]}, @"tag": @(TwoTitleCellTag_CustomAlarmDate)}];
    [dataSource addObject:@{@"cell": @"TwoTitleCell", @"data": @{@"title1": @"贪睡设置", @"title2": [NSString stringWithFormat:@"%@分钟", self.sleepTime]}, @"tag": @(TwoTitleCellTag_RiseAlarmSleep)}];
    [dataSource addObject:@{@"cell": @"TwoTitleCell", @"data": @{@"title1": @"铃声选择", @"title2": [[AlarmManager sharedInstance] nameByRingFileName:self.ringName]}, @"tag": @(TwoTitleCellTag_RingName)}];
    
    return dataSource;
}

- (void)setupPeriod:(NSInteger)period {
    NSInteger oldPeriod = self.period.integerValue;
    if (oldPeriod != period) {
        self.period = @(period);
        if (period > oldPeriod) {
            self.workInfos = [self.workInfos arrayByAddingObjectsFromArray:[ShiftWorkInfo createWorkInfos:period-oldPeriod]];
        } else {
            self.workInfos = [self.workInfos subarrayWithRange:NSMakeRange(0, period)];
        }
        for (NSInteger i = 0; i < self.period.integerValue; i++) {
            ShiftWorkInfo *workInfo = self.workInfos[i];
            workInfo.index = @(i+1);
        }
    }
}

- (BOOL)checkValid {
    return [self firstNeedWork] != nil;
}

- (void)addNotification {
    [self addNotification:NO];
}

- (void)addNotification:(BOOL)more {
    //不是添加更多通知时，删除就包括稍后提醒
    NSArray *removedUuids = [self deleteNotification:NO includeLater:!more];
    
    NSMutableArray *logArray = [NSMutableArray array];
    
    NSInteger index = 0;
    NSDate *alarmDate = [self getAlarmDateAndShiftIndex:&index];
    AlarmLog *alarmLog = [self addAlarmLog:AppNotiType_ShiftAlarm fireDate:alarmDate repeat:0];
    if (alarmLog) {
        alarmLog.extJsonStr = [@{@"shiftIndex": @(index)} JSONString_JSONKit];
        [logArray addObject:alarmLog];
    }
    
    [self removeNotiAndSaveLog:removedUuids logArray:logArray];
}

- (NSDate *)getAlarmDateAndShiftIndex:(NSInteger *)pIndex {
    NSDate *alarmDate = nil;
    NSInteger shiftIndex = 0;
    
    NSDate *startDate = [self.startDate dateAtStartOfDay];
    NSDate *nowDate = [NSDate date];
    for (NSInteger i = 0; i < self.period.integerValue; i++) {
        ShiftWorkInfo *workInfo = self.workInfos[i];
        if (workInfo.needWork.boolValue) {
            //需要上班
            NSDate *tmpDate = [[[startDate dateByAddingDays:i] dateByAddingHours:workInfo.time.hour] dateByAddingMinutes:workInfo.time.minute];
            while ([tmpDate compare:nowDate] == NSOrderedAscending) {
                tmpDate = [tmpDate dateByAddingDays:self.period.integerValue];
            }
            if (!alarmDate) {
                alarmDate = tmpDate;
                shiftIndex = i;
            } else if (tmpDate.timeIntervalSince1970 < alarmDate.timeIntervalSince1970) {
                alarmDate = tmpDate;
                shiftIndex = i;
            }
        }
    }
    
    *pIndex = shiftIndex;
    return alarmDate;
}

@end

@implementation ShiftWorkInfo

- (instancetype)init {
    self = [super init];
    if (self) {
        self.time = [NSDateFormatter dateFromString:@"9:00" formatStr:kTimeFormatStr];
        self.needWork = @YES;
    }
    return self;
}

+ (NSValueTransformer *)JSONTransformerForKey:(NSString *)key {
    if ([key isEqualToString:@"time"]) {
        return [MTLValueTransformer reversibleTransformerWithForwardBlock:^NSDate *(NSNumber *seconds) {
            return [NSDate dateWithTimeIntervalSince1970:seconds.doubleValue];
        }                                                    reverseBlock:^NSNumber *(NSDate *date) {
            return @(date.timeIntervalSince1970);
        }];
    }
    return [super JSONTransformerForKey:key];
}

+ (NSArray *)createWorkInfos:(NSInteger)num {
    NSMutableArray *array = [NSMutableArray array];
    for (NSInteger i = 0; i < num; i++) {
        [array addObject:[[ShiftWorkInfo alloc] init]];
    }
    return array;
}

- (NSString *)formatTimeStr {
    return [NSDateFormatter stringFromDate:self.time formatStr:kTimeFormatStr];
}

- (NSString *)formatIndexStr {
    return [NSString stringWithFormat:@"第%@天", self.index];
}

@end
