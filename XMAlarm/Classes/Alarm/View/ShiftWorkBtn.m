//
//  ShiftWorkBtn.m
//  XMAlarm
//
//  Created by bo.chen on 17/9/8.
//  Copyright © 2017年 com.xmm. All rights reserved.
//

#import "ShiftWorkBtn.h"

@implementation ShiftWorkBtn {
    UILabel     *_dayLbl;
    UILabel     *_timeLbl;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _dayLbl = [[UILabel alloc] init];
        _dayLbl.textColor = HexRGBA(0x666666, 255);
        _dayLbl.font = [UIFont systemFontOfSize:12*scaleRatio];
        _dayLbl.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_dayLbl];
        
        _timeLbl = [[UILabel alloc] init];
        _timeLbl.textColor = HexRGBA(0xFFFFFF, 255);
        _timeLbl.font = [UIFont systemFontOfSize:12*scaleRatio];
        _timeLbl.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_timeLbl];
        
        [_dayLbl mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self).mas_offset(-32*scaleRatio);
            make.height.mas_equalTo(14*scaleRatio);
            make.left.width.equalTo(self);
        }];
        [_timeLbl mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.width.equalTo(self);
            make.height.mas_equalTo(20*scaleRatio);
            make.bottom.equalTo(self).mas_offset(-3*scaleRatio);
        }];
    }
    return self;
}

- (void)setWorkInfo:(ShiftWorkInfo *)workInfo {
    _workInfo = workInfo;
    
    BOOL needWork = workInfo.needWork.boolValue;
    UIImage *image = [UIImage imageNamed:needWork ? @"shiftalarm_bg_work" : @"shiftalarm_bg_rest"];
    [self setBackgroundImage:image forState:UIControlStateNormal];
    _dayLbl.text = [workInfo formatIndexStr];
    _timeLbl.font = [UIFont systemFontOfSize:needWork ? 17 : 15];
    _timeLbl.text = needWork ? [workInfo formatTimeStr] : @"休息";
}

@end
