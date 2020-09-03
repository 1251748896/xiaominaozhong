//
//  RepeatSwitchView.m
//  XMAlarm
//
//  Created by bo.chen on 17/9/10.
//  Copyright © 2017年 com.xmm. All rights reserved.
//

#import "RepeatSwitchView.h"

@implementation RepeatSwitchView {
    NSMutableArray  *_btnArray;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _btnArray = [NSMutableArray array];
        for (NSInteger i = 0; i < 3; i++) {
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            UIImage *image = nil;
            UIImage *selImage = nil;
            if (0 == i) {
                image = [UIImage imageNamed:@"priodicity_img_left_nor"];
                selImage = [UIImage imageNamed:@"priodicity_img_left_sel"];
                [btn setTitle:@"每周" forState:UIControlStateNormal];
            } else if (1 == i) {
                image = [UIImage imageNamed:@"priodicity_img_mid_nor"];
                selImage = [UIImage imageNamed:@"priodicity_img_mid_sel"];
                [btn setTitle:@"每月" forState:UIControlStateNormal];
            } else {
                image = [UIImage imageNamed:@"priodicity_img_right_nor"];
                selImage = [UIImage imageNamed:@"priodicity_img_right_sel"];
                [btn setTitle:@"每年" forState:UIControlStateNormal];
            }
            
            [btn setBackgroundImage:[image getImageResize] forState:UIControlStateNormal];
            [btn setBackgroundImage:[selImage getImageResize] forState:UIControlStateSelected];
            
            [btn setTitleColor:HexRGBA(0x333333, 255) forState:UIControlStateNormal];
            [btn setTitleColor:HexRGBA(0x2390EE, 255) forState:UIControlStateSelected];
            btn.titleLabel.font = [UIFont systemFontOfSize:15];
            
            btn.tag = i+1;
            [btn addTarget:selImage action:@selector(btnPressed:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:btn];
            [_btnArray addObject:btn];
        }
        [_btnArray mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.height.equalTo(self);
        }];
        [_btnArray mas_distributeViewsAlongAxis:MASAxisTypeHorizontal withFixedSpacing:0 leadSpacing:0 tailSpacing:0];
    }
    return self;
}

- (void)setSelectedIndex:(NSInteger)selectedIndex {
    _selectedIndex = selectedIndex;
    
    for (UIButton *btn in _btnArray) {
        btn.selected = btn.tag == _selectedIndex+1;
    }
}

- (void)btnPressed:(UIButton *)sender {
    if (sender.selected) {
        return;
    }
    self.selectedIndex = sender.tag-1;
    
    if (self.indexBlock) {
        self.indexBlock(self.selectedIndex);
    }
}

@end
