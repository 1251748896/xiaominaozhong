//
//  TrafficLimitDayCell.m
//  XMAlarm
//
//  Created by bo.chen on 17/10/29.
//  Copyright © 2017年 com.xmm. All rights reserved.
//

#import "TrafficLimitDayCell.h"

@implementation TrafficLimitDayCell {
    UILabel     *_infoLbl;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _infoLbl = [[UILabel alloc] init];
        _infoLbl.textColor = [UIColor orangeColor];
        _infoLbl.font = [UIFont systemFontOfSize:Expand6(9, 10)];
        _infoLbl.textAlignment = NSTextAlignmentRight;
        [self.contentView addSubview:_infoLbl];
        
        [self.lbl2 mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self);
            make.height.equalTo(self).mas_offset(-10);
        }];
        [_infoLbl mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self.lbl2);
            make.bottom.equalTo(self);
            make.height.mas_equalTo(20);
        }];
    }
    return self;
}

- (void)setDataDict:(NSDictionary *)dataDict {
    [super setDataDict:dataDict];
    
    NSString *infoStr = dataDict[@"info"];
    if (infoStr.length > 0) {
        [self.lbl2 mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self);
            make.height.equalTo(self).mas_offset(-10);
        }];
        _infoLbl.hidden = NO;
        _infoLbl.text = infoStr;
    } else {
        [self.lbl2 mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self);
            make.height.equalTo(self);
        }];
        _infoLbl.hidden = YES;
    }
}

@end
