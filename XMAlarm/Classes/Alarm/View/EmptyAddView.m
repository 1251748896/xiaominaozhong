//
//  EmptyAddView.m
//  XMAlarm
//
//  Created by bo.chen on 17/9/6.
//  Copyright © 2017年 com.xmm. All rights reserved.
//

#import "EmptyAddView.h"

@implementation EmptyAddView {
    UIImageView *_iconView;
    UILabel     *_lbl;
    UIButton    *_addBtn;
}

- (instancetype)initWithImage:(UIImage *)image title:(NSString *)title {
    self = [super initWithFrame:CGRectMake(0, 0, deviceWidth, deviceHeight-GAP20-topBarHeight-tabBarHeight)];
    if (self) {
        _iconView = [[UIImageView alloc] initWithImage:image];
        [self addSubview:_iconView];
        
        _lbl = [[UILabel alloc] init];
        _lbl.textColor = HexGRAY(0x66, 255);
        _lbl.font = [UIFont systemFontOfSize:14];
        _lbl.textAlignment = NSTextAlignmentCenter;
        _lbl.text = title;
        [self addSubview:_lbl];
        
        _addBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_addBtn setBackgroundImage:[[UIImage imageNamed:@"alert-sure"] getImageResize] forState:UIControlStateNormal];
        [_addBtn setTitleColor:HexRGBA(0xFFFFFF, 255) forState:UIControlStateNormal];
        _addBtn.titleLabel.font = [UIFont systemFontOfSize:Expand6(14, 15)];
        [_addBtn setTitle:@"添加" forState:UIControlStateNormal];
        [self addSubview:_addBtn];
        
        UIView *gap1 = [[UIView alloc] init];
        [self addSubview:gap1];
        UIView *gap2 = [[UIView alloc] init];
        [self addSubview:gap2];
        
        [_iconView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(_iconView.image.size);
            make.centerX.equalTo(self);
            make.top.equalTo(gap1.mas_bottom);
            make.bottom.equalTo(_lbl.mas_top).mas_offset(-20);
        }];
        [_lbl mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.width.equalTo(self);
            make.height.mas_equalTo(20);
            make.top.equalTo(_iconView.mas_bottom).mas_offset(20);
            make.bottom.equalTo(_addBtn.mas_top).mas_offset(-30);
        }];
        [_addBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(deviceWidth/2, Expand6(37, 39)));
            make.centerX.equalTo(self);
            make.top.equalTo(_lbl.mas_bottom).mas_offset(30);
            make.bottom.equalTo(gap2.mas_top);
        }];
        
        [gap1 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.width.equalTo(self);
            make.bottom.equalTo(_iconView.mas_top);
            make.height.mas_equalTo(gap2);
        }];
        [gap2 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.left.width.equalTo(self);
            make.top.equalTo(_addBtn.mas_bottom);
            make.height.equalTo(gap1);
        }];
    }
    return self;
}

@end
