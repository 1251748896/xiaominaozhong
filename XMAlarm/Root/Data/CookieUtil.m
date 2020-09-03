//
//  CookieUtil.m
//  Car
//
//  Created by bo.chen on 17/7/28.
//  Copyright © 2017年 com.smaradio. All rights reserved.
//

#import "CookieUtil.h"

@implementation Cookie

- (instancetype)initWithString:(NSString *)string {
    self = [super init];
    if (self) {
        NSArray *comps = [string componentsSeparatedByString:@"="];
        if (comps.count == 2) {
            self.name = comps[0];
            self.value = comps[1];
        }
    }
    return self;
}

- (BOOL)isEqual:(Cookie *)object {
    if (self == object) {
        return YES;
    }
    if (!object) {
        return NO;
    }
    if (![object isKindOfClass:[Cookie class]]) {
        return NO;
    }
    return self.name.length > 0 && object.name.length > 0 && [self.name isEqual:object.name];
}

- (NSString *)description {
    if (!self.name || !self.value) {
        return @"";
    }
    return [NSString stringWithFormat:@"%@=%@", SSJKString(self.name), SSJKString(self.value)];
}

@end

@implementation CookieUtil {
    NSMutableArray  *_cookies;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _cookies = [NSMutableArray array];
        //读取缓存的cookie
        [self addCookieBy:[User_Default objectForKey:@"cookie-cache"]];
    }
    return self;
}

- (NSString *)cookie {
    NSMutableString *str = [NSMutableString string];
    for (NSInteger i = 0; i < _cookies.count; i++) {
        Cookie *cookie = _cookies[i];
        [str appendString:[cookie description]];
        if (i < _cookies.count-1) {
            [str appendString:@";"];
        }
    }
    return str;
}

- (void)clean {
    [_cookies removeAllObjects];
}

- (void)addCookieBy:(NSString *)cookieStr {
    if (cookieStr.length > 0) {
        NSArray *comps = [cookieStr componentsSeparatedByString:@";"];
        for (NSString *str in comps) {
            [self addCookie:[[Cookie alloc] initWithString:str]];
        }
    }
}

- (NSString *)sessionId {
    for (Cookie *cookie in _cookies) {
        if ([cookie.name isEqualToString:@"SessionId"]) {
            return cookie.value;
        }
    }
    return @"";
}

- (void)addCookieByArray:(NSArray *)cookieStrArray {
    for (NSString *cookieStr in cookieStrArray) {
        NSArray *comps = [cookieStr componentsSeparatedByString:@";"];
        for (NSString *str in comps) {
            if ([str hasPrefix:@"SessionId"] || [str hasPrefix:@"AccessToken"]) {
                [self addCookie:[[Cookie alloc] initWithString:str]];
            }
        }
    }
}

- (void)addIosCookieStr:(NSString *)cookieStr {
    //"SessionId=C7DC4EEDC9094C22BE050950A51EFB91;Version=1;Path=/;Expires=Wed, 09-Aug-2017 09:43:50 GMT, AccessToken=6ebced8d-c026-6b6f-771b-fa102d1977a2;Version=1;Path=/;Expires=Wed, 09-Aug-2017 09:43:50 GMT"
    //"AccessToken=3e129b4f-a033-effe-b17d-9198e6ecd805;Version=1;Path=/;Expires=Sat, 12-Aug-2017 02:19:52 GMT"
    NSRange range = [cookieStr rangeOfString:@"AccessToken"];
    NSMutableArray *array = [NSMutableArray array];
    if (range.location > 0) {
        [array addObject:[cookieStr substringToIndex:range.location-2]];
    }
    if (range.location != NSNotFound) {
        [array addObject:[cookieStr substringFromIndex:range.location]];
    } else {
        [array addObject:cookieStr];
    }
    [self addCookieByArray:array];
}

- (void)addCookie:(Cookie *)cookie {
    NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
    for (NSInteger i = 0; i < _cookies.count; i++) {
        if ([_cookies[i] isEqual:cookie]) {
            [indexSet addIndex:i];
        }
    }
    [_cookies removeObjectsAtIndexes:indexSet];
    [_cookies addObject:cookie];
}

- (void)cache {
    NSString *cookie = [self cookie];
    if (cookie.length > 0) {
        [User_Default setObject:cookie forKey:@"cookie-cache"];
        [User_Default synchronize];
    }
}

- (void)removeCache {
    [User_Default removeObjectForKey:@"cookie-cache"];
    [User_Default synchronize];
}

@end
