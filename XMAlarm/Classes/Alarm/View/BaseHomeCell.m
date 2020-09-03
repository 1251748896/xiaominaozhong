//
//  BaseHomeCell.m
//  XMAlarm
//
//  Created by bo.chen on 17/10/15.
//  Copyright © 2017年 com.xmm. All rights reserved.
//

#import "BaseHomeCell.h"

@implementation BaseHomeCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _infoLbl = [[UILabel alloc] init];
        _infoLbl.textColor = HexRGBA(0x757575, 255);
        _infoLbl.font = [UIFont systemFontOfSize:13];
        _infoLbl.text = @"还有x小时x分";
        [self.contentView addSubview:_infoLbl];
        
        _enableBtn = [[SwitchButton alloc] init];
        [_enableBtn addTarget:self action:@selector(switchBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_enableBtn];
    }
    return self;
}

- (void)setAlarm:(BaseAlarm *)alarm {
    _alarm = alarm;
    
    [self.contentView bringSubviewToFront:_enableBtn];
    [_enableBtn setEnlargeEdgeWithTop:23 right:12 bottom:23 left:12];
    _enableBtn.on = alarm.enabled.boolValue;
    //开启就不隐藏
    _infoLbl.hidden = !_enableBtn.on;
    if (_enableBtn.on) {
        NSTimeInterval time = [alarm howLongRing:[NSDate date]];
        if (time != kMaxRingTime && time > 0) {
            _infoLbl.hidden = NO;
            _infoLbl.text = [NSDate howLongStr:time];
            NSRegularExpression *regular = [NSRegularExpression regularExpressionWithPattern:@"[0-9]+" options:0 error:NULL];
            NSArray *matchResults = [regular matchesInString:_infoLbl.text options:0 range:NSMakeRange(0, _infoLbl.text.length)];
            NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:_infoLbl.text attributes:nil];
            for (NSTextCheckingResult *result in matchResults) {
                [attrStr addAttribute:NSForegroundColorAttributeName value:HexRGBA(0xD22828, 255) range:result.range];
            }
            
            _infoLbl.attributedText = attrStr;
        } else {
            _infoLbl.hidden = NO;
            _infoLbl.text = @"时间已过";
        }
    } else {
        _infoLbl.hidden = YES;
    }
}

- (void)switchBtnPressed:(id)sender {
    _enableBtn.on = !_enableBtn.on;
    //开启就不隐藏
    _infoLbl.hidden = !_enableBtn.on;
    
    self.alarm.enabled = @(_enableBtn.on);
    self.alarm.updateTime = [NSDate date];
    [self.alarm save];
    
    if (_enableBtn.on) {
        [self.alarm addNotification];
        //打开后就刷新下时间
        [[NSNotificationCenter defaultCenter] postNotificationName:kUpdateAlarmListView object:nil];
    } else {
        [self.alarm deleteNotification:YES];
    }
}

@end
