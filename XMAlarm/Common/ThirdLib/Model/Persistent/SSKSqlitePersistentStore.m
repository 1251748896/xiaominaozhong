//
//  MTLFMDBAdapter.h
//  Mantle
//
//  Created by Valerio Santinelli on 16/07/14.
//  Copyright (c) 2014 Valerio Santinelli. All rights reserved.
//

#import <objc/runtime.h>
#import <sqlite3.h>
#import <FMDB.h>
#import "MTLFMDBAdapter.h"
#import "SSKSqlitePersistentStore.h"
#import "SSKModel.h"
#import "SSKModel+PersistentStore.h"

NSString *const kSSKSqlitePersistentStoreErrorDomain = @"SSKSqlitePersistentStoreErrorDomain";

@interface SSKSqlitePersistentStore ()
@property(nonatomic, weak) id <SSKStoreUpdateDelegate> updateDelegate;
@end

@implementation SSKSqlitePersistentStore {
    FMDatabaseQueue *_dbQueue;
    NSMutableDictionary *_modelsCache;
    NSUInteger _maxCachedObjects;
    NSMutableArray *_tablesCache;
}
@synthesize error = _error;

- (id)initWithPath:(NSString *)path {
    if (!path.length) return nil;

    if (self = [super init]) {
        _path = [path copy];
        _dbQueue = [FMDatabaseQueue databaseQueueWithPath:_path];

        _maxCachedObjects = 5000;
        _modelsCache = [[NSMutableDictionary alloc] initWithCapacity:_maxCachedObjects];
    }
    return self;
}

- (void)drop {
    if ([[NSFileManager defaultManager] fileExistsAtPath:_path]) {
        [[NSFileManager defaultManager] removeItemAtPath:_path error:nil];
    }
    _path = nil;
}

- (NSArray *)modelsWithClass:(Class)modelClass limit:(id)limit order:(id)order where:(id)condition args:(va_list)args {
    if (![self checkTableWithModelClass:modelClass]) return nil;

    NSString *sql = [self sqlQueryWithModelClass:modelClass
                                           where:condition
                                           order:order
                                           limit:limit];

    __block NSMutableArray *models = nil;

    [_dbQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *rs = [db executeQuery:sql withVAList:args];
        [self handleDatabaseError:db];

        while ([rs next]) {
            int primaryId = [rs intForColumn:@"primaryId"];
            NSString *cacheKey = [self cacheKeyForModelClass:modelClass
                                               withPrimaryId:primaryId];
            SSKModel *model = [self modelForCacheKey:cacheKey];

            if (!model) {
                @try {
                    model = [modelClass modelFromFMResultSet:rs];
                } @catch (NSException *exception) {
                    [self handleErrorWithExcepiton:exception];
                }
                [self cacheModel:model];
            }

            if (model) {
                if (!models) models = [NSMutableArray array];
                [models addObject:model];
            }
        }

        [rs close];
    }];

    return [models copy];
}

- (NSArray *)modelsWithClass:(Class)modelClass sql:(NSString *)sql {

    if (!sql)return nil;

    __block NSMutableArray *models = nil;

    [_dbQueue inDatabase:^(FMDatabase *db) {

        FMResultSet *rs = [db executeQuery:sql withVAList:nil];

        [self handleDatabaseError:db];

        while ([rs next]) {

            SSKModel *model;

            @try {
                model = [modelClass modelFromFMResultSet:rs];
            } @catch (NSException *exception) {
                [self handleErrorWithExcepiton:exception];
            }
            if (model) {
                if (!models) models = [NSMutableArray array];
                [models addObject:model];
            }
        }
        [rs close];
    }];

    return [models copy];
}


- (NSUInteger)countWithSql:(NSString *)sql {
    if (sql == nil) return 0;

    __block NSUInteger count = 0;

    [_dbQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *rs = [db executeQuery:sql withVAList:nil];

        [self handleDatabaseError:db];

        if ([rs next]) {
            count = (NSUInteger) [rs intForColumnIndex:0];
        }
        [rs close];
    }];

    return count;
}

