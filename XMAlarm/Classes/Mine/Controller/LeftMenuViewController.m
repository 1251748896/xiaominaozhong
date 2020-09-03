//
//  LeftMenuViewController.m
//  XMAlarm
//
//  Created by bo.chen on 17/9/30.
//  Copyright © 2017年 com.xmm. All rights reserved.
//

#import "LeftMenuViewController.h"
#import "LoginViewController.h"
#import "ModifyPwdViewController.h"
#import "SettingViewController.h"
#import <LGSideMenuController.h>
#import "ShareViewController.h"

#define kBtnHeight Expand6(48, 50)

@interface LeftMenuViewController ()
{
    UIButton    *_userBtn;
}
@end

@implementation LeftMenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self addBackBtn];
    [self setupView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateUser:) name:kUserDidChangeKey object:nil];
}

- (UIView *)topView {
    return nil;
}

#pragma mark - view

- (void)setupView {
    self.view.backgroundColor = HexRGBA(0x222E46, 255);
    
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = CGRectMake(0, GAP20, 44, 44);
    [backBtn setImage:[UIImage imageNamed:@"preson_icon_back"] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(backBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backBtn];
    
    static NSString *iconStrs[] = {@"preson_icon_land", @"preson_icon_password", @"preson_icon_setup", @"preson_icon_share"};
    static NSString *titleStrs[] = {@"登录\\注册", @"修改密码", @"设置", @"分享"};
    CGFloat top = (deviceHeight-64-4*kBtnHeight)/2;
    for (NSInteger i = 0; i < 4; i++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(0, top+kBtnHeight*i, kMenuWidth, kBtnHeight);
        btn.titleLabel.font = [UIFont systemFontOfSize:Expand6(14, 15)];
        [btn setTitleColor:HexRGBA(0xFFFFFF, 255) forState:UIControlStateNormal];
        [btn setImage:[UIImage imageNamed:iconStrs[i]] forState:UIControlStateNormal];
        btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        btn.imageEdgeInsets = UIEdgeInsetsMake(0, 30*scaleRatio, 0, 0);
        btn.titleEdgeInsets = UIEdgeInsetsMake(0, 50*scaleRatio, 0, 0);
        [btn setTitle:titleStrs[i] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(btnPressed:) forControlEvents:UIControlEventTouchUpInside];
        btn.tag = i+1;
        [self.view addSubview:btn];
        if (0 == i) {
            _userBtn = btn;
            if ([[UserManager sharedInstance] isLogin]) {
                [_userBtn setTitle:TheUser.mobile forState:UIControlStateNormal];
            }
        }
    }
}

- (void)updateUser:(id)notification {
    if ([[UserManager sharedInstance] isLogin]) {
        [_userBtn setTitle:TheUser.mobile forState:UIControlStateNormal];
    } else {
        [_userBtn setTitle:@"登录\\注册" forState:UIControlStateNormal];
    }
}

#pragma mark - action

- (void)backBtnPressed:(id)sender {
    LGSideMenuController *controller = (LGSideMenuController *)[RootNavigationController sharedInstance].topViewController;
    [controller hideLeftViewAnimated:YES completionHandler:^{
        
    }];
}

- (void)hideAndPushController:(UIViewController *)controller {
    [self backBtnPressed:nil];
    
    [[RootNavigationController sharedInstance] pushViewController:controller animated:YES];
}

- (void)btnPressed:(UIButton *)sender {
    NSInteger index = sender.tag-1;
    if (0 == index) {
        if ([[UserManager sharedInstance] isLogin]) {
            [self.view showWarningText:@"已登录"];
        } else {
            LoginViewController *controller = [[LoginViewController alloc] init];
            [self hideAndPushController:controller];
        }
    } else if (1 == index) {
        if ([[UserManager sharedInstance] isLogin]) {
            ModifyPwdViewController *controller = [[ModifyPwdViewController alloc] init];
            [self hideAndPushController:controller];
        } else {
            [self.view showWarningText:@"请先登录\\注册"];
        }
    } else if (2 == index) {
        SettingViewController *controller = [[SettingViewController alloc] init];
        [self hideAndPushController:controller];
    } else if (3 == index) {
        ShareViewController *controller = [[ShareViewController alloc] init];
        [self hideAndPushController:controller];
    }
}

@end
