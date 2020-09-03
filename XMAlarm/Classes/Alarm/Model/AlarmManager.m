//
//  AlarmManager.m
//  XMAlarm
//
//  Created by bo.chen on 17/9/12.
//  Copyright © 2017年 com.xmm. All rights reserved.
//

#import "AlarmManager.h"
#import "VoicePlayer.h"
#import "ShowAlarmView.h"
#import "ShowRemindView.h"
#import "ShowTrafficView.h"
#import "DisclaimerAlertView.h"

#import "ZZXBluetoothManager.h"

#define kHolidayList @"HolidayList"

@interface AlarmManager ()
{
    NSInteger   _count;
}
@property (nonatomic, strong) NSMutableArray *holidayList;
@end

@implementation AlarmManager

+ (instancetype)sharedInstance {
    static AlarmManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[AlarmManager alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self readRingConfigData];
        [self refreshAlarmEnabled];
        [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerCallback) userInfo:nil repeats:YES];
        [self initHoliday];
    }
    return self;
}

- (void)readRingConfigData {
    self.ringConfigDict = [NSMutableDictionary dictionary];
    self.ringConfigDict[DontRingName] = @{@"name": DontRingName, @"sort": @0};
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"Ringtones" ofType:@"txt"];
    NSError *err = nil;
    NSString *configStr = [NSString stringWithContentsOfFile:filePath usedEncoding:NULL error:&err];
    if (!err) {
        NSArray *tmp = [configStr componentsSeparatedByString:@"\n"];
        for (NSString *str in tmp) {
            if (str.length <= 0) {
                continue;
            }
            NSArray *dataArray = [str componentsSeparatedByString:@","];
            NSString *filename = safeGetArrayObject(dataArray, 0);
            NSString *name = safeGetArrayObject(dataArray, 1);
            NSString *type = safeGetArrayObject(dataArray, 2);
            NSString *sort = safeGetArrayObject(dataArray, 3);
            self.ringConfigDict[SSJKString(filename)] = @{@"name": SSJKString(name), @"type": @(type.integerValue), @"sort": @(sort.integerValue)};
        }
    } else {
        DEBUG_LOG(@"%@", err);
    }
}

- (NSString *)nameByRingFileName:(NSString *)fileName {
    NSDictionary *configDict = [AlarmManager sharedInstance].ringConfigDict[fileName];
    return configDict ? configDict[@"name"] : fileName;
}

- (void)refreshAlarmEnabled {
    NSDate *date = [NSDate date];
    //移除关闭的并且时间已过的自定义闹钟和提醒
    NSArray *classArray = @[[CustomAlarm class], [TempRemind class]];
    for (Class cls in classArray) {
        [[cls allForUser] enumerateObjectsUsingBlock:^(CustomAlarm *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (!obj.enabled.boolValue && [obj.datetime compare:date] == NSOrderedAscending) {
                [obj remove];
            }
        }];
    }
    
    NSMutableArray *needShowLogs = [NSMutableArray array];
    NSArray *allLogs = [AlarmLog all];
    if (allLogs.count <= 0) {
        [[UIApplication sharedApplication] cancelAllLocalNotifications];
    }
    for (AlarmLog *log in allLogs) {
        if ([log.fireDate compare:date] == NSOrderedAscending) {
            //已过
            [needShowLogs addObject:log];
        }
    }
    [needShowLogs sortUsingComparator:^NSComparisonResult(AlarmLog *  _Nonnull obj1, AlarmLog *  _Nonnull obj2) {
        return [obj2.fireDate compare:obj1.fireDate];
    }];
    //显示界面
    if (needShowLogs.count > 0) {
        if (!KEYWindow) {
            AsyncRunAfter(^{
                for (AlarmLog *log in needShowLogs) {
                    [self showLog:log];
                }
            }, 0.1);
        } else {
            for (AlarmLog *log in needShowLogs) {
                [self showLog:log];
            }
        }
    }
    
    //刷新闹钟列表
    [[NSNotificationCenter defaultCenter] postNotificationName:kRefreshAlarmList object:nil];
}

