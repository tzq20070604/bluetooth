//
//  PanelTableCell.h
//  BlueTooth
//
//  Created by tangzhiqiang on 2023/8/17.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PanelTableCell : UITableViewCell

/** 0 关闭 1 打开*/
-(void)configWith:(NSString *)type tip:(NSString *)tip isSwitch:(BOOL)isSwitch value:(NSInteger)value;

@end

NS_ASSUME_NONNULL_END
