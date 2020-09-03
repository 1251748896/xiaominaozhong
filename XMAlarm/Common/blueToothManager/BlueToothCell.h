//
//  BlueToothCell.h
//  XMAlarm
//
//  Created by Mac mini on 2018/4/28.
//  Copyright © 2018年 com.xmm. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BlueToothCell : UITableViewCell
{
    
}
@property (nonatomic) UIImageView *statusImgv;
@property (nonatomic) UIActivityIndicatorView *activityIndicator;
@property (nonatomic) UILabel *nameLabel;
@property (nonatomic) UILabel *promitLabel;
@property (nonatomic) UILabel *statusLabel;

- (void)connecting;
- (void)stopConnectSuccess:(BOOL)connected;
@end
