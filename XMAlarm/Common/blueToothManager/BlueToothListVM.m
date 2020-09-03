//
//  BlueToothListVM.m
//  kkkk
//
//  Created by Mac mini on 2018/4/20.
//  Copyright © 2018年 Mac mini. All rights reserved.
//

#import "BlueToothListVM.h"

@implementation BlueToothListVM
+ (NSArray *)removeSameElement:(CBPeripheral *)peripheral currentArr:(NSArray *)array {
    
    if (peripheral == nil) {
        if (array) {
            return array;
        }
        
        if (array == nil) {
            return @[];
        }
        
    }
    
    if (array == nil) {
        return @[peripheral];
    }
    
    if ([array containsObject:peripheral]) {
        return array;
    }
    
    NSMutableArray *temp = [NSMutableArray arrayWithArray:array];
    [temp addObject:peripheral];
    
    return temp;
}
@end
