//
//  NSNumber+Category.h
//  KxrDoctor
//
//  Created by Mac on 15/12/4.
//  Copyright © 2015年 kouxiaoer. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSNumber (Category)

- (NSInteger)length;

- (BOOL)isEqualToString:(NSString *)str;

- (NSString *)decimalDescription;

- (NSString *)chineseTenStr;

/**
 * 把一个浮点数做精度&进位规则处理
 */
- (double)roundedNumber:(int)scale mode:(NSRoundingMode)mode;

/**
 * 把一个数字做保留两位小数的四舍五入
 */
- (double)roundedNumber;

@end
