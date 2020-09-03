//
//  BaseAlarm.h
//  XMAlarm
//
//  Created by bo.chen on 17/9/5.
//  Copyright © 2017年 com.xmm. All rights reserved.
//

#import "BaseModel.h"
#import "AlarmLog.h"

#define kTimeFormatStr @"HH:mm"
#define kDateFormatStr @"yyyy.MM.dd"
#define kMaxRingTime 34560000L

@interface BaseAlarm : SSKModel
@property (nonatomic, strong) NSString *userId;//uuid的字符串
@property (nonatomic, strong) NSDate *createTime;
@property (nonatomic, strong) NSDate *updateTime;

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSNumber *enabled;//是否启用
@property (nonatomic, strong) NSString *ringName;//铃声

+ (NSArray *)allForUser;
- (NSComparisonResult)compare:(BaseAlarm *)otherAlarm;
- (NSString *)formatAlarmTimeStr;
- (NSArray *)formatDataSource;
- (void)addNotification;
/**
 * more: YES，在添加响铃数据时不会移除稍后提醒那些
 */
- (void)addNotification:(BOOL)more;
- (NSArray *)deleteNotification:(BOOL)immediately;
- (NSArray *)deleteNotification:(BOOL)immediately includeLater:(BOOL)includeLater;
- (AlarmLog *)addAlarmLog:(AppNotiType)type fireDate:(NSDate *)fireDate repeat:(NSCalendarUnit)interval;
- (void)removeNotiAndSaveLog:(NSArray *)removedUuids logArray:(NSArray *)logArray;
- (BOOL)shouldCheckEnabled;
- (NSTimeInterval)howLongRing:(NSDate *)date;

@end
