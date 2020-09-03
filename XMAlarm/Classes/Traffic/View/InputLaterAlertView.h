//
//  InputLaterAlertView.h
//  XMAlarm
//
//  Created by bo.chen on 17/11/7.
//  Copyright © 2017年 com.xmm. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InputLaterAlertView : UIView
@property (nonatomic, copy) ObjectBlock sureBlock;
- (void)show;
@end
