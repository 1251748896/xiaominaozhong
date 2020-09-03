//
//  PullMoreView.m
//  facetalk
//
//  Created by mac003 on 14-9-12.
//  Copyright (c) 2014年 quleluo. All rights reserved.
//

#import "PullMoreView.h"

#define kHeight 44

@interface PullMoreView ()
{
    UILabel     *_moreLabel;
    UIActivityIndicatorView *_indicator;
    UILabel     *_loadingLabel;
}
@property (nonatomic, assign) UIScrollView *scrollView;
@end

@implementation PullMoreView

- (id)initInScrollView:(UIScrollView *)scrollView
{
    self = [super initWithFrame:CGRectMake(0, 0, deviceWidth, kHeight)];
    if (self) {
        self.scrollView = scrollView;
        
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [scrollView addSubview:self];
        [scrollView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
        [scrollView addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:nil];
        
        _moreLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, deviceWidth, kHeight)];
        _moreLabel.backgroundColor = [UIColor clearColor];
        _moreLabel.textColor = [UIColor grayColor];
        _moreLabel.font = [UIFont fontWithName:FONTSTYLE size:14];
        _moreLabel.textAlignment = NSTextAlignmentCenter;
//        _moreLabel.text = @"上拉加载更多";
        [self addSubview:_moreLabel];
        
        _indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        _indicator.color = BTNACTIVECOLOR;
        _indicator.center = CGPointMake(deviceWidth/2-30, kHeight/2);
        [self addSubview:_indicator];
        
        _loadingLabel = [[UILabel alloc] initWithFrame:CGRectMake(deviceWidth/2, 0, 100, kHeight)];
        _loadingLabel.backgroundColor = [UIColor clearColor];
        _loadingLabel.textColor = [UIColor grayColor];
        _loadingLabel.font = [UIFont fontWithName:FONTSTYLE size:14];
        _loadingLabel.text = @"加载中...";
        [self addSubview:_loadingLabel];
        
        _loadingLabel.hidden = YES;
        [self adjustFrame];
    }
    return self;
}

- (void)dealloc
{
    [self.scrollView removeObserver:self forKeyPath:@"contentOffset"];
    [self.scrollView removeObserver:self forKeyPath:@"contentSize"];
    self.scrollView = nil;
}

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    [super willMoveToSuperview:newSuperview];
    if (!newSuperview) {
        [self.scrollView removeObserver:self forKeyPath:@"contentOffset"];
        [self.scrollView removeObserver:self forKeyPath:@"contentSize"];
        self.scrollView = nil;
    }
}

- (void)adjustFrame
{
    CGFloat y = MAX(_scrollView.contentSize.height, _scrollView.height);
    self.top = y;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (!_loadingMore && [keyPath isEqualToString:@"contentOffset"]) {
        if (_scrollView.contentOffset.y + _scrollView.height > MAX(_scrollView.contentSize.height, _scrollView.height) + kHeight) {
            _loadingMore = YES;
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(pullMoreViewStartLoadingData:)]) {
                [self.delegate pullMoreViewStartLoadingData:self];
            }
            
            _moreLabel.hidden = YES;
            [_indicator startAnimating];
            _loadingLabel.hidden = NO;
            
            [UIView animateWithDuration:0.25f animations:^{
                _scrollView.contentInset = UIEdgeInsetsMake(0, 0, kHeight, 0);
            }];
        }
    }
    if ([keyPath isEqualToString:@"contentSize"]) {
        [self adjustFrame];
    }
}

- (void)endLoading
{
    _loadingMore = NO;
    _moreLabel.hidden = NO;
    [_indicator stopAnimating];
    _loadingLabel.hidden = YES;
    [UIView animateWithDuration:0.25f animations:^{
        _scrollView.contentInset = UIEdgeInsetsZero;
    }];
}

@end
