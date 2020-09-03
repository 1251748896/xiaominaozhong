//
//  RemindDateAlertView.m
//  XMAlarm
//
//  Created by bo.chen on 17/9/10.
//  Copyright © 2017年 com.xmm. All rights reserved.
//

#import "RemindDateAlertView.h"

@interface RemindDateAlertView ()
<JTCalendarDelegate>
{
    UILabel     *_monthLbl;
    JTCalendarWeekDayView   *_weekDayView;
    JTHorizontalCalendarView  *_calendarView;
}
@property (nonatomic, strong) JTCalendarManager *calendarManager;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSDate *selectedDate;
@end

@implementation RemindDateAlertView

- (instancetype)initWithTitle:(NSString *)title date:(NSDate *)date {
    self = [super initWithFrame:CGRectMake(0, 0, deviceWidth-20, 280)];
    if (self) {
        self.title = title;
        self.selectedDate = date;
        
        _monthLbl = [[UILabel alloc] init];
        _monthLbl.textColor = HexGRAY(0x33, 255);
        _monthLbl.font = [UIFont boldSystemFontOfSize:12];
        _monthLbl.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_monthLbl];
        [_monthLbl mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.top.width.equalTo(self);
            make.height.mas_equalTo(30);
        }];
        
        UIButton *todayBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [todayBtn setBackgroundImage:[UIImage imageNamed:@"temporay_icon_today"] forState:UIControlStateNormal];
        [todayBtn setTitleColor:HexRGBA(0x007AFF, 255) forState:UIControlStateNormal];
        todayBtn.titleLabel.font = [UIFont systemFontOfSize:10];
        [todayBtn setTitle:[NSString stringWithFormat:@"%@", @([NSDate date].day)] forState:UIControlStateNormal];
        todayBtn.titleEdgeInsets = UIEdgeInsetsMake(4, 0, 0, 0);
        [todayBtn addTarget:self action:@selector(todayBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:todayBtn];
        [todayBtn setEnlargeEdgeWithTop:6 right:15 bottom:6 left:15];
        [todayBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(16, 18));
            make.centerY.equalTo(_monthLbl);
            make.right.mas_equalTo(-15);
        }];
        
        _weekDayView = [[JTCalendarWeekDayView alloc] initWithFrame:CGRectZero];
        [self addSubview:_weekDayView];
        [_weekDayView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.width.equalTo(self);
            make.top.equalTo(_monthLbl.mas_bottom);
            make.height.mas_equalTo(20);
        }];
        
        _calendarView = [[JTHorizontalCalendarView alloc] initWithFrame:CGRectZero];
        [self addSubview:_calendarView];
        [_calendarView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_weekDayView.mas_bottom);
            make.left.bottom.width.equalTo(self);
        }];
        
        self.calendarManager = [[JTCalendarManager alloc] init];
        self.calendarManager.delegate = self;
        self.calendarManager.settings.pageViewHaveWeekDaysView = NO;
        self.calendarManager.settings.pageViewNumberOfWeeks = 0; // Automatic
        
        [self.calendarManager setContentView:_calendarView];
        [self.calendarManager setDate:self.selectedDate];
        
        _weekDayView.manager = self.calendarManager;
        [_weekDayView reload];
        
        _monthLbl.text = [NSDateFormatter stringFromDate:self.calendarManager.date formatStr:@"yyyy.M"];
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
            [alertView close];
        } else if (1 == buttonIndex) {
            if (self.sureBlock) {
                self.sureBlock(self.selectedDate);
            }
            [alertView close];
        }
    }];
    [alertView show];
}

- (void)todayBtnPressed:(id)sender {
    [self.calendarManager setDate:[NSDate date]];
}

#pragma mark - Custom View

- (UIView *)calendarBuildMenuItemView:(JTCalendarManager *)calendar {
    return nil;
}

- (UIView<JTCalendarWeekDay> *)calendarBuildWeekDayView:(JTCalendarManager *)calendar {
    JTCalendarWeekDayView *view = [[JTCalendarWeekDayView alloc] initWithFrame:CGRectMake(0, 0, self.width, 20)];
    
    for(UILabel *label in view.dayViews){
        label.textColor = HexGRAY(0xFF, 255);
        label.font = [UIFont systemFontOfSize:12];
    }
    
    return view;
}

