//
//  CalibrateViewController.m
//  CoasterCalibrate
//
//  Created by Ren Guohua on 14-9-24.
//  Copyright (c) 2014年 Nevermore. All rights reserved.
//

#import "CalibrateViewController.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "GHBLECentralManager.h"
#import "CalibrateCell.h"
#import "CBPeripheral+GHBLE.h"
#import "GHTool.h"



@interface CalibrateViewController ()<UITableViewDataSource ,UITableViewDelegate>
@property (strong, nonatomic) IBOutlet UILabel *hintLabel;

@property (weak, nonatomic) IBOutlet UITextView *detailTextView;

@property (weak, nonatomic) IBOutlet UITextField *gTextField;

@property (weak, nonatomic) IBOutlet UITextField *bTextField;

@property (weak, nonatomic) IBOutlet UIButton *writeButton;
@property (weak, nonatomic) IBOutlet UIButton *fastCalibrateButton;

@property (nonatomic, assign) NSInteger calibrateType;

- (IBAction)writeGB:(id)sender;

- (IBAction)startCalibrate:(id)sender;
- (IBAction)blink:(id)sender;
- (IBAction)shut:(id)sender;

- (IBAction)delete:(id)sender;
- (IBAction)calibrateZero:(id)sender;

- (IBAction)fastCalibrate:(UIButton *)sender;

@property (strong, nonatomic) IBOutlet UIButton *calibrateButton;
@property (strong, nonatomic) IBOutlet UIButton *blinkButton;
@property (strong, nonatomic) IBOutlet UIButton *shutButton;
@property (strong, nonatomic) IBOutlet UIButton *deleteButton;
@property (strong, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet UIButton *calibrateZeroButton;

- (IBAction)tap:(UITapGestureRecognizer *)sender;


@property (strong, nonatomic) NSArray *dataArray;

@end

@implementation CalibrateViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [[GHBLECentralManager shareManager] removeCalibrateData];
    [GHBLECentralManager shareManager].calibrateArray = nil;
    [GHBLECentralManager shareManager].calculateString = nil;
    
    [RACObserve([GHBLECentralManager shareManager], testArray) subscribeNext:^(NSArray *array) {
        
        
        if ([array count] > 0 )
        {

            _calibrateButton.enabled = YES;
            _calibrateZeroButton.enabled = YES;
            _fastCalibrateButton.enabled = YES;
            
            if (![_calibrateButton.titleLabel.text isEqualToString:@"重新校准"]) {
                    [UIView setAnimationsEnabled:NO];
                    [_calibrateButton setTitle:@"重新校准" forState:UIControlStateNormal];
                    [_calibrateButton layoutIfNeeded];
                    [UIView setAnimationsEnabled:YES];
                }
        }
        
        
        
        if ([GHBLECentralManager shareManager].calibrateType == CalibrateNormal)
        {
            NSInteger calibrateWeight = [array count] / 10;
            calibrateWeight = calibrateWeight * 100;
            _hintLabel.text = [NSString stringWithFormat:@"正在校验%ld克重量",(long)calibrateWeight];
        }
        else if ([GHBLECentralManager shareManager].calibrateType == CalibrateFast)
        {
            if ([array count] == 1)
            {
                _hintLabel.text = @"正在校验0克重量";
            }
            else if ([array count] == 2)
            {
                _hintLabel.text = @"正在校验100克重量";
            }
            else if ([array count] == 3)
            {
                _hintLabel.text = @"正在校验500克重量";
            }
            
        }
        
        [self.tableView reloadData];
        if ([[GHBLECentralManager shareManager].testArray count] > 0)
        {
            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[[GHBLECentralManager shareManager].testArray count] - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        }
    }];
    
    
    [RACObserve([GHBLECentralManager shareManager].choosedPeripheral,state) subscribeNext:^(NSNumber *state){
        
        if ([state integerValue] == CBPeripheralStateDisconnected)
        {
            _hintLabel.text = [NSString stringWithFormat:@"与蓝牙设备%@断开连接",[GHBLECentralManager shareManager].choosedPeripheral.deviceId] ;
            self.calibrateButton.enabled = NO;
            self.calibrateZeroButton.enabled = NO;
            self.fastCalibrateButton.enabled = NO;
        }
        else if ([state integerValue] == CBPeripheralStateConnecting)
        {
            _hintLabel.text = [NSString stringWithFormat:@"正在连接%@",[GHBLECentralManager shareManager].choosedPeripheral.deviceId ];
            self.calibrateButton.enabled = NO;
            self.calibrateZeroButton.enabled = NO;
            self.fastCalibrateButton.enabled = NO;
        }
        else if ([state integerValue] == CBPeripheralStateConnected)
        {
            _hintLabel.text = [NSString stringWithFormat:@"已经连接上%@",[GHBLECentralManager shareManager].choosedPeripheral.deviceId];
            [GHTool runMethodAfterDelay:5.0f withMethod:^{
                self.calibrateButton.enabled = YES;
                self.calibrateZeroButton.enabled = YES;
                self.fastCalibrateButton.enabled = YES;
            }];
        }
    
    }];
    
    
    _calibrateButton.layer.borderWidth = 1.0f;
    _calibrateButton.layer.borderColor = [UIColor redColor].CGColor;
    
    _blinkButton.layer.borderWidth = 1.0f;
    _blinkButton.layer.borderColor = [UIColor redColor].CGColor;
    
    _shutButton.layer.borderWidth = 1.0f;
    _shutButton.layer.borderColor = [UIColor redColor].CGColor;
    
    _deleteButton.layer.borderWidth = 1.0f;
    _deleteButton.layer.borderColor = [UIColor redColor].CGColor;
    
    _fastCalibrateButton.layer.borderWidth = 1.0f;
    _fastCalibrateButton.layer.borderColor = [UIColor redColor].CGColor;
    
    
    _calibrateZeroButton.layer.borderWidth = 1.0f;
    _calibrateZeroButton.layer.borderColor = [UIColor redColor].CGColor;
    
    _writeButton.layer.borderWidth = 1.0f;
    _writeButton.layer.borderColor = [UIColor redColor].CGColor;
    
    
    [self registerCell];
    
    [RACObserve([GHBLECentralManager shareManager],calculateString) subscribeNext:^(NSString *string){
        
        self.detailTextView.text = string;
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
  
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[GHBLECentralManager shareManager].centralManager cancelPeripheralConnection:[GHBLECentralManager shareManager].choosedPeripheral];
    [GHBLECentralManager shareManager].devices = nil;
    [[GHBLECentralManager shareManager] removeCalibrateData];
    [GHBLECentralManager shareManager].calibrateArray = nil;
    [GHBLECentralManager shareManager].calculateString = nil;
}


- (void)registerCell
{
    [self.tableView registerClass:[CalibrateCell class] forCellReuseIdentifier:@"CalibrateCell"];
}


#pragma  - TableVew datasoure

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[GHBLECentralManager shareManager].testArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CalibrateCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CalibrateCell"];

    [cell bindData:[GHBLECentralManager shareManager].testArray[indexPath.row]];

    
    return cell;
}

