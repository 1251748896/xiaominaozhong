//
//  RepeatYearCell.m
//  XMAlarm
//
//  Created by bo.chen on 17/9/11.
//  Copyright © 2017年 com.xmm. All rights reserved.
//

#import "RepeatYearCell.h"

@interface RepeatYearCell ()
<UIPickerViewDelegate,
UIPickerViewDataSource>
{
    UIPickerView    *_picker;
}
@end

@implementation RepeatYearCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        _picker = [[UIPickerView alloc] init];
        _picker.dataSource = self;
        _picker.delegate = self;
        [self addSubview:_picker];
        
        [_picker mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(25);
            make.right.equalTo(self).mas_offset(-25);
        }];
        
        [self.line mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(15);
            make.right.equalTo(self).mas_offset(-15);
            make.bottom.equalTo(self);
            make.height.mas_equalTo(0.5);
        }];
    }
    return self;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 2;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (0 == component) {
        return 12;
    } else {
        NSInteger selectedMonth = [pickerView selectedRowInComponent:0]+1;
        if (1 == selectedMonth || 3 == selectedMonth || 5 == selectedMonth || 7 == selectedMonth || 8 == selectedMonth || 10 == selectedMonth || 12 == selectedMonth) {
            return 31;
        } else if (2 == selectedMonth) {
            return 29;
        } else {
            return 30;
        }
    }
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if (0 == component) {
        if (row + 1 == self.selectedMonth.integerValue) {
            return [NSString stringWithFormat:@"%@月", @(row+1)];
        } else {
            return [NSString stringWithFormat:@"%@", @(row+1)];
        }
    } else {
        if (row + 1 == self.selectedMonthDay.integerValue) {
            return [NSString stringWithFormat:@"%@日", @(row+1)];
        } else {
            return [NSString stringWithFormat:@"%@", @(row+1)];
        }
    }
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if (0 == component) {
        if (self.monthBlock) {
            self.monthBlock(@(row+1));
        }
        self.selectedMonth = @(row+1);
    } else {
        if (self.monthDayBlock) {
            self.monthDayBlock(@(row+1));
        }
        self.selectedMonthDay = @(row+1);
    }
    [pickerView reloadAllComponents];
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
    return 40;
}

- (void)setSelectedMonth:(NSNumber *)selectedMonth {
    _selectedMonth = selectedMonth;
    [_picker selectRow:selectedMonth.integerValue-1 inComponent:0 animated:NO];
    if (self.selectedMonthDay) {
        NSInteger maxMonthDay = [self pickerView:_picker numberOfRowsInComponent:1];
        if (self.selectedMonthDay.integerValue > maxMonthDay) {
            self.selectedMonthDay = @(maxMonthDay);
        }
    }
}

- (void)setSelectedMonthDay:(NSNumber *)selectedMonthDay {
    _selectedMonthDay = selectedMonthDay;
    [_picker selectRow:selectedMonthDay.integerValue-1 inComponent:1 animated:NO];
}

+ (CGFloat)height {
    return 216;
}

@end
