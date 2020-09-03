//
//  SelectCityViewController.m
//  XMAlarm
//
//  Created by bo.chen on 17/9/20.
//  Copyright © 2017年 com.xmm. All rights reserved.
//

#import "SelectCityViewController.h"
#import "BaseTitleCell.h"
#import "PlateNumber2ViewController.h"
#import "DriveCardDateViewController.h"
#import "CityRuleTools.h"

@interface SelectCityViewController ()
<UISearchBarDelegate>
{
    UISearchBar *_searchBar;
    NSMutableArray  *_limitBtnArray;
}
@property (nonatomic, strong) NSArray *cityList;
@property (nonatomic, strong) NSArray *limitCityList;
@end

@implementation SelectCityViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.titleLabel.text = @"请选择限行城市";
    [self requestData];
}

- (NSArray *)cellClasses {
    return @[[BaseTitleCell class]];
}

- (void)dataFactory {
    [self.dataSource removeAllObjects];
    
    if (_searchBar.text.length > 0) {
        for (NSDictionary *dict in self.cityList) {
            NSString *name = dict[@"name"];
            if ([name contains:_searchBar.text]) {
                [self.dataSource addObject:dict];
            }
        }
    } else {
        [self.dataSource addObjectsFromArray:self.cityList];
    }
    [self.contentView reloadData];
}

- (void)requestData {
    self.cityList = (NSArray *)[[EGOCache globalCache] objectForKey:@"CityList"];
    if (self.cityList.count > 0) {
        [self requestLimitData];
    } else {
        [Api cityList:^(id body) {
            self.cityList = body;
            [[EGOCache globalCache] setObject:self.cityList forKey:@"CityList"];
            [self requestLimitData];
        } failBlock:^(NSString *message, NSInteger code) {
            [self.view showErrorText:message];
        }];
    }
}

- (void)requestLimitData {
    [Api limitCityList:^(id body) {
        self.limitCityList = body;
        [self dataFactory];
        [self setupHeaderView];
    } failBlock:^(NSString *message, NSInteger code) {
        [self.view showErrorText:message];
    }];
}

- (NSDictionary *)findLimitData:(NSNumber *)mid {
    for (NSDictionary *dict in self.limitCityList) {
        if ([dict[@"mid"] isEqual:mid]) {
            return dict;
        }
    }
    return nil;
}

#pragma mark - view

- (void)setupHeaderView {
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, GAP20+topBarHeight, deviceWidth, 54)];
    bgView.backgroundColor = HexGRAY(0xFF, 255);
    [self.view addSubview:bgView];
    self.contentView.frame = CGRectMake(0, bgView.bottom, deviceWidth, deviceHeight-bgView.bottom);
    
    _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(15, 5, deviceWidth-30, 44)];
    _searchBar.placeholder = @"输入城市名查询";
    _searchBar.delegate = self;
    //修改textField的inputAccessoryView
    UITextField *textField = nil;
    for (UIView *view in [_searchBar subviews]) {
        for (id subview in [view subviews]) {
            if ([subview isKindOfClass:[UITextField class]]) {
                textField = subview;
                break;
            }
        }
    }
    textField.backgroundColor = [UIColor clearColor];
    textField.font = [UIFont systemFontOfSize:17];
    [[_searchBar.subviews[0] subviews][0] removeFromSuperview];
    [bgView addSubview:_searchBar];
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(_searchBar.left, 5+36, _searchBar.width, 2)];
    line.backgroundColor = HexRGBA(0x0081D8, 255);
    line.userInteractionEnabled = NO;
    [bgView addSubview:line];
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, deviceWidth, 1)];
    headerView.backgroundColor = HexGRAY(0xFF, 255);
    
    UIView *sectionView1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, deviceWidth, 36)];
    sectionView1.backgroundColor = HexGRAY(0xEE, 255);
    [headerView addSubview:sectionView1];
    
    UILabel *lbl1 = [[UILabel alloc] init];
    lbl1.textColor = HexGRAY(0x40, 255);
    lbl1.font = [UIFont systemFontOfSize:16];
    lbl1.text = @"主要限行城市";
    [headerView addSubview:lbl1];
    [lbl1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15);
        make.top.right.bottom.equalTo(sectionView1);
    }];
    
    CGFloat btnWidth = (deviceWidth-30-15*3)/4;
    
    _limitBtnArray = [NSMutableArray arrayWithCapacity:self.limitCityList.count];
    for (NSInteger i = 0; i < self.limitCityList.count; i++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        
        btn.layer.borderColor = HexGRAY(0x66, 255).CGColor;
        btn.layer.borderWidth = 0.5;
        btn.layer.cornerRadius = 2;
        btn.layer.masksToBounds = YES;
        [btn setTitleColor:HexGRAY(0x33, 255) forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont systemFontOfSize:15];
        
        NSDictionary *cityDict = self.limitCityList[i];
        NSString *title = [cityDict[@"name"] stringByReplacingOccurrencesOfString:@"市" withString:@""];
        [btn setTitle:title forState:UIControlStateNormal];
        btn.tagObj = cityDict;
        
        [btn addTarget:self action:@selector(btnPressed:) forControlEvents:UIControlEventTouchUpInside];
        [headerView addSubview:btn];
        [_limitBtnArray addObject:btn];
        
        [btn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(15 + (i % 4) * (btnWidth+15));
            make.top.equalTo(sectionView1.mas_bottom).mas_offset(15+(i / 4) * 45);
            make.size.mas_equalTo(CGSizeMake(btnWidth, 30));
        }];
    }
    
    CGFloat top = 36+15+ceilf(self.limitCityList.count/4.0)*45;
    
    UIView *sectionView2 = [[UIView alloc] initWithFrame:CGRectMake(0, top, deviceWidth, 36)];
    sectionView2.backgroundColor = HexGRAY(0xEE, 255);
    [headerView addSubview:sectionView2];
    
    UILabel *lbl2 = [[UILabel alloc] init];
    lbl2.textColor = HexGRAY(0x40, 255);
    lbl2.font = [UIFont systemFontOfSize:16];
    lbl2.text = @"城市列表";
    [headerView addSubview:lbl2];
    [lbl2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15);
        make.top.right.bottom.equalTo(sectionView2);
    }];
    
    headerView.height = sectionView2.bottom;
    
    self.contentView.tableHeaderView = headerView;
}

