//
//  BaseViewController.h
//  OnMobile
//
//  Created by bo.chen on 15/9/25.
//  Copyright © 2015年 keruyun. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum
{
    ShowViewControllerDirection_BottomTop = 1,  // 从下往上
    ShowViewControllerDirection_TopBottom = 2, // 从上往下
    ShowViewControllerDirection_RightLeft = 3, // 从右往左
    ShowViewControllerDirection_LeftRight = 4 // 从左往右
} ShowViewControllerDirection;

@class TabBarViewController;

@interface BaseViewController : UIViewController
{
    UIView  *_topView;
}

/**
 * 如果该视图控制器加入了TabBarViewController，则可获取对应的TabBarViewController
 */
@property (nonatomic, weak) TabBarViewController *tabController;

@property (nonatomic, strong) UIView *topView;
@property (nonatomic, strong, readonly) UIImageView *topBgView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIButton *backBtn;

- (void)addBackBtn;
- (void)backBtnPressed:(id)sender;
- (UIColor *)topViewbackColor;

- (UIButton *)customRightTextBtn:(NSString *)text action:(SEL)action;
- (UIButton *)customRightTextBtn2:(NSString *)text action:(SEL)action;
- (UIButton *)customRightImgBtn:(UIImage *)img1 img2:(UIImage *)img2 action:(SEL)action;
- (UIButton *)customLeftImgBtn:(UIImage *)img1 img2:(UIImage *)img2 action:(SEL)action;
- (UIButton *)customLeftTextBtn:(NSString *)text action:(SEL)action;

- (void)scrollToTop:(BOOL)enabled;

//登录界面的按钮
- (UIButton *)createSureBtn:(NSString *)title selector:(SEL)selector;

#pragma mark - 自定义显示效果

// 显示时需要的maskView
@property (nonatomic, strong) UIView *shownMaskView;
// 记住显示的方向，隐藏的时候需要用
@property (nonatomic, assign) ShowViewControllerDirection shownDirection;

/**
 * 把self显示到某个视图控制器
 */
- (void)showInViewController:(UIViewController *)vc direction:(ShowViewControllerDirection)direction;

/**
 * 隐藏
 */
- (void)hide;

- (void)pushController:(UIViewController *)controller;

@end

