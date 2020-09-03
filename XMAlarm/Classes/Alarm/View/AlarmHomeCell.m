//
//  AlarmHomeCell.m
//  XMAlarm
//
//  Created by bo.chen on 17/9/4.
//  Copyright © 2017年 com.xmm. All rights reserved.
//

#import "AlarmHomeCell.h"
#import "RiseAlarm.h"
#import "ShiftAlarm.h"
#import "CustomAlarm.h"

@implementation AlarmHomeCell {
    UILabel *_titleLbl;
    UILabel *_timeLbl;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _titleLbl = [[UILabel alloc] init];
        _titleLbl.textColor = HexRGBA(0x373737, 255);
        _titleLbl.font = [UIFont systemFontOfSize:15];
        [self.contentView addSubview:_titleLbl];
        
        _timeLbl = [[UILabel alloc] init];
        _timeLbl.textColor = HexRGBA(0x373737, 255);
        _timeLbl.font = [UIFont systemFontOfSize:24];
        [self.contentView addSubview:_timeLbl];
        
        [_titleLbl mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(12);
            make.top.mas_equalTo(6);
            make.height.mas_equalTo(30);
            make.right.equalTo(self.enableBtn.mas_left).mas_offset(-12);
        }];
        [_timeLbl mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_titleLbl);
            make.right.equalTo(self.infoLbl.mas_left).mas_offset(-15);
            make.top.equalTo(_titleLbl.mas_bottom);
            make.height.mas_equalTo(30);
        }];
        [self.infoLbl mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_timeLbl.mas_right).mas_offset(15);
            make.right.equalTo(_titleLbl);
            make.top.height.equalTo(_timeLbl);
        }];
        [self.enableBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_titleLbl.mas_right).mas_offset(12);
            make.right.equalTo(self).mas_offset(-12);
            make.size.mas_equalTo(CGSizeMake(55, 25));
            make.centerY.equalTo(self);
        }];
    }
    return self;
}

- (void)setAlarm:(BaseAlarm *)alarm {
    [super setAlarm:alarm];
    
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:alarm.name attributes:@{NSForegroundColorAttributeName: _titleLbl.textColor, NSFontAttributeName: _titleLbl.font}];
    [self appendOtherTitleStr:attrStr];
    _titleLbl.attributedText = attrStr;
    _timeLbl.text = [alarm formatAlarmTimeStr];
    CGFloat lblWidth = ceilf([_timeLbl sizeThatFits:CGSizeZero].width);
    [_timeLbl mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(lblWidth);
    }];
}

- (void)appendOtherTitleStr:(NSMutableAttributedString *)attrStr {
    if ([self.alarm isMemberOfClass:[RiseAlarm class]]) {
        [attrStr appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@" (%@)", [(RiseAlarm *)self.alarm formatRepeatStr]] attributes:@{NSForegroundColorAttributeName: HexRGBA(0x757575, 255), NSFontAttributeName: [UIFont systemFontOfSize:13]}]];
    } else if ([self.alarm isMemberOfClass:[ShiftAlarm class]]) {
        [attrStr appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@" (%@)", [(ShiftAlarm *)self.alarm formatPeriodStr]] attributes:@{NSForegroundColorAttributeName: HexRGBA(0x757575, 255), NSFontAttributeName: [UIFont systemFontOfSize:13]}]];
    } else if ([self.alarm isMemberOfClass:[CustomAlarm class]]) {
        [attrStr appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@" (%@)", [(CustomAlarm *)self.alarm formatDateStr]] attributes:@{NSForegroundColorAttributeName: HexRGBA(0x757575, 255), NSFontAttributeName: [UIFont systemFontOfSize:13]}]];
    }
}

@end
