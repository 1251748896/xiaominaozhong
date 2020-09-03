//
//  TrafficLimitViewController.h
//  XMAlarm
//
//  Created by bo.chen on 17/9/20.
//  Copyright © 2017年 com.xmm. All rights reserved.
//

#import "BaseTableViewController.h"
#import "TrafficLimitAlarm.h"

/**
 * 编辑限行页面
 */
@interface TrafficLimitViewController : BaseTableViewController
@property (nonatomic, strong) TrafficLimitAlarm *alarm;
@property (nonatomic, assign) int showState;
@end
