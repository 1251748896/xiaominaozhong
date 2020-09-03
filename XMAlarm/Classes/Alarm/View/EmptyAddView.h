//
//  EmptyAddView.h
//  XMAlarm
//
//  Created by bo.chen on 17/9/6.
//  Copyright © 2017年 com.xmm. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EmptyAddView : UIView
- (instancetype)initWithImage:(UIImage *)image title:(NSString *)title;
@property (nonatomic, readonly) UIButton *addBtn;
@end