#pragma  - TableView delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 64.0f;
}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)writeGB:(id)sender {
    
    if (_gTextField.text.length <= 0 || _bTextField.text.length <= 0)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"输入不能为空"
                                                        message:nil
                                                       delegate:nil
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil, nil];
        [alert show];
    }
    long long weightG = [_gTextField.text longLongValue];
    long long weightB = [_bTextField.text longLongValue];
    
    NSData *dataG = [NSData dataWithBytes:&weightG length:4];
    
    NSData *dataB = [NSData dataWithBytes:&weightB length:4];
    
    
    [[GHBLECentralManager shareManager] writeData:dataG withfirstCmd:0X1A secondCmd:0X1B thirdCmd:0X1C forthCmd:0X1D];
    
    [[GHBLECentralManager shareManager] writeData:dataB withfirstCmd:0X1E secondCmd:0X1F thirdCmd:0X20 forthCmd:0X21];
    
    [GHBLECentralManager shareManager].writeGB = 1;
    
}

- (IBAction)startCalibrate:(id)sender {
    
     _calibrateButton.enabled = NO;
    
    if ([[GHBLECentralManager shareManager].testArray count] <= 0) {
        NSString *titleString = [NSString stringWithFormat:@"从 0g 开始校准"];
        NSString *messgae = @"请将杯垫置为空载状态，CC将从 0g 开始校准";
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:titleString
                                                        message:messgae
                                                       delegate:nil
                                              cancelButtonTitle:@"我已经做好准备"
                                              otherButtonTitles:nil, nil];
        [alert.rac_buttonClickedSignal subscribeNext:^(NSNumber *buttonIndex) {
            switch ([buttonIndex integerValue]) {
                case 0:
                {
                    [GHBLECentralManager shareManager].calibrating = YES;
                    [[GHBLECentralManager shareManager] writeByte:0X1900 toCharacteristicUUID:0XFFFB];
                    [GHBLECentralManager shareManager].calibrateType = CalibrateNormal;
                    break;
                }
                    
                    
                default:
                    break;
            }
        }];
        [alert show];
    }
    else if ([[GHBLECentralManager shareManager].testArray count] > 0)
    {
        [self reCalibrateWithCalibratetype:CalibrateNormal];
    }
    
  
}

- (IBAction)blink:(id)sender {
    
    [[GHBLECentralManager shareManager] writeByte:0X0600 toCharacteristicUUID:0xFFFB];
}

