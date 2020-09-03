//
//  TrafficLimitViewController.m
//  XMAlarm
//
//  Created by bo.chen on 17/9/20.
//  Copyright © 2017年 com.xmm. All rights reserved.
//

#import "TrafficLimitViewController.h"
#import "TrafficLimitAlarm.h"
#import "PlateNumberView.h"
#import "ProvinceKeyboardView.h"
#import "AsyncDataCell.h"
#import "TwoTitleCell.h"
#import "TrafficRemindAllCell.h"
#import "TrafficLimitDayCell.h"
#import "TrafficSwitchCell.h"
#import "CheckAlertView.h"
#import "SelectCityViewController.h"
#import "TrafficRemindViewController.h"
#import "SelectRingViewController.h"
#import "PlateNumber2ViewController.h"
#import "AlarmManager.h"

#import "DriveCardDateViewController.h"
#import "BlueToothListViewController.h"
#import "ZZXBluetoothManager.h"
#import "BlueToothConfig.h"
#import "CityRuleTools.h"
@interface TrafficLimitViewController ()
@property (nonatomic, assign) BOOL saved;
@property (nonatomic, assign) BOOL notLimit;
@property (nonatomic) UIButton *midDeleBtn;

@end

@implementation TrafficLimitViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // [self makeSureShowState];
    self.titleLabel.text = @"限行";
//    [self customRightTextBtn:@"确定" action:@selector(sureBtnPressed:)];
    if (self.alarm.primaryId) {
        [self addDeleteBtn];
    }
    [self dataFactory];
}

- (void)makeSureShowState {
    _showState = self.alarm.showState.intValue ;
    _notLimit = _showState >= 12;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self sureBtnPressed:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self sureBtnPressed:nil];
}

- (void)asyncDataByBluetooth {
    
    BOOL success = NO;
    if (success) {
        NSData *data2 = [BlueToothConfig getYearCheckTimeAndRestrictionTimeWithModel:_alarm];
        [ZZXBluetoothManager sendDataToCurrentDevice:data2];
        return;
    }
    BlueToothListViewController *vc = [[BlueToothListViewController alloc] init];
    vc.alarm = _alarm;
    [self.navigationController pushViewController:vc animated:YES];
}

- (NSArray *)cellClasses {
    return @[[TwoTitleCell class], [TrafficRemindAllCell class], [TrafficSwitchCell class], [TrafficLimitDayCell class], [AsyncDataCell class]];
}

- (void)dataFactory {
    [self.dataSource removeAllObjects];
    [self.dataSource addObjectsFromArray:[self.alarm formatDataSource]];
    [self makeSureShowState];
    if (_notLimit) {
        id temp1 = [self.dataSource firstObject];
        id temp2 = self.dataSource[1];
        [self.dataSource removeAllObjects];
        [self.dataSource addObject:temp1];
        [self.dataSource addObject:temp2];
        [self deleteButtonShow:YES];
        self.contentView.tableFooterView.hidden = YES;
    } else {
        self.contentView.tableFooterView.hidden = NO;
        [self deleteButtonShow:NO];
    }
//    NSDateFormatter *m = [[NSDateFormatter alloc] init];
//    m.dateFormat = @"yyyy-MM-dd";
//    m.dateStyle = NSDateFormatterMediumStyle;
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
    [delBtn setTitle:@"删除" forState:UIControlStateNormal];
    [delBtn addTarget:self action:@selector(delBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
    [footerView addSubview:delBtn];
    [delBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(15, 15, 15, 15));
    }];
}

#pragma mark - action

- (void)sureBtnPressed:(id)sender {
    
    if (!_notLimit) {
        
        if (!self.alarm.limitRule) {
            [self.view showErrorText:@"请选择限行城市"];
            return;
        }
        if (self.alarm.plateNumber.length <= 0) {
            [self.view showErrorText:@"请设置车牌号"];
            return;
        }
    }
    
    self.alarm.updateTime = [NSDate date];
    //编辑后自动启用
    self.alarm.enabled = @(YES);
    [self.alarm save];
    //添加通知
    [self.alarm addNotification];
    [AlarmManager sharedInstance].shouldCheckPromitAlert = YES;
}

