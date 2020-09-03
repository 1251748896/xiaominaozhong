//
//  IconLabel.h
//  QSMovie
//
//  Created by bo.chen on 17/8/21.
//  Copyright © 2017年 com.qingsheng. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 * 前面一个图标，后面单行文本的视图
 */
@interface IconLabel : UIView
- (instancetype)initWithIcon:(UIImage *)icon gap:(NSInteger)gap;
@property (nonatomic, readonly) UILabel *lbl;
@property (nonatomic, readonly) UIImageView *iconView;
@end
