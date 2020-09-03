//
//  AboutViewController.m
//  XMAlarm
//
//  Created by bo.chen on 17/9/30.
//  Copyright © 2017年 com.xmm. All rights reserved.
//

#import "AboutViewController.h"
#import "SettingViewController.h"
#import "BaseWebViewController.h"

@interface AboutViewController ()

@end

@implementation AboutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.titleLabel.text = @"关于我们";
    [self setupView];
    [self dataFactory];
}

- (NSArray *)cellClasses {
    return @[[SettingCell class]];
}

- (void)dataFactory {
    [self.dataSource removeAllObjects];
    
    [self.dataSource addObject:@{@"title": @"用户协议"}];
    [self.dataSource addObject:@{@"title": @"隐私政策"}];
    [self.dataSource addObject:@{@"title": @"联系我们"}];
}

#pragma mark - view

- (void)setupView {
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, deviceWidth, 200)];
    self.contentView.tableHeaderView = headerView;
    
    UIImageView *logoIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"img_logo"]];
    [headerView addSubview:logoIcon];
    
    UILabel *versionLbl = [[UILabel alloc] init];
    versionLbl.textColor = HexRGBA(0x333333, 255);
    versionLbl.font = [UIFont systemFontOfSize:Expand6(14, 15)];
    versionLbl.textAlignment = NSTextAlignmentCenter;
    versionLbl.text = [NSString stringWithFormat:@"当前版本：%@", APPVersionCode];
    [headerView addSubview:versionLbl];
    
    UIView *line = [[UIView alloc] init];
    line.backgroundColor = HexRGBA(0xE3E3E3, 255);
    [headerView addSubview:line];
    
    [logoIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(70, 70));
        make.top.equalTo(headerView).mas_offset(50);
        make.centerX.equalTo(headerView);
    }];
    [versionLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(headerView);
        make.top.equalTo(logoIcon.mas_bottom).mas_offset(10);
        make.height.mas_equalTo(Expand6(24, 26));
    }];
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(headerView);
        make.top.equalTo(versionLbl.mas_bottom).mas_offset(45);
        make.height.mas_equalTo(1);
    }];
}

#pragma mark - UITableView

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SettingCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SettingCell"];
    cell.titleLbl.text = self.dataSource[indexPath.row][@"title"];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (0 == indexPath.row) {
        BaseWebViewController *controller = [[BaseWebViewController alloc] init];
        controller.titleStr = @"用户协议";
        controller.urlStr = [NSString stringWithFormat:@"http://www.yupukeji.com/agreement.html"];
        [self.navigationController pushViewController:controller animated:YES];
    } else if (1 == indexPath.row) {
        BaseWebViewController *controller = [[BaseWebViewController alloc] init];
        controller.titleStr = @"隐私政策";
        controller.urlStr = [NSString stringWithFormat:@"http://www.yupukeji.com/privacy.html"];
        [self.navigationController pushViewController:controller animated:YES];
    } else if (2 == indexPath.row) {
        [[UIApplication sharedApplication]openURL:[NSURL URLWithString:@"mailto://3413378219@qq.com"]];
    }
}

@end
