//
//  BaseViewController.m
//  OnMobile
//
//  Created by bo.chen on 15/9/25.
//  Copyright © 2015年 keruyun. All rights reserved.
//

#import "BaseViewController.h"

#define kTopBgViewTag 7834

@implementation BaseViewController

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    DEBUG_LOG(@"%@ dealloc", NSStringFromClass([self class]));
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = BKGCOLOR;
    [self topView];
    NSLog(@"ppppp = %@",self.navigationController.viewControllers);
    
    if (self.navigationController.viewControllers.count > 1) {
        [self addBackBtn];
        [_backBtn setTitleColor:UIColorFromRGB(0xb4b4b5) forState:UIControlStateHighlighted];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    [[UIMenuController sharedMenuController] setMenuVisible:NO animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

#pragma mark - Status Bar

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (BOOL)prefersStatusBarHidden {
    return NO;
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation {
    return UIStatusBarAnimationNone;
}

#pragma mark - use system nav bar

- (UINavigationItem *)navigationItem {
    UINavigationItem *item = self.navigationController.navigationBar.topItem;
    if (item) {
        return item;
    } else {
        return [super navigationItem];
    }
}

#pragma mark - nav bar

- (UIView *)topView {
    if (!_topView) {
        
        UIView *topView = [[UIView alloc] initWithFrame:CGRectMake(0, GAP20, deviceWidth, topBarHeight)];
        [self.view addSubview:topView];
        
        UIImageView *bgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, -GAP20, deviceWidth, topBarHeight + GAP20)];
        bgView.backgroundColor = [self topViewbackColor];
        bgView.image = [[UIImage imageNamed:@"nav_bg"] getImageResize];
        bgView.tag = kTopBgViewTag;
        [topView addSubview:bgView];
        
        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.frame = CGRectMake(44, (topView.height - topBarHeight) / 2, deviceWidth - 88, topBarHeight);
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.font = [UIFont fontWithName:FONTSTYLEBOLD size:17];
        titleLabel.textColor = NAVTEXTCOLOR;
        titleLabel.textAlignment = NSTextAlignmentCenter;
        [topView addSubview:titleLabel];

        _titleLabel = titleLabel;
        _topView = topView;
    }
    return _topView;
}

- (UIColor *)topViewbackColor {
    return NAVBARCOLOR;
}

- (UIImageView *)topBgView {
    return [self.topView viewWithTag:kTopBgViewTag];
}

- (void)addBackBtn {
    NSLog(@"添加返回按钮");
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = CGRectMake(0, 0, 44, 44);
    [backBtn setImage:[UIImage imageNamed:@"icon_return_1"] forState:UIControlStateNormal];
//    backBtn.showsTouchWhenHighlighted = YES;
    [backBtn addTarget:self action:@selector(backBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.topView addSubview:backBtn];
    _backBtn = backBtn;
}

- (void)backBtnPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (UIButton *)customRightTextBtn:(NSString *)text action:(SEL)action {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(deviceWidth - 4 - 44, 0, 44, 44);
    btn.titleLabel.font = [UIFont fontWithName:FONTSTYLE size:16];
    CGSize size = MB_TEXTSIZE(text, btn.titleLabel.font);
    btn.width = MAX(44, 16 + ceilf(size.width));
    btn.left = deviceWidth - 4 - btn.width;
    [btn setTitle:text forState:UIControlStateNormal];
    [btn addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    [self.topView addSubview:btn];
    return btn;
}


- (UIButton *)customRightTextBtn2:(NSString *)text action:(SEL)action {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(deviceWidth - 4 - 44 - 50, 0, 44, 44);
    btn.titleLabel.font = [UIFont fontWithName:FONTSTYLE size:16];
    CGSize size = MB_TEXTSIZE(text, btn.titleLabel.font);
    btn.width = MAX(44, 16 + ceilf(size.width));
    btn.left = deviceWidth - 4 - btn.width - 50;
    [btn setTitle:text forState:UIControlStateNormal];
    [btn addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    [self.topView addSubview:btn];
    return btn;
}

- (UIButton *)customRightImgBtn:(UIImage *)img1 img2:(UIImage *)img2 action:(SEL)action {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(deviceWidth - 4 - 44, 0, 44, 44);
    [btn setImage:img1 forState:UIControlStateNormal];
    [btn setImage:img2 forState:UIControlStateHighlighted];
    [btn addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    [self.topView addSubview:btn];
    return btn;
}

- (UIButton *)customLeftImgBtn:(UIImage *)img1 img2:(UIImage *)img2 action:(SEL)action {
    // 调用right方法，然后把按钮的坐标改下
    UIButton *btn = [self customRightImgBtn:img1 img2:img2 action:action];
    btn.left = 4;
    return btn;
}

- (UIButton *)customLeftTextBtn:(NSString *)text action:(SEL)action {
    UIButton *btn = [self customRightTextBtn:text action:action];
    btn.left = 4;
    return btn;
}

- (void)scrollToTop:(BOOL)enabled {

}

- (UIButton *)createSureBtn:(NSString *)title selector:(SEL)selector {
    UIButton *loginBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    loginBtn.frame = CGRectMake(_telView.right-96, _pwdView.bottom+30, 96, 38);
    loginBtn.backgroundColor = HexRGBA(0x2e248c, 255);
    loginBtn.layer.cornerRadius = 19;
    loginBtn.layer.masksToBounds = YES;
    [loginBtn setTitleColor:HexGRAY(0xff, 255) forState:UIControlStateNormal];
    loginBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    [loginBtn setTitle:title forState:UIControlStateNormal];
    [loginBtn addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
    return loginBtn;
}

#pragma mark - 自定义显示效果

- (UIView *)shownMaskView {
    if (!_shownMaskView) {
        _shownMaskView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, deviceWidth, deviceHeight)];
        _shownMaskView.backgroundColor = HexGRAY(0x0, 255);
    }
    return _shownMaskView;
}

- (CGPoint)startPoint {
    CGPoint pt;
    switch (self.shownDirection) {
        case ShowViewControllerDirection_BottomTop:
            pt = CGPointMake(0, deviceHeight);
            break;

        case ShowViewControllerDirection_RightLeft:
            pt = CGPointMake(deviceWidth, 0);
            break;

        case ShowViewControllerDirection_TopBottom:
            pt = CGPointMake(0, -deviceHeight);
            break;

        default:
            pt = CGPointMake(-deviceWidth, 0);
            break;
    }
    return pt;
}

/**
 * 把self显示到某个视图控制器
 */
- (void)showInViewController:(UIViewController *)vc direction:(ShowViewControllerDirection)direction {
    __weak UIViewController *parentVC = vc;
    self.shownDirection = direction;

    // 加半透明层
    [parentVC.view addSubview:self.shownMaskView];
    self.shownMaskView.alpha = 0;
    // 加到父视图控制器
    [parentVC addChildViewController:self];
    [parentVC.view addSubview:self.view];
    // 设置view的开始位置
    CGPoint pt = [self startPoint];
    self.view.left = pt.x;
    self.view.top = pt.y;

    [UIView animateWithDuration:0.25 animations:^{
        self.view.left = 0;
        self.view.top = 0;
        self.shownMaskView.alpha = 0.5;
    }                completion:^(BOOL finished) {
        [parentVC didMoveToParentViewController:self];
    }];
}

/**
 * 隐藏
 */
- (void)hide {
    CGPoint pt = [self startPoint];
    [self willMoveToParentViewController:nil];
    [UIView animateWithDuration:0.25 animations:^{
        // 隐藏时的结束位置，即为开始位置
        self.view.left = pt.x;
        self.view.top = pt.y;
        self.shownMaskView.alpha = 0;
    }                completion:^(BOOL finished) {
        [self.shownMaskView removeFromSuperview];
        self.shownMaskView = nil;
        [self.view removeFromSuperview];
        [self removeFromParentViewController];
    }];
}

- (void)pushController:(UIViewController *)controller {
    [self.navigationController pushViewController:controller animated:YES];
}

@end
