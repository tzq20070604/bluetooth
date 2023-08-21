//
//  CBPeripheral+KVOState.h
//  BlueTooth
//
//  Created by tangzhiqiang on 2023/8/17.
//

#import <CoreBluetooth/CoreBluetooth.h>

NS_ASSUME_NONNULL_BEGIN

@interface CBPeripheral (KVOState)

@property (nonatomic, copy) void (^changeState)(CBPeripheral *peripheral, CBPeripheralState state);

@end

NS_ASSUME_NONNULL_END
