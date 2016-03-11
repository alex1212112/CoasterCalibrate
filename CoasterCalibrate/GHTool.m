//
//  GHTool.m
//  Coaster
//
//  Created by Ren Guohua on 14-8-24.
//  Copyright (c) 2014年 ghren. All rights reserved.
//

#import "GHTool.h"

@implementation GHTool

+ (NSString*)convertToBase64StringWithImage:(UIImage*)image
{
   // NSData *data = UIImagePNGRepresentation(image);
    //先压缩，后转换
    NSData *mataData = UIImageJPEGRepresentation(image,1.0f);
    NSData *compressionData;
    if (mataData.length > 50000.0f)
    {
        compressionData = UIImageJPEGRepresentation(image,50000.0f / mataData.length);
    }
    else
    {
        compressionData = mataData;
    }
    NSString *base64String = [compressionData base64EncodedStringWithOptions:0];
    return base64String;
}


+ (NSNumber *)numberWithRSSI:(NSNumber *)RSSI
{
    double rssiFloat = [RSSI floatValue];
    double d =  pow(10.00, ( 66 + rssiFloat) / ( 10 * 5.98));

    return [NSNumber numberWithFloat:d];
}


/**
 *  日期转换成字符串
 *
 *  @param date   要转换的日期
 *  @param format 转换的格式
 *
 *  @return 返回转换的字符串
 */
+ (NSString*)stringFromDate:(NSDate*)date withFormatString:(NSString*)format
{
    NSDateFormatter* dateFormat = [[NSDateFormatter alloc] init];//实例化一个NSDateFormatter对象
    
    [dateFormat setDateFormat:format];//设定时间格式,这里可以设置成自己需要的格式
    NSString *currentDateStr = [dateFormat stringFromDate:date];
    return currentDateStr;
}
/**
 *  字符串转换成日期格式
 *
 *  @param dateString 字符串
 *  @param format     转换的格式字符串
 *
 *  @return 返回转换的日期结果
 */
+ (NSDate*)dateFromString:(NSString*)dateString withFormatString:(NSString*)format
{
    NSDateFormatter* dateFormat = [[NSDateFormatter alloc] init];//实例化一个NSDateFormatter对象
    
    [dateFormat setDateFormat:format];//设定时间格式,这里可以设置成自己需要的格式
    NSDate *date = [dateFormat dateFromString:dateString];
    return date;
}



+ (NSDate*)dateWithTimeStamp:(long long)timeStamp
{
    //timeStamp = timeStamp / 1000;
    NSDate *confromTimesp = [NSDate dateWithTimeIntervalSince1970:(timeStamp)];
    return confromTimesp;
}

+ (long long)timeStampWithDate:(NSDate *)date
{
    long long timeStamp = (long long)[date timeIntervalSince1970];
    return timeStamp;
}


+ (UInt16)spliceInt16WithFirstData:(NSData *)first secondData:(NSData *)second
{
    NSMutableData *mutableData = [NSMutableData dataWithData:first];
    [mutableData appendData:second];
    
    UInt16 result;
    
    [mutableData getBytes:&result length:2];
    return result;
}


+ (NSInteger)weekdayNumberFromDate:(NSDate*)date
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSDateComponents *weekdayComponents = [calendar components:(NSCalendarUnitWeekday) fromDate:date];
    
    return [weekdayComponents weekday];
}

+ (void)runMethodAfterDelay:(float)delay withMethod:(void(^)())method
{
    dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, delay * NSEC_PER_SEC);
    
    dispatch_after(time, dispatch_get_main_queue(), method);
}


@end
