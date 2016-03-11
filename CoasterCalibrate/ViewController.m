//
//  ViewController.m
//  CoasterCalibrate
//
//  Created by Ren Guohua on 14-9-23.
//  Copyright (c) 2014年 Nevermore. All rights reserved.
//

#import "ViewController.h"
#import "GHBLECentralManager.h"
#import "DeviceCell.h"
#import <ReactiveCocoa/ReactiveCocoa.h>


@interface ViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (strong, nonatomic) IBOutlet UITableView *tableView;
- (IBAction)openTest:(UIBarButtonItem *)sender;
- (IBAction)openCoaster:(id)sender;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self registerCell];
    [RACObserve([GHBLECentralManager shareManager], devices) subscribeNext:^(id x) {
        [_tableView reloadData];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)registerCell
{
    //[self.tableView registerNib:[UINib nibWithNibName:@"DeviceCell" bundle:nil] forCellReuseIdentifier:@"DeviceCell"];
    [self.tableView registerClass:[DeviceCell class] forCellReuseIdentifier:@"DeviceCell"];
}



#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    return [[GHBLECentralManager shareManager].devices count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [NSString stringWithFormat:@"设备%ld",(long)section];
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DeviceCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DeviceCell" forIndexPath:indexPath];
    
    CBPeripheral *peripheral = [GHBLECentralManager shareManager].devices[indexPath.section];
    
    [cell bindData:peripheral withType:indexPath.row];
    return cell;
}




#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CBPeripheral *peripheral = [GHBLECentralManager shareManager].devices[indexPath.section];
    
    NSLog(@"choose == %@",[GHBLECentralManager shareManager].choosedPeripheral.description);
    if([GHBLECentralManager shareManager].choosedPeripheral.state == CBPeripheralStateConnecting)
    {
        NSLog(@"ing");
        [[GHBLECentralManager shareManager].centralManager cancelPeripheralConnection:[GHBLECentralManager shareManager].choosedPeripheral];
        [GHBLECentralManager shareManager].choosedPeripheral = peripheral;
        [[GHBLECentralManager shareManager] connetPeripheral:peripheral Options:nil];
    }
    else if ([GHBLECentralManager shareManager].choosedPeripheral.state == CBPeripheralStateDisconnected)
    {
        NSLog(@"discon");
        [GHBLECentralManager shareManager].choosedPeripheral = peripheral;
        [[GHBLECentralManager shareManager] connetPeripheral:peripheral Options:nil];
    }
    
    
    [self performSegueWithIdentifier:@"DeviceToCalibrate" sender:nil];
    
   // BLETestTableViewController *testVC = [[BLETestTableViewController alloc] init];
    //[self.navigationController pushViewController:testVC animated:YES];
}


- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{

    return 44.0f;
}


/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */


- (IBAction)openTest:(UIBarButtonItem *)sender {
    
   // NSLog(@"open");
//    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"tencent1103468026://?accesstoken=319F6CB0279C1430C5E9F182B0C7C1D1&openid=3857B6F97C4D8675E2AB6BFCD6B20106&accesstokenexpiretime=242342343&from=qqhealth"]];
    
    [GHBLECentralManager shareManager].devices = nil;
}

- (IBAction)openCoaster:(id)sender {
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"tencent1103468026://?accesstoken=319F6CB0279C1430C5E9F182B0C7C1D1&openid=3857B6F97C4D8675E2AB6BFCD6B20106&accesstokenexpiretime=242342343&from=qqhealth"]];
}
@end
