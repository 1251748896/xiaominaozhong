//
//  ScrollTabView.h
//  DearMentor
//
//  Created by bo.chen on 16/1/5.
//  Copyright © 2016年 cdyzjy. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ScrollTabView;

@protocol ScrollTabViewDelegate <NSObject>
- (void)scrollTabViewDidSelected:(ScrollTabView *)tabView;
@optional
- (void)setupBtnStyle:(UIButton *)btn isSelected:(BOOL)isSelected;
@end

@interface ScrollTabView : UIView
@property (nonatomic, strong) UIColor *normalColor;
@property (nonatomic, strong) UIColor *selectedColor;
@property (nonatomic, strong) UIFont *normalFont;
@property (nonatomic, strong) UIFont *selectedFont;
@property (nonatomic, assign) CGFloat btnMargin;
@property (nonatomic, readonly) UIView *lineView;
//在修改titleArray之前请先设置以上属性
@property (nonatomic, copy) NSArray *titleArray;
@property (nonatomic, weak) id<ScrollTabViewDelegate> delegate;
@property (nonatomic) NSInteger selectedIndex;
@end
