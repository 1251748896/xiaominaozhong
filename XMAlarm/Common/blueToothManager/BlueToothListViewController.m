//
//  BlueToothListViewController.m
//  kkkk
//
//  Created by Mac mini on 2018/4/20.
//  Copyright © 2018年 Mac mini. All rights reserved.
//

#import "BlueToothListViewController.h"
#import "ZZXBluetoothManager.h"
#import "BlueToothListVM.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import "BlueToothConfig.h"
#import "BlueToothCell.h"

@interface BlueToothListViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, assign) BOOL animationing;


@property (nonatomic) UITableView *tableView;
@property (nonatomic) NSMutableArray *dataArr;

@property (nonatomic) NSArray <NSData *>*sendInfo;
@property (nonatomic) UIActivityIndicatorView *activityIndicator;
@end

@implementation BlueToothListViewController

- (NSMutableArray *)dataArr {
    if (!_dataArr) {
        _dataArr= [NSMutableArray arrayWithCapacity:5];
    }
    return _dataArr;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.titleLabel.text = @"发现的设备";
//    [BlueToothConfig getYearCheckTimeAndRestrictionTimeWithModel:_alarm];
    [self initializeUserInterface];
    [BlueToothConfig getYearCheckTimeAndRestrictionTimeWithModel:_alarm];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[ZZXBluetoothManager shared] startWork];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [ZZXBluetoothManager stopWork];
}

- (void)initializeUserInterface {
    
    CGRect frame = self.view.bounds;
    frame.origin.y += 64;
    frame.size.height -= 64;
    
    _activityIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:(UIActivityIndicatorViewStyleGray)];
    
    _activityIndicator.frame = frame;
    [self.view addSubview:self.activityIndicator];
    //设置小菊花的frame
    //        self.activityIndicator.frame= CGRectMake(100, 100, 100, 100);
    //设置小菊花颜色
    _activityIndicator.color = [UIColor grayColor];
    //设置背景颜色
    _activityIndicator.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.1];
    //刚进入这个界面会显示控件，并且停止旋转也会显示，只是没有在转动而已，没有设置或者设置为YES的时候，刚进入页面不会显示
    _activityIndicator.hidesWhenStopped = NO;
    
    _tableView = [[UITableView alloc] initWithFrame:frame style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.rowHeight = 64;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    _tableView.tableFooterView = [UIView new];
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addbluetooth:) name:FINDBLUETOOTH object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sendNextData) name:FINISHSEND object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeAllData) name:REMOVEAllDATA object:nil];
}

- (void)removeAllData {
    [self.dataArr removeAllObjects];
    [_tableView reloadData];
}

