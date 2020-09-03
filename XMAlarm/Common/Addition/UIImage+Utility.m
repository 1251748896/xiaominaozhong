//
//  UIImage+Utility.m
//  OnMobile
//
//  Created by bo.chen on 16/9/22.
//  Copyright © 2016年 keruyun. All rights reserved.
//

#import "UIImage+Utility.h"

@implementation UIImage (Utility)

// 创建指定颜色指定大小的图片
+ (UIImage *)imageWithColor:(UIColor *)color andSize:(CGSize)size {
    UIImage * img = nil;
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextFillRect(context, rect);
    img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

- (UIImage *)roundedImage {
    return [self roundedImageWithSize:CGSizeMake(self.size.width, self.size.height)];
}

- (UIImage *)roundedImageWithSize:(CGSize)size {
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();

    [self drawInRect:rect];

    CGContextAddRect(context, rect);
    CGContextAddEllipseInRect(context, rect);
    CGContextEOClip(context);
    CGContextClearRect(context, rect);

    UIImage * newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return newImage;
}

- (UIImage *)resizeImageByFactor:(CGFloat)factor {
    CGSize newSize = CGSizeMake(roundf(self.size.width * factor), roundf(self.size.height * factor));
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0);
    
    [self drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

- (UIImage *)cropImageWithRect:(CGRect)rect {
    CGFloat scale = self.scale;
    
    UIImage *image = nil;
    CGImageRef cgimg = CGImageCreateWithImageInRect([self CGImage], CGRectMake(rect.origin.x * scale, rect.origin.y * scale, rect.size.width * scale, rect.size.height * scale));
    image = [UIImage imageWithCGImage:cgimg scale:scale orientation:UIImageOrientationUp];
    CGImageRelease(cgimg);//用完一定要释放，否则内存泄露
    return image;
}

- (UIEdgeInsets)getImageUIEdgeInsets {
    CGFloat hInset = floorf(self.size.width / 2);
    CGFloat vInset = floorf(self.size.height / 2);
    UIEdgeInsets insets = UIEdgeInsetsMake(vInset, hInset, vInset, hInset);
    return insets;
}

/**
 * 用作图片拉伸
 */
- (UIImage *)getImageResize {
    return [self resizableImageWithCapInsets:[self getImageUIEdgeInsets]];
}

/**
 * 创建二维码图片
 */
+ (UIImage *)qrImageForString:(NSString *)string imageSize:(CGFloat)size {
    if (string.length <= 0) {
        return nil;
    }
    NSData *stringData = [string dataUsingEncoding:NSUTF8StringEncoding];
    //创建filter
    CIFilter *qrFilter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    //设置内容和纠错级别
    [qrFilter setValue:stringData forKey:@"inputMessage"];
    [qrFilter setValue:@"M" forKey:@"inputCorrectionLevel"];
    
    //上色
#if 0
    CIColor *onColor = [CIColor colorWithCGColor:[UIColor blackColor].CGColor];
    CIColor *offColor = [CIColor colorWithCGColor:[UIColor whiteColor].CGColor];
    CIFilter *colorFilter = [CIFilter filterWithName:@"CIFalseColor" keysAndValues:@"inputImage", qrFilter.outputImage, @"inputColor0", onColor, @"inputColor1", offColor, nil];
#endif
    
    CIImage *qrImage = qrFilter.outputImage;
    //绘制
    CGImageRef cgImage = [[CIContext contextWithOptions:nil] createCGImage:qrImage fromRect:qrImage.extent];
    UIGraphicsBeginImageContext(CGSizeMake(size, size));
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetInterpolationQuality(context, kCGInterpolationNone);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextDrawImage(context, CGContextGetClipBoundingBox(context), cgImage);
    UIImage *codeImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    CGImageRelease(cgImage);
    
    return codeImage;
}

@end
