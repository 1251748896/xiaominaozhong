//
//  RepeatSwitchView.h
//  XMAlarm
//
//  Created by bo.chen on 17/9/10.
//  Copyright © 2017年 com.xmm. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RepeatSwitchView : UIView
@property (nonatomic, assign) NSInteger selectedIndex;
@property (nonatomic, copy) IndexBlock indexBlock;
@end
