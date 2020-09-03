//
//  ShowAlarmView.h
//  XMAlarm
//
//  Created by bo.chen on 17/10/30.
//  Copyright © 2017年 com.xmm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseAlarm.h"
#import "AlarmManager.h"

@interface ShowAlarmView : UIView
- (instancetype)initWithAlarm:(BaseAlarm *)alarm alarmLog:(AlarmLog *)alarmLog;
@property (nonatomic, strong) BaseAlarm *alarm;
@property (nonatomic, strong) AlarmLog *alarmLog;
- (void)show;
- (void)hideBy:(BOOL)later;
- (void)doLater:(NSNumber *)minutes;
@end
