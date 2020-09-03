//
//  SwipeView.h
//  shareKouXiaoHai
//
//  Created by bo.chen on 16/3/26.
//  Copyright © 2016年 Kouxiaoer. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SwipeView;

@protocol SwipeViewDataSource <NSObject>

- (NSInteger)numberOfItemsInSwipeView:(SwipeView *)swipeView;
- (UIView *)swipeView:(SwipeView *)swipeView viewForItemAtIndex:(NSInteger)index reusingView:(UIView *)view;

@end

@protocol SwipeViewDelegate <NSObject>
@optional

- (void)swipeViewCurrentItemIndexDidChange:(SwipeView *)swipeView;

@end

@interface SwipeView : UIView {
    NSInteger   _numberOfItems;
    NSInteger   _currentItemIndex;
}
@property (nonatomic, assign) BOOL autoScroll;
@property (nonatomic, readonly) NSInteger numberOfItems;
@property (nonatomic, readonly) NSInteger currentItemIndex;
@property (nonatomic, weak) id<SwipeViewDataSource> dataSource;
@property (nonatomic, weak) id<SwipeViewDelegate> delegate;
- (void)reloadData;
- (void)releaseTimer;
@end
