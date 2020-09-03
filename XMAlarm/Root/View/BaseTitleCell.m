//
//  BaseTitleCell.m
//  QSMovie
//
//  Created by bo.chen on 17/8/19.
//  Copyright © 2017年 com.qingsheng. All rights reserved.
//

#import "BaseTitleCell.h"

@implementation BaseTitleCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _titleLbl = [[UILabel alloc] init];
        _titleLbl.textColor = HexRGBA(0x252525, 255);
        _titleLbl.font = [UIFont systemFontOfSize:14];
        [self.contentView addSubview:_titleLbl];
        
        [_titleLbl mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(15);
            make.right.equalTo(self.contentView).mas_offset(-15);
            make.top.height.equalTo(self);
        }];
    }
    return self;
}

@end
