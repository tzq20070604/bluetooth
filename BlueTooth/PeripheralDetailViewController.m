//
//  PeripheralDetailViewController.m
//  CoreBluetoothDemo
//
//  Created by tangzhiqiang on 2023/8/14.
//  Copyright © 2023 Jone. All rights reserved.
//

#import <SVProgressHUD/SVProgressHUD.h>
#import <YYKit/YYKit.h>
#import <Masonry/Masonry.h>
#import <MJExtension/MJExtension.h>
#import "PeripheralDetailViewController.h"
#import "BlueToothModel.h"
#import "PanelTableCell.h"
#import "DisplayModel.h"
#import <CocoaLumberjack/CocoaLumberjack.h>

//声明外部变量
extern DDLogLevel ddLogLevel;

extern NSInteger _ddLogLevel;
@interface PeripheralDetailViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) CBService *service;

@property (nonatomic, strong) CBCharacteristic *writeCharacteristic;

@property (nonatomic, strong) CBCharacteristic *notifyCharacteristic;

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *dataArr;

// 第一次启动的时候状态
@property (nonatomic, strong) NSArray *offArr;

// 最后一次的状态
@property (nonatomic, strong) NSMutableArray *currentArr;

@end

@implementation PeripheralDetailViewController

#pragma mark - 生命周期和视图布局
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
    [self setupPeripheral];
}

- (void)setupUI {
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = self.peripheral.name;
    self.tableView.hidden = YES;
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop);
        make.left.right.bottom.offset(0);
    }];
}

- (void)setupPeripheral {
    [SVProgressHUD showWithStatus:@"加载中..."];
    [self.peripheral discoverServices:@[[CBUUID UUIDWithString:ServiceUUID]]];
}

- (void)refreshTableView {
    if ([self.currentArr[0][@"isSwitch"] boolValue]) {
        self.dataArr = self.currentArr;
    } else {
        self.dataArr = self.offArr.mutableCopy;
    }
    self.tableView.hidden = NO;
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PanelTableCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(PanelTableCell.class) forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    NSDictionary *dict = self.dataArr[indexPath.row];
    [cell configWith:dict[@"type"] tip:dict[@"tip"] isSwitch:[dict[@"isSwitch"] boolValue] value:[dict[@"value"] integerValue]];
    return cell;
}

#pragma mark - 数据处理
// 接收到数据进行处理
- (BlueToothModel *)updateDateModelFromData:(NSData *)receivedData {
    NSData *responseData = receivedData;
    NSString *string = [responseData hexString].lowercaseString;
    BlueToothModel *model =  [BlueToothModel createModelWithString:string];
    if (!model) {
        [SVProgressHUD showErrorWithStatus:@"接收的数据解析出错"];
        return nil;
    }
    NSArray <DisplayModel *> *displaymodelArr = [DisplayModel mj_objectArrayWithKeyValuesArray:self.currentArr];
    if (![@"01" isEqualToString:model.type] && displaymodelArr[0].value == 0) { // 在关机状态，按其他按钮不起作用
        return nil;
    }
    // 更改数据
    if ([@"01" isEqualToString:model.type]) {
        if ([model.dataStr isEqualToString:@"01"]) { // 开启
            displaymodelArr[0].value = 1;
            if (displaymodelArr[1].value == 0) {
                displaymodelArr[1].value = 1;
            }
        } else {
            displaymodelArr[0].value = 0;
        }
    } else if ([@"02" isEqualToString:model.type]) { // 加减风速， 自动风速取消
        if (displaymodelArr[2].value == 1) {
            displaymodelArr[1].value = 1;
            displaymodelArr[2].value = 0;
        } else {
            if ([model.dataStr isEqualToString:@"00"]) {
                displaymodelArr[1].value -= 1;
            } else if ([model.dataStr isEqualToString:@"01"]) {
                displaymodelArr[1].value += 1;
            }
            if (displaymodelArr[1].value > 5) {
                displaymodelArr[1].value = 1;
            }
            if (displaymodelArr[1].value <= 0) {
                displaymodelArr[1].value = 5;
            }
        }
    } else if ([@"03" isEqualToString:model.type]) { // 自动风速命令
        if ([model.dataStr isEqualToString:@"00"]) { // 关闭
            displaymodelArr[2].value = 0;
            displaymodelArr[1].value = 1;
        } else if ([model.dataStr isEqualToString:@"01"]) { // 开启
            displaymodelArr[2].value = 1;
            displaymodelArr[1].value = 1;
        }
    } else if ([@"04" isEqualToString:model.type]) {
        if ([model.dataStr isEqualToString:@"00"]) { // 关闭
            displaymodelArr[3].value = 0;
        } else if ([model.dataStr isEqualToString:@"01"]) { // 开启
            displaymodelArr[3].value = 1;
        }
    } else if ([@"05" isEqualToString:model.type]) {
         displaymodelArr[4].value = model.dataStr.intValue;
    } else if ([@"06" isEqualToString:model.type]) {
        if ([model.dataStr isEqualToString:@"00"]) { // 关闭
            displaymodelArr[5].value = 0;
        } else if ([model.dataStr isEqualToString:@"01"]) { // 开启
            displaymodelArr[5].value = 1;
        }
    } else if ([@"07" isEqualToString:model.type]) {
        if ([model.dataStr isEqualToString:@"00"]) { // 关闭
            displaymodelArr[6].value = 0;
        } else if ([model.dataStr isEqualToString:@"01"]) { // 开启
            displaymodelArr[6].value = 1;
        }
    } else {
        [SVProgressHUD showErrorWithStatus:@"接收的数据类型错误"];
        return nil;
    }
    self.currentArr = [DisplayModel mj_keyValuesArrayWithObjectArray:displaymodelArr];
    [self refreshTableView];
    return model;
}

