//
//  ScheduleViewController.h
//  XMAlarm
//
//  Created by bo.chen on 17/9/5.
//  Copyright © 2017年 com.xmm. All rights reserved.
//

#import "BaseTableViewController.h"
#import "Schedule.h"

/**
 * 待办事项
 */
@interface ScheduleViewController : BaseViewController
@property (nonatomic, strong) Schedule *schedule;
@end
