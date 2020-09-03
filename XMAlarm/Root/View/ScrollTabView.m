//
//  ScrollTabView.m
//  DearMentor
//
//  Created by bo.chen on 16/1/5.
//  Copyright © 2016年 cdyzjy. All rights reserved.
//

#import "ScrollTabView.h"

#define kTitleTag 100

@interface ScrollTabView ()
{
    UIScrollView    *_contentView;
    UIView     *_lineView;
}
@end

@implementation ScrollTabView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _selectedIndex = -1;
        self.userInteractionEnabled = YES;
        
        _contentView = [[UIScrollView alloc] initWithFrame:self.bounds];
        _contentView.backgroundColor = [UIColor clearColor];
        _contentView.scrollsToTop = NO;
        _contentView.showsHorizontalScrollIndicator = NO;
        _contentView.showsVerticalScrollIndicator = NO;
        [self addSubview:_contentView];
        
        _lineView = [[UIView alloc] initWithFrame:CGRectMake(0, self.height-3, 100, 3)];
        _lineView.backgroundColor = HexGRAY(0xFF, 255);
        _lineView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        [_contentView addSubview:_lineView];
        _lineView.hidden = YES;
        
        //设置默认属性
        self.btnMargin = 10;
    }
    return self;
}

- (void)setTitleArray:(NSArray *)titleArray {
    if (_titleArray == titleArray || 0 == titleArray.count) return;
    
    for (NSInteger i = 0; i < _titleArray.count; i++) {
        UIView *view = [self viewWithTag:kTitleTag+i];
        [view removeFromSuperview];
    }
    _titleArray = titleArray;
    
    UIFont *font = self.selectedFont;
    CGFloat gap = self.btnMargin;
    //判断是否设置为需要滚动
    CGFloat totalWidth = .0f;
    for (NSInteger i = 0; i < _titleArray.count; i++) {
        CGSize size = MB_TEXTSIZE(_titleArray[i], font);
        totalWidth += ceilf(size.width)+2*gap;
    }
    BOOL shouldScroll = (totalWidth > self.width);
    
    CGFloat oneWidth = self.width / _titleArray.count;
    CGFloat offset = .0f;
    for (NSInteger i = 0; i < _titleArray.count; i++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        CGFloat btnWidth = oneWidth;
        if (shouldScroll) {
            //如果滚动，按钮的宽度为真实宽度
            CGSize size = MB_TEXTSIZE(_titleArray[i], font);
            btnWidth = ceilf(size.width)+2*gap;
        }
        btn.frame = CGRectMake(offset, 0, btnWidth, self.height);
        [btn setTitle:_titleArray[i] forState:UIControlStateNormal];
        
        if (i == _selectedIndex) {
            btn.titleLabel.font = self.selectedFont;
            [btn setTitleColor:self.selectedColor forState:UIControlStateNormal];
        } else {
            btn.titleLabel.font = self.normalFont;
            [btn setTitleColor:self.normalColor forState:UIControlStateNormal];
        }
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(setupBtnStyle:isSelected:)]) {
            [self.delegate setupBtnStyle:btn isSelected:(i == _selectedIndex)];
        }
        
        //假如选中字体不一样，把大小不一样的字按下线对齐
        if (self.normalFont.pointSize != self.selectedFont.pointSize) {
            btn.contentVerticalAlignment = UIControlContentVerticalAlignmentBottom;
            btn.titleEdgeInsets = UIEdgeInsetsMake(0, 0, (self.height-ceilf(font.lineHeight))/2+1, 0);
        }
        
        [btn addTarget:self action:@selector(titleBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
        btn.tag = kTitleTag+i;
        [_contentView addSubview:btn];
        offset += btnWidth;
    }
    
    _contentView.contentSize = CGSizeMake(shouldScroll ? offset : self.width, self.height);
}

