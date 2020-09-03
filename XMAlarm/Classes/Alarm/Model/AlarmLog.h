//
//  AlarmLog.h
//  XMAlarm
//
//  Created by bo.chen on 17/10/30.
//  Copyright © 2017年 com.xmm. All rights reserved.
//

#import "SSKModel.h"
#import "UILocalNotification+Ext.h"

#define UseBundleRing
#define DontRingName @"不响铃"

/**
 * 告警记录
 * 一个闹钟、提醒、限行可能有多个告警记录
 * 一个告警记录可能对应多个UILocalNotification
 */
@interface AlarmLog : SSKModel
@property (nonatomic, strong) NSDate *fireDate;
@property (nonatomic, strong) NSNumber *repeatInterval;//NSCalendarUnit 0不重复
@property (nonatomic, strong) NSString *alertBody;
@property (nonatomic, strong) NSString *ringName;
@property (nonatomic, strong) NSString *relateUuid;//闹钟、提醒、限行的uuid
@property (nonatomic, strong) NSNumber *type;
@property (nonatomic, strong) NSString *extJsonStr;
@property (nonatomic, strong) NSNumber *isLaterRemind;//是否是稍后提醒
- (NSTimeInterval)howLongRing:(NSDate *)date;
- (void)ring;
- (NSArray *)createLocalNoti;
@end
