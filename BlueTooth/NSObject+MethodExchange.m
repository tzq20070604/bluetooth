//
//  NSObject+MethodExchange.m
//  BlueTooth
//
//  Created by tangzhiqiang on 2023/8/17.
//

#import "NSObject+MethodExchange.h"
#import <objc/runtime.h>

@implementation NSObject (MethodExchange)


+ (void)instanceSwizzleSelector:(SEL)swizzledSelector originalSelector:(SEL)originalSelector {
    Method originalMethod = class_getInstanceMethod(self, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(self, swizzledSelector);
    BOOL success = class_addMethod(self, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));
    if (success) {
        class_replaceMethod(self, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

@end