- (IBAction)shut:(id)sender {
     [[GHBLECentralManager shareManager] writeByte:0X0400 toCharacteristicUUID:0xFFFB];
}

- (IBAction)delete:(id)sender {
    
    [[GHBLECentralManager shareManager] writeByte:0X1300 toCharacteristicUUID:0xFFFB];
    //[[GHBLECentralManager shareManager] scan];
}

- (IBAction)calibrateZero:(id)sender {
    
    _calibrateZeroButton.enabled = NO;

    if ([[GHBLECentralManager shareManager].testArray count] <= 0) {
        NSString *titleString = [NSString stringWithFormat:@"从 0g 开始校准"];
        NSString *messgae = @"请将杯垫置为空载状态，CC将从 0g 开始校准";
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:titleString
                                                        message:messgae
                                                       delegate:nil
                                              cancelButtonTitle:@"我已经做好准备"
                                              otherButtonTitles:nil, nil];
        [alert.rac_buttonClickedSignal subscribeNext:^(NSNumber *buttonIndex) {
            switch ([buttonIndex integerValue]) {
                case 0:
                {
                    [GHBLECentralManager shareManager].calibrating = YES;
                    [GHBLECentralManager shareManager].calibrateType = CalibrateZero;
                    [[GHBLECentralManager shareManager] writeByte:0X1900 toCharacteristicUUID:0XFFFB];
                    break;
                }
                    
                    
                default:
                    break;
            }
        }];
        [alert show];
    }
    else if ([[GHBLECentralManager shareManager].testArray count] > 0)
    {
        [self reCalibrateWithCalibratetype:CalibrateZero];
    }
    
}

- (IBAction)fastCalibrate:(UIButton *)sender {
    
    //[GHBLECentralManager shareManager].calibrateType = CalibrateFast;
    _fastCalibrateButton.enabled = NO;
    
    if ([[GHBLECentralManager shareManager].testArray count] <= 0) {
        NSString *titleString = [NSString stringWithFormat:@"从 0g 开始校准"];
        NSString *messgae = @"请将杯垫置为空载状态，CC将从 0g 开始校准";
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:titleString
                                                        message:messgae
                                                       delegate:nil
                                              cancelButtonTitle:@"我已经做好准备"
                                              otherButtonTitles:nil, nil];
        [alert.rac_buttonClickedSignal subscribeNext:^(NSNumber *buttonIndex) {
            switch ([buttonIndex integerValue]) {
                case 0:
                {
                    [GHBLECentralManager shareManager].calibrateType = CalibrateFast;
                    [GHBLECentralManager shareManager].calibrating = YES;
                    [[GHBLECentralManager shareManager] writeByte:0X1900 toCharacteristicUUID:0XFFFB];
                    break;
                }
                default:
                    break;
            }
        }];
        [alert show];
    }
    else if ([[GHBLECentralManager shareManager].testArray count] > 0)
    {
        [self reCalibrateWithCalibratetype:CalibrateFast];
    }
}

- (void)reCalibrateWithCalibratetype:(CalibrateType)type
{
    [GHBLECentralManager shareManager].calibrating = NO;
    
    NSString *titleString = [NSString stringWithFormat:@"确认重新校准吗？"];
    NSString *messgae = @"若确定重新校准，请将杯垫置为空载状态，CC将重新从 0g 开始校准";
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:titleString
                                                    message:messgae
                                                   delegate:nil
                                          cancelButtonTitle:@"取消"
                                          otherButtonTitles:@"重新校准", nil];
    [alert.rac_buttonClickedSignal subscribeNext:^(NSNumber *buttonIndex) {
        switch ([buttonIndex integerValue]) {
            case 0:
            {
                [GHBLECentralManager shareManager].calibrating = YES;
                [[GHBLECentralManager shareManager] writeByte:0X1900 toCharacteristicUUID:0XFFFB];
                break;
            }
            case 1:
            {
                [[GHBLECentralManager shareManager] removeCalibrateData];
                [GHBLECentralManager shareManager].calibrating = YES;
                [GHBLECentralManager shareManager].calibrateType = type;
                [[GHBLECentralManager shareManager] writeByte:0X1900 toCharacteristicUUID:0XFFFB];
                
                break;
            }
                
            default:
                break;
        }
    }];
    [alert show];
}
- (IBAction)tap:(UITapGestureRecognizer *)sender {
    
 
    [self makeKeyBoardMiss];
    
}

- (void)makeKeyBoardMiss
{
    for (id textField in [self.view subviews])
    {
        if ([textField isKindOfClass:[UITextField class]])
        {
            UITextField *theTextField = (UITextField*)textField;
            [theTextField resignFirstResponder];
        }
    }
}
@end
