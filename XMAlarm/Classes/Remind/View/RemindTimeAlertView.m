//
//  RemindTimeAlertView.m
//  XMAlarm
//
//  Created by bo.chen on 17/9/29.
//  Copyright © 2017年 com.xmm. All rights reserved.
//

#import "RemindTimeAlertView.h"

@interface RemindTimeAlertView ()
<UIPickerViewDataSource,
UIPickerViewDelegate>
{
    UIPickerView    *_picker;
    UIDatePicker    *_timePicker;
}
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) RemindSetting *setting;
@end

@implementation RemindTimeAlertView

- (instancetype)initWithTitle:(NSString *)title remindSetting:(RemindSetting *)setting {
    self = [super initWithFrame:CGRectMake(0, 0, deviceWidth-20, 240)];
    if (self) {
        self.title = title;
        self.setting = setting;
        
        _picker = [[UIPickerView alloc] init];
        _picker.dataSource = self;
        _picker.delegate = self;
        [_picker selectRow:(1-setting.preDay.integerValue) inComponent:0 animated:NO];
        [self addSubview:_picker];
        
        _timePicker = [[UIDatePicker alloc] init];
        _timePicker.datePickerMode = UIDatePickerModeTime;
        _timePicker.date = setting.time;
        [self addSubview:_timePicker];
        
        [_picker mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.left.equalTo(self);
            make.right.equalTo(_timePicker.mas_left);
            make.width.equalTo(_timePicker.mas_width).multipliedBy(0.5);
        }];
        
        [_timePicker mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.right.equalTo(self);
            make.left.equalTo(_picker.mas_right);
            make.width.equalTo(_picker.mas_width).multipliedBy(2);
        }];
    }
    return self;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return 2;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if (0 == row) {
        return @"前一天";
    } else if (1 == row) {
        return @"当日";
    }
    return @"";
}

- (void)show {
    CustomIOSAlertView *alertView = [[CustomIOSAlertView alloc] initWithTitle:self.title];
    alertView.containerView = self;
    alertView.buttonTitles = @[@"取消", @"确定"];
    alertView.delegate = NULL;//为null，不会自动close
    [alertView setOnButtonTouchUpInside:^(CustomIOSAlertView *alertView, int buttonIndex) {
        if (0 == buttonIndex) {
            [alertView close];
        } else if (1 == buttonIndex) {
            if (self.sureBlock) {
                self.setting.preDay = @(1-[_picker selectedRowInComponent:0]);
                self.setting.time = _timePicker.date;
                self.sureBlock(self.setting);
            }
            [alertView close];
        }
    }];
    [alertView show];
}

@end
