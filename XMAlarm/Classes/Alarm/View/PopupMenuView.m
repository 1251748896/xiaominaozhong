//
//  PopupMenuView.m
//  XMAlarm
//
//  Created by bo.chen on 17/9/4.
//  Copyright © 2017年 com.xmm. All rights reserved.
//

#import "PopupMenuView.h"

@implementation PopupMenuView {
    UIView  *_maskView;
}

- (instancetype)initWithTitleArray:(NSArray *)titleArray {
    self = [super initWithFrame:CGRectMake(deviceWidth-144, 54, 144, 141)];
    if (self) {
        _maskView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, deviceWidth, deviceHeight)];
        _maskView.backgroundColor = HexGRAY(0x0, 0.1*255);
        [_maskView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hide)]];
        
        UIImageView *bg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"home_add_bg"]];
        [self addSubview:bg];
        
        for (NSInteger i = 0; i < titleArray.count; i++) {
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            btn.frame = CGRectMake(5, 9+41*i, self.width-5, 41);
            btn.titleLabel.font = [UIFont systemFontOfSize:14];
            [btn setTitleColor:HexRGBA(0x333333, 255) forState:UIControlStateNormal];
            [btn setTitle:titleArray[i] forState:UIControlStateNormal];
            [btn addTarget:self action:@selector(btnPressed:) forControlEvents:UIControlEventTouchUpInside];
            btn.tag = i;
            [self addSubview:btn];
            
            if (i < titleArray.count - 1) {
                UIView *line = [[UIView alloc] init];
                line.backgroundColor = HexRGBA(0xE3E3E3, 255);
                [self addSubview:line];
                [line mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.left.width.bottom.equalTo(btn);
                    make.height.mas_equalTo(0.5);
                }];                
            }
        }
    }
    return self;
}

- (void)show {
    [KEYWindow addSubview:_maskView];
    [KEYWindow addSubview:self];
}

- (void)hide {
    [_maskView removeFromSuperview];
    [self removeFromSuperview];
}

- (void)btnPressed:(UIButton *)sender {
    if (self.indexBlock) {
        self.indexBlock(sender.tag);
    }
    [self hide];
}

@end
