//
//  EditTwoTitleCell.m
//  XMAlarm
//
//  Created by bo.chen on 17/9/22.
//  Copyright © 2017年 com.xmm. All rights reserved.
//

#import "EditTwoTitleCell.h"

@implementation EditTwoTitleCell {
    UIImageView *_checkIcon;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self.line mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.equalTo(self);
            make.height.mas_equalTo(0.5);
        }];
        
        _checkIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_choice_nor"]];
        [self.contentView addSubview:_checkIcon];
        
        [_checkIcon mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(18, 18));
            make.centerY.equalTo(self);
            make.left.mas_equalTo(15);
        }];
        
        [self.lbl1 mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_checkIcon.mas_right).mas_offset(15);
            make.width.equalTo(self.lbl2).multipliedBy(0.5);
            make.right.equalTo(self.lbl2.mas_left).mas_offset(-10);
            make.top.height.equalTo(self);
        }];
    }
    return self;
}

- (void)setDataDict:(NSDictionary *)dataDict {
    [super setDataDict:dataDict];
    
    if ([dataDict[@"editing"] boolValue]) {
        _checkIcon.hidden = NO;
        [self.lbl1 mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_checkIcon.mas_right).mas_offset(15);
            make.width.equalTo(self.lbl2).multipliedBy(0.5);
            make.right.equalTo(self.lbl2.mas_left).mas_offset(-10);
            make.top.height.equalTo(self);
        }];
    } else {
        _checkIcon.hidden = YES;
        [self.lbl1 mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(15);
            make.width.equalTo(self.lbl2).multipliedBy(0.5);
            make.right.equalTo(self.lbl2.mas_left).mas_offset(-10);
            make.top.height.equalTo(self);
        }];
    }
    BOOL checked = [dataDict[@"checked"] boolValue];
    _checkIcon.image = [UIImage imageNamed:checked ? @"icon_choice_sel" : @"icon_choice_nor"];
}

@end
