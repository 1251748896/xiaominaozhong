//
//  RepeatWeekdayCell.h
//  XMAlarm
//
//  Created by bo.chen on 17/9/11.
//  Copyright © 2017年 com.xmm. All rights reserved.
//

#import "BaseTableViewCell.h"

@interface RepeatWeekdayCell : BaseTableViewCell
@property (nonatomic, strong) NSNumber *selectedWeekday;
@property (nonatomic, copy) ObjectBlock tapBlock;
+ (CGFloat)height;
@end
