//
//  GHBLECentralManager.m
//  Coaster
//
//  Created by Ren Guohua on 14-8-9.
//  Copyright (c) 2014年 ghren. All rights reserved.
//

#import "GHBLECentralManager.h"
#import "CBPeripheral+GHBLE.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "GHTool.h"
#import "GHCTool.h"
#import "GHMacro.h"

@interface GHBLECentralManager ()<CBCentralManagerDelegate, CBPeripheralDelegate>
{
     NSInteger receiveBindAckCount;
}

@end

@implementation GHBLECentralManager

static GHBLECentralManager *instance = nil;

+ (instancetype)shareManager{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    
    return instance;
}

- (id)init
{
    if (self = [super init])
    {
        [self startBLE];
    }
    return self;
}

- (void)setupCentralManager
{
    _centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    
}


/** Scan for peripherals - specifically for our service's 128bit CBUUID
 */
- (void)scan
{
    [self.centralManager scanForPeripheralsWithServices:nil
                                                options:@{ CBCentralManagerScanOptionAllowDuplicatesKey : @YES }];
    
    NSLog(@"Scanning started");
}


#pragma mark - Central Methods

- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
   
    if (central.state != CBCentralManagerStatePoweredOn) {
        NSLog(@"unsupport!!!");
        return;
    }
    else
    {
        [self scan];
    }
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI {
    
    
    
    NSString *deviceId = advertisementData[@"kCBAdvDataLocalName"];
    peripheral.deviceId = [deviceId substringToIndex:deviceId.length - 1 ];
    
    peripheral.discoverRSSI = RSSI;
    NSMutableArray *mutableArray = [NSMutableArray arrayWithArray:_devices];
    if (!mutableArray)
    {
        mutableArray = [NSMutableArray array];
        [mutableArray addObject:peripheral];
    }
    else
    {
        if (![_devices containsObject:peripheral])
        {
            [mutableArray addObject:peripheral];
        }
    }
    
    [self setValue:[NSArray arrayWithArray:mutableArray] forKey:@"devices"];
    
}


- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    
    NSLog(@"disconnect!!!");
    self.lastTest0 = NO;
    
    [self setValue:nil forKey:@"discoveredPeripheral"];
    [self setValue:nil forKey:@"devices"];
    
    [self scan];
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {

    NSLog(@"connect succesful");
    [self stopScan];
//    NSMutableArray *mutableArray = [NSMutableArray arrayWithArray:_devices];
//    [self setValue:[NSArray arrayWithArray:mutableArray] forKey:@"devices"];
    self.discoveredPeripheral = peripheral;
    [peripheral setDelegate:self];
    [peripheral discoverServices:nil];

}

- (void)peripheral:(CBPeripheral *)aPeripheral didDiscoverServices:(NSError *)error {
    
    if (error) {
       
        NSLog(@"error == %@",error.description);
        return;
    }
    
    for (CBService *service in aPeripheral.services) {
        
        [aPeripheral discoverCharacteristics:nil forService:service];
    }
}


- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    if (error) {

        return;
    }
    
    for (CBCharacteristic *characteristic in service.characteristics) {
        {
            [peripheral setNotifyValue:YES forCharacteristic:characteristic];
            
            
            if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"0xFFFB"]])
            {
                if (handleAfterDiscoverCharacter)
                {
                    handleAfterDiscoverCharacter();
                }
            }
        }
    }
}


- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    
    if (error)
    {
        return;
    }

}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error) {
        return;
    }
    
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"0xFFFC"]])
    {
        [self handleWeightData:characteristic.value];
    }
    else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"0xFFFA"]])
    {
       // NSString *string = [[NSString alloc] initWithData:characteristic.value encoding:NSASCIIStringEncoding];
 
    }
    else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"0xFFF9"]])
    {
        
        [self handleACK:characteristic.value];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    //NSLog(@"Did write characteristic value : %@ with ID %@", characteristic.description, characteristic.UUID);
    
    if (error) {
      //  NSLog(@"Error discovering characteristics: %@", [error localizedDescription]);
        NSLog(@"Error discovering characteristics: %@", [error description]);

        return;
    }
}


