//
//  UserModel.m
//  Car
//
//  Created by bo.chen on 16/12/5.
//  Copyright © 2016年 com.smaradio. All rights reserved.
//

#import "UserModel.h"

@implementation UserModel

- (NSString *)avatarUrlString {
    if ([self.avatar hasPrefix:@"http"]) {
        return self.avatar;
    } else {
        return [kAPIServer stringByAppendingPathComponent:self.avatar];
    }
}

@end
