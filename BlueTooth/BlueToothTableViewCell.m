//
//  BlueToothTableViewCell.m
//  CoreBluetoothDemo
//
//  Created by tangzhiqiang on 2023/8/15.
//  Copyright © 2023 Jone. All rights reserved.
//

#import "BlueToothTableViewCell.h"
#import <Masonry/Masonry.h>
#import <YYKit/YYKit.h>

@interface BlueToothTableViewCell()

@property (strong, nonatomic) UIActivityIndicatorView *indicatorView;
@property (nonatomic,strong) UIButton *disConnectBtn;

@end

@implementation BlueToothTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    self.indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:(UIActivityIndicatorViewStyleGray)];
    [self.contentView addSubview:self.indicatorView];
    [self.indicatorView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.offset(0);
        make.right.offset(-15);
    }];
    [self.contentView addSubview:self.disConnectBtn];
    
    [self.disConnectBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.offset(0);
        make.right.offset(-15);
        make.size.mas_equalTo(CGSizeMake(60, 40));
    }];
    
    self.type = RightTypeNone;
    
}

- (void)setType:(RightType)type {
    _type = type;
    self.indicatorView.hidden = YES;
    self.disConnectBtn.hidden = YES;
    self.accessoryType = UITableViewCellAccessoryNone;
    switch (type) {
        case RightTypeConnected:{
            self.disConnectBtn.hidden = NO;
            break;
        }
        case RightTypeIndicator:{
            self.indicatorView.hidden = NO;
            if (self.indicatorView.isAnimating) {
                [self.indicatorView stopAnimating];
            }
            [self.indicatorView startAnimating];
            break;
        }
        default:
            break;
    }
}


- (void)actionDisConnectBtnDidClick:(UIButton *)button {
    if (self.disconnectBlock) {
        self.disconnectBlock();
    }
}

- (UIButton *)disConnectBtn {
    if (!_disConnectBtn) {
        UIButton *btn = [[UIButton alloc] init];
        btn.titleLabel.font = [UIFont systemFontOfSize:14];
        [btn setTitle:@"断开" forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor colorWithHexString:@"#E64C3D"] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(actionDisConnectBtnDidClick:) forControlEvents:UIControlEventTouchUpInside];
        [btn.layer setBorderColor:[UIColor blackColor].CGColor];
        btn.layer.cornerRadius = 20;
        btn.layer.borderWidth = 1;
        btn.layer.masksToBounds = YES;
        _disConnectBtn = btn;
    }
    return _disConnectBtn;
}

@end
