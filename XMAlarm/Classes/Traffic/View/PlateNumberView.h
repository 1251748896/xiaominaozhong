//
//  PlateNumberView.h
//  Car
//
//  Created by bo.chen on 17/4/4.
//  Copyright © 2017年 com.smaradio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TrafficLimitAlarm.h"

/**
 * 编辑车牌号视图
 */
@interface PlateNumberView : UIView
- (instancetype)initWithModel:(NSString *)plateNumber;
@property (nonatomic, copy) NoparamBlock didCancelBlock;
@property (nonatomic, copy) ObjectBlock didSaveBlock;
- (void)show;
@end