- (void)configWithDiscoverCharacter:(HandleCharacter)handleEvent
{
    handleAfterDiscoverCharacter = handleEvent;
}

- (void)writeByte:(UInt16)byte toCharacteristicUUID:(int)characteristicUUID
{
    UInt16 num = [self swap:byte];
    NSData *data = [[NSData alloc] initWithBytes:&num length:2];

    [self writeValue:0xFFF0 characteristicUUID:0xFFFB p:self.discoveredPeripheral data:data];
}

- (void) writeValue:(int)serviceUUID characteristicUUID:(int)characteristicUUID p:(CBPeripheral *)p data:(NSData *)data {
    UInt16 s = [self swap:serviceUUID];
    UInt16 c = [self swap:characteristicUUID];
    NSData *sd = [[NSData alloc] initWithBytes:(char *)&s length:2];
    NSData *cd = [[NSData alloc] initWithBytes:(char *)&c length:2];
    
    CBUUID *su = [CBUUID UUIDWithData:sd];
    CBUUID *cu = [CBUUID UUIDWithData:cd];

    CBService *service = [self findServiceFromUUID:su p:p];

    if (!service) {
  
        return;
    }
    CBCharacteristic *characteristic = [self findCharacteristicFromUUID:cu service:service];
    if (!characteristic) {

        return;
    }
    [p writeValue:data forCharacteristic:characteristic type:CBCharacteristicWriteWithResponse];
}

-(CBService *) findServiceFromUUID:(CBUUID *)UUID p:(CBPeripheral *)p {
    for(int i = 0; i < p.services.count; i++) {
        CBService *s = [p.services objectAtIndex:i];
        if ([self compareCBUUID:s.UUID UUID2:UUID]) return s;
    }
    return nil; //Service not found on this peripheral
}

-(CBCharacteristic *) findCharacteristicFromUUID:(CBUUID *)UUID service:(CBService*)service {
    for(int i=0; i < service.characteristics.count; i++) {
        CBCharacteristic *c = [service.characteristics objectAtIndex:i];
        if ([self compareCBUUID:c.UUID UUID2:UUID]) return c;
    }
    return nil; //Characteristic not found on this service
}


-(int) compareCBUUID:(CBUUID *) UUID1 UUID2:(CBUUID *)UUID2 {
    char b1[16];
    char b2[16];
    [UUID1.data getBytes:b1 length:2];
    [UUID2.data getBytes:b2 length:2];
    if (memcmp(b1, b2, UUID1.data.length) == 0)return 1;
    else return 0;
}

-(UInt16) swap:(UInt16)s {
    UInt16 temp = s << 8;
    temp |= (s >> 8);
    return temp;
}

-(const char *) CBUUIDToString:(CBUUID *) UUID {
    return [[UUID.data description] cStringUsingEncoding:NSStringEncodingConversionAllowLossy];
}

-(const char *) UUIDToString:(CFUUIDRef)UUID {
    if (!UUID) return "NULL";
    CFStringRef s = CFUUIDCreateString(NULL, UUID);
    return CFStringGetCStringPtr(s, 0);
    
}




-(void) readValue: (int)serviceUUID characteristicUUID:(int)characteristicUUID p:(CBPeripheral *)p {
    UInt16 s = [self swap:serviceUUID];
    UInt16 c = [self swap:characteristicUUID];
    NSData *sd = [[NSData alloc] initWithBytes:(char *)&s length:2];
    NSData *cd = [[NSData alloc] initWithBytes:(char *)&c length:2];
    CBUUID *su = [CBUUID UUIDWithData:sd];
    CBUUID *cu = [CBUUID UUIDWithData:cd];
    CBService *service = [self findServiceFromUUID:su p:p];
    if (!service) {
        //printf("Could not find service with UUID %s on peripheral with UUID %s\r\n",[self CBUUIDToString:su],[self UUIDToString:p.UUID]);
        return;
    }
    CBCharacteristic *characteristic = [self findCharacteristicFromUUID:cu service:service];
    if (!characteristic) {
       // printf("Could not find characteristic with UUID %s on service with UUID %s on peripheral with UUID %s\r\n",[self CBUUIDToString:cu],[self CBUUIDToString:su],[self UUIDToString:p.UUID]);
        return;
    }
    [p readValueForCharacteristic:characteristic];
}



