//
//  BaseIconTitleCell.m
//  QSMovie
//
//  Created by bo.chen on 17/8/20.
//  Copyright © 2017年 com.qingsheng. All rights reserved.
//

#import "BaseIconTitleCell.h"

@implementation BaseIconTitleCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _iconView = [[UIImageView alloc] init];
        [self.contentView addSubview:_iconView];
        [_iconView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(14);
            make.size.mas_equalTo(CGSizeMake(20, 20));
            make.centerY.equalTo(self);
            make.right.equalTo(self.titleLbl.mas_left).mas_offset(-10);
        }];
        [self.titleLbl mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_iconView.mas_right).mas_offset(10);
            make.right.equalTo(self.contentView).mas_offset(-14);
            make.top.height.equalTo(self);
        }];
    }
    return self;
}

@end
