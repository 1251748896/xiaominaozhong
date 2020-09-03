//
//  DriveCardDateViewController.h
//  XMAlarm
//
//  Created by Mac mini on 2018/4/26.
//  Copyright © 2018年 com.xmm. All rights reserved.
//

#import "BaseViewController.h"
#import "TrafficLimitAlarm.h"


// 这个类的名字有问题：DriveCard不是车牌号，而是 = 驾驶证日期controller
@interface DriveCardDateViewController : BaseViewController
@property (nonatomic, assign) BOOL initAdd;//表示初始化添加
@property (nonatomic, strong) TrafficLimitAlarm *alarm;
@property (nonatomic, copy) void(^fixDateBlock)(void);
@property (nonatomic, assign) int showState;
@end
