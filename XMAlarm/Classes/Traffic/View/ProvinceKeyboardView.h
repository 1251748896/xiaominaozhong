//
//  ProvinceKeyboardView.h
//  Car
//
//  Created by bo.chen on 17/4/4.
//  Copyright © 2017年 com.smaradio. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProvinceKeyboardView : UIView
- (instancetype)initWithProvince:(NSString *)provinceStr;
@property (nonatomic, copy) ObjectBlock didSelectBlock;
@end

@interface ProvinceKeyboardCell : UICollectionViewCell
@property (nonatomic, readonly) UIButton *btn;
@end
