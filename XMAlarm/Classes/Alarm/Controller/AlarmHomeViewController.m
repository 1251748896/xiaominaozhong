//
//  AlarmHomeViewController.m
//  XMAlarm
//
//  Created by bo.chen on 17/9/4.
//  Copyright © 2017年 com.xmm. All rights reserved.
//

#import "AlarmHomeViewController.h"
#import "RiseAlarmViewController.h"
#import "ShiftAlarmViewController.h"
#import "CustomAlarmViewController.h"
#import "AlarmHomeCell.h"
#import "LeftMenuViewController.h"
#import <LGSideMenuController.h>

#import "EmptyAddView.h"
#import "PopupMenuView.h"
#import "AlertMenuView.h"

@interface AlarmHomeViewController ()

@end

@implementation AlarmHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.titleLabel.text = @"闹钟";
    self.contentView.frame = CGRectMake(0, GAP20+topBarHeight, deviceWidth, deviceHeight-GAP20-topBarHeight-tabBarHeight);
    [self customLeftImgBtn:[UIImage imageNamed:@"nav_icon_user"] img2:nil action:@selector(userBtnPressed:)];
    [self customRightImgBtn:[UIImage imageNamed:@"nav_icon_add"] img2:nil action:@selector(addBtnPressed:)];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dataFactory) name:kRefreshAlarmList object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshView) name:kUpdateAlarmListView object:nil];
}

- (NSArray *)cellClasses {
    return @[[AlarmHomeCell class]];
}

- (void)dataFactory {
    [self.dataSource removeAllObjects];
    
    [self.dataSource addObjectsFromArray:[RiseAlarm allForUser]];
    [self.dataSource addObjectsFromArray:[ShiftAlarm allForUser]];
    [self.dataSource addObjectsFromArray:[CustomAlarm allForUser]];
    [self.dataSource sortUsingComparator:^NSComparisonResult(BaseAlarm *  _Nonnull obj1, BaseAlarm *  _Nonnull obj2) {
        return [obj1 compare:obj2];
    }];
    [self refreshView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self dataFactory];
}

#pragma mark - view

- (BOOL)needEmptyView {
    return YES;
}

- (UIView *)emptyView {
    if (!_emptyView) {
        EmptyAddView *emptyView = [[EmptyAddView alloc] initWithImage:[UIImage imageNamed:@"home_icon_clock"] title:@"暂无闹钟，请添加..."];
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
    NSArray *titleArray = @[@"起床闹钟", @"倒班闹钟", @"自定义闹钟"];
    PopupMenuView *menuView = [[PopupMenuView alloc] initWithTitleArray:titleArray];
    WeakSelf
    menuView.indexBlock = ^(NSInteger index) {
        [weakSelf addAlarmController:index];
    };
    [menuView show];
}

- (void)addAlarmController:(NSInteger)index {
    if (0 == index) {
        RiseAlarmViewController *controller = [[RiseAlarmViewController alloc] init];
        controller.alarm = [[RiseAlarm alloc] init];
        [self.navigationController pushViewController:controller animated:YES];
    } else if (1 == index) {
        ShiftAlarmViewController *controller = [[ShiftAlarmViewController alloc] init];
        controller.alarm = [[ShiftAlarm alloc] init];
        [self.navigationController pushViewController:controller animated:YES];
    } else {
        CustomAlarmViewController *controller = [[CustomAlarmViewController alloc] init];
        controller.alarm = [[CustomAlarm alloc] init];
        [self.navigationController pushViewController:controller animated:YES];
    }
}

- (void)add2BtnPressed:(id)sender {
    NSArray *titleArray = @[@"起床闹钟", @"倒班闹钟", @"自定义闹钟"];
    AlertMenuView *menuView = [[AlertMenuView alloc] initWithTitle:@"添加" dataSource:titleArray];
    WeakSelf
    menuView.indexBlock = ^(NSInteger index) {
        [weakSelf addAlarmController:index];
    };
    [menuView show];
}

#pragma mark - UITableView

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 72;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AlarmHomeCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AlarmHomeCell"];
    cell.alarm = self.dataSource[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    BaseAlarm *alarm = self.dataSource[indexPath.row];
    alarm = [alarm copy];
    if ([alarm isMemberOfClass:[RiseAlarm class]]) {
        RiseAlarmViewController *controller = [[RiseAlarmViewController alloc] init];
        controller.alarm = (RiseAlarm *)alarm;
        [self.navigationController pushViewController:controller animated:YES];
    } else if ([alarm isMemberOfClass:[ShiftAlarm class]]) {
        ShiftAlarmViewController *controller = [[ShiftAlarmViewController alloc] init];
        controller.alarm = (ShiftAlarm *)alarm;
        [self.navigationController pushViewController:controller animated:YES];
    } else if ([alarm isMemberOfClass:[CustomAlarm class]]) {
        CustomAlarmViewController *controller = [[CustomAlarmViewController alloc] init];
        controller.alarm = (CustomAlarm *)alarm;
        [self.navigationController pushViewController:controller animated:YES];
    }
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
