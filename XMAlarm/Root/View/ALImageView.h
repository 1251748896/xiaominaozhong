//
//  ALImageView.h
//  goodnight
//
//  Created by mac003 on 15/4/10.
//  Copyright (c) 2015年 quleduo. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ALImageView;

@protocol ALImageViewDelegate <NSObject>

- (void)touchUpInside:(ALImageView *)imageView;

@end

@interface ALImageView : UIImageView
@property (nonatomic, weak) id<ALImageViewDelegate> delegate;
@end
