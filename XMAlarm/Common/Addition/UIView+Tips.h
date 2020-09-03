//
//  UIView+Tips.h
//  OnMobile
//
//  Created by bo.chen on 15/10/28.
//  Copyright © 2015年 keruyun. All rights reserved.
//

#import <UIKit/UIKit.h>

#define KEYWindow [UIApplication sharedApplication].keyWindow
#define AlertWarning(text) UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:text delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil]; \
    [alertView show]

#define kLoadingViewTag 98789
#define kWarningViewTag 86767

@interface UIView (Tips)

/**
* 显示一个loading动画视图
* text: 动画的提示文案，注意不要太长
* disableTouch: 表示在显示动画时，是否允许触摸操作，YES为不允许触摸
*/
- (void)showLoadingView:(NSString *)text disableTouch:(BOOL)disableTouch;

- (void)showLoadingView:(BOOL)disableTouch;

/**
* 隐藏loading
*/
- (void)hideLoadingView;

/**
* 显示错误视图，会自动隐藏loading
*/
- (void)showErrorText:(NSString *)text;

/**
* 显示成功视图，会自动隐藏loading
*/
- (void)showSuccessText:(NSString *)text;

/**
* 显示不带图标的提示信息视图，会自动隐藏loading
*/
- (void)showWarningText:(NSString *)text;

@end
