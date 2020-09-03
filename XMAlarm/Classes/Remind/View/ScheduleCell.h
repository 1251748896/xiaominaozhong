//
//  ScheduleCell.h
//  XMAlarm
//
//  Created by bo.chen on 17/9/10.
//  Copyright © 2017年 com.xmm. All rights reserved.
//

#import "BaseTableViewCell.h"
#import "Schedule.h"

@interface ScheduleCell : BaseTableViewCell
@property (nonatomic, strong) Schedule *schedule;
@end