- (BOOL)excuteSql:(NSString *)sql {
    if (sql == nil || sql.length == 0) return NO;
    __block BOOL result = NO;
    [_dbQueue inDatabase:^(FMDatabase *db) {
        result = [db executeUpdate:sql];
        [self handleDatabaseError:db];
    }];
    return result;
}

- (NSUInteger)countOfModelsWithClass:(Class)modelClass where:(id)condition args:(va_list)args {
    if (![self checkTableWithModelClass:modelClass]) return 0;

    NSString *sql = [self sqlQueryCountWithModelClass:modelClass where:condition];

    __block NSUInteger count = 0;

    [_dbQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *rs = [db executeQuery:sql withVAList:args];

        [self handleDatabaseError:db];

        if ([rs next]) {
            count = [rs intForColumnIndex:0];
        }
        [rs close];
    }];

    return count;
}

- (BOOL)clearModelClass:(Class)modelClass {
    if (![self checkTableWithModelClass:modelClass]) return NO;

    __block BOOL ret = NO;
    [_dbQueue inDatabase:^(FMDatabase *db) {
        NSString *sql = [@"DELETE FROM " stringByAppendingString:[modelClass FMDBTableName]];
        ret = [db executeUpdate:sql];

        [self handleDatabaseError:db];
    }];

    if (ret) {
        [self cleanCache];
    }

    return ret;
}

- (BOOL)saveModel:(SSKModel *)model {
    return [self saveModel:model where:nil args:nil];
}

- (BOOL)saveModel:(SSKModel *)model where:(id)condition args:(va_list)args {
    if (![self checkTableWithModelClass:[model class]]) return NO;

    __block BOOL ret = YES;

    [_dbQueue inDatabase:^(FMDatabase *db) {
        if ([self updateModel:model withPrimaryId:model.primaryId inDatabase:db]) return;
        if ([self updateModel:model condition:condition args:args inDatabase:db]) return;
        ret = [self insertModel:model inDatabase:db];
    }];

    assert(ret);

    return ret;
}

- (BOOL)saveBatchModels:(NSArray *)models {
    if (![self checkTableWithModelClass:[[models firstObject] class]]) return NO;

    __block BOOL ret = NO;
    [_dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        [models enumerateObjectsUsingBlock:^(SSKModel *model, NSUInteger idx, BOOL *stop) {
            ret = [self insertModel:model inDatabase:db];
        }];
    }];
    return ret;
}

- (BOOL)removeModel:(SSKModel *)model {
    if (![self checkTableWithModelClass:[model class]]) return NO;

    __block BOOL ret = NO;
    [_dbQueue inDatabase:^(FMDatabase *db) {
        NSString *stmt = [MTLFMDBAdapter deleteStatementForModel:model];
        NSArray *params = [MTLFMDBAdapter primaryKeysValues:model];
        ret = [db executeUpdate:stmt withArgumentsInArray:params];
        [self handleDatabaseError:db];
    }];

    // remove cache
    if (ret) {
        [self removeCachedModel:model];
    }

    return ret;
}

- (void)setUpateDelegate:(id <SSKStoreUpdateDelegate>)delegate {
    _updateDelegate = delegate;
}

- (id <SSKStoreUpdateDelegate>)updateDelegate {
    return _updateDelegate;
}

#pragma mark - private

- (void)performUpdateModel:(SSKModel *)model withType:(int)type {
    if ([self.updateDelegate respondsToSelector:@selector(persistentStore:updateModel:withType:)]) {
        [self.updateDelegate persistentStore:self updateModel:model withType:type];
    }
}

#pragma mark - private update model

- (BOOL)updateModel:(SSKModel *)model withPrimaryId:(NSNumber *)pk inDatabase:(FMDatabase *)db {
    if (!pk) return NO;

    NSString *sql = [NSString stringWithFormat:@"SELECT count(*) FROM %@ WHERE primaryId = %@", [model.class FMDBTableName], model.primaryId];
    FMResultSet *rs = [db executeQuery:sql];
    if ([rs next] && [rs intForColumnIndex:0]) {
        NSString *stmt = [MTLFMDBAdapter updateStatementForModel:model];
        NSArray *params = [MTLFMDBAdapter columnValues:model];
        params = [params arrayByAddingObjectsFromArray:[MTLFMDBAdapter primaryKeysValues:model]];
        if (![db executeUpdate:stmt withArgumentsInArray:params]) goto end;

        // update cache
        [self removeCachedModel:model];
        [rs close];
        return YES;
    }

    end:
    [self handleDatabaseError:db];
    [rs close];
    return NO;
}

