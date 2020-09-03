//
//  AlertMenuView.h
//  XMAlarm
//
//  Created by bo.chen on 17/9/4.
//  Copyright © 2017年 com.xmm. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AlertMenuView : UIView
- (instancetype)initWithTitle:(NSString *)title dataSource:(NSArray *)dataSource;
@property (nonatomic, copy) IndexBlock indexBlock;
- (void)show;
@end
