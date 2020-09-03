//
//  RemindHomeViewController.m
//  XMAlarm
//
//  Created by bo.chen on 17/9/4.
//  Copyright © 2017年 com.xmm. All rights reserved.
//

#import "RemindHomeViewController.h"
#import "PopupMenuView.h"
#import "RepeatRemindViewController.h"
#import "TempRemindViewController.h"
#import "ScheduleViewController.h"
#import <LGSideMenuController.h>
#import "RemindHomeCell.h"
#import "ScheduleHomeCell.h"

#import "EmptyAddView.h"
#import "PopupMenuView.h"
#import "AlertMenuView.h"

@interface RemindHomeViewController ()

@end

@implementation RemindHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.titleLabel.text = @"提醒";
    self.contentView.frame = CGRectMake(0, GAP20+topBarHeight, deviceWidth, deviceHeight-GAP20-topBarHeight-tabBarHeight);
    [self customLeftImgBtn:[UIImage imageNamed:@"nav_icon_user"] img2:nil action:@selector(userBtnPressed:)];
    [self customRightImgBtn:[UIImage imageNamed:@"nav_icon_add"] img2:nil action:@selector(addBtnPressed:)];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dataFactory) name:kRefreshAlarmList object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshView) name:kUpdateAlarmListView object:nil];
}

- (UITableViewStyle)tableViewStyle {
    return UITableViewStyleGrouped;
}

- (NSArray *)cellClasses {
    return @[[RemindHomeCell class], [ScheduleHomeCell class]];
}

- (void)dataFactory {
    [self.dataSource removeAllObjects];
    
    NSArray *array = [RepeatRemind allForUser];
    if (array.count > 0) {
        array = [array sortedArrayUsingComparator:^NSComparisonResult(BaseAlarm *  _Nonnull obj1, BaseAlarm *  _Nonnull obj2) {
            return [obj1 compare:obj2];
        }];
        [self.dataSource addObject:@{@"title": @"周期提醒", @"cell": @"RemindHomeCell", @"data": array}];
    }
    array = [TempRemind allForUser];
    if (array.count > 0) {
        array = [array sortedArrayUsingComparator:^NSComparisonResult(BaseAlarm *  _Nonnull obj1, BaseAlarm *  _Nonnull obj2) {
            return [obj1 compare:obj2];
        }];
        [self.dataSource addObject:@{@"title": @"临时提醒", @"cell": @"RemindHomeCell", @"data": array}];
    }
    array = [Schedule allForUser];
    if (array.count > 0) {
        [self.dataSource addObject:@{@"title": @"待办事项", @"cell": @"ScheduleHomeCell", @"data": array}];
    }
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
        EmptyAddView *emptyView = [[EmptyAddView alloc] initWithImage:[UIImage imageNamed:@"home_icon_remind"] title:@"暂无提醒信息，请添加..."];
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
    NSArray *titleArray = @[@"周期性提醒", @"临时提醒", @"待办事项"];
    PopupMenuView *menuView = [[PopupMenuView alloc] initWithTitleArray:titleArray];
    WeakSelf
    menuView.indexBlock = ^(NSInteger index) {
        [weakSelf addRemindController:index];
    };
    [menuView show];
}

- (void)addRemindController:(NSInteger)index {
    if (0 == index) {
        RepeatRemindViewController *controller = [[RepeatRemindViewController alloc] init];
        controller.alarm = [[RepeatRemind alloc] init];
        [self.navigationController pushViewController:controller animated:YES];
    } else if (1 == index) {
        TempRemindViewController *controller = [[TempRemindViewController alloc] init];
        controller.alarm = [[TempRemind alloc] init];
        [self.navigationController pushViewController:controller animated:YES];
    } else {
        ScheduleViewController *controller = [[ScheduleViewController alloc] init];
        controller.schedule = [[Schedule alloc] init];
        [self.navigationController pushViewController:controller animated:YES];
    }
}

- (void)add2BtnPressed:(id)sender {
    NSArray *titleArray = @[@"周期性提醒", @"临时提醒", @"待办事项"];
    AlertMenuView *menuView = [[AlertMenuView alloc] initWithTitle:@"添加" dataSource:titleArray];
    WeakSelf
    menuView.indexBlock = ^(NSInteger index) {
        [weakSelf addRemindController:index];
    };
    [menuView show];
}

#pragma mark - UITableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dataSource.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSDictionary *dataDict = self.dataSource[section];
    return [dataDict[@"data"] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 30;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSDictionary *dataDict = self.dataSource[section];
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, deviceWidth, 30)];
    headerView.backgroundColor = HexRGBA(0xEEEEEE, 255);
    
    UILabel *lbl = [[UILabel alloc] init];
    lbl.textColor = HexGRAY(0x66, 255);
    lbl.font = [UIFont systemFontOfSize:14];
    lbl.text = dataDict[@"title"];
    [headerView addSubview:lbl];
    [lbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(12);
        make.right.top.height.equalTo(headerView);
    }];
    
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *dataDict = self.dataSource[indexPath.section];
    if ([dataDict[@"cell"] isEqualToString:@"RemindHomeCell"]) {
        return 72;
    } else {
        return 64;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *dataDict = self.dataSource[indexPath.section];
    if ([dataDict[@"cell"] isEqualToString:@"RemindHomeCell"]) {
        RemindHomeCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RemindHomeCell"];
        cell.alarm = dataDict[@"data"][indexPath.row];
        return cell;
    } else {
        ScheduleHomeCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ScheduleHomeCell"];
        cell.schedule = dataDict[@"data"][indexPath.row];
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary *dataDict = self.dataSource[indexPath.section];
    BaseAlarm *alarm = dataDict[@"data"][indexPath.row];
    alarm = [alarm copy];
    if ([alarm isMemberOfClass:[RepeatRemind class]]) {
        RepeatRemindViewController *controller = [[RepeatRemindViewController alloc] init];
        controller.alarm = (RepeatRemind *)alarm;
        [self.navigationController pushViewController:controller animated:YES];
    } else if ([alarm isMemberOfClass:[TempRemind class]]) {
        TempRemindViewController *controller = [[TempRemindViewController alloc] init];
        controller.alarm = (TempRemind *)alarm;
        [self.navigationController pushViewController:controller animated:YES];
    } else if ([alarm isMemberOfClass:[Schedule class]]) {
        ScheduleViewController *controller = [[ScheduleViewController alloc] init];
        controller.schedule = (Schedule *)alarm;
        [self.navigationController pushViewController:controller animated:YES];
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (UITableViewCellEditingStyleDelete == editingStyle) {
        NSDictionary *dataDict = self.dataSource[indexPath.section];
        BaseAlarm *alarm = dataDict[@"data"][indexPath.row];
        [alarm deleteNotification:YES];
        [alarm remove];
        [self dataFactory];
    }
}

@end
