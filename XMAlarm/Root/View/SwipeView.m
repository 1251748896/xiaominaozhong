//
//  SwipeView.m
//  shareKouXiaoHai
//
//  Created by bo.chen on 16/3/26.
//  Copyright © 2016年 Kouxiaoer. All rights reserved.
//

#import "SwipeView.h"

#define kInterval 5 //5秒滚动一下

@interface SwipeView ()
<UIScrollViewDelegate>
{
    UIScrollView    *_scrollView;
    NSTimer *_timer;
    NSMutableArray  *_indexArray;
    NSMutableArray  *_threeViews;
}
@end

@implementation SwipeView

- (instancetype)init {
    self = [super init];
    if (self) {
        [self initialize];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initialize];
    }
    return self;
}

- (void)initialize {
    _autoScroll = YES;
    _indexArray = [NSMutableArray array];
    _threeViews = [NSMutableArray array];
    
    _scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
    _scrollView.contentSize = CGSizeMake(self.width*3, self.height);
    _scrollView.delegate = self;
    _scrollView.scrollsToTop = NO;
    _scrollView.pagingEnabled = YES;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.showsHorizontalScrollIndicator = NO;
    [self addSubview:_scrollView];
}

- (void)reloadData {
    _numberOfItems = [self.dataSource numberOfItemsInSwipeView:self];
    
    if (_autoScroll && _numberOfItems > 0) {
        [self createTimer];
        [self pauseTimer];
    } else {
        [_timer invalidate];
        _timer = nil;
    }
    
    [_indexArray removeAllObjects];
    
    for (NSInteger i = 0; i < _numberOfItems; i++) {
        [_indexArray addObject:@(i)];
    }
    //把最后一张放到第一个位置
    id tep = [_indexArray.lastObject copy];
    if (tep) {
        [_indexArray removeLastObject];
        [_indexArray insertObject:tep atIndex:0];
    }
    
    [self loadView];
    [self resumeTimer];
}

- (void)loadView {
    NSInteger index = 0;
    for (NSInteger i = 0; i < 3; i++) {
        if (index < _indexArray.count) {
            UIView *view = safeGetArrayObject(_threeViews, i);
            NSInteger realIndex = [_indexArray[index] integerValue];
            if (!view) {
                view = [self.dataSource swipeView:self viewForItemAtIndex:realIndex reusingView:view];
                view.left = i*self.width;
                [_threeViews addObject:view];
                [_scrollView addSubview:view];
            } else {
                [self.dataSource swipeView:self viewForItemAtIndex:realIndex reusingView:view];
            }
            if (1 == i) {
                _currentItemIndex = realIndex;
            }
            index++;
            //防止图片数小于3崩溃
            index %= _indexArray.count;
        }
    }
    _scrollView.contentOffset = CGPointMake(self.width, 0);
    if (self.delegate) {
        [self.delegate swipeViewCurrentItemIndexDidChange:self];
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (scrollView.contentOffset.x >= self.width*2) {
        //防止空数组崩溃
        id tep = [_indexArray.firstObject copy];
        if (tep) {
            [_indexArray removeObjectAtIndex:0];
            [_indexArray addObject:tep];
        }
    } else if (scrollView.contentOffset.x <= 0){
        id tep = [_indexArray.lastObject copy];
        if (tep) {
            [_indexArray removeLastObject];
            [_indexArray insertObject:tep atIndex:0];
        }
    } else {
        return;
    }
    [self loadView];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self pauseTimer];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!decelerate) {
        [self resumeTimer];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self resumeTimer];
}

#pragma mark - timer

- (void)createTimer {
    [self releaseTimer];
    _timer = [NSTimer scheduledTimerWithTimeInterval:kInterval target:self selector:@selector(timerCallback) userInfo:nil repeats:YES];
}

- (void)releaseTimer {
    [_timer invalidate];
    _timer = nil;
}

- (void)pauseTimer {
    _timer.fireDate = [NSDate distantFuture];
}

- (void)resumeTimer {
    _timer.fireDate = [NSDate dateWithTimeIntervalSinceNow:kInterval];
}

- (void)timerCallback {
    [_scrollView setContentOffset:CGPointMake(self.width*2, 0) animated:YES];
}

@end
