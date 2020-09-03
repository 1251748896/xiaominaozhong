//
//  RepeatYearCell.h
//  XMAlarm
//
//  Created by bo.chen on 17/9/11.
//  Copyright © 2017年 com.xmm. All rights reserved.
//

#import "BaseTableViewCell.h"

@interface RepeatYearCell : BaseTableViewCell
@property (nonatomic, strong) NSNumber *selectedMonth;
@property (nonatomic, strong) NSNumber *selectedMonthDay;
@property (nonatomic, copy) ObjectBlock monthBlock;
@property (nonatomic, copy) ObjectBlock monthDayBlock;
+ (CGFloat)height;
@end
