//
//  NSNumber+Category.m
//  KxrDoctor
//
//  Created by Mac on 15/12/4.
//  Copyright © 2015年 kouxiaoer. All rights reserved.
//

#import "NSNumber+Category.h"

@implementation NSNumber (Category)

- (NSInteger)length {
    return [[self description] length];
}

- (BOOL)isEqualToString:(NSString *)str {
    return [[self description] isEqualToString:str];
}

- (NSString *)decimalDescription {
    NSString *doubleString = [NSString stringWithFormat:@"%lf", self.doubleValue];
    NSDecimalNumber *decNumber = [NSDecimalNumber decimalNumberWithString:doubleString];
    return [decNumber stringValue];
}

- (NSString *)chineseTenStr {
    NSArray *tenStrArray = @[@"一", @"二", @"三", @"四", @"五", @"六", @"七", @"八", @"九", @"十"];
    NSInteger index = self.integerValue % 10 - 1;
    if (index < 0) {
        index += 10;
    }
    return tenStrArray[index];
}

/**
 * 把一个浮点数做精度&进位规则处理
 */
- (double)roundedNumber:(int)scale mode:(NSRoundingMode)mode {
    NSDecimalNumber *decNum = [NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%lf", self.doubleValue]];
    NSDecimalNumberHandler *behavior = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:mode scale:scale raiseOnExactness:NO raiseOnOverflow:NO raiseOnUnderflow:NO raiseOnDivideByZero:NO];
    NSDecimalNumber *resultNum = [decNum decimalNumberByRoundingAccordingToBehavior:behavior];
    return resultNum.doubleValue;
}

/**
 * 把一个数字做保留两位小数的四舍五入
 * decimalDigits:表示小数位数，在计算价钱的过程中都用6位小数，显示结果用2位小数
 */
- (double)roundedNumber {
    return [self roundedNumber:2 mode:NSRoundPlain];
}

@end