- (void)adjustMoreAlarm {
    //限行 倒班 起床中的非单次 周期提醒 需要刷新
    NSArray *classArray = @[[TrafficLimitAlarm class], [ShiftAlarm class], [RiseAlarm class], [RepeatRemind class]];
    NSMutableArray *alarmArray = [NSMutableArray array];
    for (Class cls in classArray) {
        [alarmArray addObjectsFromArray:[cls allForUser]];
    }
    //按更新时间从小到大刷新，后更新的后刷新
    [alarmArray sortUsingComparator:^NSComparisonResult(BaseAlarm *  _Nonnull obj1, BaseAlarm *  _Nonnull obj2) {
        return [obj1.updateTime compare:obj2.updateTime];
    }];
    [alarmArray enumerateObjectsUsingBlock:^(BaseAlarm *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.enabled.boolValue) {
            [obj addNotification:YES];
        }
    }];
}

/**
 * 在节假日和限行规则变化后调整限行闹钟，但不能移除稍后提醒
 */
- (void)adjustLimitAlarm {
    NSMutableArray *alarmArray = [NSMutableArray arrayWithArray:[TrafficLimitAlarm allForUser]];
    //按更新时间从小到大刷新，后更新的后刷新
    [alarmArray sortUsingComparator:^NSComparisonResult(BaseAlarm *  _Nonnull obj1, BaseAlarm *  _Nonnull obj2) {
        return [obj1.updateTime compare:obj2.updateTime];
    }];
    [alarmArray enumerateObjectsUsingBlock:^(BaseAlarm *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.enabled.boolValue) {
            [obj addNotification:YES];
        }
    }];
    //刷新闹钟列表
    [[NSNotificationCenter defaultCenter] postNotificationName:kRefreshAlarmList object:nil];
}

- (void)timerCallback {
    _count += 1;
    //每60秒刷新
    if (0 == (_count % 60)) {
        _count = 0;
        if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kUpdateAlarmListView object:nil];
        }
    }
    
    NSDate *date = [NSDate date];
    for (AlarmLog *log in [AlarmLog all]) {
        NSTimeInterval offset = [log howLongRing:date];
        if (offset > 0 && offset <= 1) {
            //还差一秒闹钟时间到，在前台才响铃该闹钟
            //在前台才显示界面
            if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
                [log ring];
                [self showLog:log];
            }
        }
    }
}

- (void)showLog:(AlarmLog *)log {
    BOOL exist = NO;
    for (UIView *view in KEYWindow.subviews) {
        if ([view.tagObj isEqual:log.serverId]) {
            exist = YES;
            break;
        }
    }
    if (exist) {
        return;
    }
    
    AppNotiType type = log.type.integerValue;
    BaseAlarm *alarm = [self findAlarmBy:log.relateUuid type:type];
    if (AppNotiType_RiseAlarm == type || AppNotiType_ShiftAlarm == type || AppNotiType_CustomAlarm == type) {
        ShowAlarmView *alarmView = [[ShowAlarmView alloc] initWithAlarm:alarm alarmLog:log];
        [alarmView show];
    } else if (AppNotiType_RepeatRemind == type || AppNotiType_TempRemind == type) {
        ShowRemindView *alarmView = [[ShowRemindView alloc] initWithAlarm:alarm alarmLog:log];
        [alarmView show];
    } else if (AppNotiType_Traffic == type) {
        ShowTrafficView *alarmView = [[ShowTrafficView alloc] initWithAlarm:alarm alarmLog:log];
        [alarmView show];
    }
}

- (void)stopPlay {
    [[VoicePlayer sharedInstance] stop];
}

- (BaseAlarm *)findAlarmBy:(NSString *)uuid type:(AppNotiType)type {
    if (AppNotiType_RiseAlarm == type) {
        return [RiseAlarm find:[NSString stringWithFormat:@"serverId = '%@'", uuid]];
    } else if (AppNotiType_ShiftAlarm == type) {
        return [ShiftAlarm find:[NSString stringWithFormat:@"serverId = '%@'", uuid]];
    } else if (AppNotiType_CustomAlarm == type) {
        return [CustomAlarm find:[NSString stringWithFormat:@"serverId = '%@'", uuid]];
    } else if (AppNotiType_RepeatRemind == type) {
        return [RepeatRemind find:[NSString stringWithFormat:@"serverId = '%@'", uuid]];
    } else if (AppNotiType_TempRemind == type) {
        return [TempRemind find:[NSString stringWithFormat:@"serverId = '%@'", uuid]];
    } else if (AppNotiType_Traffic == type) {
        return [TrafficLimitAlarm find:[NSString stringWithFormat:@"serverId = '%@'", uuid]];
    } else {
        DEBUG_LOG(@"AppNotiType Invalid");
        return nil;
    }
}

