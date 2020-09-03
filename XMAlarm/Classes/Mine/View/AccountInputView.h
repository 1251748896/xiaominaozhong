//
//  AccountInputView.h
//  Car
//
//  Created by bo.chen on 16/12/5.
//  Copyright © 2016年 com.smaradio. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 * 登录界面相关的输入视图
 */
@interface AccountInputView : UIView
- (instancetype)initWithIconName:(NSString *)iconName placeholder:(NSString *)placeholder;
@property (nonatomic, readonly) UITextField *textFd;

@property (nonatomic, copy) NSString *objKey;
@property (nonatomic, copy) NSString *objName;
@property (nonatomic, copy) NSString *regex;//正则表达式
- (NSString *)checkValueError;
@end
