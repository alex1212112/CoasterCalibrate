//
//  GHTool.h
//  Coaster
//  通用工具
//  Created by Ren Guohua on 14-8-24.
//  Copyright (c) 2014年 ghren. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define CURRENTVERSION ([[[UIDevice currentDevice] systemVersion] floatValue])

@interface GHTool : NSObject

/**
 *  将图片压缩成50kb，然后转换成base64字符串
 *
 *  @param image 原始图片
 *
 *  @return base64字符串
 */
+ (NSString *)convertToBase64StringWithImage:(UIImage *)image;

/**
 *  将RSSI转换成距离
 *
 *  @param RSSI 信号强度
 *
 *  @return 距离
 */
+ (NSNumber *)numberWithRSSI:(NSNumber *)RSSI;

/**
 *  日期转换成字符串
 *
 *  @param date   要转换的日期
 *  @param format 转换的格式
 *
 *  @return 返回转换的字符串
 */
+ (NSString *)stringFromDate:(NSDate *)date withFormatString:(NSString *)format;


/**
 *  字符串转换成日期格式
 *
 *  @param dateString 字符串
 *  @param format     转换的格式字符串
 *
 *  @return 返回转换的日期结果
 */

+ (NSDate *)dateFromString:(NSString *)dateString withFormatString:(NSString *)format;


/**
 *  计算date 是一周中的第几天
 *
 *  @param date
 *
 *  @return 一周中的第几天
 */
+ (NSInteger)weekdayNumberFromDate:(NSDate *)date;

/**
 *  计算unix时间，即从1970年之后经过一段时间之后的时间
 *
 *  @param timeStamp 时间戳（经过了多少秒的时间）
 *
 *  @return 具体日期
 */
+ (NSDate *)dateWithTimeStamp:(long long)timeStamp;


/**
 *  计算一个日期的unix时间戳（即从1970年之后到这个日期总共是多少秒）
 *
 *  @param date 日期
 *
 *  @return 时间戳（秒数）
 */
+ (long long)timeStampWithDate:(NSDate *)date;

/**
 *  将两个1字节的data 合并成 一个两字节的data，并转换成 UInt16 类型；
 *
 *  @param first  第一个data
 *  @param second 第二个data
 *
 *  @return 转换后的结果
 */

+ (UInt16)spliceInt16WithFirstData:(NSData *)first secondData:(NSData *)second;

+ (void)runMethodAfterDelay:(float)delay withMethod:(void(^)())method;
@end
