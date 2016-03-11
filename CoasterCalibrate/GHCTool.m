//
//  GHCTool.m
//  CoasterCalibrate
//
//  Created by Ren Guohua on 14-10-9.
//  Copyright (c) 2014年 Nevermore. All rights reserved.
//

#import "GHCTool.h"
#import "GHTool.h"
#import "GHBLECentralManager.h"

@implementation GHCTool

+ (NSDictionary *)parseData:(NSData *)data
{
    
    NSData *data0t3 = [data subdataWithRange:(NSRange){0,4}];
    NSData *data4t7 = [data subdataWithRange:(NSRange){4,4}];
    NSData *data8t11 = [data subdataWithRange:(NSRange){8,4}];
    
    
    UInt32 *time = (UInt32 *)[data0t3 bytes];
    UInt32 *preWeight = (UInt32 *)[data4t7 bytes];
    UInt32 *lastWeight = (UInt32 *)[data8t11 bytes];
    
    NSInteger G = [[GHBLECentralManager shareManager].weightG integerValue];
    NSInteger B = [[GHBLECentralManager shareManager].weightB integerValue];
    
    NSInteger sumWeight = *preWeight + *lastWeight;
    
    NSInteger w;
    
//    NSLog(@"G==%ld,B==%ld",G,B);
//    NSLog(@"G1==%ld",G);
//    NSLog(@"B1==%ld",B);
    if (G == 0 || B == 0)
    {
        w = sumWeight * 6156 + (-6947463);
    }
    else
    {
        w = sumWeight * G + B;
    }
    
    NSLog(@"time == %ld", (long)*time);
    NSLog(@"x ======= %ld",(long)sumWeight);
    NSLog(@"w ======= %ld",(long)w);
    NSDate *date = [GHTool dateWithTimeStamp:*time];
    NSLog(@"***********************************");
    
    NSString *dateString = [GHTool stringFromDate:date withFormatString:@"yyyy-MM-dd HH:mm:ss"];
    
    NSLog(@"dateString === %@",dateString);
    return @{@"datetime":dateString,@"weight":[NSNumber numberWithInteger:w]};
}


+ (NSArray *)averagrArrayWithCalibrateXArray:(NSArray *)array
{

  //  NSMutableArray *mutableArray = [NSMutableArray array];
    NSMutableArray *resultArray = [NSMutableArray array];
   __block NSInteger sum = 0;
    
    [array enumerateObjectsUsingBlock:^(NSNumber *x, NSUInteger idx, BOOL *stop) {
        
        sum = sum + [x integerValue];
        if ((idx + 1) % 10 == 0)
        {
            [resultArray addObject: @(sum / 10)];
            sum = 0;  
        }
    }];
    
    return  [NSArray arrayWithArray:resultArray];
}



+ (NSArray *)weightWithADArray:(NSArray *)array GValue:(NSNumber *)g BValue:(NSNumber *)b
{
    
    NSLog(@"g === %@",g.description);
    NSLog(@"b === %@",b.description);
    
    NSMutableArray *mutableArray = [NSMutableArray array];
    
    [array enumerateObjectsUsingBlock:^(NSNumber *x, NSUInteger idx, BOOL *stop) {
        
        [mutableArray addObject:@(([x longLongValue] * [g longLongValue] + [b longLongValue]) / 1000)];
        
    }];
    
    return [NSArray arrayWithArray:mutableArray];
}

@end
