//
//  BlueToothConfig.h
//  BlueToothCon
//
//  Created by 姜波 on 2018/4/21.
//  Copyright © 2018年 姜波. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TrafficLimitAlarm.h"

struct XMDate {
    int year;
    int month;
    int day;
    int week;
    
    NSTimeInterval interval;
};

struct XMHoliday {
    int oneYearMonth;
    int oneDay;
    
    int twoYearMonth;
    int twoDay;
    
    int thirdYearMonth;
    int thirdDay;
    
    int fourYearMonth;
    int fourDay;
    
    int fiveYearMonth;
    int fiveDay;
    
    int sixYearMonth;
    int sixDay;
    
    int sevenYearMonth;
    int sevenDay;
    
    int eightYearMonth;
    int eightDay;
    
    int nineYearMonth;
    int nineDay;
    
    BOOL success;
};

struct XMYearCheckDate {
    int year;
    int month;
    int day;
};

@interface BlueToothConfig : NSObject

/**1.返回同步数据的时间*/
+ (NSData *)getSyncTime ;
/**2.下发年检时间和限行时间*/
+ (NSData *)getYearCheckTimeAndRestrictionTimeWithModel:(TrafficLimitAlarm *)model;
/**3.解除年检更新报警*/
+ (NSData *)getUpdateInfoIsAlarm:(BOOL)alarm;
/**获取设备时间和车内温湿度*/
+ (NSData *)getDeviceTimeAndTemperature;
/**下发节假日*/
+ (NSData *)getHolidayData:(NSInteger)order;
+ (void)printAllHolidayInfo;
@end

/*
 
 1.链接蓝牙的入口
 
 2.链接成功和链接失败
 
 3.拼装数据
 
 4.发送数据给硬件
 
 5.收到硬件的返回信息
 
 6.传送成功
 
 7.传送失败，重新链接
 
 8.网络异常，传送中断
 
 1.点击 “确定” 按钮，是有返回操作的 ---> 不能进入 蓝牙list页面的bug
 2.限行列表--->底部label单独显示年检（开关关掉会隐藏）需要单独设置
 3.之前的提示语句弹窗（点击确定不会有反应），需要增加回调
 4.

 */





