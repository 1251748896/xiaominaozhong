//
//  ZZXBluetoothManager.h
//  kkkk
//
//  Created by Mac mini on 2018/4/20.
//  Copyright © 2018年 Mac mini. All rights reserved.
//

#import <Foundation/Foundation.h>

#define FINDBLUETOOTH @"FINDBLUETOOTH"
#define FINISHSEND @"FINISHSEND"
#define REMOVEAllDATA @"REMOVEAllDATA"

#import <CoreBluetooth/CoreBluetooth.h>

@interface ZZXBluetoothManager : NSObject

@property (nonatomic) NSArray *holidayArray;
/** 连接到的外设 */
@property (nonatomic, strong) CBPeripheral *peripheral;
/** 中心管理者 */
@property (nonatomic, strong) CBCentralManager *cMgr;
@property (nonatomic, assign) NSInteger sendOrder;

// BabyBluetooth 很好的三方库
+ (instancetype)shared;
- (void)startWork ;

+ (void)connectToPeriphal:(CBPeripheral *)periphal;
+ (void)sendDataToCurrentDevice:(NSData *)data;

+ (void)stopWork ;


/*
 1.时间跑的非常快（约10秒 = 跳一分钟）
 2.永远显示：“年审到期”
 3.新收到的两个显示器都有问题。以前的就显示器正常
 4.当天限行的车子，需要同步2次，屏幕上才显示“今日限行”
 */


@end
