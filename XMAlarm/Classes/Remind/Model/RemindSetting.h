//
//  RemindSetting.h
//  XMAlarm
//
//  Created by bo.chen on 17/9/23.
//  Copyright © 2017年 com.xmm. All rights reserved.
//

#import "BaseModel.h"
#import "BaseAlarm.h"

@interface RemindSetting : BaseModel
@property (nonatomic, strong) NSNumber *preDay; //前几天提醒 当天为0 前一天为1
@property (nonatomic, strong) NSDate *time;//时间
- (NSString *)formatTrafficRemindStr;
@end
