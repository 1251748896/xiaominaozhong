//
//  NormalCityManager.m
//  XMAlarm
//
//  Created by 姜波 on 2018/7/9.
//  Copyright © 2018年 com.xmm. All rights reserved.
//

#import "NormalCityManager.h"
#import "TrafficLimitAlarm.h"
@implementation NormalCityManager

+ (ChinaDistrict *)normalCityLocationModel:(NSDictionary *)dict {
    ChinaDistrict *model = [ChinaDistrict modelFromJSONDictionary:dict];
    return model;
}

+ (TrafficLimitRule *)normalCityRuleModel:(NSDictionary *)dict {
    TrafficLimitRule *model = [TrafficLimitRule modelFromJSONDictionary:dict];
    return model;
}

@end