// 回复数据
- (void)writeDataWithModel:(BlueToothModel *)model {
    NSData *writeData = [self modelData:model];
    NSString *string = [NSString stringWithFormat:@"%@", writeData];
    DDLogInfo(@"\n外设\n%@\n特征\n%@\n属性\n%@\n写入数据:\n%@\n\n",self.peripheral.identifier.UUIDString, self.writeCharacteristic.UUID.UUIDString, [NSString stringWithFormat:@"0x%02lx",(unsigned long)self.writeCharacteristic.properties],string);
    NSLog(@"writeData=%@",writeData);
    // 这个不需要回复
    [self.peripheral writeValue:writeData forCharacteristic:self.writeCharacteristic type:CBCharacteristicWriteWithResponse];
}

- (NSData *)modelData:(BlueToothModel *)model {
    BlueToothModel *replayModel = [[BlueToothModel alloc] init];
    replayModel.head = model.head;
    replayModel.type = @"10";
    replayModel.len = @"0200";
    replayModel.dataStr = [model.type stringByAppendingString:model.dataStr];
    replayModel.sum = [replayModel createSum];
    NSString *writeHexStr = [replayModel joinToHexStr];
    NSData *data = [NSData dataWithHexString:writeHexStr];
    return data;
}


#pragma mark - CBPeripheralManagerDelegate 外围角色的实现
- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral {
    NSLog(@"%s",__FUNCTION__);
}


- (void)centralManager:(CBCentralManager *)central didUpdateANCSAuthorizationForPeripheral:(CBPeripheral *)peripheral {
    NSLog(@"%s",__FUNCTION__);
}

#pragma mark - CBPeripheralDelegate

// 发现服务
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(nullable NSError *)error {
    NSLog(@"%s",__FUNCTION__);
    if (!error) {
        NSArray *services = peripheral.services;
        for (int i = 0; i < services.count; i++) {
            CBService *service = services[i];
            NSLog(@"service.UUID %@", service.UUID.UUIDString);
            if ([service.UUID.UUIDString isEqualToString:ServiceUUID]) {
                self.service = service;
                break;
            }
        }
        if (!self.service) {
            [SVProgressHUD showErrorWithStatus:@"未找到对应的服务"];
        } else {
            [peripheral discoverCharacteristics:nil forService:self.service];
        }
    } else {
        [SVProgressHUD showErrorWithStatus:error.localizedDescription];
    }
    
}

// 发现特性值
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(nullable NSError *)error {
    NSLog(@"%s",__FUNCTION__);
    if (!error && [service.UUID.UUIDString isEqualToString:ServiceUUID]) {
        for (int i = 0; i < service.characteristics.count; i++) {
            CBCharacteristic *ch = service.characteristics[i];
            if ([ch.UUID.UUIDString isEqualToString:WriteCharacteristicUUID]) {
                self.writeCharacteristic = ch;
                DDLogInfo(@"\n发现外设\n%@\n服务\n%@\n特征\n%@\n属性\n%@\n\n",peripheral.identifier.UUIDString, service.UUID.UUIDString,ch.UUID.UUIDString,[NSString stringWithFormat:@"0x%02lx",(unsigned long)ch.properties]);
            }
            if ([ch.UUID.UUIDString isEqualToString:NotifyingCharacteristicUUID]) {
                DDLogInfo(@"\n发现外设\n%@\n服务\n%@\n特征\n%@\n属性\n%@\n\n",peripheral.identifier.UUIDString, service.UUID.UUIDString,ch.UUID.UUIDString,[NSString stringWithFormat:@"0x%02lx",(unsigned long)ch.properties]);
                self.notifyCharacteristic = ch;
                [peripheral setNotifyValue:YES forCharacteristic:self.notifyCharacteristic];
            }
        }
        if (self.writeCharacteristic && self.notifyCharacteristic) {
            [SVProgressHUD showSuccessWithStatus:@"蓝牙初始化成功"];
            [self refreshTableView];
        } else {
            [SVProgressHUD showErrorWithStatus:@"未找到对应的特征"];
        }
    } else {
        [SVProgressHUD showErrorWithStatus:error.localizedDescription];
    }
}

