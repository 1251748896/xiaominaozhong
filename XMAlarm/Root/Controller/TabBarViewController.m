//
//  TabBarViewController.m
//  Car
//
//  Created by bo.chen on 15/9/25.
//  Copyright © 2015年 com.smaradio. All rights reserved.
//

#import "TabBarViewController.h"
#import "AlarmHomeViewController.h"
#import "RemindHomeViewController.h"
#import "TrafficHomeViewController.h"

@interface TabBarViewController ()
@end

@implementation TabBarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.topView.hidden = [self useChildControllerTopView];
    [self initTabBar];
    [self initViewControllers];
    [self updateSelectStatus:-1];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - ViewController Transition

- (void)removeViewController:(UIViewController *)controller {
    [controller willMoveToParentViewController:nil];
    [controller.view removeFromSuperview];
    [controller removeFromParentViewController];
}

- (void)addViewController {
    UIViewController *controller = self.viewControllers[_selectedIndex];
    [self addChildViewController:controller];
    [self.view insertSubview:controller.view atIndex:0];
    controller.view.top = 0;
    [controller didMoveToParentViewController:self];
}

#pragma mark - dataSource

/**
 * 每个子controller有不同的topView
 */
- (BOOL)useChildControllerTopView {
    return YES;
}

- (UIColor *)tabBarColor {
    return HexGRAY(0xffffff, 255);
}

- (UIColor *)btnNormalColor {
    return HexRGBA(0x757575, 255);
}

- (UIColor *)btnSelectedColor {
    return HexRGBA(0x4598DE, 255);
}

- (UIFont *)titleLabFont{
    return [UIFont fontWithName:FONTSTYLE size:11];
}

- (NSInteger)tabNum {
    return 3;
}

- (NSArray *)tabIconNames {
    return @[@"tab_icon_clock_nor", @"tab_icon_remind_nor", @"tab_icon_limitline_nor"];
}

- (NSArray *)tabIconNames2 {
    return @[@"tab_icon_clock_sel", @"tab_icon_remind_sel", @"tab_icon_limitline_sel"];
}

- (NSArray *)tabTitles {
    return @[@"闹钟", @"提醒", @"限行"];
}

- (NSArray *)tabViewControllers {
    return @[[[AlarmHomeViewController alloc] init],
             [[RemindHomeViewController alloc] init],
             [[TrafficHomeViewController alloc] init]];
}

#pragma mark - property

- (void)setSelectedIndex:(NSUInteger)selectedIndex {
    if (_selectedIndex == selectedIndex) {
        return;
    }
    NSInteger oldIndex = _selectedIndex;
    _selectedIndex = selectedIndex;
    if (self.isViewLoaded) {      
        [self updateSelectStatus:oldIndex];
    }
}

- (void)updateSelectStatus:(NSInteger)oldIndex {
    // 修改按钮状态
    for (NSInteger i = 0; i < [self tabNum]; i++) {
        UIButton *btn = (UIButton *) [_tabBar viewWithTag:i + kTabBtnTag];
        btn.selected = i == _selectedIndex;
    }
    // 切换视图
    if (oldIndex >= 0) {
        [self removeViewController:self.viewControllers[oldIndex]];
    }
    [self addViewController];
}

- (UIViewController *)selectedViewController {
    return _viewControllers[_selectedIndex];
}

#pragma mark - view

- (void)initTabBar {
    if (!_tabBar) {
        _tabBar = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.height - tabBarHeight, self.view.width, tabBarHeight-BottomGap)];
        _tabBar.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        _tabBar.backgroundColor = [self tabBarColor];
        
        UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _tabBar.width, tabBarHeight)];
        bgView.backgroundColor = _tabBar.backgroundColor;
        [_tabBar addSubview:bgView];
        
        UIImageView *bg = [[UIImageView alloc] initWithFrame:_tabBar.bounds];
        bg.image = [UIImage imageNamed:@"nav-1"];
        [_tabBar addSubview:bg];

        NSInteger tabNum = [self tabNum];
        NSArray *iconNames = [self tabIconNames];
        NSArray *iconNames2 = [self tabIconNames2];
        NSArray *titles = [self tabTitles];

        for (NSInteger i = 0; i < tabNum; i++) {
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            btn.frame = CGRectMake(i * deviceWidth / tabNum, 2, deviceWidth / tabNum, tabBarHeight - 2 - BottomGap);
            [btn setImage:[UIImage imageNamed:iconNames[i]] forState:UIControlStateNormal];
            [btn setImage:[UIImage imageNamed:iconNames2[i]] forState:UIControlStateHighlighted];
            [btn setImage:[UIImage imageNamed:iconNames2[i]] forState:UIControlStateSelected];
            [btn setTitleColor:[self btnNormalColor] forState:UIControlStateNormal];
            [btn setTitleColor:[self btnSelectedColor] forState:UIControlStateHighlighted];
            [btn setTitleColor:[self btnSelectedColor] forState:UIControlStateSelected];
            btn.titleLabel.font = [self titleLabFont];
            [btn setTitle:titles[i] forState:UIControlStateNormal];
            [btn layoutButtonWithEdgeInsetsStyle:ButtonEdgeInsetsStyleImageTop imageTitlespace:3];
            [btn addTarget:self action:@selector(btnPressed:) forControlEvents:UIControlEventTouchUpInside];
            btn.tag = i + kTabBtnTag;
            [_tabBar addSubview:btn];

            UIImageView *redPoint = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"red_point"]];
            redPoint.tag = i + kRedPointTag;
            [_tabBar addSubview:redPoint];
            [redPoint mas_makeConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(CGSizeMake(8, 8));
                make.centerX.equalTo(btn).mas_offset(11);
                make.centerY.equalTo(btn).mas_offset(-14);
            }];
            redPoint.hidden = YES;
        }
        
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, deviceWidth, 0.5)];
        lineView.backgroundColor = HexGRAY(0xDC, 255);
        [_tabBar addSubview:lineView];

        [self.view addSubview:_tabBar];
    }
}

- (void)initViewControllers {
    self.viewControllers = [self tabViewControllers];
    // 赋值TabController
    for (BaseViewController *controller in self.viewControllers) {
        controller.tabController = self;
    }
}

/**
 * 在TabBarViewController的某个index对应的按钮位置显示红点
 */
- (void)showRedPointAtIndex:(NSInteger)index {
    [_tabBar viewWithTag:kRedPointTag + index].hidden = NO;
}

/**
 * 隐藏红点
 */
- (void)hideRedPointAtIndex:(NSInteger)index {
    [_tabBar viewWithTag:kRedPointTag + index].hidden = YES;
}

#pragma mark - action

- (void)btnPressed:(UIButton *)sender {
    NSInteger index = sender.tag - 100;
    [self hideRedPointAtIndex:index];
    
    if (_selectedIndex != index) {
        self.selectedIndex = index;
    } else {

    }
}

@end
