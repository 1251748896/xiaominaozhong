//
//  NameAlertView.h
//  XMAlarm
//
//  Created by bo.chen on 17/9/4.
//  Copyright © 2017年 com.xmm. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NameAlertView : UIView
- (instancetype)initWithTitle:(NSString *)title name:(NSString *)name placeholder:(NSString *)placeholder;
@property (nonatomic, copy) ObjectBlock sureBlock;
- (void)show;
@end
