//
//  ShiftAlarmViewController.h
//  XMAlarm
//
//  Created by bo.chen on 17/9/4.
//  Copyright © 2017年 com.xmm. All rights reserved.
//

#import "BaseTableViewController.h"
#import "ShiftAlarm.h"

/**
 * 倒班闹钟
 */
@interface ShiftAlarmViewController : BaseTableViewController
@property (nonatomic, strong) ShiftAlarm *alarm;
@end