- (BOOL)updateModel:(SSKModel *)model condition:(id)condition args:(va_list)args inDatabase:(FMDatabase *)db {
    NSString *where = [self whereStatement:condition];
    if (!where) {
        if (!model.serverId.length) return NO;

        where = [NSString stringWithFormat:@"WHERE serverId = '%@'", model.serverId];
    }

    NSString *sql = [NSString stringWithFormat:@"SELECT primaryId FROM %@ %@", [model.class FMDBTableName], where];

    FMResultSet *rs = [db executeQuery:sql withVAList:args];
    if ([rs next]) {
        int pk = [rs intForColumnIndex:0];
        model.primaryId = [NSNumber numberWithInt:pk];

        NSString *stmt = [MTLFMDBAdapter updateStatementForModel:model];
        NSArray *params = [MTLFMDBAdapter columnValues:model];
        params = [params arrayByAddingObjectsFromArray:[MTLFMDBAdapter primaryKeysValues:model]];
        if (![db executeUpdate:stmt withArgumentsInArray:params]) goto end;

        // update cache
        [self removeCachedModel:model];
        [rs close];
        return YES;
    }

    end:
    [self handleDatabaseError:db];
    [rs close];
    return NO;
}

- (BOOL)insertModel:(SSKModel *)model inDatabase:(FMDatabase *)db {
    NSString *stmt = [MTLFMDBAdapter insertStatementForModel:model];
    NSArray *params = [MTLFMDBAdapter columnValues:model];
    if ([db executeUpdate:stmt withArgumentsInArray:params]) return YES;
    
    [self handleDatabaseError:db];
    return NO;
}

- (BOOL)backupToPath:(NSString *)path {
    if (!path.length) return NO;

    __block BOOL ret = NO;

    [_dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        sqlite3 *pTo = NULL;
        int rc = sqlite3_open(path.UTF8String, &pTo);
        if (rc == SQLITE_OK && pTo) {
            sqlite3_backup *pBackup = sqlite3_backup_init(pTo, "backup", db.sqliteHandle, "main");
            if (pBackup) {
                sqlite3_backup_step(pBackup, -1);
                sqlite3_backup_finish(pBackup);
            }

            ret = (sqlite3_errcode(pTo) == SQLITE_OK);

            sqlite3_close(pTo);
        }
    }];

    return ret;
}

#pragma mark - private SQL builder

- (NSString *)sqlQueryWithModelClass:(Class)modelClass where:(id)condition order:(id)order limit:(id)limit {
    NSMutableArray *stmts = [NSMutableArray array];
    [stmts addSaveObject:[@"SELECT * FROM " stringByAppendingString:[modelClass FMDBTableName]]];
    [stmts addSaveObject:[self whereStatement:condition]];
    [stmts addSaveObject:[self orderStatement:order]];
    [stmts addSaveObject:[self limitStatement:limit]];

    return [stmts componentsJoinedByString:@" "];
}

- (NSString *)whereStatement:(id)condition {
    if (!condition) return nil;

    if ([condition isKindOfClass:[NSString class]]) {
        return [@"WHERE " stringByAppendingString:condition];
    }

    if ([condition isKindOfClass:[NSArray class]]) {
        return [@"WHERE " stringByAppendingString:[condition componentsJoinedByString:@" AND "]];
    }

    if ([condition isKindOfClass:[NSDictionary class]]) {
        NSMutableArray *conditions = [[NSMutableArray alloc] initWithCapacity:[condition count]];
        [condition enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            if ([obj isKindOfClass:[NSString class]]) {
                [conditions addObject:[key stringByAppendingFormat:@" = '%@'", obj]];
            } else if ([obj isKindOfClass:[NSNumber class]]) {
                [conditions addObject:[key stringByAppendingFormat:@" = %@", obj]];
            } else if (obj == [NSNull null]) {
                [conditions addObject:[key stringByAppendingFormat:@" is null"]];
            }
            else {
                *stop = YES;
            }
        }];

        if ([conditions count] == 0) {
            return nil;
        }

        return [@"WHERE " stringByAppendingString:[conditions componentsJoinedByString:@" AND "]];
    }

    return nil;
}

