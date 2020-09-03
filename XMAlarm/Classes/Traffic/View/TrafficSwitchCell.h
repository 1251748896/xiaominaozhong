//
//  TrafficSwitchCell.h
//  XMAlarm
//
//  Created by bo.chen on 17/9/20.
//  Copyright © 2017年 com.xmm. All rights reserved.
//

#import "BaseTableViewCell.h"

/**
 * 限行里面的开关选项cell
 */
@interface TrafficSwitchCell : BaseTableViewCell
@property (nonatomic, strong) NSDictionary *dataDict;
@property (nonatomic, copy) ObjectBlock tapSwitchBlock;
+ (CGFloat)heightWithDataDict:(NSDictionary *)dataDict;
@end