- (void)setSelectedIndex:(NSInteger)selectedIndex {
    if (0 == _titleArray.count) return;
    if (_selectedIndex == selectedIndex) return;
    
    _selectedIndex = selectedIndex;
    
    if (-1 == _selectedIndex) {
        [self clearSelectedStatus];
        return;
    }
    
    UIView *view = [self viewWithTag:kTitleTag+_selectedIndex];
    _lineView.left = view.left;
    _lineView.width = view.width;
    
    for (NSInteger i = 0; i < _titleArray.count; i++) {
        UIButton *btn = (UIButton *)[self viewWithTag:kTitleTag+i];
        if (i == _selectedIndex) {
            btn.titleLabel.font = self.selectedFont;
            [btn setTitleColor:self.selectedColor forState:UIControlStateNormal];
        } else {
            btn.titleLabel.font = self.normalFont;
            [btn setTitleColor:self.normalColor forState:UIControlStateNormal];
        }
        if (self.delegate && [self.delegate respondsToSelector:@selector(setupBtnStyle:isSelected:)]) {
            [self.delegate setupBtnStyle:btn isSelected:(i == _selectedIndex)];
        }
    }
    
    [self adjustTitleBtnVisible];
}

/**
 * 清空选中状态
 */
- (void)clearSelectedStatus {
    _lineView.left = 0;
    _lineView.width = 0;
    
    for (NSInteger i = 0; i < _titleArray.count; i++) {
        UIButton *btn = (UIButton *)[self viewWithTag:kTitleTag+i];
        if (self.delegate && [self.delegate respondsToSelector:@selector(setupBtnStyle:isSelected:)]) {
            [self.delegate setupBtnStyle:btn isSelected:NO];
        }
    }
}

/**
 * 调整title按钮到可视
 */
- (void)adjustTitleBtnVisible
{
    UIView *view = [self viewWithTag:kTitleTag+_selectedIndex];
    
    if (view.right > _contentView.contentOffset.x+self.width) {
        // 向左滚动视图
        CGFloat offset = view.center.x-self.width/2;
        offset = MIN(offset, _contentView.contentSize.width-self.width);
        [_contentView setContentOffset:CGPointMake(offset, 0) animated:YES];
    } else if (view.left < _contentView.contentOffset.x) {
        //向右滚动视图
        CGFloat offset = view.center.x-self.width/2;
        offset = MIN(offset, 0);
        [_contentView setContentOffset:CGPointMake(offset, 0) animated:YES];
    }
}

/**
 * 滚动时修改两边的title
 */
/*
- (void)linearTitleColorAndSize:(CGFloat)offsetX
{
    if ((NSInteger)offsetX % (NSInteger)deviceWidth == 0) {
        return;
    }
    
    //    HexRGBA(0x21, 0xBF, 0x66, 255)
    //    HexRGBA(0x3D, 0x3D, 0x3D, 255)
    
    UIButton *currentBtn = _titleArray[self.selectedIndex];
    CGFloat currentX = self.selectedIndex * deviceWidth;
    CGFloat diff = (offsetX-currentX)/deviceWidth;
    if (diff < 0) diff = -diff;
    
    currentBtn.titleLabel.font = [UIFont systemFontOfSize:kTitleSelectedSize-diff*(kTitleSelectedSize-kTitleNormalSize)];
    [currentBtn setTitleColor:[UIColor colorWithRed:(0x21-diff*(0x21-0x3D))/255.0 green:(0xBF-diff*(0xBF-0x3D))/255.0 blue:(0x66-diff*(0x66-0x3D))/255.0 alpha:1.0] forState:UIControlStateNormal];
    
    UIButton *otherBtn = nil;
    if (offsetX > currentX && self.currentIndex+1 < _titleArray.count-1) {
        otherBtn = _titleArray[self.currentIndex+1];
    } else if (offsetX < currentX && self.currentIndex-1 >= 0) {
        otherBtn = _titleArray[self.currentIndex-1];
    }
    
    diff = 1-diff;
    otherBtn.titleLabel.font = [UIFont systemFontOfSize:kTitleSelectedSize-diff*(kTitleSelectedSize-kTitleNormalSize)];
    [otherBtn setTitleColor:[UIColor colorWithRed:(0x21-diff*(0x21-0x3D))/255.0 green:(0xBF-diff*(0xBF-0x3D))/255.0 blue:(0x66-diff*(0x66-0x3D))/255.0 alpha:1.0] forState:UIControlStateNormal];
}
 */

- (void)titleBtnPressed:(UIButton *)btn {
    NSInteger index = btn.tag-kTitleTag;
    if (_selectedIndex != index) {
        self.selectedIndex = index;
        // 通知代理
        if (_delegate && [_delegate respondsToSelector:@selector(scrollTabViewDidSelected:)]) {
            [_delegate scrollTabViewDidSelected:self];
        }
    }
}

@end
