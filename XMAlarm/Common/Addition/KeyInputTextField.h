//
//  KeyInputTextField.h
//  Car
//
//  Created by bo.chen on 17/5/16.
//  Copyright © 2017年 com.smaradio. All rights reserved.
//

#import <UIKit/UIKit.h>

@class KeyInputTextField;

@protocol KeyInputTextFieldDelegate <NSObject>

@optional
- (void)deleteBackward:(KeyInputTextField *)textField;//点击键盘的删除按键，抛出代理

@end

@interface KeyInputTextField : UITextField
@property (nonatomic, weak) id<KeyInputTextFieldDelegate> keyInputDelegate;
@end