- (NSString *)orderStatement:(id)order {
    if (!order) return nil;

    if ([order isKindOfClass:[NSString class]]) {
        return [@"ORDER BY " stringByAppendingString:order];
    }

    if ([order isKindOfClass:[NSArray class]]) {
        if (![order count]) return nil;

        return [@"ORDER BY " stringByAppendingString:[order componentsJoinedByString:@","]];
    }

    return nil;
}

- (NSString *)limitStatement:(id)limit {
    if (!limit) return nil;

    if ([limit isKindOfClass:[NSNumber class]]) {
        return [@"LIMIT " stringByAppendingFormat:@"%d", [limit intValue]];
    }

    if ([limit isKindOfClass:[NSArray class]]) {
        NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:2];
        [limit enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if ([obj isKindOfClass:[NSNumber class]]) {
                [array addObject:[NSString stringWithFormat:@"%d", [obj intValue]]];
            }

            if (idx == 1) *stop = YES;
        }];

        if (![array count]) return nil;

        return [@"LIMIT " stringByAppendingString:[array componentsJoinedByString:@","]];
    }

    return nil;
}

- (NSString *)sqlQueryCountWithModelClass:(Class)modelClass where:(id)condition {
    NSMutableArray *stmts = [NSMutableArray array];
    [stmts addSaveObject:[@"SELECT COUNT(*) FROM " stringByAppendingString:[modelClass FMDBTableName]]];
    [stmts addSaveObject:[self whereStatement:condition]];
    return [stmts componentsJoinedByString:@" "];
}

#pragma mark - Model Cache

- (NSString *)cacheKeyForModelClass:(Class)cls withPrimaryId:(int)pk {
    NSString *table = [cls FMDBTableName];
    return [table stringByAppendingFormat:@"-%d", pk];
}

- (NSString *)cacheKeyForModel:(SSKModel *)model {
    NSString *table = [model.class FMDBTableName];
    return [table stringByAppendingFormat:@"-%d", model.primaryId.intValue];
}

- (void)cacheModel:(SSKModel *)model {
    if (!model) return;

    NSString *key = [self cacheKeyForModel:model];

    if ([_modelsCache count] > _maxCachedObjects) {
        [self cleanCache];
        _maxCachedObjects = [_modelsCache count] * 2;
    }

    [_modelsCache setSaveValue:model forKey:key];
}

- (SSKModel *)modelForCacheKey:(NSString *)key {
    if (!key) return nil;
    SSKModel *modle = [_modelsCache objectForKey:key];
    return modle;
}

- (void)removeCachedModel:(SSKModel *)model {
    NSString *key = [self cacheKeyForModel:model];
    [_modelsCache removeObjectForKey:key];
}

- (void)cleanCache {
    for (NSString *key in [_modelsCache allKeys]) {
        SSKModel *model = _modelsCache[key];
        CFIndex retainCount = CFGetRetainCount((__bridge CFTypeRef) model);
        if (retainCount <= 2) {
            [_modelsCache removeObjectForKey:key];
        }
    }
}

#pragma mark - private check table

