//
//  BlueToothTableViewCell.h
//  CoreBluetoothDemo
//
//  Created by tangzhiqiang on 2023/8/15.
//  Copyright © 2023 Jone. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>

typedef NS_ENUM(NSInteger, RightType) {
    RightTypeNone,
    RightTypeConnected,
    RightTypeIndicator
};

NS_ASSUME_NONNULL_BEGIN

@interface BlueToothTableViewCell : UITableViewCell

@property (strong, nonatomic) CBPeripheral* peripheral;

@property (assign, nonatomic) RightType type;

@property (nonatomic,copy) void(^disconnectBlock)(void);


@end

NS_ASSUME_NONNULL_END
