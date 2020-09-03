//
//  RepeatRemindViewController.m
//  XMAlarm
//
//  Created by bo.chen on 17/9/10.
//  Copyright © 2017年 com.xmm. All rights reserved.
//

#import "RepeatRemindViewController.h"
#import "TwoTitleCell.h"
#import "NameAlertView.h"
#import "DateAlertView.h"
#import "SelectRingViewController.h"
#import "AlarmManager.h"

#import "RepeatSwitchView.h"
#import "RepeatWeekdayCell.h"
#import "RepeatMonthCell.h"
#import "RepeatYearCell.h"

@interface RepeatRemindViewController ()

@end

@implementation RepeatRemindViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.titleLabel.text = @"周期性提醒";
    [self customRightTextBtn:@"确定" action:@selector(sureBtnPressed:)];
    [self setupView];
    if (self.alarm.primaryId) {
        [self addDeleteBtn];
    }
    [self dataFactory];
}

- (NSArray *)cellClasses {
    return @[[RepeatWeekdayCell class], [RepeatMonthCell class], [RepeatYearCell class], [TwoTitleCell class]];
}

- (void)dataFactory {
    [self.dataSource removeAllObjects];
    
    [self.dataSource addObjectsFromArray:[self.alarm formatDataSource]];
    [self.contentView reloadData];
}

#pragma mark - view

- (void)setupView {
    UIView *bgView = [[UIView alloc] init];
    bgView.backgroundColor = HexGRAY(0xFF, 255);
    [self.view addSubview:bgView];
    [bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.width.equalTo(self.view);
        make.top.equalTo(self.topView.mas_bottom);
        make.height.mas_equalTo(10+32+10);
    }];
    
    RepeatSwitchView *switchView = [[RepeatSwitchView alloc] initWithFrame:CGRectZero];
    NSCalendarUnit unit = self.alarm.calendarUnit.integerValue;
    if (NSCalendarUnitWeekOfYear == unit) {
        switchView.selectedIndex = 0;
    } else if (NSCalendarUnitMonth == unit) {
        switchView.selectedIndex = 1;
    } else {
        switchView.selectedIndex = 2;
    }
    WeakSelf
    switchView.indexBlock = ^(NSInteger index) {
        if (0 == index) {
            weakSelf.alarm.calendarUnit = @(NSCalendarUnitWeekOfYear);
        } else if (1 == index) {
            weakSelf.alarm.calendarUnit = @(NSCalendarUnitMonth);
        } else {
            weakSelf.alarm.calendarUnit = @(NSCalendarUnitYear);
        }
        [weakSelf dataFactory];
    };
    [self.view addSubview:switchView];
    [switchView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15);
        make.right.equalTo(self.view).mas_offset(-15);
        make.top.equalTo(self.topView.mas_bottom).mas_offset(10);
        make.height.mas_equalTo(32);
    }];
    
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.width.bottom.equalTo(self.view);
        make.top.equalTo(bgView.mas_bottom);
    }];
}

- (void)addDeleteBtn {
    //E3 F7 2390EE
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, deviceWidth, 15+42+15)];
    footerView.backgroundColor = HexGRAY(0xFF, 255);
    self.contentView.tableFooterView = footerView;
    
    UIButton *delBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    delBtn.layer.borderWidth = 1;
    delBtn.layer.borderColor = HexGRAY(0xE3, 255).CGColor;
    delBtn.layer.cornerRadius = 21;
    delBtn.layer.masksToBounds = YES;
    delBtn.backgroundColor = HexGRAY(0xE7, 255);
    [delBtn setTitleColor:HexRGBA(0xFF0000, 255) forState:UIControlStateNormal];
    delBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [delBtn setTitle:@"删除" forState:UIControlStateNormal];
    [delBtn addTarget:self action:@selector(delBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
    [footerView addSubview:delBtn];
    [delBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(15, 15, 15, 15));
    }];
}

#pragma mark - action

- (void)sureBtnPressed:(id)sender {
    NoparamBlock block = ^() {
        self.alarm.updateTime = [NSDate date];
        //编辑后自动启用
        self.alarm.enabled = @(YES);
        [self.alarm save];
        //添加通知
        [self.alarm addNotification];
        [self backBtnPressed:nil];
        [[AlarmManager sharedInstance] checkDisclaimerAlert];
    };
    
    if (self.alarm.calendarUnit.integerValue == NSCalendarUnitMonth &&
        (self.alarm.day.integerValue == 29 || self.alarm.day.integerValue == 30 || self.alarm.day.integerValue == 31)) {
        NSString *msgStr = [NSString stringWithFormat:@"如果提醒月不足%@天，响铃时间会自动跳至提醒月的最后一天", self.alarm.day];
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:msgStr cancelButtonTitle:@"确定"];
        [alertView showUsingBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
            block();
        }];
    } else {
        block();
    }
}

