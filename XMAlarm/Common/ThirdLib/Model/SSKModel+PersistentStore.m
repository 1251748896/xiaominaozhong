//
//  MTLFMDBAdapter.h
//  Mantle
//
//  Created by Valerio Santinelli on 16/07/14.
//  Copyright (c) 2014 Valerio Santinelli. All rights reserved.
//

#import "SSKModel+PersistentStore.h"
#import "SSKModelPersistentStore.h"

static id <SSKModelPersistentStore> _persistentStore;

@implementation SSKModel (PersistentStore)

+ (void)setPersistentStore:(id <SSKModelPersistentStore>)store {
    _persistentStore = store;
}

+ (id <SSKModelPersistentStore>)persitentStore {
    return _persistentStore;
}

+ (id)modelFromFMResultSet:(FMResultSet *)ResultSet {
    NSError *error = nil;
    SSKModel *model = [MTLFMDBAdapter modelOfClass:self fromFMResultSet:ResultSet error:&error];
    assert(!error);
    return model;
}

+ (NSArray *)modelsFromFMResultSetArray:(FMResultSet *)FMResultSet {
    NSMutableArray *models = [NSMutableArray array];

    while ([FMResultSet next]) {
        NSError *error = nil;
        SSKModel *model = [MTLFMDBAdapter modelOfClass:self
                                       fromFMResultSet:FMResultSet
                                                 error:&error];
        assert(!error);
        [models addObject:model];
    }

    return [models copy];
}

- (BOOL)save {
    return [_persistentStore saveModel:self];
}

- (BOOL)saveWhere:(id)condition, ... {
    BOOL ret = NO;

    va_list args;
    va_start(args, condition);

    ret = [_persistentStore saveModel:self where:condition args:args];

    va_end(args);
    return ret;
}

- (BOOL)remove {
    return [_persistentStore removeModel:self];
}

+ (BOOL)insertBatchModels:(NSArray *)models {
    return [_persistentStore saveBatchModels:models];
}

+ (NSArray *)all {
    return [[self class] where:nil];
}

+ (NSArray *)where:(id)condition, ... {
    va_list args;
    va_start(args, condition);

    NSArray *array = [_persistentStore modelsWithClass:self
                                                 limit:nil
                                                 order:nil
                                                 where:condition
                                                  args:args];

    va_end(args);
    return array;
}

+ (NSArray *)order:(id)order where:(id)condition, ... {
    va_list args;
    va_start(args, condition);

    NSArray *array = [_persistentStore modelsWithClass:self
                                                 limit:nil
                                                 order:order
                                                 where:condition
                                                  args:args];

    va_end(args);
    return array;
}

+ (id)find:(id)condition, ... {
    va_list args;
    va_start(args, condition);

    NSArray *array = [_persistentStore modelsWithClass:self
                                                 limit:nil
                                                 order:nil
                                                 where:condition
                                                  args:args];

    va_end(args);
    return [array firstObject];
}

+ (NSArray *)query:(Class)modelClass sql:(NSString *)sql {

    NSArray *array = [_persistentStore modelsWithClass:modelClass sql:sql];

    return array;
}

+ (id)findLimit:(id)limit order:(id)order where:(id)condition, ... {
    va_list args;
    va_start(args, condition);

    NSArray *array = [_persistentStore modelsWithClass:self
                                                 limit:limit
                                                 order:order
                                                 where:condition
                                                  args:args];

    va_end(args);
    return [array firstObject];
}

+ (NSArray *)limit:(id)limit order:(id)order where:(id)condition, ... {
    va_list args;
    va_start(args, condition);

    NSArray *array = [_persistentStore modelsWithClass:self
                                                 limit:limit
                                                 order:order
                                                 where:condition
                                                  args:args];

    va_end(args);
    return array;
}

+ (NSUInteger)countWithSql:(NSString *)sql {
    NSUInteger count = [_persistentStore countWithSql:sql];
    return count;
}

+ (NSUInteger)countWhere:(id)condition, ... {
    va_list args;
    va_start(args, condition);

    NSUInteger count = [_persistentStore countOfModelsWithClass:self
                                                          where:condition
                                                           args:args];

    va_end(args);
    return count;
}

+ (BOOL)clear {
    return [_persistentStore clearModelClass:self];
}

+ (BOOL)excuteSql:(NSString *)sql {
    return [_persistentStore excuteSql:sql];
}

+ (void)clearTableCache {
    [_persistentStore clearTableCache];
}

+ (void)clearDataCache {
    [_persistentStore clearDataCache];
}


@end
