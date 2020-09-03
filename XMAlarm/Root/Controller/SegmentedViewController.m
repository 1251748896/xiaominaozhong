//
//  SegmentedViewController.m
//  goodnight
//
//  Created by mac003 on 15/7/8.
//  Copyright (c) 2015年 quleduo. All rights reserved.
//

#import "SegmentedViewController.h"

@interface SegmentedViewController () <UIScrollViewDelegate> {
    UIScrollView *_rootScrollView;
    NSMutableDictionary *_menuViewsDict;
    NSInteger _currentIndex;
}
@end

@implementation SegmentedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _menuViewsDict = [NSMutableDictionary dictionary];
    [self rootScrollView];
    [self toggleToIndex:0];
}

- (void)viewDidLayoutSubviews {
    _rootScrollView.contentSize = CGSizeMake(_rootScrollView.contentSize.width, self.view.height);
}

#pragma mark - view

- (UIScrollView *)rootScrollView {
    if (!_rootScrollView) {
        _rootScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, deviceWidth, self.view.height)];
        _rootScrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _rootScrollView.delegate = self;
        _rootScrollView.pagingEnabled = YES;
        _rootScrollView.showsHorizontalScrollIndicator = NO;
        _rootScrollView.showsVerticalScrollIndicator = NO;
        _rootScrollView.scrollsToTop = NO;
        _rootScrollView.contentSize = CGSizeMake(deviceWidth * [self numberOfViewController], self.view.height);
        _rootScrollView.scrollEnabled = [self scrollEnabled];
        [self.view insertSubview:_rootScrollView atIndex:0];
        //保持滑动返回的手势
        [_rootScrollView.panGestureRecognizer requireGestureRecognizerToFail:self.navigationController.interactivePopGestureRecognizer];
    }
    return _rootScrollView;
}

- (CGFloat)segViewHeight {
    return 36;
}

- (ScrollTabView *)segView {
    if (!_segView) {
        _segView = [[ScrollTabView alloc] initWithFrame:CGRectMake(0, GAP20 + topBarHeight, deviceWidth, [self segViewHeight])];
        _segView.delegate = self;
        [self.view addSubview:_segView];
    }
    return _segView;
}

- (NSArray *)shownControllers {
    return [_menuViewsDict allValues];
}

#pragma mark - ScrollTabViewDelegate

- (void)scrollTabViewDidSelected:(ScrollTabView *)tabView {
    NSInteger index = tabView.selectedIndex;
    [self toggleToIndex:index];
}

#pragma mark - override

- (BOOL)scrollEnabled {
    return YES;
}

- (NSInteger)numberOfViewController {
    return 0;
}

- (id)viewKeyOfIndex:(NSInteger)index {
    return @(index);
}

- (BaseViewController *)viewControllerForIndex:(NSInteger)index {
    return nil;
}

- (void)willToggleToIndex:(NSInteger)index {
}

- (void)didToggleToIndex:(NSInteger)index {
    self.segView.selectedIndex = index;
}

#pragma mark - public

- (void)toggleToIndex:(NSInteger)index {
    if (index < 0 || index >= [self numberOfViewController]) {
        return;
    }
    [self willToggleToIndex:index];
    
    _currentIndex = index;
    // 修改contentOffset会触发didscroll回调
    [_rootScrollView setContentOffset:CGPointMake(index * deviceWidth, 0) animated:NO];
    [self updateMenuController:index];
    [self updateScrollToTop];
    
    [self didToggleToIndex:index];
}

- (void)adjustControllerPos {
    for (NSInteger i = 0; i < [self numberOfViewController]; i++) {
        id key = [self viewKeyOfIndex:i];
        BaseViewController *controller = _menuViewsDict[key];
        if (controller) {
            controller.view.left = i * deviceWidth;
        }
    }
}

#pragma mark - method

- (BaseViewController *)currentViewController {
    if (self.currentIndex < 0 || self.currentIndex >= [self numberOfViewController]) {
        return nil;
    }
    NSNumber *key = @(self.currentIndex);
    return _menuViewsDict[key];
}

- (void)updateMenuController:(NSInteger)index {
    if (index < 0 || index >= [self numberOfViewController]) {
        return;
    }
    id key = [self viewKeyOfIndex:index];
    if (!_menuViewsDict[key]) {
        BaseViewController *controller = [self viewControllerForIndex:index];
        _menuViewsDict[key] = controller;
        
        [self addChildViewController:controller];
        [_rootScrollView addSubview:controller.view];
        controller.view.left = index * deviceWidth;
        controller.view.top = 0;
        [controller didMoveToParentViewController:self];
    }
}

- (void)updateScrollToTop {
    for (id key in _menuViewsDict.allKeys) {
        BaseViewController *controller = _menuViewsDict[key];
        [controller scrollToTop:[key isEqual:[self viewKeyOfIndex:_currentIndex]]];
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView.contentOffset.x < _currentIndex * scrollView.width) {
        [self updateMenuController:_currentIndex - 1];
    } else if (scrollView.contentOffset.x > _currentIndex * scrollView.width) {
        [self updateMenuController:_currentIndex + 1];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    NSInteger pageIndex = scrollView.contentOffset.x / scrollView.bounds.size.width;
    [self toggleToIndex:pageIndex];
}

@end
