//
//  AppDelegate+JPush.h
//  VoiceBox
//
//  Created by bo.chen on 16/3/30.
//  Copyright © 2016年 helfy. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate (JPush)

/**
* 注册jpush
*/
- (void)registerPush:(NSDictionary *)launchOptions;

@end
