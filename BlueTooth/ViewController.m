//
//  ViewController.m
//  CoreBluetoothDemo
//
//  Created by Jone on 07/12/2016.
//  Copyright © 2016 Jone. All rights reserved.
//

#import <SVProgressHUD/SVProgressHUD.h>
#import "ViewController.h"
#import "BlueToothTableViewCell.h"
#import "PeripheralDetailViewController.h"
#import "CoreBluetoothManager.h"
#import <CoreBluetooth/CBPeripheral.h>
#import <SVProgressHUD/SVProgressHUD.h>
#import "CBPeripheral+KVOState.h"

@interface ViewController () <UITableViewDelegate, UITableViewDataSource, CoreBluetoothManagerVCDelegate>
@property (nonatomic, strong) CoreBluetoothManager *manager;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray <CBPeripheral *> *peripherals;
@property (nonatomic, strong) NSArray <CBPeripheral *> *colectedPeripherals;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.tableView];
    
    UIBarButtonItem *scanItem = [[UIBarButtonItem alloc] initWithTitle:@"开始扫描" style:UIBarButtonItemStylePlain target:self action:@selector(actionScan)];
    self.navigationItem.rightBarButtonItem = scanItem;

    CoreBluetoothManager *manager = [[CoreBluetoothManager alloc] init];
    manager.vcDelegate = self;
    _manager = manager;
}

//- (void)viewDidAppear:(BOOL)animated {
//    [super viewDidAppear:animated];
//    [self actionScan];
//}
//
//- (void)viewDidDisappear:(BOOL)animated {
//    [super viewDidDisappear:animated];
//    [self actionScan];
//}


- (void)reloadTableView {
    [self.tableView reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return @"已连接的设备";
    } else {
        return @"未连接的设备";
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return self.colectedPeripherals.count == 0 ? 1 : self.colectedPeripherals.count;
    } else {
        return self.peripherals.count == 0 ? 1 : self.peripherals.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BlueToothTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"peripheralsCell"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (indexPath.section == 0) {
        if (self.colectedPeripherals.count == 0) {
            cell.textLabel.text = @"暂无绑定的设备";
            cell.detailTextLabel.text = @"";
            cell.type = RightTypeNone;
            return cell;
        }
    } else {
        if (self.peripherals.count == 0) {
            cell.textLabel.text = @"未扫描到未连接的设备";
            cell.detailTextLabel.text = @"";
            cell.type = RightTypeNone;
            return cell;
        }
    }
    CBPeripheral *peripheral = nil;
    if (indexPath.section == 0) {
        peripheral = self.colectedPeripherals[indexPath.row];
    } else {
        peripheral = self.peripherals[indexPath.row];
    }
    
    cell.textLabel.text = peripheral.name;
    cell.detailTextLabel.text = peripheral.identifier.UUIDString;
    
    
    if (peripheral.state == CBPeripheralStateConnected) {
        cell.type = RightTypeConnected;
    } else if (peripheral.state == CBPeripheralStateConnecting || peripheral.state ==  CBPeripheralStateDisconnecting) {
        cell.type = RightTypeIndicator;
    } else  {
        cell.type = RightTypeNone;
    }
    
    void(^block)(CBPeripheral *peripheral, CBPeripheralState state, BlueToothTableViewCell *cell) =
     ^(CBPeripheral *peripheral, CBPeripheralState state, BlueToothTableViewCell *cell) {
        if (cell) {
            if (peripheral.state == CBPeripheralStateConnected) {
                cell.type = RightTypeConnected;
            } else if (peripheral.state == CBPeripheralStateConnecting || peripheral.state ==  CBPeripheralStateDisconnecting) {
                cell.type = RightTypeIndicator;
            } else  {
                cell.type = RightTypeNone;
            }
        }
    };
    __weak typeof(self) weakSelf = self;
    cell.disconnectBlock = ^(void){
        if (peripheral.state == CBPeripheralStateDisconnected) {
            [weakSelf.manager toConnectPeripheral:peripheral];
        } else if (peripheral.state == CBPeripheralStateConnecting){
            [SVProgressHUD showInfoWithStatus:@"连接中...，请稍后再试"];
        } else if (peripheral.state == CBPeripheralStateDisconnecting){
            [SVProgressHUD showInfoWithStatus:@"断开中...，请稍后再试"];
        } else {
            [weakSelf.manager.centralManager cancelPeripheralConnection:peripheral];
        }
    };
    block(peripheral, peripheral.state, cell);
    
    __weak typeof(cell) weakCell = cell;
    peripheral.changeState = ^(CBPeripheral *peripheral, CBPeripheralState state) {
        block(peripheral,state, weakCell);
    };
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    CBPeripheral *peripheral = nil;
    if (indexPath.section == 0) {
        if (self.colectedPeripherals.count == 0) {
            return;
        }
        peripheral = self.colectedPeripherals[indexPath.row];
        if (self.manager.centralManager.state != CBManagerStatePoweredOn) {
            [SVProgressHUD showInfoWithStatus:@"请打开蓝牙"];
            return;
        }
        [self.manager stopScanPeripherals];
        PeripheralDetailViewController *detailVC = [PeripheralDetailViewController new];
        detailVC.manager = self.manager;
        detailVC.peripheral = peripheral;
        peripheral.delegate = detailVC;
        [self.navigationController pushViewController:detailVC animated:YES];
    } else {
        if (self.peripherals.count == 0) {
            return;
        }
        if (self.manager.centralManager.state != CBManagerStatePoweredOn) {
            [SVProgressHUD showInfoWithStatus:@"请打开蓝牙"];
            return;
        }
        peripheral = self.peripherals[indexPath.row];
        if (peripheral.state == CBPeripheralStateDisconnected) {
            [self.manager toConnectPeripheral:peripheral];
        } else if (peripheral.state == CBPeripheralStateConnecting){
            [SVProgressHUD showInfoWithStatus:@"连接中...，请稍后再试"];
        } else if (peripheral.state == CBPeripheralStateDisconnecting){
            [SVProgressHUD showInfoWithStatus:@"断开中...，请稍后再试"];
        } else {
            [SVProgressHUD showInfoWithStatus:@"蓝牙已经连接"];
        }
        
    }
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.frame];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [_tableView registerClass:[BlueToothTableViewCell class] forCellReuseIdentifier:@"peripheralsCell"];
    }
    return _tableView;
}

