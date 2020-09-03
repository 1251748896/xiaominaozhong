//
//  RepeatMonthCell.h
//  XMAlarm
//
//  Created by bo.chen on 17/9/11.
//  Copyright © 2017年 com.xmm. All rights reserved.
//

#import "BaseTableViewCell.h"

@interface RepeatMonthCell : BaseTableViewCell
@property (nonatomic, strong) NSNumber *selectedDay;
@property (nonatomic, copy) ObjectBlock tapBlock;
+ (CGFloat)height;
@end
