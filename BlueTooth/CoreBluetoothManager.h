//
//  CoreBluetoothManager.h
//  DMRentEnterprise
//
//  Created by Jone on 01/12/2016.
//  Copyright © 2016 Jone. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

#define ServiceUUID @"4B443330-3844-2D41-3437-362D30313000"
#define NotifyingCharacteristicUUID @"4B443330-3844-2D41-3437-362D30313001"
#define WriteCharacteristicUUID @"4B443330-3844-2D41-3437-362D30313002"

@protocol CoreBluetoothManagerVCDelegate <NSObject>

- (void)deviceStatusHasChangedWithPeripherals:(NSArray<CBPeripheral *> *) peripherals colectedPeripherals:(NSArray <CBPeripheral *> *) colectedPeripherals;

// 开始扫描
-(void)managerStartScan;

// 停止扫描
-(void)managerStopScan;

// 刷新列表
-(void)reloadTableView;


@end

@interface CoreBluetoothManager : NSObject

@property (nonatomic, strong) CBCentralManager *centralManager;

@property (nonatomic, strong, readonly) NSArray<CBPeripheral *> *peripherals;

@property (nonatomic, strong, readonly) NSArray <CBPeripheral *> *colectedPeripherals;

@property (nonatomic, weak) id<CoreBluetoothManagerVCDelegate> vcDelegate;

- (void)startScanPeripherals;

- (void)stopScanPeripherals;

- (void)toConnectPeripheral:(CBPeripheral *)peripheral;

@end