- (BOOL)checkTableWithModelClass:(Class)modelClass {
    NSString *tableName = [modelClass FMDBTableName];

    if (!tableName.length) {
        _error = [NSError errorWithDomain:kSSKSqlitePersistentStoreErrorDomain
                                     code:0
                                 userInfo:@{@"message" : @"invalid table name"}];
        return NO;
    }

    if (!_tablesCache) {
        _tablesCache = [[NSMutableArray alloc] init];
    }

    if ([_tablesCache containsObject:tableName]) return YES;

    // create table
    NSMutableString *sql = [NSMutableString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (primaryId INTEGER PRIMARY KEY AUTOINCREMENT", tableName];

    NSMutableArray *fields = [NSMutableArray array];

    NSSet *props = [modelClass propertyKeys];
    NSDictionary *columsByPropKey = [modelClass FMDBColumnsByPropertyKey];
    [props enumerateObjectsUsingBlock:^(NSString *prop, BOOL *stop) {
        if ([prop isEqualToString:@"primaryId"]) return;

        NSString *colum = columsByPropKey[prop];

        if ([colum isEqual:NSNull.null]) return;

        colum = colum ? colum : prop;
        NSString *propType = [self propTypeForClass:modelClass withProp:prop];
        if ([self checkIntegerType:propType]) {
            [fields addObject:[colum stringByAppendingString:@" INTEGER"]];
        } else if ([self checkTextType:propType]) {
            [fields addObject:[colum stringByAppendingString:@" TEXT"]];
        } else if ([self checkDateType:propType]) {
            [fields addObject:[colum stringByAppendingString:@" DATETIME"]];
        } else {
            [fields addObject:[colum stringByAppendingString:@" BLOB"]];
        }
    }];

    if ([fields count]) {
        [sql appendFormat:@",%@)", [fields componentsJoinedByString:@","]];
    } else {
        [sql appendString:@")"];
    }

    __block BOOL ret = NO;
    [_dbQueue inDatabase:^(FMDatabase *db) {
        ret = [db executeUpdate:sql];
        [self handleDatabaseError:db];
    }];

    if (ret) {
        [_tablesCache addObject:tableName];
    }

    return ret;
}

- (NSString *)propTypeForClass:(Class)modelClass withProp:(NSString *)prop {
    objc_property_t property_t = class_getProperty(modelClass, prop.UTF8String);
    NSString *attrs = [NSString stringWithUTF8String:property_getAttributes(property_t)];
    if ([attrs rangeOfString:@",R,"].location == NSNotFound) {
        NSArray *attrsComponets = [attrs componentsSeparatedByString:@","];
        return [[attrsComponets firstObject] substringFromIndex:1];
    }
    return nil;
}

- (BOOL)checkIntegerType:(NSString *)prop {
    NSString *p = [prop lowercaseString];
    if ([p isEqualToString:@"i"] || // int, unsigned int
            [p isEqualToString:@"l"] || // long , unsiged long
            [p isEqualToString:@"q"] || // long long
            [p isEqualToString:@"s"] || // short, unsigned short
            [p isEqualToString:@"b"])   // bool, _Bool
    {
        return YES;
    }

    if ([prop hasPrefix:@"@"]) {
        NSString *className = [prop substringWithRange:NSMakeRange(2, prop.length - 3)];
        return [className isEqualToString:@"NSNumber"];
    }

    return NO;
}

- (BOOL)checkTextType:(NSString *)prop {
    if ([prop hasPrefix:@"@"]) {
        NSString *className = [prop substringWithRange:NSMakeRange(2, prop.length - 3)];
        return [className isEqualToString:@"NSString"];
    }

    return NO;
}

- (BOOL)checkDateType:(NSString *)prop {
    if ([prop hasPrefix:@"@"]) {
        NSString *className = [prop substringWithRange:NSMakeRange(2, prop.length - 3)];
        return [className isEqualToString:@"NSDate"];
    }

    return NO;
}

#pragma mark - private handle error

- (void)handleDatabaseError:(FMDatabase *)db {
    _error = nil;

    if ([db hadError]) {
        _error = [NSError errorWithDomain:kSSKSqlitePersistentStoreErrorDomain
                                     code:[db lastErrorCode]
                                 userInfo:@{@"FMDatabase" : [db lastErrorMessage]}];

        DEBUG_LOG(@"catch db error: %@", _error);

        assert(0);
    }
}

- (void)handleErrorWithExcepiton:(NSException *)exp {
    _error = [NSError errorWithDomain:kSSKSqlitePersistentStoreErrorDomain
                                 code:0
                             userInfo:@{@"exception" : exp}];
    DEBUG_LOG(@"catch exception error: %@", _error);

    assert(0);
}

- (void)clearTableCache {
    [_tablesCache removeAllObjects];
}

- (void)clearDataCache {
    [_modelsCache removeAllObjects];
}


@end
