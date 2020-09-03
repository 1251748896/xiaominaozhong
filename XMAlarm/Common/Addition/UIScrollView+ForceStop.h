//
//  UIScrollView+ForceStop.h
//  OnMobile
//
//  Created by Mac on 15/12/28.
//  Copyright © 2015年 keruyun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIScrollView (ForceStop)

/**
 * 强制停止滚动，比如正在减速过程中
 */
- (void)forceStopScrolling;

@end