- (void)startBLE
{

    [self configWithDiscoverCharacter:^ {
        
        long long uid = 0XAABBCCDD;
        
        [self bindCoasterToUser:uid];
        
        }];
    
    [self setupCentralManager];
  
}

- (void)connetPeripheral:(CBPeripheral*)peripheral Options:(NSDictionary*)options
{
    if (_centralManager)
    {
        if (_discoveredPeripheral.state == CBPeripheralStateDisconnected)
        {
            [_centralManager connectPeripheral:peripheral options:options];
        }
    }
}

- (void)stopScan
{
    [_centralManager stopScan];
}

- (void)handleACK:(NSData*)data
{
    UInt16 *bindMessage = (UInt16*)[data bytes];
    
    NSLog(@"bindMessage == %lX",(long)*bindMessage);
    
    if (*bindMessage == [self swap:0x0201])
    {
        long long uid = 0XAABBCCDD;
        [self matchCoasterToUser:uid];
        return;
    }
    
     if (*bindMessage == [self swap:0x0204])   //匹配成功
    {
        [self setHighTransportSpeed];
        return;
    }
    
    if (*bindMessage == [self swap:0x0203])   //绑定失败
    {
        if (receiveBindAckCount == 0)
        {
            UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"绑定失败" message:@"请解除绑定后重新连接" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
            alert.alertViewStyle=UIAlertViewStyleDefault;
            [alert show];
        }
        receiveBindAckCount ++;
        if (receiveBindAckCount == 4)
        {
            receiveBindAckCount = 0;
        }
        if (_choosedPeripheral)
        {
            [self.centralManager cancelPeripheralConnection:_choosedPeripheral];
        }
        return;
    }
    
    
    if (*bindMessage == [self swap:0x0206])         //校准成功
    {
        
        if (self.writeGB == 1)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"GB写入成功"
                                                            message:nil
                                                           delegate:nil
                                                  cancelButtonTitle:@"确定"
                                                  otherButtonTitles:nil, nil];
            [alert show];
            
            self.writeGB = 0;
            return;
        }
        else
        {
            NSArray *result = self.calibrateArray;
            NSString *titleString = [NSString stringWithFormat:@"校准结束，G值为:%@,B值为:%@,请把杯垫置为空载状态",[result[0] stringValue],[result[1] stringValue]];
            
            NSString *message;
            
            if ([GHBLECentralManager shareManager].calibrateType == CalibrateNormal)
            {
                NSArray *averageADArray = [GHCTool averagrArrayWithCalibrateXArray:_calibrateX];
                NSArray *weightArray = [GHCTool weightWithADArray:averageADArray GValue:self.weightG BValue:self.weightB];
                
                if ([weightArray count] == 6)
                {
                    message = [NSString stringWithFormat:@"实际重量－计算重量\n0－%@\n100－%@\n200－%@\n300－%@\n400－%@\n500－%@",[weightArray[0] description],[weightArray[1] description],[weightArray[2] description],[weightArray[3] description],[weightArray[4] description],[weightArray[5] description]];
                }
            }
            else if ([GHBLECentralManager shareManager].calibrateType == CalibrateFast)
            {
                NSArray *averageADArray = _calibrateX;
                NSArray *weightArray = [GHCTool weightWithADArray:averageADArray GValue:self.weightG BValue:self.weightB];
                
                if ([weightArray count] == 3)
                {
                    message = [NSString stringWithFormat:@"实际重量－计算重量\n0－%@\n100－%@\n500－%@",[weightArray[0] description],[weightArray[1] description],[weightArray[2] description]];
                }
            }
            
            
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:titleString
                                                            message:message
                                                           delegate:nil
                                                  cancelButtonTitle:@"确定"
                                                  otherButtonTitles:nil, nil];
            
            [alert.rac_buttonClickedSignal subscribeNext:^(NSNumber *buttonIndex) {
                switch ([buttonIndex integerValue]) {
                    case 0:
                    {
                        [self testLastZero];
                        break;
                    }
                        
                    default:
                        break;
                }
            }];
            [alert show];
        }
        return;
    }
}


