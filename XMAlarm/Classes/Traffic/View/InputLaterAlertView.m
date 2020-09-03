//
//  InputLaterAlertView.m
//  XMAlarm
//
//  Created by bo.chen on 17/11/7.
//  Copyright © 2017年 com.xmm. All rights reserved.
//

#import "InputLaterAlertView.h"

@interface InputLaterAlertView ()
<UIPickerViewDataSource,
UIPickerViewDelegate>
{
    UIPickerView    *_picker1;
    UIPickerView    *_picker2;
}
@end

@implementation InputLaterAlertView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:CGRectMake(0, 0, deviceWidth-20, 240)];
    if (self) {
        UIImageView *bgView = [[UIImageView alloc] init];
        bgView.image = [UIImage imageNamed:@"bg_custom_time"];
        bgView.hidden = YES;
        [self addSubview:bgView];
        
        _picker1 = [[UIPickerView alloc] init];
        _picker1.dataSource = self;
        _picker1.delegate = self;
        [_picker1 selectRow:2 inComponent:0 animated:NO];
        [self addSubview:_picker1];
        
        _picker2 = [[UIPickerView alloc] init];
        _picker2.dataSource = self;
        _picker2.delegate = self;
        [_picker2 selectRow:0 inComponent:0 animated:NO];
        [self addSubview:_picker2];
        
        UILabel *hourLbl = [[UILabel alloc] init];
        hourLbl.textColor = HexRGBA(0x333333, 255);
        hourLbl.font = [UIFont boldSystemFontOfSize:Expand6(16, 17)];
        hourLbl.text = @"小时";
        hourLbl.textAlignment = NSTextAlignmentCenter;
        [self addSubview:hourLbl];
        
        UILabel *minLbl = [[UILabel alloc] init];
        minLbl.textColor = HexRGBA(0x333333, 255);
        minLbl.font = [UIFont boldSystemFontOfSize:Expand6(16, 17)];
        minLbl.text = @"分钟";
        minLbl.textAlignment = NSTextAlignmentCenter;
        [self addSubview:minLbl];
        
        [bgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(Expand6(244, 280), 67));
            make.center.equalTo(self);
        }];
        
        [_picker1 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.height.equalTo(self);
            make.left.equalTo(bgView).mas_offset(25);
            make.right.equalTo(hourLbl.mas_left);
        }];
        [hourLbl mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(20);
            make.centerY.equalTo(self);
            make.left.equalTo(_picker1.mas_right);
            make.right.equalTo(_picker2.mas_left);
            make.width.equalTo(_picker1);
        }];
        [_picker2 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.height.equalTo(self);
            make.left.equalTo(hourLbl.mas_right);
            make.right.equalTo(minLbl.mas_left);
            make.width.equalTo(_picker1);
        }];
        [minLbl mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(20);
            make.centerY.equalTo(self);
            make.left.equalTo(_picker2.mas_right);
            make.right.equalTo(bgView.mas_right).mas_offset(-15);
            make.width.equalTo(_picker1);
        }];
    }
    return self;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (pickerView == _picker1) {
        return 12+1;
    } else {
        if ([_picker1 selectedRowInComponent:0] == 0) {
            return 59;
        } else {
            return 60;
        }
    }
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if (pickerView == _picker1) {
        return [NSString stringWithFormat:@"%@", @(row)];
    } else {
        if ([_picker1 selectedRowInComponent:0] == 0) {
            return [NSString stringWithFormat:@"%@", @(row+1)];
        } else {
            return [NSString stringWithFormat:@"%@", @(row)];
        }
    }
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if (pickerView == _picker1) {
        [_picker2 reloadAllComponents];
    }
}

- (void)show {
    NSString *title = [NSDateFormatter stringFromDate:[NSDate date] formatStr:@"今天  HH:mm"];
    CustomIOSAlertView *alertView = [[CustomIOSAlertView alloc] initWithTitle:title];
    alertView.containerView = self;
    alertView.buttonTitles = @[@"取消", @"确定"];
    alertView.delegate = NULL;//为null，不会自动close
    [alertView setOnButtonTouchUpInside:^(CustomIOSAlertView *alertView, int buttonIndex) {
        if (0 == buttonIndex) {
            [alertView close];
        } else if (1 == buttonIndex) {
            if (self.sureBlock) {
                NSInteger minutes = 0;
                if ([_picker1 selectedRowInComponent:0] == 0) {
                    minutes = [_picker2 selectedRowInComponent:0]+1;
                } else {
                    minutes = [_picker2 selectedRowInComponent:0];
                    minutes += [_picker1 selectedRowInComponent:0]*60;
                }
                self.sureBlock(@(minutes));
            }
            [alertView close];
        }
    }];
    [alertView show];
}

@end
