//
//  CheckAlertView.h
//  XMAlarm
//
//  Created by bo.chen on 17/9/4.
//  Copyright © 2017年 com.xmm. All rights reserved.
//

#import "BaseTableViewCell.h"

@interface CheckAlertView : UIView
- (instancetype)initWithTitle:(NSString *)title dataSource:(NSArray *)dataSource checkedIndexes:(NSArray *)checkedIndexes cellTag:(TwoTitleCellTag)cellTag;
@property (nonatomic, copy) ObjectBlock sureBlock;
- (void)show;
@end

@interface CheckAlertCell : BaseTableViewCell
@property (nonatomic, strong) NSDictionary *dataDict;
@end