- (void)setHighTransportSpeed
{
    [GHTool runMethodAfterDelay:0.5f withMethod:^{
        
        [self writeByte:0X2B00 toCharacteristicUUID:0xFFFB];
        
        [GHTool runMethodAfterDelay:0.5f withMethod:^{
            
            [self writeByte:0X2A00 toCharacteristicUUID:0xFFFB];
        }];
        
    }];

}

- (void)testLastZero
{
    self.lastTest0 = YES;
    [self writeByte:0X1900 toCharacteristicUUID:0XFFFB];
}


- (void)handleCalibrateWeight:(NSInteger)sumWeight
{
    NSLog(@"sumWeight === %ld",(long)sumWeight);
    
    
    if (!self.isCalibrating)
    {
        return;
    }

    
    if (sumWeight <= 10 || sumWeight >= 2040)
    {
        
        NSString *string = [NSString stringWithFormat:@"校准值为%ld,不在正常范围之内",(long)sumWeight];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"校准错误"
                                                        message:string
                                                       delegate:nil
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    
    
    if (!_calibrateX)
    {
        _calibrateX = [NSMutableArray array];
    }
    if (!_calibrateW)
    {
        _calibrateW = [NSMutableArray array];
    }
    
    [_calibrateX addObject:@(sumWeight)];

    

    if (_calibrateType == CalibrateZero)
    {
        [_calibrateW addObject:@0];
        if ([_calibrateX count] == 10)
        {
            [self calibrateResultWithZero];
        }
        else if([_calibrateX count] < 10)
        {
            [self writeByte:0X1900 toCharacteristicUUID:0XFFFB];
        }
    }
    else if (_calibrateType == CalibrateNormal)
    {
        if ([_calibrateX count] <= 10 )
        {
            [_calibrateW addObject:@0];
            
            if ([_calibrateX count] == 10)
            {
                [self showAlertWithWeight:100];
            }
            else
            {
                [GHTool runMethodAfterDelay:0.5f withMethod:^{
                    
                    [self writeByte:0X1900 toCharacteristicUUID:0XFFFB];
                }];
            }
            
        }
        else if ([_calibrateX count] <= 20)
        {
            [_calibrateW addObject:@(100 * 1000)];
            if ([_calibrateX count] == 20)
            {
                [self showAlertWithWeight:200];
            }
            else
            {
                [GHTool runMethodAfterDelay:0.5f withMethod:^{
                    
                    [self writeByte:0X1900 toCharacteristicUUID:0XFFFB];
                }];
            }
        }
        else if ([_calibrateX count] <= 30)
        {
            [_calibrateW addObject:@(200 * 1000)];
            if ([_calibrateX count] == 30)
            {
                [self showAlertWithWeight:300];
            }
            else
            {
                [GHTool runMethodAfterDelay:0.5f withMethod:^{
                    
                    [self writeByte:0X1900 toCharacteristicUUID:0XFFFB];
                }];
            }
        }
        else if ([_calibrateX count] <= 40)
        {
            [_calibrateW addObject:@(300 * 1000)];
            if ([_calibrateX count] == 40)
            {
                [self showAlertWithWeight:400];
            }
            else
            {
                [GHTool runMethodAfterDelay:0.5f withMethod:^{
                    
                    [self writeByte:0X1900 toCharacteristicUUID:0XFFFB];
                }];
            }
        }
        else if ([_calibrateX count] <= 50)
        {
            [_calibrateW addObject:@(400 * 1000)];
            if ([_calibrateX count] == 50)
            {
                [self showAlertWithWeight:500];
            }
            else
            {
                [GHTool runMethodAfterDelay:0.5f withMethod:^{
                    
                    [self writeByte:0X1900 toCharacteristicUUID:0XFFFB];
                }];
            }
        }
        else if ([_calibrateX count] <= 60)
        {
            [_calibrateW addObject:@(500 * 1000)];
            if ([_calibrateX count] == 60)
            {
                [self calibrateResult];
            }
            else
            {
                [GHTool runMethodAfterDelay:0.5f withMethod:^{
                    
                    [self writeByte:0X1900 toCharacteristicUUID:0XFFFB];
                }];
            }
        }
    }
    else if (_calibrateType == CalibrateFast)
    {
        if ([_calibrateX count] == 1 )
        {
            [_calibrateW addObject:@0];

            [self showAlertWithWeight:100];
        }
        else if ([_calibrateX count] == 2)
        {
            [_calibrateW addObject:@(100 * 1000)];
            
            [self showAlertWithWeight:500];
        }
        else if ([_calibrateX count] == 3 )
        {
            [_calibrateW addObject:@(500 * 1000)];
            
            [self calibrateResult];
        }
    }
    
    NSMutableArray *mutableArray = [NSMutableArray arrayWithArray:_testArray];
    if (!mutableArray)
    {
        mutableArray = [NSMutableArray array];
    }
    
    NSNumber *xNumber = [_calibrateX lastObject];
    NSNumber *wNumber = [_calibrateW lastObject];
    NSDictionary *dic = @{@"x" : xNumber, @"w" : wNumber, @"n" : @([_calibrateX count] -1 )};
    
    [mutableArray addObject:dic];
    
    NSArray *array = [NSArray arrayWithArray:mutableArray];
    
    [self setValue:array forKey:@"testArray"];
    
   // NSLog(@"testArray == %@",self.testArray.description);
    
}


- (void)writeData:(NSData*)data withfirstCmd:(Byte)cmd1 secondCmd:(Byte)cmd2 thirdCmd:(Byte)cmd3 forthCmd:(Byte)cmd4
{
    NSData *data1 = [data subdataWithRange:(NSRange){0,1}];
    NSData *data2 = [data subdataWithRange:(NSRange){1,1}];
    
    NSData *data3 = [data subdataWithRange:(NSRange){2,1}];
    NSData *data4 = [data subdataWithRange:(NSRange){3,1}];
    
    
    
    UInt16 number1 = [GHTool spliceInt16WithFirstData:data1 secondData:[NSData dataWithBytes:&cmd1 length:1]];
    
    UInt16 number2 = [GHTool spliceInt16WithFirstData:data2 secondData:[NSData dataWithBytes:&cmd2 length:1]];
    
    UInt16 number3 = [GHTool spliceInt16WithFirstData:data3 secondData:[NSData dataWithBytes:&cmd3 length:1]];
    
    UInt16 number4 = [GHTool spliceInt16WithFirstData:data4 secondData:[NSData dataWithBytes:&cmd4 length:1]];
    
    dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC);
    
    dispatch_after(time, dispatch_get_main_queue(), ^{
        
        [self writeByte:number1 toCharacteristicUUID:0xFFFB];
        
        dispatch_after(time, dispatch_get_main_queue(), ^{
            
            [self writeByte:number2 toCharacteristicUUID:0xFFFB];
            
            dispatch_after(time, dispatch_get_main_queue(), ^{
                
                [self writeByte:number3 toCharacteristicUUID:0xFFFB];
                
                dispatch_after(time, dispatch_get_main_queue(), ^{
                    
                    [self writeByte:number4 toCharacteristicUUID:0xFFFB];
                    NSLog(@"number4 === %lX",(long)number4);
                });
                
            });
            
        });
    });
}


