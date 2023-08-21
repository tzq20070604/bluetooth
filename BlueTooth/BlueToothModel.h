//
//  BlueToothModel.h
//  CoreBluetoothDemo
//
//  Created by tangzhiqiang on 2023/8/16.
//  Copyright © 2023 Jone. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BlueToothModel : NSObject

+ (instancetype)createModelWithString:(NSString *)string;

// 创建sum
- (NSString *)createSum;

// 创建16进制字符串 没有前面0x
- (NSString *)joinToHexStr;

@property (strong, nonatomic) NSString *head;

@property (strong, nonatomic) NSString *type;

@property (strong, nonatomic) NSString *len;

@property (strong, nonatomic) NSString *dataStr;

@property (strong, nonatomic) NSString *sum;

@end

NS_ASSUME_NONNULL_END
