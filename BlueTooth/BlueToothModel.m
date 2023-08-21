//
//  BlueToothModel.m
//  CoreBluetoothDemo
//
//  Created by tangzhiqiang on 2023/8/16.
//  Copyright © 2023 Jone. All rights reserved.
//

#import "BlueToothModel.h"
#import <YYKit/YYKit.h>

@implementation BlueToothModel

// <aa550201 00010301>
// 这个指令是否有限
+ (instancetype)createModelWithString:(NSString *)string {
    if (string.length < 14) {
        return nil;
    }
    
    NSString *head = [string substringToIndex:4];
    if (![head.uppercaseString isEqualToString:@"aa55".uppercaseString]) {
        return nil;
    }
    
    NSString *type = [string substringWithRange:NSMakeRange(4, 2)];
    
    NSString *len = [string substringWithRange:NSMakeRange(6, 4)];
    
    NSString *len1 = [string substringWithRange:NSMakeRange(6, 2)];
    
    NSString *len2 = [string substringWithRange:NSMakeRange(8, 2)];
    
    NSString *lenStr = [len2 stringByAppendingString:len1];
    
    NSInteger dataLen = 0;
    
    NSDictionary *hexDict = [BlueToothModel hexDict];
    for (int i = 0; i < lenStr.length; i++) {
        NSString *item = [lenStr substringWithRange:NSMakeRange(i, 1)];
        NSString *decimalismStr = hexDict[item];
        if (decimalismStr.length == 0) {
            return nil;
        }
        dataLen += decimalismStr.intValue * (int)pow(16, lenStr.length - i - 1);
    }
    NSInteger totalLength = (10 + dataLen * 2 + 4);
    if (string.length != totalLength) {
        return nil;
    }
    
    NSString *dataStr = [string substringWithRange:NSMakeRange(10, dataLen * 2)];
    NSString *sum = [string substringWithRange:NSMakeRange(10 + dataLen * 2, 4)];
    
    BlueToothModel *model = [[self alloc] init];
    model.head = head;
    model.type = type;
    model.len = len;
    model.dataStr = dataStr;
    model.sum = sum;
    return model;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"\n{\nhead=%@,\ntype=%@,\nlen=%@,\ndataStr=%@,\nsum=%@\n}\n", self.head, self.type, self.len, self.dataStr, self.sum];
}

- (NSString *)createSum {
    NSLog(@"createSum model = %@", self);
    NSInteger head = [self hexValueWithLSBString:self.head];
    NSString *headStr = [NSString stringWithFormat:@"%0lx",head];
    NSLog(@"headStr=%@\n",headStr);
    
    NSInteger type = [self hexValueWithLSBString:self.type];
    NSString *typeStr = [NSString stringWithFormat:@"%0lx",type];
    NSLog(@"typeStr=%@\n",typeStr);
    
    NSInteger len = [self hexValueWithLSBString:self.len];
    NSString *lenStr = [NSString stringWithFormat:@"%0lx",len];
    NSLog(@"lenStr=%@\n",lenStr);
    
    // 这个比较特殊
    NSString *dataString = [NSString stringWithFormat:@"0x%@",self.dataStr];
    NSInteger dataInt = dataString.numberValue.integerValue;
    NSString *dataStr = [NSString stringWithFormat:@"%0lx",dataInt];
    NSLog(@"dataStr=%@\n",dataStr);
    
    NSInteger sum = (type + len + dataInt) & 0xffff;
    NSString *sumStr = [NSString stringWithFormat:@"%04lx",sum];
    NSLog(@"sumStr=%@",sumStr);
    
    NSMutableString *mutableStr = [NSMutableString string];
    for (NSInteger i = sumStr.length - 1; i >= 0; i = i - 2) {
        [mutableStr appendString:[sumStr substringWithRange:NSMakeRange(i - 1, 2)]];
    }
    return mutableStr;
}

- (NSInteger)hexValueWithLSBString:(NSString *)lsbHexStr {
    if (lsbHexStr.length <= 0 || (lsbHexStr.length % 2 != 0)){
        return 0x00;
    } else {
        NSMutableString *mutableStr = [[NSMutableString alloc] initWithString:@"0x"];
        for (NSInteger i = lsbHexStr.length - 1; i >= 0; i = i - 2) {
            [mutableStr appendString:[lsbHexStr substringWithRange:NSMakeRange(i - 1, 2)]];
        }
        return mutableStr.numberValue.integerValue;
    }
}

- (NSString *)joinToHexStr {
    NSMutableString *totalStr = [NSMutableString string];
    [totalStr appendString:self.head ?: @""];
    [totalStr appendString:self.type ?: @""];
    [totalStr appendString:self.len ?: @""];
    [totalStr appendString:self.dataStr ?: @""];
    [totalStr appendString:self.sum ?: @""];
    return totalStr.copy;
}

+ (NSDictionary *)hexDict {
    return @{
        @"0" : @"0",
        @"1" : @"1",
        @"2" : @"2",
        @"3" : @"3",
        @"4" : @"4",
        @"5" : @"5",
        @"6" : @"6",
        @"7" : @"7",
        @"8" : @"8",
        @"9" : @"9",
        @"a" : @"10",
        @"b" : @"11",
        @"c" : @"12",
        @"d" : @"13",
        @"e" : @"14",
        @"f" : @"15",
        @"A" : @"10",
        @"B" : @"11",
        @"C" : @"12",
        @"D" : @"13",
        @"E" : @"14",
        @"F" : @"15"
    };
}
@end
