//
//  IntroSlideView.m
//  XMAlarm
//
//  Created by bo.chen on 17/10/18.
//  Copyright © 2017年 com.xmm. All rights reserved.
//

#import "IntroSlideView.h"

@interface IntroSlideView ()
<UIScrollViewDelegate>
{
    NSArray     *_imageNames;
    UIPageControl * _pageControl;
}
@end

@implementation IntroSlideView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _imageNames = @[@"intro_1@3x",@"intro_2@3x",@"intro_3@3x"];
        [self createScrollView];
    }
    return self;
}

- (void)createScrollView {
    self.backgroundColor = [UIColor whiteColor];
    
    UIScrollView * scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
    scrollView.contentSize = CGSizeMake(self.width*_imageNames.count, self.height);
    scrollView.pagingEnabled = YES;
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.delegate = self;
    if (@available(iOS 11.0, *)) {
        scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    [self addSubview:scrollView];
    
    _pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, scrollView.height - 24 - BottomGap, scrollView.width, 6)];
    _pageControl.numberOfPages = _imageNames.count;
    _pageControl.currentPage = 0;
    _pageControl.pageIndicatorTintColor = UIColorFromRGBA(0x259cf7, .1);
    _pageControl.currentPageIndicatorTintColor = UIColorFromRGBA(0x259cf7, .4);
    [self addSubview:_pageControl];
    
    for (NSInteger i = 0; i < _imageNames.count; i++) {
        NSString *name = _imageNames[i];
        
        UIImageView * imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0+self.width*i, 0, self.width, self.height)];
        imageView.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:name ofType:@"jpg"]];
        if (i == _imageNames.count - 1) {
            UIButton * nextButton = [[UIButton alloc] initWithFrame:CGRectMake((deviceWidth - 280) / 2.0f, self.height - 90 - BottomGap, 280, 48)];
            [nextButton setBackgroundImage:[[UIImage imageNamed:@"btn_immediate"] getImageResize] forState:UIControlStateNormal];
            [nextButton setTitle:@"立即体验" forState:UIControlStateNormal];
            [nextButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [nextButton addTarget:self action:@selector(processNextButton) forControlEvents:UIControlEventTouchUpInside];
            nextButton.titleLabel.font = [UIFont systemFontOfSize:17];
            nextButton.titleLabel.adjustsFontSizeToFitWidth = YES;
            nextButton.titleLabel.minimumScaleFactor =  0.5f;
            [imageView addSubview:nextButton];
            imageView.userInteractionEnabled = YES;
        }
        [scrollView addSubview:imageView];
    }
}

- (void)processNextButton {
    [UIView animateWithDuration:0.8 animations:^{
        self.alpha = 0;
        self.transform = CGAffineTransformMakeScale(2, 2);
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    NSInteger page = floor((scrollView.contentOffset.x - scrollView.width / 2) / scrollView.width) + 1;
    _pageControl.currentPage = page;
}

@end