- (void)delBtnPressed:(id)sender {
    [self.alarm deleteNotification:YES];
    [self.alarm remove];
    [self backBtnPressed:nil];
}

- (void)modifySyncAlarm:(NSNumber *)syncAlarm {
    self.alarm.syncAlarm = syncAlarm;
    [self dataFactory];
}

- (void)deleteButtonShow:(BOOL)show {
    if (!show) {
        self.midDeleBtn.hidden = YES;
        return;
    }
    self.midDeleBtn.hidden = NO;
    [self.view bringSubviewToFront:self.midDeleBtn];
}

- (UIButton *)midDeleBtn {
    if (_midDeleBtn == nil) {
        CGFloat btnX = 20.0;
        CGFloat btnH = 44.0;
        CGFloat btnW = [UIScreen mainScreen].bounds.size.width - btnX*2;
        CGFloat btnY = [UIScreen mainScreen].bounds.size.height * 0.7;
        
        _midDeleBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _midDeleBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        _midDeleBtn.layer.cornerRadius = 20;
        _midDeleBtn.layer.masksToBounds = YES;
        _midDeleBtn.layer.borderWidth = 1;
        _midDeleBtn.layer.borderColor = HexGRAY(0xE3, 255).CGColor;
        [_midDeleBtn setBackgroundColor:HexGRAY(0xE7, 255)];
        [_midDeleBtn setTitle:@"删除" forState:UIControlStateNormal];
        _midDeleBtn.frame = CGRectMake(btnX, btnY, btnW, btnH);
        [_midDeleBtn setTitleColor:HexRGBA(0xFF0000, 255) forState:UIControlStateNormal];
        [_midDeleBtn addTarget:self action:@selector(delBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_midDeleBtn];
    }
    return _midDeleBtn;
}

#pragma mark - UITableView

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *dataDict = self.dataSource[indexPath.row];
    
    if ([dataDict[@"cell"] isEqualToString:@"AsyncDataCell"]) {
        return [AsyncDataCell height];
    } else if ([dataDict[@"cell"] isEqualToString:@"TwoTitleCell"]) {
        return [TwoTitleCell height];
    } else if ([dataDict[@"cell"] isEqualToString:@"TrafficLimitDayCell"]) {
        return [TwoTitleCell height];
    } else if ([dataDict[@"cell"] isEqualToString:@"TrafficRemindAllCell"]) {
        return [TrafficRemindAllCell heightWithRemindArray:self.alarm.remindSettings];
    } else if ([dataDict[@"cell"] isEqualToString:@"TrafficSwitchCell"]) {
        return [TrafficSwitchCell heightWithDataDict:dataDict[@"data"]];
    } else {
        return 230;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *dataDict = self.dataSource[indexPath.row];
    
    if ([dataDict[@"cell"] isEqualToString:@"AsyncDataCell"]) {
        AsyncDataCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AsyncDataCell"];
        cell.dataDict = dataDict;
        return cell;
    } else if ([dataDict[@"cell"] isEqualToString:@"TwoTitleCell"]) {
        TwoTitleCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TwoTitleCell"];
        cell.dataDict = dataDict[@"data"];
        return cell;
    } else if ([dataDict[@"cell"] isEqualToString:@"TrafficLimitDayCell"]) {
        TrafficLimitDayCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TrafficLimitDayCell"];
        cell.dataDict = dataDict[@"data"];
        return cell;
    } else if ([dataDict[@"cell"] isEqualToString:@"TrafficRemindAllCell"]) {
        TrafficRemindAllCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TrafficRemindAllCell"];
        cell.remindArray = self.alarm.remindSettings;
        return cell;
    } else if ([dataDict[@"cell"] isEqualToString:@"TrafficSwitchCell"]) {
        TrafficSwitchCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TrafficSwitchCell"];
        cell.dataDict = dataDict[@"data"];
        WeakSelf
        cell.tapSwitchBlock = ^(NSNumber *syncAlarm) {
            [weakSelf modifySyncAlarm:syncAlarm];
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
    
    if ([dataDict[@"cell"] isEqualToString:@"AsyncDataCell"]) {
        [self asyncDataByBluetooth];
    } else if ([dataDict[@"cell"] isEqualToString:@"TwoTitleCell"] || [dataDict[@"cell"] isEqualToString:@"TrafficLimitDayCell"]) {
        TwoTitleCellTag tag = [dataDict[@"tag"] integerValue];
        
        if (TwoTitleCellTag_yearCheckDate == tag) {
            // 修改年检日期
            DriveCardDateViewController *vc = [[DriveCardDateViewController alloc] init];
            vc.alarm = self.alarm;
            vc.fixDateBlock = ^{
                [weakSelf dataFactory];
            };
            [self.navigationController pushViewController:vc animated:YES];
            
        } else if (TwoTitleCellTag_City == tag) {
            // 修改城市
            SelectCityViewController *controller = [[SelectCityViewController alloc] init];
            controller.alarm = self.alarm;
            controller.sureBlock = ^() {
                [weakSelf dataFactory];
            };
            [self.navigationController pushViewController:controller animated:YES];
        } else if (TwoTitleCellTag_PlateNumber == tag) {
            [self editPlateNumber];
        } else if (TwoTitleCellTag_RemindSetting == tag) {
            TrafficRemindViewController *controller = [[TrafficRemindViewController alloc] init];
            controller.alarm = self.alarm;
            controller.updateBlock = ^() {
                [weakSelf dataFactory];
            };
            [self.navigationController pushViewController:controller animated:YES];
        } else if (TwoTitleCellTag_TimeAfterAlarm == tag) {
            NSMutableArray *dataSource = [NSMutableArray array];
            for (NSInteger i = 1; i <= 4; i++) {
                [dataSource addObject:@(i*5)];
            }
            [dataSource addObject:@60];
            NSInteger index = [dataSource indexOfObject:self.alarm.timeAfterAlarm];
            CheckAlertView *alertView = [[CheckAlertView alloc] initWithTitle:@"提醒时间" dataSource:dataSource checkedIndexes:@[@(index)] cellTag:TwoTitleCellTag_RiseAlarmSleep];
            alertView.sureBlock = ^(NSArray *checkedIndexes) {
                weakSelf.alarm.timeAfterAlarm = [dataSource objectAtIndex:[[checkedIndexes firstObject] integerValue]];
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

#pragma mark - platenumber

- (void)editPlateNumber {
    if (!self.alarm.limitRule) {
        [self.view showErrorText:@"请先选择限行城市"];
        return;
    }
    
    NSString *plateNumber = self.alarm.plateNumber;
    if (self.alarm.plateNumber.length <= 0) {
        plateNumber = self.alarm.limitRule.plateNumberPre;
    }
    
    WeakSelf
#if 0
    //弹出编辑车牌号界面
    PlateNumberView *plateNumberView = [[PlateNumberView alloc] initWithModel:plateNumber];
    plateNumberView.didCancelBlock = ^() {
    };
    plateNumberView.didSaveBlock = ^(NSString *str) {
        weakSelf.alarm.plateNumber = str;
        [weakSelf dataFactory];
    };
    [plateNumberView show];
#else
    PlateNumber2ViewController *controller = [[PlateNumber2ViewController alloc] initWithPlateNumber:plateNumber];
    controller.alarm = self.alarm;
//    controller.sureBlock = ^(NSString *str) {
//        weakSelf.alarm.plateNumber = str;
//        [weakSelf dataFactory];
//    };
    
    controller.fixCity = ^(NSString *plateNumber, int state) {
        weakSelf.alarm.plateNumber = plateNumber;
        weakSelf.showState = state;
        [weakSelf dataFactory];
    };
    
    [self.navigationController pushViewController:controller animated:YES];
#endif
}

- (void)reloadView {
    //检查城市和车牌
    WeakSelf
    [CityRuleTools showDetailInfo:self.alarm finish:^(int state) {
        weakSelf.showState = state;
    }];
}

@end
