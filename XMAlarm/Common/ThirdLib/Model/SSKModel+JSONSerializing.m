//
//  MTLFMDBAdapter.h
//  Mantle
//
//  Created by Valerio Santinelli on 16/07/14.
//  Copyright (c) 2014 Valerio Santinelli. All rights reserved.
//

#import "SSKModel+JSONSerializing.h"

@implementation SSKModel (JSONSerializing)

+ (id) modelFromJSONDictionary:(NSDictionary*)JSONDictionary {
    if (!JSONDictionary) return nil;
    
    NSError* error = nil;
    SSKModel* model = [MTLJSONAdapter modelOfClass:self
                                fromJSONDictionary:JSONDictionary
                                             error:&error];
    NSAssert(!error, error.description);
    return model;
}

+ (NSArray*) modelsFromJSONArray:(NSArray*)JSONArray {
    if (!JSONArray) return nil;
    
    NSError* error = nil;
    NSArray* models = [MTLJSONAdapter modelsOfClass:self
                                      fromJSONArray:JSONArray
                                              error:&error];
    NSAssert(!error, error.description);
    return models;
}

- (NSDictionary*) JSONDictionary {
    return [MTLJSONAdapter JSONDictionaryFromModel:self];
}

+ (NSArray*) JSONArrayFromModels:(NSArray*)models {
    NSMutableArray* array = models ? [[NSMutableArray alloc] initWithCapacity:models.count] : nil;
    [models enumerateObjectsUsingBlock:^(SSKModel* model, NSUInteger idx, BOOL *stop) {
        [array addObject:[model JSONDictionary]];
    }];
    return [array copy];
}

@end
