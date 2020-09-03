//
//  TwoTitleCell.m
//  XMAlarm
//
//  Created by bo.chen on 17/9/4.
//  Copyright © 2017年 com.xmm. All rights reserved.
//

#import "TwoTitleCell.h"

@implementation TwoTitleCell {
    UILabel *_lbl1;
    UILabel *_lbl2;
    UIImageView *_arrow;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.accessoryType = UITableViewCellAccessoryNone;
        
        _lbl1 = [[UILabel alloc] init];
        _lbl1.textColor = HexRGBA(0x333333, 255);
        _lbl1.font = [UIFont systemFontOfSize:Expand6(14, 15)];
        [self.contentView addSubview:_lbl1];
        
        _lbl2 = [[UILabel alloc] init];
        _lbl2.textColor = HexRGBA(0x666666, 255);
        _lbl2.font = [UIFont systemFontOfSize:Expand6(12, 13)];
        _lbl2.textAlignment = NSTextAlignmentRight;
        _lbl2.numberOfLines = 0;
        [self.contentView addSubview:_lbl2];
        
        _arrow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_next_more"]];
        [self.contentView addSubview:_arrow];
        
        [_lbl1 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(15);
            make.width.equalTo(_lbl2).multipliedBy(0.5);
            make.right.equalTo(_lbl2.mas_left).mas_offset(-10);
            make.top.height.equalTo(self);
        }];
        [_lbl2 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_lbl1.mas_right).mas_offset(10);
            make.right.equalTo(_arrow.mas_left).mas_offset(-7);
            make.width.equalTo(_lbl1).multipliedBy(2);
            make.top.height.equalTo(self);
        }];
        [_arrow mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(8, 13));
            make.centerY.equalTo(self);
            make.left.equalTo(_lbl2.mas_right).mas_offset(7);
            make.right.equalTo(self).mas_offset(-15);
        }];
        [self.line mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(15);
            make.right.equalTo(self).mas_offset(-15);
            make.bottom.equalTo(self);
            make.height.mas_equalTo(0.5);
        }];
    }
    return self;
}

- (void)setDataDict:(NSDictionary *)dataDict {
    _dataDict = dataDict;
    
    _lbl1.text = dataDict[@"title1"];
    if ([dataDict[@"title2"] isKindOfClass:[NSString class]]) {
        _lbl2.text = dataDict[@"title2"];
    } else {
        _lbl2.attributedText = dataDict[@"title2"];
    }
    BOOL hideArrow = [dataDict[@"hideArrow"] boolValue];
    [_arrow mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(hideArrow ? 0 : 8);
        make.right.equalTo(self).mas_offset(hideArrow ? -8 : -15);
    }];
}

+ (CGFloat)height {
    return Expand6(50, 54);
}

@end
