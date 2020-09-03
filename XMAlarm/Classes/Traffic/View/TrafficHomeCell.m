//
//  TrafficHomeCell.m
//  XMAlarm
//
//  Created by bo.chen on 17/9/20.
//  Copyright © 2017年 com.xmm. All rights reserved.
//

#import "TrafficHomeCell.h"
#import "TrafficLimitAlarm.h"

@implementation TrafficHomeCell {
    UILabel     *_cityLbl;
    UILabel     *_plateNumLbl;
    UILabel     *_titleLabel;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        UILabel *lbl = [[UILabel alloc] init];
        lbl.textColor = HexRGBA(0x373737, 255);
        lbl.font = [UIFont systemFontOfSize:17];
        lbl.textAlignment = NSTextAlignmentCenter;
        lbl.text = @"限行";
        [self.contentView addSubview:lbl];
        _titleLabel = lbl;
        
        UIView *vline = [[UIView alloc] init];
        vline.backgroundColor = HexRGBA(0xE3E3E3, 255);
        [self.contentView addSubview:vline];
        
        _cityLbl = [[UILabel alloc] init];
        _cityLbl.textColor = HexRGBA(0x666666, 255);
        _cityLbl.font = [UIFont systemFontOfSize:16];
        _cityLbl.text = @"北京 每周五（13周轮换）";
        [self.contentView addSubview:_cityLbl];
        
        _plateNumLbl = [[UILabel alloc] init];
        _plateNumLbl.textColor = HexRGBA(0x666666, 255);
        _plateNumLbl.font = [UIFont systemFontOfSize:14];
        _plateNumLbl.text = @"川A: 00000";
        [self.contentView addSubview:_plateNumLbl];
        
        [lbl mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.top.bottom.equalTo(self);
            make.width.mas_equalTo(60);
        }];
        [vline mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(lbl.mas_right);
            make.height.mas_equalTo(60);
            make.width.mas_equalTo(0.5);
            make.centerY.equalTo(self);
        }];
        [_cityLbl mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(11);
            make.height.mas_equalTo(22);
            make.left.equalTo(vline.mas_right).mas_offset(12);
            make.right.equalTo(self.enableBtn.mas_left).mas_offset(-12);
        }];
        [_plateNumLbl mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.width.height.equalTo(_cityLbl);
            make.top.equalTo(_cityLbl.mas_bottom);
        }];
        [self.infoLbl mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.width.height.equalTo(_cityLbl);
            make.top.equalTo(_plateNumLbl.mas_bottom);
        }];
        [self.enableBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_cityLbl.mas_right).mas_offset(12);
            make.right.equalTo(self).mas_offset(-12);
            make.size.mas_equalTo(CGSizeMake(55, 25));
            make.centerY.equalTo(self);
        }];
    }
    return self;
}

- (void)setAlarm:(TrafficLimitAlarm *)alarm {
    [super setAlarm:alarm];
    NSString *limitDayString = [alarm formatLimitDayStr];
    if ([alarm.showState intValue] == 12 || [alarm.showState intValue] == 13) {
        limitDayString = @"";
    }
    
    
    int show = alarm.showState.intValue;
    _cityLbl.text = [NSString stringWithFormat:@"%@   %@", [alarm.city.name stringByReplacingOccurrencesOfString:@"市" withString:@""], limitDayString];
    if (1 == alarm.limitRule.limitMode.integerValue && show != 12 && show != 13) {
        _cityLbl.text = [_cityLbl.text stringByAppendingFormat:@" (%@周轮换)", alarm.limitRule.shiftWeeks];
    }
    _plateNumLbl.attributedText = [alarm formatPlateNumberStr2];
    
    if (show == 12 || show == 13) {
        _titleLabel.text = @"年审";
        NSString *time = [alarm.yearCheckDate dateFormat:@"yyyy-MM-dd"];
        NSString *temp = [[time componentsSeparatedByString:@" "] firstObject];
        _plateNumLbl.text = [NSString stringWithFormat:@"车辆注册日期: %@",temp];
        self.infoLbl.text = @"";
        self.enableBtn.hidden = YES;
    } else {
        if ([alarm.city.mid intValue] == 581) {
            //长春 外地车不限行
            if (![alarm.plateNumber hasPrefix:alarm.limitRule.plateNumberPre]) {
                _titleLabel.text = @"年审";
                NSString *time = [alarm.yearCheckDate dateFormat:@"yyyy-MM-dd"];
                NSString *temp = [[time componentsSeparatedByString:@" "] firstObject];
                if (alarm.plateNumber.length) {
                    _plateNumLbl.text = alarm.plateNumber;
                    self.infoLbl.text = [NSString stringWithFormat:@"车辆注册日期: %@",temp];
                } else {
                    _plateNumLbl.text = [NSString stringWithFormat:@"车辆注册日期: %@",temp];
                    self.infoLbl.text = @"";
                }
                
                self.enableBtn.hidden = YES;
                return;
            }
        }
        
        if ([alarm.showState intValue] == 12 || [alarm.showState intValue] == 13) {
            //年审
            if (![alarm.plateNumber hasPrefix:alarm.limitRule.plateNumberPre]) {
                _titleLabel.text = @"年审";
                NSString *time = [alarm.yearCheckDate dateFormat:@"yyyy-MM-dd"];
                NSString *temp = [[time componentsSeparatedByString:@" "] firstObject];
                if (alarm.plateNumber.length) {
                    _plateNumLbl.text = alarm.plateNumber;
                    self.infoLbl.text = [NSString stringWithFormat:@"车辆注册日期: %@",temp];
                } else {
                    _plateNumLbl.text = [NSString stringWithFormat:@"车辆注册日期: %@",temp];
                    self.infoLbl.text = @"";
                }
                
                self.enableBtn.hidden = YES;
                return;
            }
        }
        
        _titleLabel.text = @"限行";
        self.enableBtn.hidden = NO;
    }
}

@end
