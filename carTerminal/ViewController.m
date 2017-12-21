//
//  ViewController.m
//  carTerminal
//
//  Created by Willow Ma on 2017/12/19.
//  Copyright © 2017年 Willow Ma. All rights reserved.
//

#import "ViewController.h"
#import <CoreBluetooth/CoreBluetooth.h>

#define uuid (@"")


@interface ViewController ()<CBCentralManagerDelegate,CBPeripheralDelegate>


@property (nonatomic,strong) CBCentralManager *manager;
@property (weak, nonatomic) IBOutlet UITextView *terminalTextView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self print:@"[sys]终端已启动"];
    
    
    self.manager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    
    // Do any additional setup after loading the view, typically from a nib.
}

- (IBAction)scan:(id)sender {
    NSArray *uuids = @[uuid];
    [self.manager scanForPeripheralsWithServices:uuids options:nil];
}


//发现外设
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *,id> *)advertisementData RSSI:(NSNumber *)RSSI{
    [central stopScan];
    [central connectPeripheral:peripheral options:nil];
}

//连接成功
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral{
    [self print:@"连接成功"];
    peripheral.delegate = self;
    [peripheral discoverServices:nil];
}

//连接失败
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{
    [self print:@"连接失败"];
}

//判断蓝牙是否开启
- (void)centralManagerDidUpdateState:(nonnull CBCentralManager *)central {
    switch (central.state) {
        case CBManagerStatePoweredOn:
            [self print:@"蓝牙开启"];
            break;
        default:
            [self print:@"蓝牙未开启"];
            break;
    }
}


//已连接外设服务
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error{
    if (error != nil) {
        [self print:@"连接服务失败"];
        return;
    }
    for (CBService *service in peripheral.services) {
        [peripheral discoverCharacteristics:nil forService:service];
    }
}

//扫描到特征值
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error{
    if (error != nil) {
        [self print:@"扫描特征失败"];
        return;
    }
    for (CBCharacteristic *characteristic in service.characteristics) {
        [peripheral setNotifyValue:YES forCharacteristic:characteristic];
        if ([characteristic.UUID.UUIDString isEqualToString:uuid]) {
            [peripheral readValueForCharacteristic:characteristic];
        }
    }
}

//获取特征值之后的操作
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    if (error != nil) {
        [self print:@"获取数值失败"];
        return;
    }
    if ([characteristic.UUID.UUIDString isEqualToString:uuid]) {
        NSString *str = [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding];
        NSString *resultStr = [NSString stringWithFormat:@"获取的值为：%@\n",str];
        [self print:resultStr];
    }
}

- (void)print:(NSString *)str{
    NSString *lastStr = self.terminalTextView.text;
    NSString *newStr = [NSString stringWithFormat:@"%@-%@\n",lastStr,str];
    self.terminalTextView.text = newStr;
}

- (IBAction)clearMsg:(UIButton *)sender {
    self.terminalTextView.text = @"";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
