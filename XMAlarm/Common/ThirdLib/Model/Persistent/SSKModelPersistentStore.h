//
//  MTLFMDBAdapter.h
//  Mantle
//
//  Created by Valerio Santinelli on 16/07/14.
//  Copyright (c) 2014 Valerio Santinelli. All rights reserved.
//

@class SSKModel;
@protocol SSKModelPersistentStore;

typedef enum _ModelUpdateType {
    ModelUpdateType_Insert = 0,
    ModelUpdateType_Delete,
    ModelUpdateType_Update
} ModelUpdateType;

@protocol SSKStoreUpdateDelegate <NSObject>
- (void) persistentStore:(id<SSKModelPersistentStore>)store updateModel:(SSKModel*)model withType:(int)type;
@end

@protocol SSKModelPersistentStore <NSObject>

- (void) drop;

- (NSArray*) modelsWithClass:(Class)modelClass limit:(id)limit order:(id)order where:(id)condition args:(va_list)args;

- (NSArray *)modelsWithClass:(Class)modelClass sql:(NSString *)sql;

- (NSUInteger)countWithSql:(NSString *)sql;

- (BOOL)excuteSql:(NSString *)sql;

- (NSUInteger) countOfModelsWithClass:(Class)modelClass where:(id)condition args:(va_list)args;

- (BOOL) clearModelClass:(Class)modelClass;

- (BOOL) saveModel:(SSKModel*)model;
- (BOOL) saveModel:(SSKModel*)model where:(id)condition args:(va_list)args;
- (BOOL) removeModel:(SSKModel*)model;

- (BOOL) saveBatchModels:(NSArray *)models;

- (void) setUpateDelegate:(id<SSKStoreUpdateDelegate>)delegate;
- (id<SSKStoreUpdateDelegate>) updateDelegate;

- (BOOL) backupToPath:(NSString*)path;

-(void)clearTableCache;

-(void)clearDataCache;

@property (nonatomic, readonly) NSError* error;

@end
