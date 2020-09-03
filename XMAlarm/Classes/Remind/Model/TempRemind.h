//
//  TempRemind.h
//  XMAlarm
//
//  Created by bo.chen on 17/9/10.
//  Copyright © 2017年 com.xmm. All rights reserved.
//

#import "BaseAlarm.h"

@interface TempRemind : BaseAlarm
@property (nonatomic, strong) NSDate *datetime;//日期时间
- (NSString *)formatDateStr;
@end
