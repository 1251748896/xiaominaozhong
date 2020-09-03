//
//  BaseHomeCell.h
//  XMAlarm
//
//  Created by bo.chen on 17/10/15.
//  Copyright © 2017年 com.xmm. All rights reserved.
//

#import "BaseTableViewCell.h"
#import "BaseAlarm.h"
#import "SwitchButton.h"

@interface BaseHomeCell : BaseTableViewCell
@property (nonatomic, strong) BaseAlarm *alarm;
@property (nonatomic, strong) UILabel *infoLbl;
@property (nonatomic, strong) SwitchButton *enableBtn;
@end
