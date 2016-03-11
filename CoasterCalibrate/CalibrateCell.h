//
//  CalibrateCell.h
//  CoasterCalibrate
//
//  Created by Ren Guohua on 14-10-9.
//  Copyright (c) 2014年 Nevermore. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CalibrateCell : UITableViewCell

@property (nonatomic, strong) UILabel *testDataLabel;
@property (nonatomic, strong) UILabel *realDataLabel;



- (void)bindData:(id)data;
@end
