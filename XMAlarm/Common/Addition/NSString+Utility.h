//
//  NSString+Utility.h
//  Keruyun
//
//  Created by gang.xu on 13-11-27.
//  Copyright (c) 2013年 shishike.com. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
 * NSString扩展类
 */
@interface NSString (Utility)

// 本地日期和时间
- (NSDate *)localDateTime;

// 本地日期
- (NSDate *)localDate;

// 时分秒时间
- (NSDate *)localTime;

// 判断是否为IP地址
- (BOOL)isIpAddress;

// 判断是否为手机号码
- (BOOL)checkMobile;

// 判断是否为座机号码
- (BOOL)checkTel;

// 秒转日期
- (NSDate *)dateFromMilliseconds;

// 字符串宽度
- (NSInteger)widthWithFont:(UIFont *)font;

// MD5加密
- (NSString *)md5FromString;

// 子字符串的起始下标
- (NSInteger)indexOfSubString:(NSString *)aString;

// 电话隐藏格式
- (NSString *)phoneHideString;

/**  Return the char value at the specified index. */
- (unichar)charAt:(int)index;

/**
* Compares two strings lexicographically.
* the value 0 if the argument string is equal to this string;
* a value less than 0 if this string is lexicographically less than the string argument;
* and a value greater than 0 if this string is lexicographically greater than the string argument.
*/
- (int)compareTo:(NSString *)anotherString;

- (int)compareToIgnoreCase:(NSString *)str;

- (BOOL)contains:(NSString *)str;

- (BOOL)startsWith:(NSString *)prefix;

- (BOOL)endsWith:(NSString *)suffix;

- (BOOL)equals:(NSString *)anotherString;

- (BOOL)equalsIgnoreCase:(NSString *)anotherString;

- (int)indexOfChar:(unichar)ch;

- (int)indexOfChar:(unichar)ch fromIndex:(int)index;

- (int)indexOfString:(NSString *)str;

- (int)indexOfString:(NSString *)str fromIndex:(int)index;

- (int)lastIndexOfChar:(unichar)ch;

- (int)lastIndexOfChar:(unichar)ch fromIndex:(int)index;

- (int)lastIndexOfString:(NSString *)str;

- (int)lastIndexOfString:(NSString *)str fromIndex:(int)index;

- (NSString *)substringFromIndex:(int)beginIndex toIndex:(int)endIndex;

- (NSString *)toLowerCase;

- (NSString *)toUpperCase;

- (NSString *)trim;

- (NSString *)replaceAll:(NSString *)origin with:(NSString *)replacement;

- (NSArray *)split:(NSString *)separator;

- (NSString *)trimWhitespace;

- (NSString *)toPwdStr;

- (CGSize)labelSizeWithFont:(CGFloat)fontSize labelWidth:(CGFloat)width;

- (NSString *)SSJKStringValue;

- (BOOL)hasTextValue;

- (NSString *)handleNumber;

+ (NSString *)uuid;

+ (NSString *)jsonStringWithDictionary:(NSDictionary *)dictionary;

+ (NSString *)jsonStringWithArray:(NSArray *)array;

+ (NSString *)jsonStringWithString:(NSString *)string;

+ (NSString *)jsonStringWithObject:(id)object;

- (NSObject *)safeNullValue;

+ (BOOL)isValidatIP:(NSString *)ipAddress;

@property (readonly) char charValue;

- (NSString *)sha256;

@end