#pragma mark - action

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [self dataFactory];
}

- (void)btnPressed:(UIButton *)sender {
    [self checkCity:sender.tagObj];
}

- (void)checkCity:(NSDictionary *)cityDict {
    NSDictionary *ruleDict = cityDict[@"limitRule"];
    if (6 == [ruleDict[@"limitMode"] integerValue]) {
        NSString *limitTip = SSJKString(ruleDict[@"limitTip"]);
        if (limitTip.length <= 0) {
            limitTip = @"本地车不限行，外埠车辆部分限行";
        }
        self.alarm.showState = [NSNumber numberWithInt:12];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:limitTip cancelButtonTitle:@"确定"];
        [alert showUsingBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
            NSNumber *mid = cityDict[@"mid"];
            NSDictionary *city = [self findLimitData:mid];
            [self allCityCanSaveInfo:city];
        }];

    } else {
        self.alarm.city = [ChinaDistrict modelFromJSONDictionary:cityDict];
        self.alarm.limitRule = [TrafficLimitRule modelFromJSONDictionary:ruleDict];
        [self.alarm resetRemindSettings];
        if (self.initAdd) {
            [self gotoPlateNumber];
        } else if (self.alarm.plateNumber.length > 0) {
            [self checkPlateNumber];
        } else {
            [self doneSureBlock];
        }
    }
}

- (void)gotoPlateNumber {
    NSString *plateNumber = self.alarm.plateNumber;
    if (self.alarm.plateNumber.length <= 0) {
        plateNumber = self.alarm.limitRule.plateNumberPre;
    }
    
    PlateNumber2ViewController *controller = [[PlateNumber2ViewController alloc] initWithPlateNumber:plateNumber];
    controller.initAdd = self.initAdd;
    controller.alarm = self.alarm;
    [self.navigationController pushViewController:controller animated:YES];
}

- (NSString *)plateNumber {
    return self.alarm.plateNumber;
}

- (void)checkPlateNumber {
    // 到了这个地方，说明该城市是有限行规则的（ ruleLimit ！= nil ）
//    NSString *limitTip = SSJKString(self.alarm.limitRule.limitTip);
//    NSString *otherTip = SSJKString(self.alarm.limitRule.otherTip);
    [CityRuleTools showDetailInfo:self.alarm finish:^(int state) {
        NSLog(@"state = %d",state);
        [self doneSureBlock];
        if (state == 10) {
            // 显示
        } else if (state == 11) {
            // 显示
        } else if (state == 12) {
            // 不显示
//            [self doneSureBlock];
        } else if (state == 13) {
            // 不显示，直接输入年检日期
//            [self doneSureBlock];
        }
    }];
}

- (void)doneSureBlock {
    if (self.sureBlock) {
        self.sureBlock();
    }
    [self backBtnPressed:nil];
}

#pragma mark - UITableView

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BaseTitleCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BaseTitleCell"];
    cell.titleLbl.text = self.dataSource[indexPath.row][@"name"];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary *city = self.dataSource[indexPath.row];
    NSNumber *mid = city[@"mid"];
    NSDictionary *cityDict = [self findLimitData:mid];
    if (!cityDict) {
        self.alarm.showState = @(13);
        [self allCityCanSaveInfo:city];
//        NSString *msg = [NSString stringWithFormat:@"抱歉！暂无%@的限行规则！", self.dataSource[indexPath.row][@"name"]];
//        AlertWarning(msg);
    } else {
        [self checkCity:cityDict];
    }
}

- (void)allCityCanSaveInfo:(NSDictionary *)dict {
    
    self.alarm.city = [ChinaDistrict modelFromJSONDictionary:dict];
    NSDictionary *ruleDict = dict[@"limitRule"];
    self.alarm.limitRule = [TrafficLimitRule modelFromJSONDictionary:ruleDict];
//    [self.alarm resetRemindSettings]; // 不设置
    [self pushhhhhh];
}

- (void)pushhhhhh {
    if (self.alarm.limitRule.limitMode.intValue == 6) {
        
        DriveCardDateViewController *vc = [[DriveCardDateViewController alloc] init];
        vc.alarm = self.alarm;
        vc.initAdd = self.initAdd;
        [self.navigationController pushViewController:vc animated:YES];
        return;
    }
    if (self.initAdd) {
        [self gotoPlateNumber];
    } else {
        [self checkPlateNumber];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [_searchBar resignFirstResponder];
}

@end