- (void)calibrateResult
{
    _calibrating = NO;
    NSArray *result  = [self calibrateWithXArray:_calibrateX wArray:_calibrateW];
    self.calibrateArray = result;
    
    NSNumber *G = result[0];
    NSNumber *B = result[1];
    
    long long weightG = [G intValue];
    long long weightB = [B intValue];
    
    self.weightG = G;
    self.weightB = B;
    NSData *dataG = [NSData dataWithBytes:&weightG length:4];
    
    NSData *dataB = [NSData dataWithBytes:&weightB length:4];
    
    
    [self writeData:dataG withfirstCmd:0X1A secondCmd:0X1B thirdCmd:0X1C forthCmd:0X1D];
    [self writeData:dataB withfirstCmd:0X1E secondCmd:0X1F thirdCmd:0X20 forthCmd:0X21];


    
}


- (void)calibrateResultWithZero
{
    _calibrating = NO;
    
    NSLog(@"avg == %f",[[_calibrateX valueForKeyPath:@"@avg.self"] floatValue]);
    
   // NSNumber *bValue = @(- [kCSTGValue floatValue] * [[_calibrateX valueForKeyPath:@"@avg.self"] floatValue]);
    NSString *string = [NSString stringWithFormat:@"%f * %f",- [kCSTGValue floatValue],[[_calibrateX valueForKeyPath:@"@avg.self"] floatValue]];
    
    NSExpression *express = [NSExpression expressionWithFormat:string];
    
    NSNumber *bValue = [express expressionValueWithObject:nil context:nil];
    
    
    [self setValue:string forKeyPath:@"calculateString"];
    
    
    NSArray *result  = @[@([kCSTGValue floatValue]),bValue];
    self.calibrateArray = result;
    
    NSNumber *G = result[0] ;
    NSNumber *B = result[1];
    
    long long weightG = [G intValue];
    long long weightB = [B intValue];
    
    self.weightG = G;
    self.weightB = B;
    
    NSData *dataG = [NSData dataWithBytes:&weightG length:4];
    
    NSData *dataB = [NSData dataWithBytes:&weightB length:4];
    
    
    [self writeData:dataG withfirstCmd:0X1A secondCmd:0X1B thirdCmd:0X1C forthCmd:0X1D];
    [self writeData:dataB withfirstCmd:0X1E secondCmd:0X1F thirdCmd:0X20 forthCmd:0X21];

}

