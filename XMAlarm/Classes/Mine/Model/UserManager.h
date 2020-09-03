//
//  UserManager.h
//  Car
//
//  Created by bo.chen on 16/12/5.
//  Copyright © 2016年 com.smaradio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UserModel.h"

#define TheUser [UserManager sharedInstance].user

#define kUserDidChangeKey @"UserDidChangeKey"

@interface UserManager : NSObject
+ (instancetype)sharedInstance;
@property (nonatomic, strong) UserModel *user;

- (BOOL)isLogin;
- (void)userDidChange:(UserModel *)user;
- (void)exitLogin;

@end
