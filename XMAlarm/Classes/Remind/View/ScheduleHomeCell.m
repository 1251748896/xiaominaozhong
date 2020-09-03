//
//  ScheduleHomeCell.m
//  XMAlarm
//
//  Created by bo.chen on 17/9/10.
//  Copyright © 2017年 com.xmm. All rights reserved.
//

#import "ScheduleHomeCell.h"

@implementation ScheduleHomeCell {
    UIImageView     *_iconView;
    UILabel         *_lbl1;
    UILabel         *_lbl2;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        _iconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"remind_home_note"]];
        [self.contentView addSubview:_iconView];
        
        _lbl1 = [[UILabel alloc] init];
        _lbl1.textColor = HexRGBA(0x373737, 255);
        _lbl1.font = [UIFont systemFontOfSize:15];
        [self.contentView addSubview:_lbl1];
        
        _lbl2 = [[UILabel alloc] init];
        _lbl2.textColor = HexRGBA(0x757575, 255);
        _lbl2.font = [UIFont systemFontOfSize:12];
        [self.contentView addSubview:_lbl2];
        
        [_iconView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(12);
            make.centerY.equalTo(_lbl1);
            make.size.mas_equalTo(_iconView.image.size);
        }];
        [_lbl1 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_iconView.mas_right).mas_offset(12);
            make.right.equalTo(self.contentView.mas_right).mas_offset(-12);
            make.height.mas_equalTo(20);
            make.top.mas_equalTo(12);
        }];
        [_lbl2 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(_lbl1);
            make.top.mas_equalTo(_lbl1.mas_bottom);
            make.height.mas_equalTo(20);
        }];
    }
    return self;
}

- (void)setSchedule:(Schedule *)schedule {
    _schedule = schedule;
    
    _lbl1.text = schedule.note;
    _lbl2.text = [NSDateFormatter stringFromDate:schedule.updateTime formatStr:kDateFormatStr];
}

@end
