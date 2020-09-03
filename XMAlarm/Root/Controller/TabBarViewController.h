//
//  TabBarViewController.h
//  Car
//
//  Created by bo.chen on 15/9/25.
//  Copyright © 2015年 com.smaradio. All rights reserved.
//

#import "BaseViewController.h"

#define kTabBtnTag 100
#define kRedPointTag 1000

@interface TabBarViewController : BaseViewController
{
    UIView *_tabBar;
    NSMutableArray *_tabBtnArray;
}
@property(nonatomic, copy) NSArray *viewControllers;
@property(nonatomic, assign) NSUInteger selectedIndex;
@property(nonatomic, readonly) BaseViewController *selectedViewController;

/**
 * 初始化底部工具条
 */
- (void)initTabBar;

/**
 *  切换 tabbar
 */
- (void)setSelectedIndex:(NSUInteger)selectedIndex;

/**
 * 在TabBarViewController的某个index对应的按钮位置显示红点
 */
- (void)showRedPointAtIndex:(NSInteger)index;

/**
 * 隐藏红点
 */
- (void)hideRedPointAtIndex:(NSInteger)index;

@end
