//
//  RemindSetting.m
//  XMAlarm
//
//  Created by bo.chen on 17/9/23.
//  Copyright © 2017年 com.xmm. All rights reserved.
//

#import "RemindSetting.h"

@implementation RemindSetting

- (instancetype)init {
    self = [super init];
    if (self) {
        self.preDay = @0;
        self.time = [NSDateFormatter dateFromString:@"6:30" formatStr:kTimeFormatStr];
    }
    return self;
}

+ (NSValueTransformer *)JSONTransformerForKey:(NSString *)key {
    if ([key isEqualToString:@"time"]) {
        return [MTLValueTransformer reversibleTransformerWithForwardBlock:^NSDate *(NSNumber *seconds) {
            return [NSDate dateWithTimeIntervalSince1970:seconds.doubleValue];
        }                                                    reverseBlock:^NSNumber *(NSDate *date) {
            return @(date.timeIntervalSince1970);
        }];
    }
    return [super JSONTransformerForKey:key];
}

- (NSString *)formatTrafficRemindStr {
    return [NSString stringWithFormat:@"%@%@  %@", self.preDay.integerValue > 0 ? @"前一天" : @"当日", (self.time.hour < 12 ? @"上午" : @"下午"), [NSDateFormatter stringFromDate:self.time formatStr:kTimeFormatStr]];
}

@end
