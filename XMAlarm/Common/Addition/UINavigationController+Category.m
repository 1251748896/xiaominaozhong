//
//  UINavigationController+Category.m
//  OnMobile
//
//  Created by bo.chen on 16/5/30.
//  Copyright © 2016年 keruyun. All rights reserved.
//

#import "UINavigationController+Category.h"

@implementation UINavigationController (Category)

- (void)replaceLastViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if (self.viewControllers.count <= 1) {
        [self setViewControllers:@[viewController] animated:animated];
        return;
    }
    
    NSMutableArray *array = [NSMutableArray arrayWithArray:self.viewControllers];
    [array removeLastObject];
    [array addObject:viewController];
    [self setViewControllers:array animated:animated];
}

@end
