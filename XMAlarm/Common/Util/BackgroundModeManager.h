//
//  BackgroundModeManager.h
//  PrintServer
//
//  Created by bo.chen on 15/7/29.
//  Copyright (c) 2015年 Beijing ShiShiKe Technologies Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

// 通过定时播放声音来启动后台模式，让打印服务器一直能在后台运行
@interface BackgroundModeManager : NSObject

+ (instancetype)sharedInstance;
- (void)openBackgroundMode;
- (void)stopBackgroundMode;

@end