- (void)delBtnPressed:(id)sender {
    [self.alarm deleteNotification:YES];
    [self.alarm remove];
    [self backBtnPressed:nil];
}


#pragma mark - UITableView

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *dataDict = self.dataSource[indexPath.row];
    if ([dataDict[@"cell"] isEqualToString:@"TwoTitleCell"]) {
        return [TwoTitleCell height];
    } else if ([dataDict[@"cell"] isEqualToString:@"RepeatWeekdayCell"]) {
        return [RepeatWeekdayCell height];
    } else if ([dataDict[@"cell"] isEqualToString:@"RepeatMonthCell"]) {
        return [RepeatMonthCell height];
    } else if ([dataDict[@"cell"] isEqualToString:@"RepeatYearCell"]) {
        return [RepeatYearCell height];
    } else {
        return 230;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    WeakSelf
    NSDictionary *dataDict = self.dataSource[indexPath.row];
    if ([dataDict[@"cell"] isEqualToString:@"TwoTitleCell"]) {
        TwoTitleCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TwoTitleCell"];
        cell.dataDict = dataDict[@"data"];
        return cell;
    } else if ([dataDict[@"cell"] isEqualToString:@"RepeatWeekdayCell"]) {
        RepeatWeekdayCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RepeatWeekdayCell"];
        cell.selectedWeekday = self.alarm.weekday;
        cell.tapBlock = ^(NSNumber *weekday) {
            weakSelf.alarm.weekday = weekday;
            [weakSelf dataFactory];
        };
        return cell;
    } else if ([dataDict[@"cell"] isEqualToString:@"RepeatMonthCell"]) {
        RepeatMonthCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RepeatMonthCell"];
        cell.selectedDay = self.alarm.day;
        cell.tapBlock = ^(NSNumber *day) {
            weakSelf.alarm.day = day;
            [weakSelf dataFactory];
        };
        return cell;
    } else if ([dataDict[@"cell"] isEqualToString:@"RepeatYearCell"]) {
        RepeatYearCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RepeatYearCell"];
        cell.selectedMonth = self.alarm.month;
        cell.selectedMonthDay = self.alarm.monthDay;
        cell.monthBlock = ^(NSNumber *month) {
            weakSelf.alarm.month = month;
            [weakSelf dataFactory];
        };
        cell.monthDayBlock = ^(NSNumber *monthDay) {
            weakSelf.alarm.monthDay = monthDay;
            [weakSelf dataFactory];
        };
        return cell;
    } else {
        return nil;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    WeakSelf
    
    NSDictionary *dataDict = self.dataSource[indexPath.row];
    if ([dataDict[@"cell"] isEqualToString:@"TwoTitleCell"]) {
        TwoTitleCellTag tag = [dataDict[@"tag"] integerValue];
        if (TwoTitleCellTag_Name == tag) {
            NameAlertView *alertView = [[NameAlertView alloc] initWithTitle:@"修改提醒标题" name:self.alarm.name placeholder:@"输入提醒标题"];
            alertView.sureBlock = ^(NSString *name) {
                weakSelf.alarm.name = name;
                [weakSelf dataFactory];
            };
            [alertView show];
        } else if (TwoTitleCellTag_RepeatRemindTime == tag) {
            DateAlertView *alertView = [[DateAlertView alloc] initWithTitle:@"响铃时间" date:self.alarm.time mode:UIDatePickerModeTime];
            alertView.sureBlock = ^(NSDate *date) {
                weakSelf.alarm.time = date;
                [weakSelf dataFactory];
            };
            [alertView show];
        } else if (TwoTitleCellTag_RingName == tag) {
            SelectRingViewController *controller = [[SelectRingViewController alloc] init];
            controller.alarm = self.alarm;
            controller.sureBlock = ^(NSString *ringName) {
                weakSelf.alarm.ringName = ringName;
                [weakSelf dataFactory];
            };
            [self.navigationController pushViewController:controller animated:YES];
        }
    }
}

@end