- (void)actionScan {
    if (self.manager.centralManager.state != CBManagerStatePoweredOn) {
        [SVProgressHUD showInfoWithStatus:@"请打开蓝牙"];
    } else {
        if ([self.navigationItem.rightBarButtonItem.title isEqual: @"开始扫描"]) {
            if (self.manager.centralManager.isScanning) {
                [self.manager stopScanPeripherals];
            }
            [self.manager startScanPeripherals];
        } else {
            [self.manager stopScanPeripherals];
        }
    }
}

- (void)managerStopScan {
    self.navigationItem.rightBarButtonItem.title = @"开始扫描";
}

- (void)managerStartScan {
    self.navigationItem.rightBarButtonItem.title = @"扫描中";
}

- (void)deviceStatusHasChangedWithPeripherals:(NSArray<CBPeripheral *> *) peripherals colectedPeripherals:(NSArray <CBPeripheral *> *) colectedPeripherals {
    NSMutableArray *tempPeripherals = [NSMutableArray array];
    NSMutableArray *tempColectedPeripherals = [NSMutableArray array];
    for (int i = 0; i < peripherals.count; i++) {
        CBPeripheral *peripheral = peripherals[i];
        if (peripheral.state == CBPeripheralStateConnected) {
            [tempColectedPeripherals addObject:peripheral];
        } else {
            [tempPeripherals addObject:peripheral];
        }
    }

    for (int j = 0; j < colectedPeripherals.count; j++) {
        CBPeripheral *peripheral = colectedPeripherals[j];
        if (peripheral.state == CBPeripheralStateConnected) {
            [tempColectedPeripherals addObject:peripheral];
        } else {
            [tempPeripherals addObject:peripheral];
        }
    }
    
    self.peripherals = [tempPeripherals copy];
    self.colectedPeripherals = [tempColectedPeripherals copy];
    [self reloadTableView];
}

@end
