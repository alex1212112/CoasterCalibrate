//
//  GHBLECentralManager.h
//  Coaster
//
//  Created by Ren Guohua on 14-8-9.
//  Copyright (c) 2014年 ghren. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

typedef NS_ENUM(NSInteger, CalibrateType)
{
    CalibrateNormal,
    CalibrateZero,
    CalibrateFast
};

typedef  void(^HandleCharacter)();

@interface GHBLECentralManager : NSObject
{
    HandleCharacter handleAfterDiscoverCharacter;
}

@property (strong, nonatomic) CBCentralManager      *centralManager;
@property (strong, nonatomic) CBPeripheral          *discoveredPeripheral;
@property (strong, nonatomic) CBPeripheral          *choosedPeripheral;

@property (nonatomic, strong) NSArray *devices;
@property (nonatomic, assign) BOOL needSendWeightACK;
@property (nonatomic, strong) NSMutableArray *calibrateW;
@property (nonatomic, strong) NSMutableArray *calibrateX;
@property (nonatomic, strong) NSArray *calibrateArray;
@property (nonatomic, strong) NSArray *testArray;
@property (nonatomic, assign,getter = isCalibrating) BOOL calibrating;
@property (nonatomic, assign) NSInteger reCalibrate;
@property (nonatomic, strong) NSString *calculateString;
@property (nonatomic, assign) NSInteger writeGB;
@property (nonatomic, assign) CalibrateType calibrateType;
@property (nonatomic, assign) BOOL lastTest0;

@property (nonatomic, strong) NSNumber *weightG;
@property (nonatomic, strong) NSNumber *weightB;

+ (instancetype)shareManager;

- (void)setupCentralManager;

- (void)scan;

- (void)stopScan;

- (void)writeByte:(UInt16)byte toCharacteristicUUID:(int)characteristicUUID;

- (void)configWithDiscoverCharacter:(HandleCharacter)handleEvent;

- (void)startBLE;

- (void)connetPeripheral:(CBPeripheral*)peripheral Options:(NSDictionary*)options;

- (void)removeCalibrateData;

- (void)writeData:(NSData*)data withfirstCmd:(Byte)cmd1 secondCmd:(Byte)cmd2 thirdCmd:(Byte)cmd3 forthCmd:(Byte)cmd4;


@end
