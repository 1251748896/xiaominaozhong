//
//  MTLFMDBAdapter.h
//  Mantle
//
//  Created by Valerio Santinelli on 16/07/14.
//  Copyright (c) 2014 Valerio Santinelli. All rights reserved.
//

#import "SSKModel.h"
#import "SSKModelPersistentStore.h"

@implementation SSKModel

#pragma mark - MTLFMDBSerializing
+ (NSDictionary *)FMDBColumnsByPropertyKey {
    return @{};
}

+ (NSArray *)FMDBPrimaryKeys {
    return @[@"primaryId"];
}

+ (NSString *)FMDBTableName {
    return NSStringFromClass(self);
}

#pragma mark - MTLJSONSerializing
+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"primaryId": @"_id",
             };
}

@end
