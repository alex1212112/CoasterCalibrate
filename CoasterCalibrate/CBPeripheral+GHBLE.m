//
//  CBPeripheral+GHBLE.m
//  Coaster
//
//  Created by Ren Guohua on 14-9-22.
//  Copyright (c) 2014年 ghren. All rights reserved.
//

#import "CBPeripheral+GHBLE.h"
#import <objc/runtime.h>

static char discoverRSSIKey;
static char deviceIdKey;
@implementation CBPeripheral (GHBLE)

- (void)setDiscoverRSSI:(NSNumber *)discoverRSSI
{
    objc_setAssociatedObject (self,&discoverRSSIKey,discoverRSSI,OBJC_ASSOCIATION_RETAIN);
}

- (NSNumber *)discoverRSSI
{
    return (id)objc_getAssociatedObject(self, &discoverRSSIKey);
}


- (void)setDeviceId:(NSString *)deviceId
{
    objc_setAssociatedObject (self,&deviceIdKey,deviceId,OBJC_ASSOCIATION_RETAIN);
}

- (NSString *)deviceId
{
    return (id)objc_getAssociatedObject(self, &deviceIdKey);
}

@end