- (NSArray *)calibrateWithXArray:(NSMutableArray *)x wArray:(NSMutableArray *)w
{

    long long sumX = 0;
    long long sumX2 = 0;
    
    long long sumW = 0;
    long long sumXW = 0;
    
    NSMutableArray *xArray = x;
    NSMutableArray *wArray = w;
    
    for (NSInteger n = 0; n < [xArray  count] ; n++ )
    {
        sumX = (long long)sumX + (long long)[xArray[n] integerValue];
        sumX2 = (long long)sumX2 + (long long)[xArray[n] integerValue] * (long long)[xArray[n] integerValue];
        sumXW = (long long)sumXW + (long long)[xArray[n] integerValue] * ( long long)[wArray[n] integerValue];
        sumW = (long long)sumW + (long long)[wArray[n] integerValue];
    }
    
    //NSInteger matDet = [xArray count] * sumX2 - sumX * sumX;
    
    long  long number1 = [xArray count] * sumX2;
    long  long number2 = sumX * sumX;
    
    long  long matDet = number1 - number2;
    
    float G = (float)(([xArray count] * (long long)sumXW  - (long long)sumX * (long)sumW) / (long)matDet);
    float B = (float)(( - (long long)sumX * (long long)sumXW + (long long)sumX2 * (long long)sumW) / (long long)matDet);
    
    NSString *string =   [NSString stringWithFormat:@"sumX  == %lld\nsumX2 == %lld\nsumXW == %lld\nsumW == %lld\nmatDet == %lld\nG:(60 * sumXW  - sumX * sumW) / matDet\nG:(%lld * %lld - %lld * %lld) / %lld = %f\nB:( - sumX * sumXW + sumX2 * sumW) / matDet\nB:(-%lld * %lld + %lld * %lld) / %lld = %f",(long long)sumX,(long long)sumX2,(long long)sumXW,(long long)sumW,(long long)matDet,(long long)[xArray count],(long long)sumXW,(long long)sumX,(long long)sumW,(long long)matDet,G,(long long)sumX,(long long)sumXW,(long long)sumX2,(long long)sumW,(long long)matDet,B];
    
    [self setValue:string forKeyPath:@"calculateString"];
    
    
    return @[@(G),@(B)];
}


- (void)showAlertWithWeight:(NSInteger)weight
{
    
    self.calibrating = NO;
    NSString *titleString = [NSString stringWithFormat:@"请先换上%ld克重量，再点击确定",(long)weight];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:titleString
                                                    message:nil
                                                   delegate:nil
                                          cancelButtonTitle:@"确定"
                                          otherButtonTitles:nil, nil];
    [alert.rac_buttonClickedSignal subscribeNext:^(NSNumber *buttonIndex) {
        switch ([buttonIndex integerValue]) {
            case 0:
            {
                self.calibrating = YES;
                [self writeByte:0X1900 toCharacteristicUUID:0XFFFB];
                break;
            }
                
            default:
                break;
        }
    }];
    [alert show];
}

