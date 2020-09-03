//
//  RemindTimeAlertView.h
//  XMAlarm
//
//  Created by bo.chen on 17/9/29.
//  Copyright © 2017年 com.xmm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RemindSetting.h"

@interface RemindTimeAlertView : UIView
- (instancetype)initWithTitle:(NSString *)title remindSetting:(RemindSetting *)setting;
@property (nonatomic, copy) ObjectBlock sureBlock;
- (void)show;
@end
