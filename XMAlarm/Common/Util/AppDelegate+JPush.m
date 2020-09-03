//
//  AppDelegate+JPush.m
//  VoiceBox
//
//  Created by bo.chen on 16/3/30.
//  Copyright © 2016年 helfy. All rights reserved.
//

#import "AppDelegate+JPush.h"
#import "JPUSHService.h"

@implementation AppDelegate (JPush)

/**
* 注册jpush
*/
- (void)registerPush:(NSDictionary *)launchOptions {
    //可以添加自定义categories
    [JPUSHService registerForRemoteNotificationTypes:(UIUserNotificationTypeBadge |
                    UIUserNotificationTypeSound |
                    UIUserNotificationTypeAlert)
                                          categories:nil];
//    [JPUSHService setDebugMode];
    [JPUSHService setLogOFF];
#ifdef DEBUG
    BOOL isProduction = NO;
#else
    BOOL isProduction = YES;
#endif
    [JPUSHService setupWithOption:launchOptions appKey:kJpushAppKey channel:kChannel apsForProduction:isProduction];
}

#pragma mark - APNS

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    [JPUSHService registerDeviceToken:deviceToken];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    DEBUG_LOG(@"%@", error);
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    DEBUG_LOG(@"%@", [userInfo JSONString_JSONKit]);
}

@end