- (void)handleWeightData:(NSData*)data
{
    
    if (self.lastTest0)
    {
        self.lastTest0 = NO;
        NSDictionary *dic = [GHCTool parseData:data];
        NSLog(@"dic == %@",dic.description);
        
        NSInteger weight = [dic[@"weight"] integerValue] / 1000;
        UIAlertView *alert;
        if (weight > 30 || weight < -30)
        {
            NSString *message = [NSString stringWithFormat:@"空载时重量为%ldg",(long)weight];
            
            alert = [[UIAlertView alloc] initWithTitle:@"残次品-空载重量不合格"
                                                            message:message
                                                           delegate:nil
                                                  cancelButtonTitle:@"确定"
                                                  otherButtonTitles:nil, nil];
        }
        else if ([self.weightG integerValue] > 4800 * 1.2 || [self.weightG integerValue] < 4800 * 0.8)
        {
            
            NSString *message = [NSString stringWithFormat:@"G值为%ld",(long)[self.weightG  integerValue]];
            
            alert = [[UIAlertView alloc] initWithTitle:@"残次品-G值不合格"
                                               message:message
                                              delegate:nil
                                     cancelButtonTitle:@"确定"
                                     otherButtonTitles:nil, nil];
        }
        else
        {
            NSString *message = [NSString stringWithFormat:@"空载时重量为%ldg,G值为%ld",(long)weight,(long)[self.weightG integerValue]];
            
            alert = [[UIAlertView alloc] initWithTitle:@"测试通过"
                                                            message:message
                                                           delegate:nil
                                                  cancelButtonTitle:@"确定"
                                                  otherButtonTitles:nil, nil];
        }
        
        [alert.rac_buttonClickedSignal subscribeNext:^(NSNumber *buttonIndex) {
            switch ([buttonIndex integerValue]) {
                case 0:
                {
                    [GHTool runMethodAfterDelay:0.5f withMethod:^{
                        
                        [self writeByte:0X1300 toCharacteristicUUID:0xFFFB];
                    }];
                    break;
                }
                    
                default:
                    break;
            }
        }];
        [alert show];
        
        return;
    }
    
    NSLog(@"data ==== %@",data);
   // NSData *data0t3 = [data subdataWithRange:(NSRange){0,4}];
    NSData *data4t7 = [data subdataWithRange:(NSRange){4,4}];
    NSData *data8t11 = [data subdataWithRange:(NSRange){8,4}];
    
    NSData *data12 = [data subdataWithRange:(NSRange){12,1}];
    
   // SInt32 *currentTime = (SInt32 *)[data0t3 bytes];
    SInt32 *preWeight = (SInt32 *)[data4t7 bytes];
    SInt32 *lastWeight = (SInt32 *)[data8t11 bytes];
    
    NSLog(@"pre ==== %ld",(long)*preWeight);
    NSLog(@"last ==== %ld",(long)*lastWeight);
    
    NSInteger flag =  *(Byte *)[data12 bytes];
    
    if (flag == 0)
    {
        
    }
    else if (flag == 1)
    {
        
        NSInteger sumWeight = *preWeight + *lastWeight;
        
        [self handleCalibrateWeight:sumWeight];
    }
    else if (flag == 2)
    {
        
    }
}


- (void)removeCalibrateData
{
    [_calibrateX removeAllObjects];
    [_calibrateW removeAllObjects];
    _testArray = nil;
}


- (void)bindCoasterToUser:(long long)uid
{
    NSLog(@"SendBind!!!");
 
    
    NSData *uidData = [NSData dataWithBytes:&uid length:4];
    
    [self writeData:uidData withfirstCmd:0X0B secondCmd:0X0C thirdCmd:0X0D forthCmd:0X0E];
}

- (void)matchCoasterToUser:(long long)uid
{
    NSData *uidData = [NSData dataWithBytes:&uid length:4];
    
    [self writeData:uidData withfirstCmd:0X0F secondCmd:0X10 thirdCmd:0X11 forthCmd:0X12];
}


@end
