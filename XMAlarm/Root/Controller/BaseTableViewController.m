//
//  BaseTableViewController.m
//  shareKouXiaoHai
//
//  Created by bo.chen on 16/2/22.
//  Copyright © 2016年 Kouxiaoer. All rights reserved.
//

#import "BaseTableViewController.h"

@implementation BaseTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (UITableViewStyle)tableViewStyle {
    return UITableViewStylePlain;
}

- (TPKeyboardAvoidingTableView *)contentView {
    if (!_contentView) {
        _contentView = [[TPKeyboardAvoidingTableView alloc] initWithFrame:CGRectMake(0, GAP20+topBarHeight, deviceWidth, deviceHeight-GAP20-topBarHeight) style:[self tableViewStyle]];
        _contentView.backgroundColor = [UIColor clearColor];
        _contentView.dataSource = self;
        _contentView.delegate = self;
        _contentView.separatorStyle = UITableViewCellSeparatorStyleNone;
        for (Class cls in [self cellClasses]) {
            [_contentView registerClass:cls forCellReuseIdentifier:NSStringFromClass(cls)];
        }
    }
    return _contentView;
}

#pragma mark - UITableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

//IOS11以后，当我们的UITableView的风格设置为UITableViewStyleGrouped，如果我们要想调整高度，令其返回2个view来进行填充
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return [[UIView alloc] init];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [[UIView alloc] init];
}

@end
