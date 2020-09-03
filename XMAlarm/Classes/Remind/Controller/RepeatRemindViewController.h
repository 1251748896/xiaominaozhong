//
//  RepeatRemindViewController.h
//  XMAlarm
//
//  Created by bo.chen on 17/9/10.
//  Copyright © 2017年 com.xmm. All rights reserved.
//

#import "BaseTableViewController.h"
#import "RepeatRemind.h"

/**
 * 周期性提醒
 */
@interface RepeatRemindViewController : BaseTableViewController
@property (nonatomic, strong) RepeatRemind *alarm;
@end
