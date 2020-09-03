//
//  IconLabel.m
//  QSMovie
//
//  Created by bo.chen on 17/8/21.
//  Copyright © 2017年 com.qingsheng. All rights reserved.
//

#import "IconLabel.h"

@implementation IconLabel {
    UIImageView *_iconView;
    UILabel     *_lbl;
    NSInteger   _gap;
}

- (instancetype)initWithIcon:(UIImage *)icon gap:(NSInteger)gap {
    self = [super init];
    if (self) {
        _gap = gap;
        
        _iconView = [[UIImageView alloc] initWithImage:icon];
        [self addSubview:_iconView];
        
        _lbl = [[UILabel alloc] init];
        [self addSubview:_lbl];
        
        [_iconView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self);
            make.centerY.equalTo(self);
            make.right.equalTo(_lbl.mas_left).mas_offset(-gap);
        }];
        [_lbl mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_iconView.mas_right).mas_offset(gap);
            make.right.equalTo(self);
            make.height.centerY.equalTo(self);
        }];
    }
    return self;
}

- (CGSize)sizeThatFits:(CGSize)size {
    CGSize fitSize = [_lbl sizeThatFits:size];
    fitSize.width += _gap+_iconView.width;
    return fitSize;
}

@end
