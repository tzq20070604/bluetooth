//
//  DisplayModel.h
//  BlueTooth
//
//  Created by tangzhiqiang on 2023/8/17.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DisplayModel : NSObject

@property (nonatomic, strong) NSString *type;

@property (nonatomic, strong) NSString *tip;

@property (nonatomic, assign) BOOL isSwitch;

@property (nonatomic, assign) NSInteger value;

@end

NS_ASSUME_NONNULL_END
