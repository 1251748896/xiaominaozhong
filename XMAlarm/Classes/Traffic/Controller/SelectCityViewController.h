//
//  SelectCityViewController.h
//  XMAlarm
//
//  Created by bo.chen on 17/9/20.
//  Copyright © 2017年 com.xmm. All rights reserved.
//

#import "BaseTableViewController.h"
#import "TrafficLimitAlarm.h"

/*
 这个页面----不限行车辆可以确定showState = 13
 limitMode == 6 (本地车不限行，外地车部分限行) 能确定showState = 12
 模式1~5，不能确定showState
 */


@interface SelectCityViewController : BaseTableViewController
@property (nonatomic, assign) BOOL initAdd;//表示初始化添加
@property (nonatomic, strong) TrafficLimitAlarm *alarm;
@property (nonatomic, strong) NoparamBlock sureBlock;

@end
