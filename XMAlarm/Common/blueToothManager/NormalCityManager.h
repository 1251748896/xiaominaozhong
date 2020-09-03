//
//  NormalCityManager.h
//  XMAlarm
//
//  Created by 姜波 on 2018/7/9.
//  Copyright © 2018年 com.xmm. All rights reserved.
//

#import <Foundation/Foundation.h>
@class ChinaDistrict;
@class TrafficLimitRule;
@interface NormalCityManager : NSObject

+ (ChinaDistrict *)normalCityLocationModel:(NSDictionary *)dict;
+ (TrafficLimitRule *)normalCityRuleModel:(NSDictionary *)dict;


@end
