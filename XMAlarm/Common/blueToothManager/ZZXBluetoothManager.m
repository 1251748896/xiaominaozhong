//
//  ZZXBluetoothManager.m
//  kkkk
//
//  Created by Mac mini on 2018/4/20.
//  Copyright © 2018年 Mac mini. All rights reserved.
//

#import "ZZXBluetoothManager.h"

#import "LYFHudView.h"

@interface ZZXBluetoothManager()<CBCentralManagerDelegate,CBPeripheralDelegate>

//
@property (nonatomic, strong) CBCharacteristic *writecharacteristic;

@end

@implementation ZZXBluetoothManager
+ (instancetype)shared {
    static ZZXBluetoothManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[ZZXBluetoothManager alloc] init];
    });
    return manager;
}


- (CBCentralManager *)cMgr
{
    if (!_cMgr) {
        _cMgr = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
        NSLog(@"重新初始化");
    } else {
        NSLog(@"不需要初始化");
    }
    return _cMgr;
}

- (void)startWork {
    // 搜索外设
    NSLog(@"搜索");
//    _cMgr = nil;
//    _peripheral = nil;
//    _writecharacteristic = nil;
    NSLog(@"startWork-----------------------------");
    CBCentralManager *mar = [ZZXBluetoothManager shared].cMgr;
    [mar scanForPeripheralsWithServices:nil options:nil];
}

+ (void)connectToPeriphal:(CBPeripheral *)periphal {
    
    if ([periphal.name hasPrefix:@"XXQ_"]) {
        NSLog(@"开始连接");
        [ZZXBluetoothManager shared].peripheral = periphal;
        [[ZZXBluetoothManager shared].cMgr connectPeripheral:periphal options:nil];
    } else {
        [LYFHudView showText:@"请选择TM开始的设备"];
    }
}

//7.给外围设备发送数据（也就是写入数据到蓝牙）
+ (void)sendDataToCurrentDevice:(NSData *)data {
    ZZXBluetoothManager *man = [ZZXBluetoothManager shared];
    CBCharacteristic *cha = man.writecharacteristic;
    if (cha != nil) {
        [man.peripheral writeValue:data forCharacteristic:cha type:CBCharacteristicWriteWithoutResponse];
    } else {
        [LYFHudView showText:@"没有找到蓝牙特征"];
    }
}

- (void)sendOverTime:(NSNumber *)num {
    
}

+ (void)stopWork {
    [[ZZXBluetoothManager shared].cMgr stopScan];
    CBPeripheral *per = [ZZXBluetoothManager shared].peripheral;
    if (per) {
        [[ZZXBluetoothManager shared].cMgr cancelPeripheralConnection:per];
        NSLog(@"有设备的ppp");
    } else {
        NSLog(@"mei有设备的ppp");
    }
}

#pragma mark -- 只要中心管理者初始化 就会触发此代理方法 判断手机蓝牙状态
- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    NSString *message = @"";
    NSLog(@"central.state = %ld",central.state);
    switch (central.state) {
        case 0:
            NSLog(@"CBCentralManagerStateUnknown");
            break;
        case 1:
            NSLog(@"CBCentralManagerStateResetting");
            break;
        case 2:
            NSLog(@"CBCentralManagerStateUnsupported");//不支持蓝牙
            message = @"您的设备不支持蓝牙";
            break;
        case 3:
            NSLog(@"CBCentralManagerStateUnauthorized");
            break;
        case 4:
        {
            NSLog(@"CBCentralManagerStatePoweredOff");//蓝牙未开启
            [[NSNotificationCenter defaultCenter] postNotificationName:REMOVEAllDATA object:nil];
            message = @"请先开启手机蓝牙";
            // [CoreBluetooth] API MISUSE: <CBCentralManager: 0x1574b8a60> can only accept this command while in the powered on state
        }
            break;
        case 5:
        {
            
            NSLog(@"CBCentralManagerStatePoweredOn");//蓝牙已开启
            [[ZZXBluetoothManager shared].cMgr scanForPeripheralsWithServices:nil   // 通过某些服务筛选外设
                                                                      options:nil]; // dict,条件
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(20 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [ZZXBluetoothManager stopWork];
            });
        }
            break;
        default:
            break;
    }
    
    
    if (message.length) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请先开启手机蓝牙" cancelButtonTitle:@"确定"];
        [alertView show];
    }
}

#pragma mark -- 发现外设后调用的方法
- (void)centralManager:(CBCentralManager *)central // 中心管理者
 didDiscoverPeripheral:(CBPeripheral *)peripheral // 外设
     advertisementData:(NSDictionary *)advertisementData // 外设携带的数据
                  RSSI:(NSNumber *)RSSI // 外设发出的蓝牙信号强度
{
    
    NSLog(@"peripheral = %@",peripheral);
    
    if ([peripheral.name containsString:@"XXQ"]) {
        NSDictionary
        *dict = @{@"s":peripheral,@"status":@"未连接", @"zt":@(0)};
        if (self.peripheral == nil) {
            dict = @{@"s":peripheral,@"status":@"未连接", @"zt":@(1)};
            
            
            NSLog(@"这咯在字段调用0000000000000000000");
            
            [ZZXBluetoothManager connectToPeriphal:peripheral];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:FINDBLUETOOTH object:dict];
        NSLog(@"发起通知 dict= %@" ,dict);
    } else {
        
        NSLog(@"不发通知");// E5AF2796-A815-4E6C-892F-08C080979A72 ---> XXQ_1808D5EBDAF2
                         // 959F6A64-C92C-4FE9-AE53-A2F73229F4DF ---> XXQ_63613FF0DBE0
        NSLog(@"name = %@",peripheral);
    }
}

