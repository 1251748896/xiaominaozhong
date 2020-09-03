//
//  RootNavigationController.m
//  OnMobile
//
//  Created by bo.chen on 15/9/25.
//  Copyright © 2015年 keruyun. All rights reserved.
//

#import "RootNavigationController.h"
#import "LoginViewController.h"
#import "TabBarViewController.h"
#import <LGSideMenuController.h>
#import "LeftMenuViewController.h"

@implementation RootNavigationController

+ (instancetype)sharedInstance {
    static RootNavigationController *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[RootNavigationController alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setNavigtaionBarStyle];
    }
    return self;
}

- (void)setNavigtaionBarStyle {
    [[UINavigationBar appearance] setBarTintColor:HexGRAY(0x3A, 255)];
    [[UINavigationBar appearance] setTintColor:HexGRAY(0xFA, 255)];
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName : HexGRAY(0xFF, 255)}];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationBarHidden = YES;
//    [self toggleLoginView];
    [self toggleHomeView];
}

/**
 * 从当前可前的导航Controller push
 */
- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if (self.visibleViewController.navigationController && self.visibleViewController.navigationController != self) {
        [self.visibleViewController.navigationController pushViewController:viewController animated:animated];
    } else {
        [super pushViewController:viewController animated:animated];
    }
}

/**
 * 保证展现的controller都放到UINavigationController中
 */
- (void)presentViewController:(UIViewController *)viewControllerToPresent animated:(BOOL)flag completion:(void (^)(void))completion {
    if ([viewControllerToPresent isKindOfClass:[UINavigationController class]]) {
        [super presentViewController:viewControllerToPresent animated:flag completion:completion];
    } else {
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:viewControllerToPresent];
        navController.navigationBarHidden = YES;
        [super presentViewController:navController animated:flag completion:completion];
    }
}

#pragma mark - public

- (void)toggleHomeView {
    if (self.presentingLoginView) {
        [self dismissViewControllerAnimated:YES completion:^{
            self.presentingLoginView = NO;
        }];
        return;
    }
#if 0
    TabBarViewController *controller = [[TabBarViewController alloc] init];
    self.viewControllers = @[controller];
    self.restorationIdentifier = @"TabBarViewController";
#else
    LGSideMenuController *controller = [LGSideMenuController sideMenuControllerWithRootViewController:[[TabBarViewController alloc] init] leftViewController:[[LeftMenuViewController alloc] init] rightViewController:nil];
    controller.automaticallyAdjustsScrollViewInsets = NO;
    controller.leftViewPresentationStyle = LGSideMenuPresentationStyleSlideBelow;
    controller.leftViewWidth = kMenuWidth;
    self.viewControllers = @[controller];
    self.restorationIdentifier = @"LGSideMenuController";
#endif
}

- (void)toggleLoginView {
    LoginViewController *controller = [[LoginViewController alloc] init];
    self.viewControllers = @[controller];
    self.restorationIdentifier = @"LoginViewController";
}

@end
