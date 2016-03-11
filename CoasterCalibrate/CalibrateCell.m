//
//  CalibrateCell.m
//  CoasterCalibrate
//
//  Created by Ren Guohua on 14-10-9.
//  Copyright (c) 2014年 Nevermore. All rights reserved.
//

#import "CalibrateCell.h"

@implementation CalibrateCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    if (self)
    {
        
        
    }
    return self;
}


- (void)bindData:(id)data
{
    if ([data isKindOfClass:[NSDictionary class]])
    {
        NSDictionary *dic = (NSDictionary *)data;
        self.textLabel.text = [NSString stringWithFormat:@"%ld - 测量值:%@",(long)[dic[@"n"] integerValue],[dic[@"x"] stringValue]];
        
        self.detailTextLabel.text = [NSString stringWithFormat:@"实际重量:%ldg",(long)[dic[@"w"] integerValue] / 1000];
    }

}

@end
