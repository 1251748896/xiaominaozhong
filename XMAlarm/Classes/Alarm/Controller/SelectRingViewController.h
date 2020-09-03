//
//  SelectRingViewController.h
//  XMAlarm
//
//  Created by bo.chen on 17/9/5.
//  Copyright © 2017年 com.xmm. All rights reserved.
//

#import "BaseTableViewController.h"
#import "BaseTableViewCell.h"
#import "BaseAlarm.h"

/**
 * 选择铃声
 */
@interface SelectRingViewController : BaseTableViewController
@property (nonatomic, strong) BaseAlarm *alarm;
@property (nonatomic, strong) ObjectBlock sureBlock;
@end

@interface SelectRingCell : BaseTableViewCell
@property (nonatomic, strong) NSDictionary *dataDict;
@end