// 写入成功
- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(nullable NSError *)error {
    NSLog(@"%s",__FUNCTION__);
    DDLogInfo(@"\n外设\n%@\n特征\n%@\n属性\n%@\n写入数据成功\n\n",peripheral.identifier.UUIDString, characteristic.UUID.UUIDString, [NSString stringWithFormat:@"0x%02lx",(unsigned long)characteristic.properties]);
    if (!error) {
        NSLog(@"Write Success");
    } else {
        NSLog(@"WriteVale Error = %@", error);
    }
}

// 通知到达
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    NSLog(@"%s",__FUNCTION__);
    if (error) {
        [SVProgressHUD showErrorWithStatus:error.localizedDescription];
    } else {
        NSString *string = [NSString stringWithFormat:@"%@",characteristic.value];
        DDLogInfo(@"\n外设\n%@\n特征\n%@\n属性\n%@\n接收数据成功:\n%@\n\n",peripheral.identifier.UUIDString, characteristic.UUID.UUIDString, [NSString stringWithFormat:@"0x%02lx",(unsigned long)characteristic.properties],string);
        NSLog(@"readData=%@", characteristic.value);
        BlueToothModel *model = [self updateDateModelFromData:characteristic.value];
        if (model) {
            [self writeDataWithModel:model];
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForDescriptor:(CBDescriptor *)descriptor error:(NSError *)error {
    NSLog(@"%s",__FUNCTION__);
}

- (void)peripheralDidUpdateName:(CBPeripheral *)peripheral {
    NSLog(@"%s",__FUNCTION__);
}

- (void)peripheral:(CBPeripheral *)peripheral didReadRSSI:(NSNumber *)RSSI error:(NSError *)error {
    NSLog(@"%s",__FUNCTION__);
}

- (void)peripheralDidUpdateRSSI:(CBPeripheral *)peripheral error:(NSError *)error {
    NSLog(@"%s",__FUNCTION__);
}

#pragma mark - 懒加载
- (UITableView *)tableView {
    if (!_tableView) {
        UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        tableView.backgroundColor = [UIColor colorWithHexString:@"0xf4f4f5"];
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.estimatedRowHeight = 44;
        tableView.rowHeight = UITableViewAutomaticDimension;
        tableView.showsVerticalScrollIndicator = NO;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
        UIEdgeInsets edge = UIEdgeInsetsZero;
        if (@available(iOS 11.0, *)) {
            tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
            edge = [[UIApplication sharedApplication] delegate].window.safeAreaInsets;
            tableView.contentInset = UIEdgeInsetsMake(0, 0, edge.bottom, 0);
        }
        [tableView registerClass:PanelTableCell.class forCellReuseIdentifier:NSStringFromClass(PanelTableCell.class)];
        _tableView = tableView;
    }
    return _tableView;
}


- (NSArray *)offArr {
    return @[
        @{ @"type":@"01", @"tip":@"开关", @"isSwitch" : @(1),   @"value": @(0)},
        @{ @"type":@"02", @"tip":@"风速", @"isSwitch" : @(0),   @"value": @(0)},
        @{ @"type":@"03", @"tip":@"自动风速", @"isSwitch": @(1), @"value":@(0)},
        @{ @"type":@"04", @"tip":@"睡眠", @"isSwitch" : @(1),   @"value": @(0)},
        @{ @"type":@"05", @"tip":@"定时", @"isSwitch" : @(0),   @"value": @(0)},
        @{ @"type":@"06", @"tip":@"童锁", @"isSwitch" : @(1),   @"value": @(0)},
        @{ @"type":@"07", @"tip":@"杀菌", @"isSwitch" : @(1),   @"value": @(0)}
    ];
}

- (NSMutableArray *)currentArr {
    if (!_currentArr) {
        _currentArr = [self.offArr mutableCopy];
    }
    return _currentArr;
}
@end
