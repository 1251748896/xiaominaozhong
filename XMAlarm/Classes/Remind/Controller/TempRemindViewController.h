//
//  TempRemindViewController.h
//  XMAlarm
//
//  Created by bo.chen on 17/9/5.
//  Copyright © 2017年 com.xmm. All rights reserved.
//

#import "BaseTableViewController.h"
#import "TempRemind.h"

/**
 * 临时提醒
 */
@interface TempRemindViewController : BaseTableViewController
@property (nonatomic, strong) TempRemind *alarm;
@end
