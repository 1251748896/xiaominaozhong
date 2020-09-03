//
//  ShiftAlertView.h
//  XMAlarm
//
//  Created by bo.chen on 17/9/4.
//  Copyright © 2017年 com.xmm. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 * 倒班周期
 */
@interface ShiftAlertView : UIView
- (instancetype)initWithTitle:(NSString *)title currentPeriod:(NSInteger)period;
@property (nonatomic, copy) ObjectBlock sureBlock;
- (void)show;
@end
