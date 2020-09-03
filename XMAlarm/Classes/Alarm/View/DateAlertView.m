//
//  DateAlertView.m
//  XMAlarm
//
//  Created by bo.chen on 17/9/4.
//  Copyright © 2017年 com.xmm. All rights reserved.
//

#import "DateAlertView.h"

@interface DateAlertView ()
{
    UIDatePicker    *_picker;
    UILabel         *_todayLbl;
}

@property (nonatomic, strong) NSDate *setdate;

@property (nonatomic, strong) NSString *title;
@property (nonatomic, weak) CustomIOSAlertView *alertView;
@end

@implementation DateAlertView

- (instancetype)initWithTitle:(NSString *)title date:(NSDate *)date mode:(UIDatePickerMode)mode {
    self = [super initWithFrame:CGRectMake(0, 0, deviceWidth-20, 240)];
    if (self) {
        self.title = title;
        _setdate = date;
        _picker = [[UIDatePicker alloc] init];
        _picker.datePickerMode = mode;
        _picker.date = date;
        [_picker addTarget:self action:@selector(dateDidChanged:) forControlEvents:UIControlEventValueChanged];
        [self addSubview:_picker];

            [_picker mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(self);
            }];
    }
    return self;
}

- (void)show {
    CustomIOSAlertView *alertView = [[CustomIOSAlertView alloc] initWithTitle:self.title];
    alertView.containerView = self;
    alertView.buttonTitles = @[@"取消", @"确定"];
    alertView.delegate = NULL;//为null，不会自动close
    [alertView setOnButtonTouchUpInside:^(CustomIOSAlertView *alertView, int buttonIndex) {
        if (0 == buttonIndex) {
            if (self.cancleBlock) {
                self.cancleBlock();
            }
            [alertView close];
            
        } else if (1 == buttonIndex) {
            if (self.sureBlock) {
                self.sureBlock(_picker.date);
            }
            [alertView close];
        }
    }];
    [alertView show];
    self.alertView = alertView;
    [self dateDidChanged:_picker];
}

- (void)dateDidChanged:(UIDatePicker *)picker {
    if (picker.datePickerMode == UIDatePickerModeDate) {
        
        NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
        style.lineSpacing = 4;
        style.alignment = NSTextAlignmentCenter;
        
        NSArray *days = @[@"星期日", @"星期一", @"星期二", @"星期三", @"星期四", @"星期五", @"星期六"];
        NSString *str = [NSString stringWithFormat:@"%@\n%@", self.title, days[picker.date.weekday-1]];
        NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:str attributes:@{NSParagraphStyleAttributeName: style}];
        NSRange range1 = NSMakeRange(0, self.title.length);
        NSRange range2 = NSMakeRange(self.title.length+1, str.length-self.title.length-1);
        [attrStr addAttribute:NSForegroundColorAttributeName value:HexRGBA(0x373737, 255) range:range1];
        [attrStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:16] range:range1];
        [attrStr addAttribute:NSForegroundColorAttributeName value:HexRGBA(0x666666, 255) range:range2];
        [attrStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:14] range:range2];
        self.alertView.titleLbl.attributedText = attrStr;
        
        _todayLbl.hidden = ![picker.date isToday];
        
        // 判断大小
        long long cur = [self getDateTimeTOMilliSeconds:[NSDate date]];
        long long sele = [self getDateTimeTOMilliSeconds:picker.date];
        
        if (cur < sele) {
            picker.date = _setdate;
        }
    }
}

-(long long)getDateTimeTOMilliSeconds:(NSDate *)datetime

{
    
    NSTimeInterval interval = [datetime timeIntervalSince1970];
    
    NSLog(@"转换的时间戳=%f",interval);
    
    long long totalMilliseconds = interval*1000 ;
    
    NSLog(@"totalMilliseconds=%llu",totalMilliseconds);
    
    return totalMilliseconds;
    
}

@end
