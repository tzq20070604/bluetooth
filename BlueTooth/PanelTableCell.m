//
//  BlueToothFindTableCell.m
//  BlueTooth
//
//  Created by tangzhiqiang on 2023/8/17.
//

#import <YYKit/YYKit.h>
#import "PanelTableCell.h"
#import <Masonry/Masonry.h>

@interface PanelTableCell()

@property (nonatomic, strong) UILabel *tipLB;

@property (nonatomic,strong) UILabel *valueLB;

@property (nonatomic, strong) UISwitch *switchBtn;

@end

@implementation PanelTableCell

#pragma mark - 生命周期
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self addContentView];
    }
    return self;
}

#pragma mark - 视图布局
- (void)addContentView {
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    [self.contentView addSubview:self.tipLB];
    [self.contentView addSubview:self.valueLB];
    [self.contentView addSubview:self.switchBtn];
    
    [self.tipLB mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.offset(15);
        make.centerY.offset(0);
    }];
    
    [self.valueLB mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.tipLB.mas_right).offset(15);
        make.centerY.offset(0);
    }];
    
    [self.switchBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.tipLB.mas_right).offset(15);
        make.centerY.offset(0);
    }];
    
}

-(void)configWith:(NSString *)type tip:(NSString *)tip isSwitch:(BOOL)isSwitch value:(NSInteger)value {
    self.tipLB.text = tip;
    if (isSwitch) {
        self.switchBtn.hidden = NO;
        self.valueLB.hidden = YES;
        [self.switchBtn setOn:(value == 1)];
    } else {
        self.switchBtn.hidden = YES;
        self.valueLB.hidden = NO;
        if ([type isEqualToString:@"02"]) {
            if (value == 0) {
                self.valueLB.text = [NSString stringWithFormat:@"--"];
            } else {
                self.valueLB.text = [NSString stringWithFormat:@"%ld 挡", value];
            }
        } else if ([type isEqualToString:@"05"]) {
            if (value == 0) {
                self.valueLB.text = [NSString stringWithFormat:@"--"];
            } else {
                self.valueLB.text = [NSString stringWithFormat:@"定时模式 %ld", value];
            }
            
           
        } else {
            self.valueLB.text = [NSString stringWithFormat:@"%ld", value];
        }
    }
}

- (UILabel *)tipLB {
    if (!_tipLB) {
        UILabel *label = [[UILabel alloc] init];
        label.font = [UIFont systemFontOfSize:14];
        label.textAlignment = NSTextAlignmentLeft;
        label.textColor = [UIColor colorWithHexString:@"#2D3132"];
        _tipLB = label;
    }
    return _tipLB;
}

- (UILabel *)valueLB {
    if (!_valueLB) {
        UILabel *label = [[UILabel alloc] init];
        label.font = [UIFont boldSystemFontOfSize:14];
        label.textAlignment = NSTextAlignmentLeft;
        label.textColor = [UIColor colorWithHexString:@"#2D3132"];
        _valueLB = label;
    }
    return _valueLB;
}

- (UISwitch *)switchBtn {
    if (!_switchBtn) {
        UISwitch *switchBtn = [[UISwitch alloc] init];
        _switchBtn = switchBtn;
    }
    return _switchBtn;
}
@end