- (void)addbluetooth:(NSNotification *)notification {
    if (notification.object == nil) {
        return;
    }
    BOOL contain = NO;
    CBPeripheral *dev = notification.object[@"s"];
    NSArray *tempArr = [NSArray arrayWithArray:self.dataArr];
    for (NSDictionary *d in tempArr) {
        CBPeripheral *tempDev = d[@"s"];
        if (tempDev == dev) {
            
            NSInteger indx = [tempArr indexOfObject:d];
            [self.dataArr replaceObjectAtIndex:indx withObject:notification.object];
            contain = YES;
            break;
        }
    }
    
    //把 链接中、链接成功 的设备放在第一位
    NSArray *tempArr2 = [NSArray arrayWithArray:self.dataArr];
    for (NSDictionary *d in tempArr2) {
        NSInteger zt = [d[@"zt"] integerValue];
        if (zt == 1 || zt == 2) {
            [self.dataArr removeObject:d];
            [self.dataArr insertObject:d atIndex:0];
            break;
        }
    }
    
    if (!contain) {
        [self.dataArr addObject:notification.object];
    }
    
    [self.tableView reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"cell";
    BlueToothCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[BlueToothCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
//    CBPeripheral *peripheral = self.dataArr[indexPath.row];
    
    NSDictionary *dict = self.dataArr[indexPath.row];
    CBPeripheral *peripheral = dict[@"s"];
    NSString *status = dict[@"status"];
    NSInteger zt = [dict[@"zt"] integerValue];
    status = [NSString stringWithFormat:@"%@",status];
    NSString *name = [NSString stringWithFormat:@"TM%@",peripheral.name];
    cell.nameLabel.text = name;
    cell.statusLabel.text = status;
    
    if (zt == 1) {
        [cell connecting];
        cell.promitLabel.text = nil;
    } else if (zt == 2) {
        cell.promitLabel.text = @"请检查设备上的蓝牙标志已点亮";
        [cell stopConnectSuccess:YES];
    } else {
        cell.promitLabel.text = nil;
        [cell stopConnectSuccess:NO];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary *dict = self.dataArr[indexPath.row];
    
    CBPeripheral *peripheral = dict[@"s"];
    CBPeripheral *connectDev = [ZZXBluetoothManager shared].peripheral;
    CBCentralManager *man = [ZZXBluetoothManager shared].cMgr;
    if (peripheral == connectDev) {
        
        NSData *asyncTime = [BlueToothConfig getSyncTime];
        NSData *yearCheckTimeAndRestTime = [BlueToothConfig getYearCheckTimeAndRestrictionTimeWithModel:_alarm];
//        NSData *updateYearCheckAlarmStatus = [BlueToothConfig getUpdateInfoIsAlarm:YES];
        NSData *tempratureData = [BlueToothConfig getDeviceTimeAndTemperature];
        NSData *holiday1 = [BlueToothConfig getHolidayData:1];
        NSData *holiday2 = [BlueToothConfig getHolidayData:2];
        NSData *holiday3 = [BlueToothConfig getHolidayData:3];
        NSData *holiday4 = [BlueToothConfig getHolidayData:4];
//        if (holiday1 == nil || holiday2 == nil || holiday3 == nil || holiday4 == nil) {
//            return;
//        }
        self.sendInfo = @[yearCheckTimeAndRestTime,asyncTime,tempratureData,
                          holiday1,holiday2,holiday3,holiday4];
        [ZZXBluetoothManager shared].sendOrder = 0;
        [self startAnimation];
        [self sendNextData];
    } else {
        //找到之前链接的设备，并断开链接!!!!!
        if (connectDev) {
            [man cancelPeripheralConnection:connectDev];
        }
        NSMutableDictionary *temp = dict.mutableCopy;
        [temp setObject:@"未连接" forKey:@"zt"];
        [self.dataArr replaceObjectAtIndex:indexPath.row withObject:temp.copy];
        [ZZXBluetoothManager connectToPeriphal:peripheral];
    }
}

- (void)startAnimation {
    _animationing = YES;
    [HUD showHUDWithString:@"正在上传" vc:self];
    [self performSelector:@selector(timeOutEvent) withObject:nil afterDelay:15];
}

- (void)stopAnimation {
    _animationing = NO;
    [HUD hiddenHUDWithVc:self];
}

- (void)timeOutEvent {
    if (_animationing) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self stopAnimation];
            UIAlertView *alertView = [[UIAlertView alloc] initWithMessage:@"同步超时" cancelButtonTitle:@"确定"];
            [alertView show];
        });
        _animationing = NO;
    }
}

- (void)sendNextData {
    
    if (!_animationing) {
        return;
    }
    float delayInSeconds = 0.050;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSInteger indx = [ZZXBluetoothManager shared].sendOrder;
        if (self.sendInfo.count > indx) {
            [ZZXBluetoothManager sendDataToCurrentDevice:self.sendInfo[indx]];
        } else {
            [self.activityIndicator stopAnimating];
            UIAlertView *alertView = [[UIAlertView alloc] initWithMessage:@"数据同步完成" cancelButtonTitle:@"确定"];
            [alertView show];
            [self stopAnimation];
            [ZZXBluetoothManager shared].sendOrder = 0;
        }
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
