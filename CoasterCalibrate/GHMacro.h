//
//  GHMacro.h
//  CoasterCalibrate
//
//  Created by Ren Guohua on 14-9-23.
//  Copyright (c) 2014年 Nevermore. All rights reserved.
//

#ifndef CoasterCalibrate_GHMacro_h
#define CoasterCalibrate_GHMacro_h

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

static NSString *const kCSTGValue = @"4882.8125";

#endif
