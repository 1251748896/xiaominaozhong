//
//  AlarmTimeCell.m
//  XMAlarm
//
//  Created by bo.chen on 17/9/5.
//  Copyright © 2017年 com.xmm. All rights reserved.
//

#import "AlarmTimeCell.h"

@implementation AlarmTimeCell {
    UIDatePicker    *_picker;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        _picker = [[UIDatePicker alloc] init];
        _picker.datePickerMode = UIDatePickerModeTime;
        [self.contentView addSubview:_picker];
        
        [_picker mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
        
        [self.line mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self);
            make.height.mas_equalTo(0.5);
            make.left.mas_equalTo(15);
            make.right.equalTo(self).mas_offset(-15);
        }];
    }
    return self;
}

@end
