//
//  RootNavigationController.h
//  OnMobile
//
//  Created by bo.chen on 15/9/25.
//  Copyright © 2015年 keruyun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RootNavigationController : UINavigationController
+ (instancetype)sharedInstance;
- (void)toggleHomeView;
- (void)toggleLoginView;
@property (nonatomic, assign) BOOL presentingLoginView;
@end
