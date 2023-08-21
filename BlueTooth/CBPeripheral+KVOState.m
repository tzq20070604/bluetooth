//
//  CBPeripheral+KVOState.m
//  BlueTooth
//
//  Created by tangzhiqiang on 2023/8/17.
//

#import "CBPeripheral+KVOState.h"
#import "NSObject+MethodExchange.h"
#import <objc/message.h>

@implementation CBPeripheral (KVOState)

+(void)load {
    [self instanceSwizzleSelector:@selector(setBlueToothState) originalSelector:@selector(setState:)];
}

- (void)setBlueToothState {
    [self setBlueToothState];
    if (self.changeState) {
        self.changeState(self, self.state);
    }
}

- (void)setChangeState:(void (^)(CBPeripheral * _Nonnull, CBPeripheralState))changeState {
    objc_setAssociatedObject(self, @"changeBlock", changeState, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void (^)(CBPeripheral * _Nonnull, CBPeripheralState))changeState {
    return objc_getAssociatedObject(self, @"changeBlock");
}

@end
