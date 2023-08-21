//
//  NSObject+MethodExchange.h
//  BlueTooth
//
//  Created by tangzhiqiang on 2023/8/17.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (MethodExchange)

+ (void)instanceSwizzleSelector:(SEL)swizzledSelector originalSelector:(SEL)originalSelector;

@end

NS_ASSUME_NONNULL_END
