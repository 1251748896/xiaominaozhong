//
//  ShareBtnView.m
//  XMAlarm
//
//  Created by bo.chen on 2017/11/11.
//  Copyright © 2017年 com.xmm. All rights reserved.
//

#import "ShareBtnView.h"

@interface ShareBtnView ()
{
    UIView  *_maskView;
}
@end

@implementation ShareBtnView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:CGRectMake(0, deviceHeight, deviceWidth, 29+48+120+BottomGap)];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        _maskView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, deviceWidth, deviceHeight)];
        _maskView.backgroundColor = HexGRAY(0x0, 255);
        
        UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [closeBtn setImage:[UIImage imageNamed:@"share_icon_close"] forState:UIControlStateNormal];
        [closeBtn addTarget:self action:@selector(hide) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:closeBtn];
        [closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self);
            make.size.mas_equalTo(CGSizeMake(61, 29));
            make.right.equalTo(self).mas_offset(10);
        }];
        
        UIView *div1 = [[UIView alloc] init];
        div1.backgroundColor = HexGRAY(0xFF, 255);
        [self addSubview:div1];
        [div1 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.width.equalTo(self);
            make.bottom.equalTo(self);
            make.top.equalTo(closeBtn.mas_bottom);
        }];
        
        UILabel *lbl = [[UILabel alloc] init];
        lbl.textColor = HexRGBA(0x000000, 255);
        lbl.font = [UIFont systemFontOfSize:Expand6(16, 17)];
        lbl.textAlignment = NSTextAlignmentCenter;
        lbl.text = @"分享到";
        [self addSubview:lbl];
        [lbl mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.width.equalTo(div1);
            make.height.mas_equalTo(48);
        }];
        
        UIView *line = [[UIView alloc] init];
        line.backgroundColor = HexRGBA(0xE3E3E3, 255);
        [self addSubview:line];
        [line mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.bottom.width.equalTo(lbl);
            make.height.mas_equalTo(0.5);
        }];
        
        CGFloat width = deviceWidth/2;
        for (NSInteger i = 0; i < 2; i++) {
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            btn.frame = CGRectMake(0, 0, 180, 180);
            btn.titleLabel.font = [UIFont systemFontOfSize:Expand6(12, 13)];
            [btn setTitleColor:HexRGBA(0x000000, 255) forState:UIControlStateNormal];
            [btn setTitle:0 == i ? @"微信好友" : @"朋友圈" forState:UIControlStateNormal];
            [btn setImage:[UIImage imageNamed:0 == i ? @"share_icon_weixin" : @"share_icon_pyq"] forState:UIControlStateNormal];
            [btn layoutButtonWithEdgeInsetsStyle:ButtonEdgeInsetsStyleImageTop imageTitlespace:12];
            [btn addTarget:self action:@selector(btnPressed:) forControlEvents:UIControlEventTouchUpInside];
            btn.tag = i;
            [self addSubview:btn];
            [btn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(lbl.mas_bottom);
                make.bottom.equalTo(div1).mas_offset(-BottomGap);
                make.left.mas_equalTo(width*i);
                make.width.mas_equalTo(width);
            }];
        }
    }
    return self;
}

- (void)show {
    _maskView.alpha = 0;
    [KEYWindow addSubview:_maskView];
    self.top = deviceHeight;
    [KEYWindow addSubview:self];
    
    [UIView animateWithDuration:0.25 animations:^{
        _maskView.alpha = 0.75;
        self.bottom = deviceHeight;
    }];
}

- (void)hide {
    [UIView animateWithDuration:0.25 animations:^{
        _maskView.alpha = 0;
        self.top = deviceHeight;
    } completion:^(BOOL finished) {
        [_maskView removeFromSuperview];
        [self removeFromSuperview];
    }];
}

- (void)btnPressed:(UIButton *)sender {
    if (self.sureBlock) {
        self.sureBlock(sender.tag);
    }
    [self hide];
}

@end
