//
//  TwoTitleCell.h
//  XMAlarm
//
//  Created by bo.chen on 17/9/4.
//  Copyright © 2017年 com.xmm. All rights reserved.
//

#import "BaseTableViewCell.h"

@interface TwoTitleCell : BaseTableViewCell
@property (nonatomic, strong) NSDictionary *dataDict;
@property (nonatomic, readonly) UILabel *lbl1;
@property (nonatomic, readonly) UILabel *lbl2;
+ (CGFloat)height;
@end
