//
//  ShiftWorkAlertView.h
//  XMAlarm
//
//  Created by bo.chen on 17/9/8.
//  Copyright © 2017年 com.xmm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ShiftAlarm.h"

/**
 * 设置上班时间和休息
 */
@interface ShiftWorkAlertView : UIView
- (instancetype)initWithTitle:(NSString *)title workInfo:(ShiftWorkInfo *)workInfo;
@property (nonatomic, copy) ObjectBlock sureBlock;
- (void)show;
@end
