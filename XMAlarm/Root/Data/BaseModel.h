//
//  BaseModel.h
//  shareKouXiaoHai
//
//  Created by Mac on 15/11/30.
//  Copyright © 2015年 Kouxiaoer. All rights reserved.
//

#import "MTLModel.h"

@interface BaseModel : MTLModel <MTLJSONSerializing>

#pragma mark - JSON method

+ (id)modelFromJSONDictionary:(NSDictionary *)JSONDictionary;

+ (NSArray *)modelsFromJSONArray:(NSArray *)JSONArray;

- (NSDictionary *)JSONDictionary;

+ (NSArray *)JSONArrayFromModels:(NSArray *)models;

@end
