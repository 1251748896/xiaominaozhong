//
//  CustomAlarmViewController.h
//  XMAlarm
//
//  Created by bo.chen on 17/9/4.
//  Copyright © 2017年 com.xmm. All rights reserved.
//

#import "BaseTableViewController.h"
#import "CustomAlarm.h"

/**
 * 自定义闹钟
 */
@interface CustomAlarmViewController : BaseTableViewController
@property (nonatomic, strong) CustomAlarm *alarm;
@end
