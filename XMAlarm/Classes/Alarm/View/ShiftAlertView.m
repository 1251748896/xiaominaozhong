//
//  ShiftAlertView.m
//  XMAlarm
//
//  Created by bo.chen on 17/9/4.
//  Copyright © 2017年 com.xmm. All rights reserved.
//

#import "ShiftAlertView.h"

@interface ShiftAlertView ()
<UIPickerViewDataSource,
UIPickerViewDelegate>
{
    UIPickerView    *_picker;
}
@property (nonatomic, strong) NSString *title;
@end

@implementation ShiftAlertView

- (instancetype)initWithTitle:(NSString *)title currentPeriod:(NSInteger)period {
    self = [super initWithFrame:CGRectMake(0, 0, deviceWidth-20, 240)];
    if (self) {
        self.title = title;
        
        _picker = [[UIPickerView alloc] init];
        _picker.dataSource = self;
        _picker.delegate = self;
        [_picker selectRow:period-1 inComponent:1 animated:NO];
        [self addSubview:_picker];
        
        [_picker mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
    }
    return self;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 3;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (0 == component || 2 == component) {
        return 1;
    } else {
        return 31;
    }
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if (0 == component) {
        return @"每一轮";
    } else if (2 == component) {
        return @"天";
    } else {
        return [NSString stringWithFormat:@"%@", @(row+1)];
    }
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
                NSInteger choice = [_picker selectedRowInComponent:1];
                self.sureBlock(@(choice+1));
            }
            [alertView close];
        }
    }];
    [alertView show];
}

@end
