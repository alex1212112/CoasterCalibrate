//
//  GHCTool.h
//  CoasterCalibrate
//
//  Created by Ren Guohua on 14-10-9.
//  Copyright (c) 2014年 Nevermore. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GHCTool : NSObject


+ (NSDictionary *)parseData:(NSData *)data;


+ (NSArray *)averagrArrayWithCalibrateXArray:(NSArray *)array;

+ (NSArray *)weightWithADArray:(NSArray *)array GValue:(NSNumber *)g BValue:(NSNumber *)b;


@end
