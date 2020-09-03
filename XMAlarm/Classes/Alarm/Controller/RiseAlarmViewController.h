//
//  RiseAlarmViewController.h
//  XMAlarm
//
//  Created by bo.chen on 17/9/4.
//  Copyright © 2017年 com.xmm. All rights reserved.
//

#import "BaseTableViewController.h"
#import "RiseAlarm.h"

/**
 * 起床闹钟
 */
@interface RiseAlarmViewController : BaseTableViewController
@property (nonatomic, strong) RiseAlarm *alarm;
@end
