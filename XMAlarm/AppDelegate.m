//
//  AppDelegate.m
//  XMAlarm
//
//  Created by bo.chen on 17/9/2.
//  Copyright © 2017年 com.xmm. All rights reserved.
//

#import "AppDelegate.h"
#import "SSKSqlitePersistentStore.h"
#import "BackgroundModeManager.h"
#import "VoicePlayer.h"
#import "AlarmManager.h"
#import "IntroSlideView.h"
#import "AppDelegate+JPush.h"
#import <SFHFKeychainUtils.h>
#import <ShareSDK/ShareSDK.h>
#import <ShareSDKConnector/ShareSDKConnector.h>
#import <WXApi.h>
CGFloat scaleRatio = 1.0f;

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    // Override point for customization after application launch.
    scaleRatio = deviceWidth/320;
    [self createDeviceId];
    [self initDefaults];
    [self updateData];
    [self configUmeng];
    [self registerPush:launchOptions];
    [self configShareSDK];
    [self createDatabase];
//    [[BackgroundModeManager sharedInstance] openBackgroundMode];
    // 启动网络状态变化监听
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
#if 0
    [[ApiClient sharedInstance] initHTTPDns];
    [[ApiClient sharedInstance] queryIpAddress];
    
    //注册本地通知
    UIUserNotificationType notificationTypes = UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:notificationTypes categories:nil];
    [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
#endif
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.rootViewController = [RootNavigationController sharedInstance];
    [self.window makeKeyAndVisible];
    
    //第一次启动进入启动介绍页面(给图后开启)
    if (![User_Default boolForKey:@"shownIntro"]) {
        IntroSlideView *intro = [[IntroSlideView alloc] initWithFrame:CGRectMake(0, 0, deviceWidth, deviceHeight)];
        [KEYWindow addSubview:intro];
        [User_Default setBool:YES forKey:@"shownIntro"];
    }
    
    //检查更新
    [self checkVersion];
    [[AlarmManager sharedInstance] uploadAlarmNum];
    
    // 记录app版本号，方便知道app是从什么版本升级到什么版本
    [User_Default setObject:APPVersionCode forKey:kAppVersionKey];
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    application.applicationIconBadgeNumber = 0;
    [[AlarmManager sharedInstance] adjustMoreAlarm];
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    //检查更新
    [self checkVersion];
    [[AlarmManager sharedInstance] updateHoliday:NULL];
    [[AlarmManager sharedInstance] uploadAlarmNum];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
    });
    //检查通知是否开启
    UIUserNotificationType types = [UIApplication sharedApplication].currentUserNotificationSettings.types;
    if (!(types & UIUserNotificationTypeSound)) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"检测到您没有开启通知声音，将会导致您收不到提醒，是否去设置" cancelButtonTitle:@"知道了" otherButtonTitle:@"去设置"];
        [alertView showUsingBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
            if (1 == buttonIndex) {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
            }
        }];
    }
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [[AlarmManager sharedInstance] refreshAlarmEnabled];
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - method

- (void)createDeviceId {
    NSString *deviceId = [SFHFKeychainUtils getPasswordForUsername:kDeviceIDKey andServiceName:kKeychainServiceName error:nil];
    if (deviceId.length <= 0) {
        deviceId = [UIDevice currentDevice].identifierForVendor.UUIDString;
        [User_Default setObject:deviceId forKey:kDeviceIDKey];
        [SFHFKeychainUtils storeUsername:kDeviceIDKey andPassword:deviceId forServiceName:kKeychainServiceName updateExisting:YES error:nil];
    } else {
        [User_Default setObject:deviceId forKey:kDeviceIDKey];
    }
}

- (void)configUmeng {
    [MobClick setCrashReportEnabled:YES];
    [MobClick setAppVersion:APPVersionCode];
    [MobClick setEncryptEnabled:YES];
    UMAnalyticsConfig *umengConfig = [[UMAnalyticsConfig alloc] init];
    umengConfig.appKey = kUmengAppKey;
    umengConfig.bCrashReportEnabled = YES;
    umengConfig.channelId = kChannel;
    [MobClick startWithConfigure:umengConfig];
}

- (void)configShareSDK {
    [ShareSDK registerActivePlatforms:@[@(SSDKPlatformTypeWechat)] onImport:^(SSDKPlatformType platformType) {
        switch (platformType)
        {
            case SSDKPlatformTypeWechat:
                [ShareSDKConnector connectWeChat:[WXApi class]];
                break;
            default:
                break;
        }
    } onConfiguration:^(SSDKPlatformType platformType, NSMutableDictionary *appInfo) {
        switch (platformType)
        {
            case SSDKPlatformTypeWechat:
                [appInfo SSDKSetupWeChatByAppId:@"wx30d5332b7ade93a6"
                                      appSecret:@"9f04aa1e2081633c20c7ead484fc0c0a"];
                break;
            default:
                break;
        }
    }];
}

#pragma mark - 创建数据库来开发测试

- (NSString *)databasePath {
    NSString *dbPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    dbPath = [dbPath stringByAppendingPathComponent:@"alarm.db"];
    DEBUG_LOG(@"%@", dbPath);
    return dbPath;
}

- (void)createDatabase {
    if ([SSKModel persitentStore]) return;
    NSString *path = [self databasePath];
    id <SSKModelPersistentStore> store = [[SSKSqlitePersistentStore alloc] initWithPath:path];
    [SSKModel setPersistentStore:store];
}

- (void)removeDatabase {
    NSString *path = [self databasePath];
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
    }
}

- (void)initDefaults {
    if (![User_Default objectForKey:kDisclaimerKnownKey]) {
        [User_Default setObject:@NO forKey:kDisclaimerKnownKey];
    }
    [User_Default synchronize];
}

- (void)updateData {
    if ([User_Default objectForKey:kAppVersionKey] && [[User_Default objectForKey:kAppVersionKey] compare:APPVersionCode options:NSNumericSearch] == NSOrderedAscending) {
        //app升级后重新恢复不响铃警告
        [User_Default setObject:@NO forKey:kDisclaimerKnownKey];
        [User_Default synchronize];
    }
}

- (void)checkVersion {
    [Api checkVersion:@{@"localVersion": APPVersionCode, @"type": @2} successBlock:^(id body) {
        NSString *servVer = body[@"curVersion"];
        NSString *upgradeMsg = body[@"upgradeMsg"];
        NSString *upgradeUrl = body[@"upgradeUrl"];
        if ([APPVersionCode compare:servVer options:NSNumericSearch] == NSOrderedAscending) {
            if (upgradeUrl.length <= 0) {
                upgradeUrl = kAppStoreLink;
            }
            if ([body[@"forceUpgrade"] boolValue]) {
                // 强制升级新版
                NSString *msg = @"很抱歉，需要升级新版本才能使用";
                if ([body[@"forceMsg"] length] > 0) {
                    msg = body[@"forceMsg"];
                }
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:msg message:upgradeMsg cancelButtonTitle:@"确定"];
                [alertView showUsingBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:upgradeUrl]];
                }];
            } else {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"升级到新版本%@", servVer] message:upgradeMsg cancelButtonTitle:@"取消" otherButtonTitle:@"升级"];
                [alertView showUsingBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                    if (1 == buttonIndex) {
                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:upgradeUrl]];
                    }
                }];
            }
        } else {
            //没有新版本
        }
    } failBlock:^(NSString *message, NSInteger code) {
    }];
}

@end