#pragma mark --  中心管理者连接外设成功
- (void)centralManager:(CBCentralManager *)central // 中心管理者
  didConnectPeripheral:(CBPeripheral *)peripheral // 外设
{
    //链接成功
    NSDictionary
    *dict = @{@"s":peripheral,@"status":@"同步", @"zt":@(2)};
    [[NSNotificationCenter defaultCenter] postNotificationName:FINDBLUETOOTH object:dict];
    [LYFHudView showText:@"连接成功"];
    
    self.peripheral = peripheral;
    self.peripheral.delegate = self;
    // 外设发现服务,传nil代表不过滤
    [self.peripheral discoverServices:nil];
    // [self.cMgr stopScan];
}

#pragma mark -- 外设连接失败
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    self.peripheral = nil;
    NSDictionary
    *dict = @{@"s":peripheral,@"status":@"未连接", @"zt":@(3)};
    [[NSNotificationCenter defaultCenter] postNotificationName:FINDBLUETOOTH object:dict];
    [LYFHudView showText:@"连接失败"];
}
#pragma mark -- 丢失连接
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    self.peripheral = nil;
    NSDictionary
    *dict = @{@"s":peripheral,@"status":@"未连接", @"zt":@(4)};
    [[NSNotificationCenter defaultCenter] postNotificationName:FINDBLUETOOTH object:dict];
    [LYFHudView showText:@"断开连接"];
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    
    for (CBService *server in peripheral.services) {
        //返回特定的服务，订阅的特征即可
        [peripheral discoverCharacteristics:@[[CBUUID UUIDWithString:@"6e400002-b5a3-f393-e0a9-e50e24dcca9e"],[CBUUID UUIDWithString:@"6e400003-b5a3-f393-e0a9-e50e24dcca9e"]] forService:server];
    }
}

#pragma mark -- 4.获得外围设备的服务 & 5.获得服务的特征
// 发现外设服务里的特征的时候调用的代理方法(这个是比较重要的方法，你在这里可以通过事先知道UUID找到你需要的特征，订阅特征，或者这里写入数据给特征也可以)
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    // 在此处可以获取服务中的特征了，与硬件工程师沟通后得知，uuid为ffe2的特征是用于向外部蓝牙设备写数据的，uuid为ffe1的特征是用于从外部蓝牙设备读取数据的，那读信息，因为我在下面向蓝牙外部设备写数据的时候，我使用了一个参数：CBCharacteristicWriteWithoutResponse（也就是说，没有回调，因那没有回调就取不到数据咯？但是我们可以给读取数据的服务设置一个通知，也就是下面的setNotifyValue:方法了，一旦设置，如果外部蓝牙设备给中心设备发送信息，我们就能在didUpdateValueForCharacteristic代理方法中进行获取了）
    
    // 只需要调用以下方法就可以实现数据写入了,【subData就是我们的需要写入外部蓝牙设备的数据了；self.characteristic是我们写的服务；CBCharacteristicWriteWithoutResponse 不需要回调函数（一开始踩了个坑设置的CBCharacteristicWriteWithResponse，报错"writing is not permitted"）
    for (CBCharacteristic *cha in service.characteristics) {
        NSString *devuuidString = [cha.UUID.UUIDString lowercaseString];
        if([devuuidString isEqualToString:@"6e400003-b5a3-f393-e0a9-e50e24dcca9e"]) {
            [self.peripheral setNotifyValue:YES forCharacteristic:cha];
        } else if([devuuidString isEqualToString:@"6e400002-b5a3-f393-e0a9-e50e24dcca9e"]) {
            self.writecharacteristic = cha;   //self.readcharacteristic
            [self.peripheral setNotifyValue:YES forCharacteristic:cha];
        }
    }
}

// 6.从外围设备读数据
// 更新特征的value的时候会调用 （凡是从蓝牙传过来的数据都要经过这个回调，简单的说这个方法就是你拿数据的唯一方法） 你可以判断是否
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    
    NSData *data = characteristic.value;
    const uint8_t *bytes = [data bytes];
    NSString *dataStr = @"";
    for (int i=0; i<20; i++) {
        int value = bytes[i];
        if (dataStr.length) {
            dataStr = [NSString stringWithFormat:@"%@|%@",dataStr,[self getHexByDecimal:value]];
        } else {
            dataStr = [self getHexByDecimal:value];
        }
    }
    NSLog(@"收到设备的数据 = %@",dataStr);
    self.sendOrder ++;
    [[NSNotificationCenter defaultCenter] postNotificationName:FINISHSEND object:nil];
    
}
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverDescriptorsForCharacteristic:(CBCharacteristic *)characteristic error:(nullable NSError *)error {
    NSLog(@"等待数据超时1111111");
}

// 10 -> 16
- (NSString *)getHexByDecimal:(NSInteger)decimal {
    
    NSString *hex =@"";
    NSString *letter;
    NSInteger number;
    for (int i = 0; i<9; i++) {
        
        number = decimal % 16;
        decimal = decimal / 16;
        switch (number) {
                
            case 10:
                letter =@"A"; break;
            case 11:
                letter =@"B"; break;
            case 12:
                letter =@"C"; break;
            case 13:
                letter =@"D"; break;
            case 14:
                letter =@"E"; break;
            case 15:
                letter =@"F"; break;
            default:
                letter = [NSString stringWithFormat:@"%ld", number];
        }
        hex = [letter stringByAppendingString:hex];
        if (decimal == 0) {
            
            break;
        }
    }
    return hex;
}

@end
