//
//  SwitchButton.m
//  XMAlarm
//
//  Created by bo.chen on 17/9/6.
//  Copyright © 2017年 com.xmm. All rights reserved.
//

#import "SwitchButton.h"

@implementation SwitchButton

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setBackgroundImage:[UIImage imageNamed:@"btn_puttingoff"] forState:UIControlStateNormal];
        [self setImage:[UIImage imageNamed:@"btn_switch_button"] forState:UIControlStateNormal];
        
        [self setEnlargeEdgeWithTop:15 right:0 bottom:15 left:0];
        
        self.on = NO;
    }
    return self;
}

- (void)setOn:(BOOL)on {
    _on = on;
    
    [self setBackgroundImage:[UIImage imageNamed:on ? @"btn_puttingon" : @"btn_puttingoff"] forState:UIControlStateNormal];
    self.imageEdgeInsets = UIEdgeInsetsZero;
    if (on) {
        self.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        self.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 1);
    } else {
        self.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        self.imageEdgeInsets = UIEdgeInsetsMake(0, 1, 0, 0);
    }
}

@end
