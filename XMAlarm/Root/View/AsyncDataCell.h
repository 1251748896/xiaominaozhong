//
//  AsyncDataCell.h
//  XMAlarm
//
//  Created by Mac mini on 2018/4/27.
//  Copyright © 2018年 com.xmm. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AsyncDataCell : UITableViewCell

/**left*/
@property (nonatomic, readonly) UIImageView *cellImgv;

/**伪按钮*/
@property (nonatomic, readonly) UILabel *statusLabel;
@property (nonatomic, readonly) UILabel *promitLabel;


@property (nonatomic, strong) NSDictionary *dataDict;

+ (CGFloat)height;

@end
