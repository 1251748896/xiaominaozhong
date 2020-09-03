//
//  BlueToothListVM.h
//  kkkk
//
//  Created by Mac mini on 2018/4/20.
//  Copyright © 2018年 Mac mini. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
@interface BlueToothListVM : NSObject
+ (NSArray *)removeSameElement:(CBPeripheral *)peripheral currentArr:(NSArray *)array;
@end
