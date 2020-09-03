//
//  TrafficRemindAllCell.h
//  XMAlarm
//
//  Created by bo.chen on 17/9/20.
//  Copyright © 2017年 com.xmm. All rights reserved.
//

#import "BaseTableViewCell.h"

/**
 * 编辑限行页面的所有限行提醒
 */
@interface TrafficRemindAllCell : BaseTableViewCell
@property (nonatomic, strong) NSArray *remindArray;//remindSettings
+ (CGFloat)heightWithRemindArray:(NSArray *)remindArray;
@end
