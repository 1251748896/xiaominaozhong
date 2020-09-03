//
//  CustomAlarm.h
//  XMAlarm
//
//  Created by bo.chen on 17/9/5.
//  Copyright © 2017年 com.xmm. All rights reserved.
//

#import "BaseAlarm.h"

@interface CustomAlarm : BaseAlarm
@property (nonatomic, strong) NSDate *datetime;//日期时间
@property (nonatomic, strong) NSNumber *sleepTime;//贪睡设置
- (NSString *)formatDateStr;
@end
