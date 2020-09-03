//
//  UIScrollView+ForceStop.m
//  OnMobile
//
//  Created by Mac on 15/12/28.
//  Copyright © 2015年 keruyun. All rights reserved.
//

#import "UIScrollView+ForceStop.h"

@implementation UIScrollView (ForceStop)

- (void)forceStopScrolling {
    CGPoint offset = self.contentOffset;
    //垂直方向的滚动
    if (offset.y + self.height > self.contentSize.height) {
        offset.y = self.contentSize.height - self.height;
    }
    if (offset.y < 0) {
        offset.y = 0;
    }
    //水平方向的滚动
    if (offset.x + self.width > self.contentSize.width) {
        offset.x = self.contentSize.width - self.width;
    }
    if (offset.x < 0) {
        offset.x = 0;
    }
    [self setContentOffset:offset animated:NO];
}

@end