- (UIView<JTCalendarDay> *)calendarBuildDayView:(JTCalendarManager *)calendar {
    CalenderDayView *view = [[CalenderDayView alloc] init];
    return view;
}

#pragma mark - JTCalendarDelegate

- (void)calendar:(JTCalendarManager *)calendar prepareDayView:(CalenderDayView *)dayView {
    // Today
    /*if ([_calendarManager.dateHelper date:[NSDate date] isTheSameDayThan:dayView.date]) {
        dayView.circleView.hidden = NO;
        dayView.circleView.backgroundColor = HexRGBA(0x00AA45, 255);
        dayView.textLabel.textColor = [UIColor whiteColor];
        dayView.twoLbl.textColor = [UIColor whiteColor];
    }
    // Selected date
    else*/ if (self.selectedDate && [_calendarManager.dateHelper date:self.selectedDate isTheSameDayThan:dayView.date]) {
        dayView.circleView.hidden = NO;
        dayView.circleView.backgroundColor = HexRGBA(0x00AA45, 255);
        dayView.textLabel.textColor = [UIColor whiteColor];
        dayView.twoLbl.textColor = [UIColor whiteColor];
    }
    // Other month
    else if (![_calendarManager.dateHelper date:_calendarView.date isTheSameMonthThan:dayView.date]) {
        dayView.circleView.hidden = YES;
        dayView.textLabel.textColor = HexGRAY(0x66, 255);
        dayView.twoLbl.textColor = HexGRAY(0x99, 255);
    }
    // Another day of the current month
    else {
        dayView.circleView.hidden = YES;
        dayView.textLabel.textColor = HexGRAY(0x33, 255);
        dayView.twoLbl.textColor = HexGRAY(0x99, 255);
    }
    
    // Other month
    dayView.hidden = (![_calendarManager.dateHelper date:_calendarView.date isTheSameMonthThan:dayView.date]);
    dayView.twoLbl.text = [dayView.date chineseDayStr];
    if ([_calendarManager.dateHelper date:[NSDate date] isTheSameDayThan:dayView.date]) {
        dayView.twoLbl.text = @"今日";
    }
    
    //重新用属性字符串来显示好居中
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:dayView.textLabel.text attributes:@{NSForegroundColorAttributeName: dayView.textLabel.textColor, NSFontAttributeName: dayView.textLabel.font}];
    [attrStr appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n"]];
    [attrStr appendAttributedString:[[NSAttributedString alloc] initWithString:dayView.twoLbl.text attributes:@{NSForegroundColorAttributeName: dayView.twoLbl.textColor, NSFontAttributeName: dayView.twoLbl.font}]];
    dayView.textLabel.attributedText = attrStr;
}

- (void)calendar:(JTCalendarManager *)calendar didTouchDayView:(CalenderDayView *)dayView {
    if (![dayView.date isEarlierThanDate:[[NSDate date] dateAtStartOfDay]]) {
        self.selectedDate = dayView.date;
        [self.calendarManager reload];
    }
}

- (BOOL)calendar:(JTCalendarManager *)calendar canDisplayPageWithDate:(NSDate *)date {
    return YES;
}

- (void)calendarDidLoadPreviousPage:(JTCalendarManager *)calendar {
    _monthLbl.text = [NSDateFormatter stringFromDate:calendar.date formatStr:@"yyyy.M"];
}

- (void)calendarDidLoadNextPage:(JTCalendarManager *)calendar {
    _monthLbl.text = [NSDateFormatter stringFromDate:calendar.date formatStr:@"yyyy.M"];
}

@end

@implementation CalenderDayView {
    UILabel     *_twoLbl;
}

- (void)commonInit {
    [super commonInit];
    
    {
        _twoLbl = [UILabel new];
        [self addSubview:_twoLbl];
        
        _twoLbl.textColor = [UIColor blackColor];
        _twoLbl.textAlignment = NSTextAlignmentCenter;
        _twoLbl.font = [UIFont systemFontOfSize:[UIFont systemFontSize]];
        _twoLbl.hidden = YES;
    }

    self.dotView.hidden = YES;
    self.textLabel.numberOfLines = 0;
    self.textLabel.font = [UIFont systemFontOfSize:14];
    self.twoLbl.font = [UIFont systemFontOfSize:10];
}

@end
