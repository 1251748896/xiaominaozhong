//
//  TrafficHomeViewController.m
//  XMAlarm
//
//  Created by bo.chen on 17/9/4.
//  Copyright © 2017年 com.xmm. All rights reserved.
//

#import "TrafficHomeViewController.h"
#import "TrafficHomeCell.h"
#import "TrafficLimitViewController.h"
#import "SelectCityViewController.h"
#import <LGSideMenuController.h>
#import "TrafficLimitAlarm.h"
#import "AlarmManager.h"
#import "EmptyAddView.h"
#import "PopupMenuView.h"
#import "AlertMenuView.h"

@interface TrafficHomeViewController ()

@end

@implementation TrafficHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.titleLabel.text = @"限行";
    self.contentView.frame = CGRectMake(0, GAP20+topBarHeight, deviceWidth, deviceHeight-GAP20-topBarHeight-tabBarHeight);
    [self customLeftImgBtn:[UIImage imageNamed:@"nav_icon_user"] img2:nil action:@selector(userBtnPressed:)];
    [self customRightImgBtn:[UIImage imageNamed:@"nav_icon_add"] img2:nil action:@selector(addBtnPressed:)];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dataFactory) name:kRefreshAlarmList object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshView) name:kUpdateAlarmListView object:nil];
    
}

- (NSArray *)cellClasses {
    return @[[TrafficHomeCell class]];
}

- (void)dataFactory {
    [self.dataSource removeAllObjects];
    
    [self.dataSource addObjectsFromArray:[TrafficLimitAlarm allForUser]];
    [self.dataSource sortUsingComparator:^NSComparisonResult(BaseAlarm *  _Nonnull obj1, BaseAlarm *  _Nonnull obj2) {
        return [obj1 compare:obj2];
    }];
    
    [self refreshView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if ([AlarmManager sharedInstance].shouldCheckPromitAlert) {
        [[AlarmManager sharedInstance] checkDisclaimerAlert];
        [AlarmManager sharedInstance].shouldCheckPromitAlert = NO;
    }
    
    [self dataFactory];
}

#pragma mark - view

- (BOOL)needEmptyView {
    return YES;
}

- (UIView *)emptyView {
    if (!_emptyView) {
        EmptyAddView *emptyView = [[EmptyAddView alloc] initWithImage:[UIImage imageNamed:@"home_icon_limitline"] title:@"暂无限行信息，请添加..."];
        [emptyView.addBtn addTarget:self action:@selector(add2BtnPressed:) forControlEvents:UIControlEventTouchUpInside];
        _emptyView = emptyView;
    }
    return _emptyView;
}

#pragma mark - action

- (void)userBtnPressed:(id)sender {
    LGSideMenuController *controller = (LGSideMenuController *)[RootNavigationController sharedInstance].topViewController;
    [controller showLeftViewAnimated:YES completionHandler:^{
        
    }];
}

- (void)addBtnPressed:(id)sender {
    SelectCityViewController *controller = [[SelectCityViewController alloc] init];
    controller.initAdd = YES;
    controller.alarm = [[TrafficLimitAlarm alloc] init];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)add2BtnPressed:(id)sender {
    [self addBtnPressed:nil];
}

#pragma mark - UITableView

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 88;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TrafficHomeCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TrafficHomeCell"];
    cell.alarm = self.dataSource[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    TrafficLimitAlarm *alarm = self.dataSource[indexPath.row];
    alarm = [alarm copy];
    TrafficLimitViewController *controller = [[TrafficLimitViewController alloc] init];
    controller.alarm = alarm;
    [self.navigationController pushViewController:controller animated:YES];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (UITableViewCellEditingStyleDelete == editingStyle) {
        BaseAlarm *alarm = self.dataSource[indexPath.row];
        [alarm deleteNotification:YES];
        [alarm remove];
        if (self.dataSource.count == 1) {
            [self dataFactory];
        } else {
            [self.dataSource removeObjectAtIndex:indexPath.row];
            [self.contentView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
    }
}

@end
