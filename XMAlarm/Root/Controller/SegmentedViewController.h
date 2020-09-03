//
//  SegmentedViewController.h
//  goodnight
//
//  Created by mac003 on 15/7/8.
//  Copyright (c) 2015年 quleduo. All rights reserved.
//

#import "BaseViewController.h"
#import "ScrollTabView.h"

@interface SegmentedViewController : BaseViewController
<ScrollTabViewDelegate> {
    ScrollTabView *_segView;
}
@property (nonatomic, readonly) UIScrollView *rootScrollView;
@property (nonatomic, readonly) NSMutableDictionary *menuViewsDict;
@property (nonatomic, readonly) NSInteger currentIndex;
@property (nonatomic, readonly) BaseViewController *currentViewController;
@property (nonatomic, readonly) ScrollTabView *segView;
@property (nonatomic, readonly) NSArray *shownControllers;//所有显示过的界面
- (void)toggleToIndex:(NSInteger)index;
- (void)adjustControllerPos;
#pragma mark - override
- (BOOL)scrollEnabled;
- (NSInteger)numberOfViewController;
- (id)viewKeyOfIndex:(NSInteger)index;
- (BaseViewController *)viewControllerForIndex:(NSInteger)index;
- (void)willToggleToIndex:(NSInteger)index;
- (void)didToggleToIndex:(NSInteger)index;
@end
