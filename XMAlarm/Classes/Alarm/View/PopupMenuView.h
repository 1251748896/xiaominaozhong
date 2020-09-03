//
//  PopupMenuView.h
//  XMAlarm
//
//  Created by bo.chen on 17/9/4.
//  Copyright © 2017年 com.xmm. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PopupMenuView : UIView
- (instancetype)initWithTitleArray:(NSArray *)titleArray;
@property (nonatomic, copy) IndexBlock indexBlock;
- (void)show;
@end
