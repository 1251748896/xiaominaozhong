//
//  BaseModel.m
//  shareKouXiaoHai
//
//  Created by Mac on 15/11/30.
//  Copyright © 2015年 Kouxiaoer. All rights reserved.
//

#import "BaseModel.h"

@implementation BaseModel

#pragma mark - MTLJSONSerializing

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{};
}

+ (NSValueTransformer *)JSONTransformerForKey:(NSString *)key {
    return nil;
}

#pragma mark - JSON method

+ (id)modelFromJSONDictionary:(NSDictionary *)JSONDictionary {
    if (!JSONDictionary) {
        return nil;
    }

    NSError *err = nil;
    id model = [MTLJSONAdapter modelOfClass:self fromJSONDictionary:JSONDictionary error:&err];
    if (err) {
        DEBUG_LOG(@"%@", err);
    }
    return model;
}

+ (NSArray *)modelsFromJSONArray:(NSArray *)JSONArray {
    if (!JSONArray) {
        return nil;
    }

    NSError *err = nil;
    NSArray *models = [MTLJSONAdapter modelsOfClass:self fromJSONArray:JSONArray error:&err];
    if (err) {
        DEBUG_LOG(@"%@", err);
    }
    return models;
}

- (NSDictionary *)JSONDictionary {
    return [MTLJSONAdapter JSONDictionaryFromModel:self];
}

+ (NSArray *)JSONArrayFromModels:(NSArray *)models {
    if (!models) {
        return nil;
    }

    NSError *err = nil;
    NSArray *jsonArray = [MTLJSONAdapter JSONArrayFromModels:models];
    if (err) {
        DEBUG_LOG(@"%@", err);
    }
    return jsonArray;
}

@end
