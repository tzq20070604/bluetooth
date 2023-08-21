//
//  CoreBluetoothManager.m
//  DMRentEnterprise
//
//  Created by Jone on 01/12/2016.
//  Copyright © 2016 Jone. All rights reserved.
//

#import "CoreBluetoothManager.h"
#import "BlueToothModel.h"

#define DevicesUUIDStringFilePth [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask , YES) objectAtIndex:0] stringByAppendingPathComponent:@"DevicesUUIDS.plist"]

@interface CoreBluetoothManager()<CBCentralManagerDelegate, CBPeripheralDelegate,CBPeripheralManagerDelegate> {
    NSMutableArray *_peripheralsList;
    NSMutableArray *_collectedPeripheralsList;
}

@end

@implementation CoreBluetoothManager

- (instancetype)init {
    self = [super init];
    if (!self) return nil;
    /**
     CBCentralManagerOptionShowPowerAlertKey
     布尔值，表示的是在central manager初始化时，如果当前蓝牙没打开，是否弹出alert框。
     CBCentralManagerOptionRestoreIdentifierKey
     字符串，一个唯一的标示符，用来蓝牙的恢复连接的。
     原文链接：https://blog.csdn.net/q1194259339/article/details/76283768
     */
    CBCentralManager *centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil options:@{CBCentralManagerOptionShowPowerAlertKey : @(YES), CBCentralManagerOptionRestoreIdentifierKey : @(YES)}];
    _centralManager = centralManager;
    return self;
}

#pragma mark - CBCentralManagerDelegate
// 在 cetral 的状态变为 CBManagerStatePoweredOn 的时候开始扫描
- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    switch (central.state) {
        case CBManagerStatePoweredOn:{
            break;
        }
        default:
            break;
    }
}

- (void)startScanPeripherals {
    _peripheralsList = [NSMutableArray array];
    _collectedPeripheralsList = [NSMutableArray array];
    // 根据自定义的服务ID找出手机系统已连接的设备
    /**http://www.manongjc.com/detail/19-mtxkcrybdnulpge.html */
    NSArray *serviceArr = @[
       [CBUUID UUIDWithString:@"0000180F-0000-1000-8000-00805f9b34fb"],
       [CBUUID UUIDWithString:@"0000180A-0000-1000-8000-00805f9b34fb"],
       [CBUUID UUIDWithString:@"0000FFF0-0000-1000-8000-00805f9b34fb"],
       [CBUUID UUIDWithString:@"A8253F01-0C51-4000-B84F-1500068FB5A3"],
       [CBUUID UUIDWithString:@"4B443330-3844-2D41-3437-362D30313000"]
    ];
    
    NSArray<CBPeripheral*>* peripheralArray = [_centralManager retrieveConnectedPeripheralsWithServices:serviceArr];
    NSLog(@"peripheralArray %@",peripheralArray);
    for (int i = 0; i < peripheralArray.count; i++) {
        CBPeripheral *peripheral = peripheralArray[i];
        if (peripheral.name.length != 0) {
            [_collectedPeripheralsList addObject:peripheral];
        }
    }
    _colectedPeripherals = [_collectedPeripheralsList copy];
    _peripherals = [_peripheralsList copy];
    if ([self.vcDelegate respondsToSelector:@selector(deviceStatusHasChangedWithPeripherals:colectedPeripherals:)]) {
        [self.vcDelegate deviceStatusHasChangedWithPeripherals:self.peripherals colectedPeripherals:self.colectedPeripherals];
    }
    if (!_centralManager.isScanning) {
        /**
         CBCentralManagerScanOptionAllowDuplicatesKey
         默认值为NO表示不会重复扫描已经发现的设备,如需要不断获取最新的信号强度RSSI则设为YES。
         */
        [_centralManager scanForPeripheralsWithServices:serviceArr options:nil];
    }
    [self.vcDelegate managerStartScan];
}

// 停止扫描
- (void)stopScanPeripherals {
    if (_centralManager.isScanning) {
        [_centralManager stopScan];
    }
    [self.vcDelegate managerStopScan];
}

- (void)toConnectPeripheral:(CBPeripheral *)peripheral {
    // 在某个地方停止扫描并连接至周边设备
    
    NSLog(@"peripheral %@",peripheral.identifier.UUIDString);
    NSLog(@"%s",__FUNCTION__);
    [self stopScanPeripherals];
    /**
     CBConnectPeripheralOptionNotifyOnConnectionKey
     在程序被挂起时，连接成功显示Alert提醒框
     CBConnectPeripheralOptionNotifyOnDisconnectionKey;
     在程序被挂起时，断开连接显示Alert提醒框
     CBConnectPeripheralOptionNotifyOnNotificationKey
     在程序被挂起时，显示所有的提醒消息
     原文链接：https://blog.csdn.net/q1194259339/article/details/76283768
     */
    [_centralManager connectPeripheral:peripheral options:nil];
}


- (void)centralManager:(CBCentralManager *)central
 didDiscoverPeripheral:(CBPeripheral *)peripheral
     advertisementData:(NSDictionary<NSString *, id> *)advertisementData RSSI:(NSNumber *)RSSI {
    NSLog(@"%s",__FUNCTION__);
    if (!peripheral.name) return; // Ingore name is nil peripheral.
    if (![_peripheralsList containsObject:peripheral] && ![_collectedPeripheralsList containsObject:peripheral]) {
        [_peripheralsList addObject:peripheral];
    }
    _colectedPeripherals = [_collectedPeripheralsList copy];
    _peripherals = [_peripheralsList copy];
    if ([self.vcDelegate respondsToSelector:@selector(deviceStatusHasChangedWithPeripherals:colectedPeripherals:)]) {
        [self.vcDelegate deviceStatusHasChangedWithPeripherals:self.peripherals colectedPeripherals:self.colectedPeripherals];
    }
}


- (void)centralManager:(CBCentralManager *)central willRestoreState:(NSDictionary<NSString *, id> *)dict {
    NSLog(@"%s", __FUNCTION__);
    NSLog(@"willRestoreState=%@",dict);
}
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    NSLog(@"%s",__FUNCTION__);
    NSLog(@"didConnectPeripheral:%@",peripheral);
    if ([self.vcDelegate respondsToSelector:@selector(deviceStatusHasChangedWithPeripherals:colectedPeripherals:)]) {
        [self.vcDelegate deviceStatusHasChangedWithPeripherals:self.peripherals colectedPeripherals:self.colectedPeripherals];
    }
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    NSLog(@"%s",__FUNCTION__);
    NSLog(@"didFailToConnectPeripheral %@ %@",peripheral, error);
    if ([self.vcDelegate respondsToSelector:@selector(deviceStatusHasChangedWithPeripherals:colectedPeripherals:)]) {
        [self.vcDelegate deviceStatusHasChangedWithPeripherals:self.peripherals colectedPeripherals:self.colectedPeripherals];
    }
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    NSLog(@"%s",__FUNCTION__);
    NSLog(@"didDisconnectPeripheral %@ %@",peripheral, error);
    if ([self.vcDelegate respondsToSelector:@selector(deviceStatusHasChangedWithPeripherals:colectedPeripherals:)]) {
        [self.vcDelegate deviceStatusHasChangedWithPeripherals:self.peripherals colectedPeripherals:self.colectedPeripherals];
    }
}

- (void)centralManager:(CBCentralManager *)central connectionEventDidOccur:(CBConnectionEvent)event forPeripheral:(CBPeripheral *)peripheral {
    NSLog(@"%s",__FUNCTION__);
}

@end
