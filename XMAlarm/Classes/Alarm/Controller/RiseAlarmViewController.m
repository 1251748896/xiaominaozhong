//
//  RiseAlarmViewController.m
//  XMAlarm
//
//  Created by bo.chen on 17/9/4.
//  Copyright © 2017年 com.xmm. All rights reserved.
//

#import "RiseAlarmViewController.h"
#import "AlarmTimeCell.h"
#import "TwoTitleCell.h"
#import "NameAlertView.h"
#import "CheckAlertView.h"
#import "SelectRingViewController.h"
#import "AlarmManager.h"

@interface RiseAlarmViewController ()

@end

@implementation RiseAlarmViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.titleLabel.text = @"起床闹钟";
    [self customRightTextBtn:@"确定" action:@selector(sureBtnPressed:)];
    if (self.alarm.primaryId) {
        [self addDeleteBtn];
    }
    [self dataFactory];
}

- (NSArray *)cellClasses {
    return @[[AlarmTimeCell class], [TwoTitleCell class]];
}

- (void)dataFactory {
    [self.dataSource removeAllObjects];
    
    [self.dataSource addObjectsFromArray:[self.alarm formatDataSource]];
    [self.contentView reloadData];
}

#pragma mark - view

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
    [delBtn setTitle:@"删除闹钟" forState:UIControlStateNormal];
    [delBtn addTarget:self action:@selector(delBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
    [footerView addSubview:delBtn];
    [delBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(15, 15, 15, 15));
    }];
}

#pragma mark - action

- (void)sureBtnPressed:(id)sender {
    self.alarm.updateTime = [NSDate date];
    //编辑后自动启用
    self.alarm.enabled = @(YES);
    [self.alarm save];
    //添加通知
    [self.alarm addNotification];
    [self backBtnPressed:nil];
    [[AlarmManager sharedInstance] checkDisclaimerAlert];
}

- (void)delBtnPressed:(id)sender {
    [self.alarm deleteNotification:YES];
    [self.alarm remove];
    [self backBtnPressed:nil];
}

- (void)timePickerDidChanged:(UIDatePicker *)sender {
    self.alarm.time = sender.date;
}

#pragma mark - UITableView

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *dataDict = self.dataSource[indexPath.row];
    if ([dataDict[@"cell"] isEqualToString:@"TwoTitleCell"]) {
        return [TwoTitleCell height];
    } else {
        return 230;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *dataDict = self.dataSource[indexPath.row];
    if ([dataDict[@"cell"] isEqualToString:@"TwoTitleCell"]) {
        TwoTitleCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TwoTitleCell"];
        cell.dataDict = dataDict[@"data"];
        return cell;
    } else {
        AlarmTimeCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AlarmTimeCell"];
        cell.picker.date = self.alarm.time;
        [cell.picker addTarget:self action:@selector(timePickerDidChanged:) forControlEvents:UIControlEventValueChanged];
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    WeakSelf
    
    NSDictionary *dataDict = self.dataSource[indexPath.row];
    if ([dataDict[@"cell"] isEqualToString:@"TwoTitleCell"]) {
        TwoTitleCellTag tag = [dataDict[@"tag"] integerValue];
        if (TwoTitleCellTag_Name == tag) {
            NameAlertView *alertView = [[NameAlertView alloc] initWithTitle:@"修改闹钟名称" name:self.alarm.name placeholder:@"输入闹钟名称"];
            alertView.sureBlock = ^(NSString *name) {
                weakSelf.alarm.name = name;
                [weakSelf dataFactory];
            };
            [alertView show];
        } else if (TwoTitleCellTag_RiseAlarmPeriod == tag) {
            NSArray *dataSource = @[@"响铃一次", @"星期一", @"星期二", @"星期三", @"星期四", @"星期五", @"星期六", @"星期日"];
            CheckAlertView *alertView = [[CheckAlertView alloc] initWithTitle:@"闹铃周期" dataSource:dataSource checkedIndexes:self.alarm.repeatArray cellTag:tag];
            alertView.sureBlock = ^(NSArray *checkedIndexes) {
                weakSelf.alarm.repeatArray = checkedIndexes;
                [weakSelf dataFactory];
            };
            [alertView show];
        } else if (TwoTitleCellTag_RiseAlarmSleep == tag) {
            NSMutableArray *dataSource = [NSMutableArray arrayWithObject:@1];
            for (NSInteger i = 1; i <= 6; i++) {
                [dataSource addObject:@(i*5)];
            }
            NSInteger index = [dataSource indexOfObject:self.alarm.sleepTime];
            CheckAlertView *alertView = [[CheckAlertView alloc] initWithTitle:@"贪睡设置" dataSource:dataSource checkedIndexes:@[@(index)] cellTag:tag];
            alertView.sureBlock = ^(NSArray *checkedIndexes) {
                weakSelf.alarm.sleepTime = [dataSource objectAtIndex:[[checkedIndexes firstObject] integerValue]];
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
