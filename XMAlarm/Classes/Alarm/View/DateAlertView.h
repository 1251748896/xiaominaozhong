//
//  DateAlertView.h
//  XMAlarm
//
//  Created by bo.chen on 17/9/4.
//  Copyright © 2017年 com.xmm. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DateAlertView : UIView
- (instancetype)initWithTitle:(NSString *)title date:(NSDate *)date mode:(UIDatePickerMode)mode;
@property (nonatomic, readonly) UIDatePicker *picker;
@property (nonatomic, assign) BOOL canSelectedAllDate;
@property (nonatomic, copy) ObjectBlock sureBlock;
@property (nonatomic, copy) void(^cancleBlock)(void);
- (void)show;
@end
