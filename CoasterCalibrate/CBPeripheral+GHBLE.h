//
//  CBPeripheral+GHBLE.h
//  Coaster
//
//  Created by Ren Guohua on 14-9-22.
//  Copyright (c) 2014年 ghren. All rights reserved.
//

#import <CoreBluetooth/CoreBluetooth.h>

@interface CBPeripheral (GHBLE)

@property (nonatomic, strong) NSNumber *discoverRSSI;
@property (nonatomic, strong) NSString *deviceId;

@end
