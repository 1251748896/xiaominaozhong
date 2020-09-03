//
//  ForgetPwdViewController.m
//  XMAlarm
//
//  Created by bo.chen on 17/9/29.
//  Copyright © 2017年 com.xmm. All rights reserved.
//

#import "ForgetPwdViewController.h"

@interface ForgetPwdViewController ()

@end

@implementation ForgetPwdViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.titleLabel.text = @"找回密码";
}

- (void)execRequest:(NSDictionary *)params successBlock:(SuccessBlock)success failBlock:(FailBlock)fail {
    [Api resetPwd:params successBlock:success failBlock:fail];
}

@end
