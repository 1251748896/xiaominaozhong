//
//  TrafficRemindViewController.m
//  XMAlarm
//
//  Created by bo.chen on 17/9/20.
//  Copyright © 2017年 com.xmm. All rights reserved.
//

#import "TrafficRemindViewController.h"
#import "EditTwoTitleCell.h"
#import "BaseTitleCell.h"
#import "RemindTimeAlertView.h"

@interface TrafficRemindViewController ()
{
    NSMutableArray  *_selectedRows;
}
@property (nonatomic, strong) UIButton *editBtn;
@property (nonatomic, strong) UIView *bottomView;
@end

@implementation TrafficRemindViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _selectedRows = [NSMutableArray array];
    self.titleLabel.text = @"提醒设置";
    
    [self setupView];
    [self dataFactory];
}

- (NSArray *)cellClasses {
    return @[[EditTwoTitleCell class], [BaseTitleCell class]];
}

- (void)dataFactory {
    [self.dataSource removeAllObjects];
    
    for (NSInteger i = 0; i < self.alarm.remindSettings.count; i++) {
        RemindSetting *setting = self.alarm.remindSettings[i];
        BOOL checked = [_selectedRows indexOfObject:@(i)] != NSNotFound;
        [self.dataSource addObject:@{@"title1": [NSString stringWithFormat:@"第%@次", [@(i+1) chineseTenStr]], @"title2": [setting formatTrafficRemindStr], @"editing": @(self.editBtn.selected), @"checked": @(checked)}];
    }
    if (!self.editBtn.selected && self.alarm.remindSettings.count < 3) {
        [self.dataSource addObject:@1];
    }
    [self.contentView reloadData];
}

#pragma mark - view

- (void)setupView {
    self.editBtn = [self customRightTextBtn:@"编辑" action:@selector(editBtnPressed:)];
    [self.editBtn setTitle:@"确定" forState:UIControlStateSelected];
    
    self.bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, deviceWidth, 15+42+15)];
    self.bottomView.top = deviceHeight-self.bottomView.height-BottomGap;
    self.bottomView.backgroundColor = HexGRAY(0xFF, 255);
    [self.view addSubview:self.bottomView];
    self.bottomView.hidden = !self.editBtn.selected;
    
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
    [self.bottomView addSubview:delBtn];
    [delBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(15, 15, 15, 15));
    }];
}

#pragma mark - action

- (void)editBtnPressed:(id)sender {
    self.editBtn.selected = !self.editBtn.selected;
    if (!self.editBtn.selected) {
        [_selectedRows removeAllObjects];
    }
    self.bottomView.hidden = !self.editBtn.selected;
    [self dataFactory];
}

- (void)delBtnPressed:(id)sender {
    if (_selectedRows.count > 0) {
        NSMutableArray *array = [NSMutableArray arrayWithArray:self.alarm.remindSettings];
        NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
        for (NSNumber *row in _selectedRows) {
            [indexSet addIndex:row.integerValue];
        }
        [array removeObjectsAtIndexes:indexSet];
        
        [self updateRemindSettings:array];
    }
}

- (void)updateRemindSettings:(NSArray *)settings {
    self.alarm.remindSettings = [settings sortedArrayUsingComparator:^NSComparisonResult(RemindSetting *  _Nonnull obj1, RemindSetting *  _Nonnull obj2) {
        if (obj1.preDay.integerValue == obj2.preDay.integerValue) {
            return [obj1.time compareIgnoringDate:obj2.time];
        } else {
            //反过来比较，大的在前
            return [obj2.preDay compare:obj1.preDay];
        }
    }];
    if (self.updateBlock) {
        self.updateBlock();
    }
    //清空数据
    [_selectedRows removeAllObjects];
    [self dataFactory];
}

#pragma mark - UITableView

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [EditTwoTitleCell height];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    id data = self.dataSource[indexPath.row];
    if ([data isKindOfClass:[NSDictionary class]]) {
        EditTwoTitleCell *cell = [tableView dequeueReusableCellWithIdentifier:@"EditTwoTitleCell"];
        cell.dataDict = data;
        return cell;
    } else {
        BaseTitleCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BaseTitleCell"];
        cell.titleLbl.font = [UIFont systemFontOfSize:Expand6(14, 15)];
        cell.titleLbl.textAlignment = NSTextAlignmentCenter;
        cell.titleLbl.textColor = BTNACTIVECOLOR;
        cell.titleLbl.text = @"继续添加响铃时间";
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    id data = self.dataSource[indexPath.row];
    WeakSelf
    if ([data isKindOfClass:[NSDictionary class]]) {
        if (self.editBtn.selected) {
            if ([_selectedRows indexOfObject:@(indexPath.row)] == NSNotFound) {
                if (_selectedRows.count + 1 == self.alarm.remindSettings.count) {
                    [self.view showWarningText:@"至少保留一个响铃"];
                    return;
                } else {
                    [_selectedRows addObject:@(indexPath.row)];
                }
            } else {
                [_selectedRows removeObject:@(indexPath.row)];
            }
            [self dataFactory];
        } else {
            //弹出时间选择
            RemindTimeAlertView *alertView = [[RemindTimeAlertView alloc] initWithTitle:@"提醒时间" remindSetting:self.alarm.remindSettings[indexPath.row]];
            alertView.sureBlock = ^(RemindSetting *setting) {
                [weakSelf updateRemindSettings:self.alarm.remindSettings];
            };
            [alertView show];
        }
    } else {
        RemindSetting *remindSetting = [[RemindSetting alloc] init];
        
        RemindTimeAlertView *alertView = [[RemindTimeAlertView alloc] initWithTitle:@"提醒时间" remindSetting:remindSetting];
        alertView.sureBlock = ^(RemindSetting *setting) {
            NSArray *array = [weakSelf.alarm.remindSettings arrayByAddingObject:setting];
            [weakSelf updateRemindSettings:array];
        };
        [alertView show];
    }
}

@end
