//
//  TrafficRemindAllCell.m
//  XMAlarm
//
//  Created by bo.chen on 17/9/20.
//  Copyright © 2017年 com.xmm. All rights reserved.
//

#import "TrafficRemindAllCell.h"
#import "RemindSetting.h"

@implementation TrafficRemindAllCell {
    NSMutableArray  *_lblArray;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        _lblArray = [NSMutableArray arrayWithCapacity:3];
        
        for (NSInteger i = 0; i < 3; i++) {
            UILabel *lbl = [[UILabel alloc] init];
//            if (0 == i) {
//                lbl.backgroundColor = [UIColor redColor];
//            } else if (1 == i) {
//                lbl.backgroundColor = [UIColor greenColor];
//            } else {
//                lbl.backgroundColor = [UIColor blueColor];
//            }
            lbl.textColor = HexRGBA(0x666666, 255);
            lbl.font = [UIFont systemFontOfSize:Expand6(12, 13)];
            [self.contentView addSubview:lbl];
            [_lblArray addObject:lbl];
        }
//        
//        [_lblArray mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.left.mas_equalTo(15);
//            make.right.equalTo(self).mas_offset(-15);
//            make.height.mas_equalTo(Expand6(14, 15));
//        }];
//        [_lblArray[1] mas_updateConstraints:^(MASConstraintMaker *make) {
//            make.centerY.equalTo(self);
//        }];
//        [_lblArray[0] mas_updateConstraints:^(MASConstraintMaker *make) {
//            make.bottom.equalTo([_lblArray[1] mas_top]);
//        }];
//        [_lblArray[2] mas_updateConstraints:^(MASConstraintMaker *make) {
//            make.top.equalTo([_lblArray[1] mas_bottom]);
//        }];
    }
    return self;
}

- (void)setRemindArray:(NSArray *)remindArray {
    _remindArray = remindArray;
    
    for (NSInteger i = 0; i < _lblArray.count; i++) {
        UILabel *lbl = _lblArray[i];
        if (i < remindArray.count) {
            lbl.hidden = NO;
            RemindSetting *setting = remindArray[i];
            lbl.text = [NSString stringWithFormat:@"第%@次   %@", [@(i+1) chineseTenStr], [setting formatTrafficRemindStr]];
        } else {
            lbl.hidden = YES;
        }
    }
    if (remindArray.count == 1) {
        [_lblArray[0] mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(15);
            make.right.equalTo(self).mas_offset(-15);
            make.height.mas_equalTo(18);
            make.centerY.equalTo(self);
        }];
    } else if (remindArray.count == 2) {
        [_lblArray[0] mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(15);
            make.right.equalTo(self).mas_offset(-15);
            make.height.mas_equalTo(18);
            make.bottom.equalTo(self.mas_centerY).mas_offset(-2);
        }];
        [_lblArray[1] mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(15);
            make.right.equalTo(self).mas_offset(-15);
            make.height.mas_equalTo(18);
            make.top.equalTo(self.mas_centerY).mas_offset(2);
        }];
    } else {
        [_lblArray[1] mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(15);
            make.right.equalTo(self).mas_offset(-15);
            make.height.mas_equalTo(18);
            make.centerY.equalTo(self);
        }];
        [_lblArray[0] mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(15);
            make.right.equalTo(self).mas_offset(-15);
            make.height.mas_equalTo(18);
            make.bottom.equalTo([_lblArray[1] mas_top]);
        }];
        [_lblArray[2] mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(15);
            make.right.equalTo(self).mas_offset(-15);
            make.height.mas_equalTo(18);
            make.top.equalTo([_lblArray[1] mas_bottom]);
        }];
    }
}

+ (CGFloat)heightWithRemindArray:(NSArray *)remindArray {
    return Expand6(50, 54) + Expand6(14, 15) * (remindArray.count-1);
}

@end
