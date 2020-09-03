//
//  PullMoreView.h
//  facetalk
//
//  Created by mac003 on 14-9-12.
//  Copyright (c) 2014年 quleluo. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PullMoreView;

@protocol PullMoreViewDelegate <NSObject>

- (void)pullMoreViewStartLoadingData:(PullMoreView *)view;

@end

@interface PullMoreView : UIView
@property (nonatomic, assign) id<PullMoreViewDelegate> delegate;
@property (nonatomic, readonly) BOOL loadingMore;
@property (nonatomic, readonly) UILabel *moreLabel;
@property (nonatomic, readonly) UILabel *loadingLabel;
- (id)initInScrollView:(UIScrollView *)scrollView;
- (void)endLoading;
@end
