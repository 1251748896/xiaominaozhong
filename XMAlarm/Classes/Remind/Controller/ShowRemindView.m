//
//  ShowRemindView.m
//  XMAlarm
//
//  Created by bo.chen on 17/10/30.
//  Copyright © 2017年 com.xmm. All rights reserved.
//

#import "ShowRemindView.h"

@implementation ShowRemindView

- (UIImage *)bgImg {
    return [UIImage imageNamed:@"infor_remind_bg"];
}

- (NSString *)dateLblText {
    return [NSDateFormatter stringFromDate:[NSDate date] formatStr:kDateFormatStr];
}

- (UIImage *)iconViewImg {
    return [UIImage imageNamed:@"infor_icon_topremind"];
}

- (NSString *)lblText {
    return @"信息提示";
}

- (NSString *)timeLblText {
    return self.alarm.name;
}

- (AppNotiType)notiType {
    if ([self.alarm isMemberOfClass:[TempRemind class]]) {
        return AppNotiType_TempRemind;
    } else {
        return AppNotiType_RepeatRemind;
    }
}

- (void)sureBtnPressed:(id)sender {
    if ([self.alarm isMemberOfClass:[TempRemind class]]) {
        //自定义闹钟 临时提醒 提醒后就删除
        [self.alarm remove];
    }
    
    [self hideBy:NO];
}

@end
