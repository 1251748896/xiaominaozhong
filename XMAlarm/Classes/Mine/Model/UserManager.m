//
//  UserManager.m
//  Car
//
//  Created by bo.chen on 16/12/5.
//  Copyright © 2016年 com.smaradio. All rights reserved.
//

#import "UserManager.h"
#import <JPUSHService.h>

#define kCacheUserKey @"CacheUser"

@implementation UserManager

+ (instancetype)sharedInstance {
    static UserManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[UserManager alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        NSDictionary *userDict = [User_Default objectForKey:kCacheUserKey];
        if (userDict) {
            UserModel *user = [UserModel modelFromJSONDictionary:userDict];
            [self userDidChange:user];
        }
    }
    return self;
}

- (BOOL)isLogin {
    return (self.user != nil && self.user.id != nil);
}

- (void)userDidChange:(UserModel *)user {
    self.user = user;
//    [JPUSHService setTags:[NSSet set] alias:user.id fetchCompletionHandle:^(int iResCode, NSSet *iTags, NSString *iAlias) {
//        DEBUG_LOG(@"%d %@ %@", iResCode, iTags, iAlias);
//    }];
    //保存已登录账号信息
    [User_Default setObject:[NSDictionary recursiveRemoveNSNull:[user JSONDictionary]] forKey:kCacheUserKey];
    [[NSNotificationCenter defaultCenter] postNotificationName:kUserDidChangeKey object:nil];
}

- (void)exitLogin {
    [User_Default removeObjectForKey:kCacheUserKey];
    [User_Default synchronize];
    self.user = nil;
    [[NSNotificationCenter defaultCenter] postNotificationName:kUserDidChangeKey object:nil];
    //刷新闹钟列表
    [[NSNotificationCenter defaultCenter] postNotificationName:kRefreshAlarmList object:nil];
    //清除缓存的cookie
    ApiClient *apiClient = [ApiClient sharedInstance];
    [apiClient.cookieUtil clean];
    [apiClient.cookieUtil removeCache];
}

@end
