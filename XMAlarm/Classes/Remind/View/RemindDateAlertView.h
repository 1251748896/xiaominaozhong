//
//  RemindDateAlertView.h
//  XMAlarm
//
//  Created by bo.chen on 17/9/10.
//  Copyright © 2017年 com.xmm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JTCalendar.h"

/**
 * 临时提醒日期
 */
@interface RemindDateAlertView : UIView
- (instancetype)initWithTitle:(NSString *)title date:(NSDate *)date;
@property (nonatomic, strong) ObjectBlock sureBlock;
- (void)show;
@end

@interface CalenderDayView: JTCalendarDayView
@property (nonatomic, readonly) UILabel *twoLbl;
@end
