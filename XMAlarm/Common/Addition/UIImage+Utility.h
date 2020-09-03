//
//  UIImage+Utility.h
//  OnMobile
//
//  Created by bo.chen on 16/9/22.
//  Copyright © 2016年 keruyun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

/*
 * UIImage扩展类
 */
@interface UIImage (Utility)

+ (UIImage *)imageWithColor:(UIColor *)color andSize:(CGSize)size;
- (UIImage *)roundedImage;

- (UIImage *)resizeImageByFactor:(CGFloat)factor;
- (UIImage *)cropImageWithRect:(CGRect)cropRect;

- (UIImage *)getImageResize;

/**
 * 创建二维码图片
 */
+ (UIImage *)qrImageForString:(NSString *)string imageSize:(CGFloat)size;

@end
