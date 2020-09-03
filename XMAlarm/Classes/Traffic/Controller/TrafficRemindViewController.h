//
//  TrafficRemindViewController.h
//  XMAlarm
//
//  Created by bo.chen on 17/9/20.
//  Copyright © 2017年 com.xmm. All rights reserved.
//

#import "BaseTableViewController.h"
#import "TrafficLimitAlarm.h"

/**
 * 限行提醒设置
 */
@interface TrafficRemindViewController : BaseTableViewController
@property (nonatomic, strong) TrafficLimitAlarm *alarm;
@property (nonatomic, copy) NoparamBlock updateBlock;
@end