- (void)bindAlarmData {
    NSArray *classArray = @[[RiseAlarm class], [ShiftAlarm class], [CustomAlarm class], [RepeatRemind class], [TempRemind class], [TrafficLimitAlarm class], [Schedule class]];
    for (Class cls in classArray) {
        NSArray *models = [cls where:@" userId is null or userId = ''"];
        for (BaseAlarm *alarm in models) {
            alarm.userId = TheUser.id;
            [alarm save];
        }
    }
    //刷新闹钟列表
    [[NSNotificationCenter defaultCenter] postNotificationName:kRefreshAlarmList object:nil];
    //绑定后就上传闹钟数量
    [self uploadAlarmNum];
}

- (void)uploadAlarmNum {    
    NSInteger alarmNum = [RiseAlarm allForUser].count + [ShiftAlarm allForUser].count + [CustomAlarm allForUser].count;
    NSInteger remindNum = [RepeatRemind allForUser].count + [TempRemind allForUser].count;
    NSInteger trafficNum = [TrafficLimitAlarm allForUser].count;
    NSInteger noteNum = [Schedule allForUser].count;
    NSDictionary *content = @{@"deviceId": DeviceID,
                              @"mobileOS": [NSString stringWithFormat:@"%@ %@", [UIDevice currentDevice].systemName, [UIDevice currentDevice].systemVersion],
                              @"mobileModel": [UIDevice currentDevice].model,
                              @"uid": SSJKString(TheUser.id), @"alarmNum": @(alarmNum), @"remindNum": @(remindNum), @"trafficNum": @(trafficNum), @"noteNum": @(noteNum)};
    [Api uploadAlarmNum:content successBlock:^(id body) {
    } failBlock:^(NSString *message, NSInteger code) {
    }];
}

- (BOOL)checkDateIsHoliday:(NSDate *)date {
    NSInteger index = [self.holidayList indexOfObjectPassingTest:^BOOL(NSNumber *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSDate *holDate = [NSDate dateWithTimeIntervalSince1970:obj.doubleValue/1000];
        return [holDate isEqualToDateIgnoringTime:date];
    }];
    return index != NSNotFound;
}

- (void)initHoliday {
    self.holidayList = [NSMutableArray arrayWithArray:(NSArray *)[[EGOCache globalCache] objectForKey:kHolidayList]];
    [self updateHoliday:NULL];
}

- (void)updateHoliday:(ObjectBlock)block {
    [Api holidayList:^(id body) {
        NSLog(@"holidayList = %@",body);
        [ZZXBluetoothManager shared].holidayArray = body;
        self.holidayList = [NSMutableArray arrayWithArray:body];
        [[EGOCache globalCache] setObject:self.holidayList forKey:kHolidayList];
        //调整限行闹钟
        [self adjustLimitAlarm];
        
        if (block) {
            block(@YES);
        }
        
#if 0
        //检查更新的限行城市数据
        NSMutableArray *cityList = [NSMutableArray array];
        for (TrafficLimitAlarm *alarm in [TrafficLimitAlarm allForUser]) {
            [cityList addObject:[alarm.city JSONDictionary]];
        }
        [Api checkUpdatedCity:@{@"cityList": cityList} successBlock:^(id body) {
        } failBlock:^(NSString *message, NSInteger code) {
        }];
#endif
    } failBlock:^(NSString *message, NSInteger code) {
        if (block) {
            block(@NO);
        }
    }];
}

/**
 * 弹框一天弹一次（第一次设置好闹钟／提醒／限行条目后），如果点击了不再提醒，则不再弹出，app升级后再重复上述逻辑。
 */
- (void)checkDisclaimerAlert {
    //没有点不再提醒
    if (![[User_Default objectForKey:kDisclaimerKnownKey] boolValue]) {
        NSDate *lastTime = [User_Default objectForKey:kDisclaimerAlertTimeKey];
        if (!lastTime || ![lastTime isEqualToDateIgnoringTime:[NSDate date]]) {
            //没有或者不是今天，就提醒
            DisclaimerAlertView *alertView = [[DisclaimerAlertView alloc] initWithFrame:CGRectZero];
            [alertView show];
            
            [User_Default setObject:[NSDate date] forKey:kDisclaimerAlertTimeKey];
            [User_Default synchronize];
        }
    }
}

@end
