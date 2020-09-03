//
//  SettingViewController.m
//  XMAlarm
//
//  Created by bo.chen on 17/9/30.
//  Copyright © 2017年 com.xmm. All rights reserved.
//

#import "SettingViewController.h"
#import "FeedbackViewController.h"
#import "AboutViewController.h"
#import "AlarmManager.h"

@interface SettingViewController ()

@end

@implementation SettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.titleLabel.text = @"设置";
    self.view.backgroundColor = HexRGBA(0xEEEEEE, 255);
    [self dataFactory];
    if ([[UserManager sharedInstance] isLogin]) {
        [self setupView];
    }
}

- (UITableViewStyle)tableViewStyle {
    return UITableViewStyleGrouped;
}

- (NSArray *)cellClasses {
    return @[[SettingCell class]];
}

- (void)dataFactory {
    [self.dataSource removeAllObjects];
    
    [self.dataSource addObject:@{@"title": @"法定工作日数据更新"}];
    [self.dataSource addObject:@{@"title": @"建议反馈"}];
    [self.dataSource addObject:@{@"title": @"关于"}];
}

- (void)setupView {
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, deviceWidth, 10+46+10)];
    self.contentView.tableFooterView = footerView;
    
    UIButton *sureBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    sureBtn.frame = CGRectMake(15, 10, deviceWidth-30, 46);
    sureBtn.layer.cornerRadius = 2;
    sureBtn.layer.masksToBounds = YES;
    sureBtn.backgroundColor = HexRGBA(0x248FEC, 255);
    [sureBtn setTitleColor:HexGRAY(0xFF, 255) forState:UIControlStateNormal];
    sureBtn.titleLabel.font = [UIFont systemFontOfSize:17];
    [sureBtn setTitle:@"退出" forState:UIControlStateNormal];
    [sureBtn addTarget:self action:@selector(exitBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
    [footerView addSubview:sureBtn];
}

- (void)exitBtnPressed:(id)sender {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"确定要退出登录吗？" cancelButtonTitle:@"取消" otherButtonTitle:@"确定"];
    [alertView showUsingBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
        if (1 == buttonIndex) {
            [[UserManager sharedInstance] exitLogin];
            self.contentView.tableFooterView = nil;
        }
    }];
}

#pragma mark - UITableView

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 15;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SettingCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SettingCell"];
    cell.titleLbl.text = self.dataSource[indexPath.row][@"title"];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (0 == indexPath.row) {
        [[AlarmManager sharedInstance] updateHoliday:^(NSNumber * obj) {
            if ([obj boolValue]) {
                [self.view showSuccessText:@"已更新"];
            } else {
                [self.view showErrorText:@"更新失败"];
            }
        }];
    } else if (1 == indexPath.row) {
        FeedbackViewController *controller = [[FeedbackViewController alloc] init];
        [self.navigationController pushViewController:controller animated:YES];
    } else if (2 == indexPath.row) {
        AboutViewController *controller = [[AboutViewController alloc] init];
        [self.navigationController pushViewController:controller animated:YES];
    }
}

@end

@implementation SettingCell {
    UIImageView *_arrow;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _arrow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_next_more"]];
        [self.contentView addSubview:_arrow];
        
        [self.titleLbl mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(15);
            make.top.height.equalTo(self);
            make.right.equalTo(_arrow.mas_left).mas_offset(-15);
        }];
        [_arrow mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(8, 13));
            make.centerY.equalTo(self);
            make.right.equalTo(self).mas_offset(-15);
        }];
    }
    return self;
}

@end
