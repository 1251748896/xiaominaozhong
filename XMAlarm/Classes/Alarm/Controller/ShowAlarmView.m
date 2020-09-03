//
//  ShowAlarmView.m
//  XMAlarm
//
//  Created by bo.chen on 17/10/30.
//  Copyright © 2017年 com.xmm. All rights reserved.
//

#import "ShowAlarmView.h"
#import "TrafficLimitAlarm.h"

@interface ShowAlarmView ()
@property (nonatomic, strong) UILabel *timeLbl;
@property (nonatomic, strong) UIButton *riseBtn;
@property (nonatomic, strong) UIButton *sleepBtn;
@end

@implementation ShowAlarmView

- (instancetype)initWithAlarm:(BaseAlarm *)alarm alarmLog:(AlarmLog *)alarmLog {
    self = [super initWithFrame:CGRectMake(0, 0, deviceWidth, deviceHeight)];
    if (self) {
        self.alarm = alarm;
        self.alarmLog = alarmLog;
        self.tagObj = alarmLog.serverId;
        [self setupView];
    }
    return self;
}

#pragma mark - view

- (void)setupView {
    self.backgroundColor = HexGRAY(0xFF, 255);
    
    UIImageView *bgImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"infor_bg"]];
    [self addSubview:bgImg];
    
    self.timeLbl = [[UILabel alloc] init];
    self.timeLbl.textColor = HexGRAY(0xFF, 255);
    self.timeLbl.font = [UIFont boldSystemFontOfSize:64];
    self.timeLbl.textAlignment = NSTextAlignmentCenter;
    //显示当前时间
    self.timeLbl.text = [NSDateFormatter stringFromDate:[NSDate date] formatStr:@"HH:mm"];
    [self addSubview:self.timeLbl];
    
    UIButton *riseBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    riseBtn.frame = CGRectMake(0, 0, deviceWidth/2, 180);
    [riseBtn setTitleColor:HexGRAY(0x33, 255) forState:UIControlStateNormal];
    riseBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    [riseBtn setTitle:@"起床了" forState:UIControlStateNormal];
    [riseBtn setImage:[UIImage imageNamed:@"infor_icon_getup"] forState:UIControlStateNormal];
    [riseBtn layoutButtonWithEdgeInsetsStyle:ButtonEdgeInsetsStyleImageTop imageTitlespace:8];
    [riseBtn addTarget:self action:@selector(riseBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:riseBtn];
    self.riseBtn = riseBtn;
    
    UIButton *sleepBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    sleepBtn.frame = CGRectMake(0, 0, deviceWidth/2, 180);
    [sleepBtn setTitleColor:HexGRAY(0x33, 255) forState:UIControlStateNormal];
    sleepBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    [sleepBtn setTitle:@"贪睡" forState:UIControlStateNormal];
    [sleepBtn setImage:[UIImage imageNamed:@"infor_icon_sleep"] forState:UIControlStateNormal];
    [sleepBtn layoutButtonWithEdgeInsetsStyle:ButtonEdgeInsetsStyleImageTop imageTitlespace:2];
    [sleepBtn addTarget:self action:@selector(sleepBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:sleepBtn];
    self.sleepBtn = sleepBtn;
    
    [bgImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.width.equalTo(self);
        make.height.mas_equalTo(bgImg.image.size.height/bgImg.image.size.width*deviceWidth);
    }];
    [self.timeLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.width.equalTo(self);
        make.top.mas_equalTo(50+TopGap);
        make.height.mas_equalTo(64);
    }];
    
    CGFloat left = (deviceWidth-320)/3;
    [riseBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self).mas_offset(-(10+BottomGap));
        make.height.mas_equalTo(180);
        make.width.mas_equalTo(160);
        make.left.mas_equalTo(left);
    }];
    [sleepBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.height.width.equalTo(riseBtn);
        make.right.equalTo(self).mas_offset(-left);
    }];
}

- (void)show {
    [KEYWindow endEditing:YES];
    [KEYWindow addSubview:self];
    self.top = deviceHeight;
    [UIView animateWithDuration:0.25 animations:^{
        self.top = 0;
    } completion:^(BOOL finished) {
    }];
}

- (void)hideBy:(BOOL)later {
    [[AlarmManager sharedInstance] stopPlay];
    
    if (later) {
        //UILocalNotification已删除
        [self.alarmLog remove];
    } else {
        //删除UILocalNotification
        [self.alarmLog remove];
        [self.alarm removeNotiAndSaveLog:@[self.tagObj] logArray:@[]];
        
        //添加更多闹钟
        NSArray *classArray = @[[TrafficLimitAlarm class], [ShiftAlarm class], [RiseAlarm class], [RepeatRemind class]];
        NSInteger index = [classArray indexOfObjectPassingTest:^BOOL(Class  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            return [self.alarm isMemberOfClass:obj];
        }];
        if (index != NSNotFound) {
            [self.alarm addNotification:YES];
        }
    }
    
    //刷新闹钟列表
    [[NSNotificationCenter defaultCenter] postNotificationName:kRefreshAlarmList object:nil];
    
    [UIView animateWithDuration:0.25 animations:^{
        self.top = deviceHeight;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

- (AppNotiType)notiType {
    AppNotiType type = AppNotiType_RiseAlarm;
    if ([self.alarm isMemberOfClass:[ShiftAlarm class]]) {
        type = AppNotiType_ShiftAlarm;
    } else if ([self.alarm isMemberOfClass:[CustomAlarm class]]) {
        type = AppNotiType_CustomAlarm;
    }
    return type;
}

- (void)doLater:(NSNumber *)minutes {
    NSDate *alarmDate = [[NSDate date] dateByAddingTimeInterval:minutes.integerValue*60];
    AlarmLog *alarmLog = [self.alarm addAlarmLog:[self notiType] fireDate:alarmDate repeat:0];
    alarmLog.isLaterRemind = @YES;
    alarmLog.extJsonStr = self.alarmLog.extJsonStr;
    [self.alarm removeNotiAndSaveLog:@[self.tagObj] logArray:@[alarmLog]];
    [self hideBy:YES];
}

#pragma mark - action

- (void)riseBtnPressed:(id)sender {
    if ([self.alarm isMemberOfClass:[CustomAlarm class]]) {
        //自定义闹钟 临时提醒 提醒后就删除
        [self.alarm remove];
    } else if ([self.alarm isMemberOfClass:[RiseAlarm class]]) {
        //检查限行，同步生成提醒
        for (TrafficLimitAlarm *limitAlarm in [TrafficLimitAlarm allForUser]) {
            [limitAlarm syncShiftAlarm];
        }
        if (((RiseAlarm *)self.alarm).repeatArray.count == 0) {
            //单次起床闹钟，提醒后就停掉
            self.alarm.enabled = @(NO);
            self.alarm.updateTime = [NSDate date];
            [self.alarm save];
        }
    }
    
    [self hideBy:NO];
}

- (void)sleepBtnPressed:(id)sender {
    //闹钟都有小睡，小睡是再生成一次提醒，不能调用deleteNotification，本次提醒对应的AlarmLog会先删除
    RiseAlarm *riseAlarm = (RiseAlarm *)self.alarm;
    [self doLater:riseAlarm.sleepTime];
}

@end
