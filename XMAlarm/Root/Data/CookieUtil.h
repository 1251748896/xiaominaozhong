//
//  CookieUtil.h
//  Car
//
//  Created by bo.chen on 17/7/28.
//  Copyright © 2017年 com.smaradio. All rights reserved.
//

#import <Foundation/Foundation.h>

#define COOKIE_KEY @"Set-Cookie"
#define CLIENT_COOKIE @"Cookie"

@interface Cookie : NSObject
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *value;
- (instancetype)initWithString:(NSString *)string;
@end

@interface CookieUtil : NSObject
- (NSString *)cookie;
- (void)clean;
- (void)addCookieBy:(NSString *)cookieStr;
- (NSString *)sessionId;
- (void)addCookieByArray:(NSArray *)cookieStrArray;
- (void)addIosCookieStr:(NSString *)cookieStr;
- (void)addCookie:(Cookie *)cookie;

- (void)cache;
- (void)removeCache;
@end
