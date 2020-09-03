//
//  ShowTrafficView.m
//  XMAlarm
//
//  Created by bo.chen on 17/10/30.
//  Copyright © 2017年 com.xmm. All rights reserved.
//

#import "ShowTrafficView.h"
#import "RemindLaterAlertView.h"

@interface ShowTrafficView ()
@property (nonatomic, strong) UILabel *timeLbl;
@end

@implementation ShowTrafficView

#pragma mark - view

- (UIImage *)bgImg {
    return [UIImage imageNamed:@"infor_limitline_bg"];
}

- (NSString *)dateLblText {
    return [NSDateFormatter stringFromDate:[NSDate date] formatStr:kDateFormatStr];
}

- (UIImage *)iconViewImg {
    return [UIImage imageNamed:@"infor_icon_toplimitline"];
}

- (NSString *)lblText {
    return @"限行提示";
}

- (NSString *)timeLblText {
    NSDictionary *extDict = [self.alarmLog.extJsonStr objectFromJSONString_JSONKit];
    NSDate *limitDate = [NSDate dateWithTimeIntervalSince1970:[extDict[@"limitDate"] doubleValue]];
    BOOL isToday = [limitDate isEqualToDateIgnoringTime:[NSDate date]];
    return [NSString stringWithFormat:@"%@     %@限行", (isToday ? @"今天" : @"明天"), [(TrafficLimitAlarm *)self.alarm plateNumberForShow]];
}

- (AppNotiType)notiType {
    return AppNotiType_Traffic;
}

- (void)setupView {
    self.backgroundColor = HexGRAY(0xFF, 255);
    
    UIImageView *bgImg = [[UIImageView alloc] initWithImage:[self bgImg]];
    [self addSubview:bgImg];
    
    UILabel *dateLbl = [[UILabel alloc] init];
    dateLbl.textColor = HexRGBA(0xFFFFFF, 255);
    dateLbl.font = [UIFont systemFontOfSize:22];
    dateLbl.text = [self dateLblText];
    [self addSubview:dateLbl];
    
    UIImageView *iconView = [[UIImageView alloc] initWithImage:[self iconViewImg]];
    [self addSubview:iconView];
    
    UILabel *lbl = [[UILabel alloc] init];
    lbl.textColor = HexRGBA(0x0090FF, 255);
    lbl.font = [UIFont systemFontOfSize:20];
    lbl.textAlignment = NSTextAlignmentCenter;
    lbl.text = [self lblText];
    [self addSubview:lbl];
    
    UIView *line1 = [[UIView alloc] init];
    line1.backgroundColor = HexRGBA(0xE3E3E3, 255);
    [self addSubview:line1];
    
    self.timeLbl = [[UILabel alloc] init];
    self.timeLbl.textColor = HexRGBA(0x373737, 255);
    self.timeLbl.textAlignment = NSTextAlignmentCenter;
    self.timeLbl.text = [self timeLblText];
    [self addSubview:self.timeLbl];
    
    UIView *line2 = [[UIView alloc] init];
    line2.backgroundColor = HexRGBA(0xE3E3E3, 255);
    [self addSubview:line2];
    
    UIButton *laterBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    laterBtn.frame = CGRectMake(0, 0, 60, 60);
    [laterBtn setBackgroundImage:[UIImage imageNamed:@"inforlimit_btn_later2"] forState:UIControlStateNormal];
    [laterBtn setTitleColor:HexGRAY(0xFF, 255) forState:UIControlStateNormal];
    laterBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    laterBtn.titleEdgeInsets = UIEdgeInsetsMake(-4, 0, 0, 0);
    [laterBtn addTarget:self action:@selector(laterBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:laterBtn];
    
    UILabel *laterLbl = [[UILabel alloc] init];
    laterLbl.textColor = HexGRAY(0xFF, 255);
    laterLbl.font = [UIFont systemFontOfSize:14];
    laterLbl.numberOfLines = 2;
    laterLbl.text = @"稍后\n提醒";
    laterLbl.textAlignment = NSTextAlignmentCenter;
    [self addSubview:laterLbl];
    
    UIButton *sureBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    sureBtn.frame = CGRectMake(0, 0, 60, 60);
    [sureBtn setBackgroundImage:[UIImage imageNamed:@"infor_btn_sure2"] forState:UIControlStateNormal];
    [sureBtn setTitleColor:HexRGBA(0x4598DE, 255) forState:UIControlStateNormal];
    sureBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [sureBtn setTitle:@"知道了" forState:UIControlStateNormal];
    sureBtn.titleEdgeInsets = UIEdgeInsetsMake(-4, 0, 0, 0);
    [sureBtn addTarget:self action:@selector(sureBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:sureBtn];
    
    [bgImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.width.equalTo(self);
        make.top.equalTo(self).mas_offset(0);
        make.height.mas_equalTo(bgImg.image.size.height/bgImg.image.size.width*deviceWidth);
    }];
    [dateLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(60);
        make.left.mas_equalTo(30*scaleRatio);
        make.width.mas_equalTo(150);
        make.top.mas_equalTo(20*scaleRatio+TopGap);
    }];
    [iconView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(iconView.image.size);
        make.bottom.equalTo(lbl.mas_top).mas_offset(-(scaleRatio*15));
        make.centerX.equalTo(self);
    }];
    [lbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(deviceWidth, 60*scaleRatio));
        make.top.mas_equalTo(scaleRatio*210);
        make.centerX.equalTo(self);
    }];
    [line1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(lbl.mas_bottom).mas_offset(15*scaleRatio);
        make.height.mas_equalTo(1);
        make.left.mas_equalTo(45);
        make.right.equalTo(self).mas_offset(-45);
    }];
    [self.timeLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.width.equalTo(line1);
        make.height.mas_equalTo(68);
        make.top.equalTo(line1.mas_bottom);
    }];
    [line2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.width.height.equalTo(line1);
        make.top.equalTo(self.timeLbl.mas_bottom);
    }];
    
    CGFloat left = (deviceWidth-320)/3;
    [laterBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self).mas_offset(-(50+BottomGap));
        make.size.mas_equalTo(CGSizeMake(60, 60));
        make.left.mas_equalTo(left+(160-60)/2.0+Expand6(10, 20));
    }];
    [laterLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.equalTo(laterBtn);
        make.left.equalTo(laterBtn).mas_offset(-2);
        make.top.equalTo(laterBtn).mas_offset(-2);
    }];
    [sureBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(laterBtn);
        make.size.mas_equalTo(CGSizeMake(60, 60));
        make.right.equalTo(self).mas_offset(-(left+(160-60)/2.0+Expand6(10, 20)));
    }];
}

#pragma mark - action

- (void)laterBtnPressed:(id)sender {
    //点击了稍后提醒后，页面跳转到设置时间页面，同时停止铃声
    [[AlarmManager sharedInstance] stopPlay];
    
    WeakSelf
    RemindLaterAlertView *alertView = [[RemindLaterAlertView alloc] initWithFrame:CGRectZero];
    alertView.sureBlock = ^(NSNumber *minutes) {
        [weakSelf doLater:minutes];
    };
    [alertView show];
}

- (void)sureBtnPressed:(id)sender {
    //知道了就直接隐藏
    [self hideBy:NO];
}

@end
