//
//  DeviceCell.m
//  CoasterCalibrate
//
//  Created by Ren Guohua on 14-9-23.
//  Copyright (c) 2014年 Nevermore. All rights reserved.
//

#import "DeviceCell.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import "GHMacro.h"
#import "CBPeripheral+GHBLE.h"

@implementation DeviceCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseIdentifier];
    if (self)
    {
        
    }
    return self;
}

- (void)awakeFromNib {
    // Initialization code
  
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)bindData:(id)data withType:(NSInteger)type
{
    CBPeripheral *p;
    if ([data isKindOfClass:[CBPeripheral class]])
    {
        p =  (CBPeripheral*)data;
    }
    switch (type) {
            
        case 0:
        {
            self.textLabel.text = @"名称";
            self.detailTextLabel.text = p.name;
           
            break;
        }
        case 1:
        {
            self.textLabel.text = @"ID";
            NSString *uuidString = p.deviceId;
           // NSString *handleString = [uuidString substringWithRange:(NSRange){uuidString.length - 4,4}];
            self.detailTextLabel.text = uuidString;
         
            
            break;
        }
        case 2:
        {
            self.textLabel.text = @"连接状态";
            if (p.state == CBPeripheralStateDisconnected )
            {
                self.detailTextLabel.text = @"Disconnected";
            }
            else if (p.state == CBPeripheralStateConnected)
            {
                self.detailTextLabel.text = @"Connected";
            }
            else if (p.state == CBPeripheralStateConnecting)
            {
                self.detailTextLabel.text = @"Connecting";
            }
            break;
        }
        case 3:
        {
            self.textLabel.text = @"信号强度";
            //NSNumber *distance = [GHTool numberWithRSSI:p.discoverRSSI];
            self.detailTextLabel.text = [NSString stringWithFormat:@"%lddBm",(long)[p.discoverRSSI integerValue]];
            break;
        }
            
        default:
            break;
    }
    
}


@end
