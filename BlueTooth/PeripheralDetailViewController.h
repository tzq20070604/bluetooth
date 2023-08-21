//
//  PeripheralDetailViewController.h
//  CoreBluetoothDemo
//
//  Created by tangzhiqiang on 2023/8/14.
//  Copyright © 2023 Jone. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreBluetoothManager.h"
#import <CoreBluetooth/CBPeripheral.h>

NS_ASSUME_NONNULL_BEGIN

@interface PeripheralDetailViewController : UIViewController <CBPeripheralDelegate>

@property (nonatomic, strong) CoreBluetoothManager *manager;
@property (nonatomic, strong) CBPeripheral *peripheral;

@end

NS_ASSUME_NONNULL_END
