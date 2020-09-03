//
//  PlateNumber2ViewController.h
//  XMAlarm
//
//  Created by bo.chen on 17/10/29.
//  Copyright © 2017年 com.xmm. All rights reserved.
//

#import "BaseViewController.h"
#import "TrafficLimitAlarm.h"

@interface PlateNumber2ViewController : BaseViewController
- (instancetype)initWithPlateNumber:(NSString *)plateNumber;
@property (nonatomic, assign) BOOL initAdd;//表示初始化添加
@property (nonatomic, strong) TrafficLimitAlarm *alarm;
@property (nonatomic, copy) ObjectBlock sureBlock;

/*
 针对修改车牌的毁掉函数
 */
@property (nonatomic, copy) void(^fixCity)(NSString * , int);


@end
