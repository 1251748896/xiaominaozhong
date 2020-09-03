/************************************************************
*  * EaseMob CONFIDENTIAL
* __________________
* Copyright (C) 2013-2014 EaseMob Technologies. All rights reserved.
*
* NOTICE: All information contained herein is, and remains
* the property of EaseMob Technologies.
* Dissemination of this information or reproduction of this material
* is strictly forbidden unless prior written permission is obtained
* from EaseMob Technologies.
*/

#import "NSDateFormatter+Category.h"

@implementation NSDateFormatter (Category)

+ (instancetype)sharedInstance {
    static NSDateFormatter *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[NSDateFormatter alloc] init];
        instance.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    });
    return instance;
}

+ (id)dateFormatter {
    return [self sharedInstance];
}

+ (id)dateFormatterWithFormat:(NSString *)dateFormat {
    NSDateFormatter *dateFormatter = [self sharedInstance];
    dateFormatter.dateFormat = dateFormat;
    return dateFormatter;
}

+ (id)defaultDateFormatter {
    NSDateFormatter *dateFormatter = [self sharedInstance];
    dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    return dateFormatter;
}

+ (NSDate *)dateFromString:(NSString *)dateStr formatStr:(NSString *)formatStr {
    NSDateFormatter *dateFormatter = [self sharedInstance];
    dateFormatter.dateFormat = formatStr;
    return [dateFormatter dateFromString:dateStr];
}

+ (NSString *)stringFromDate:(NSDate *)date formatStr:(NSString *)formatStr {
    NSDateFormatter *dateFormatter = [self sharedInstance];
    dateFormatter.dateFormat = formatStr;
    return [dateFormatter stringFromDate:date];
}

@end
