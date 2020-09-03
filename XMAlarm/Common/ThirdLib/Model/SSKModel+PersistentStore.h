//
//  MTLFMDBAdapter.h
//  Mantle
//
//  Created by Valerio Santinelli on 16/07/14.
//  Copyright (c) 2014 Valerio Santinelli. All rights reserved.
//

#import "SSKModel.h"
#import "FMDB.h"

@protocol SSKModelPersistentStore;

@interface SSKModel (PersistentStore)

/*!
 *  @method setPersistentStore:
 *
 *  @param store The store will perform `Model` store or fetch
 *
 *  @discussion Set persitent store
 */
+ (void)setPersistentStore:(id <SSKModelPersistentStore>)store;

/*!
 *
 *  @method persitentStore
 * 
 *  @return Current persitent store object
 *
 */
+ (id <SSKModelPersistentStore>)persitentStore;

/*!
 *  @method modelFromFMResultSet:
 *
 *  @param ResultSet FMDBResoltSet object
 *  
 *  @return <code>BaseData</code> objcet
 *
 *  @discussion Parsing a FMDBResoltSet object into `BaseData` object
 *
 */
+ (id)modelFromFMResultSet:(FMResultSet *)ResultSet;

/*!
 *  @method modelsFromFMResultSetArray:
 *
 *  @param FMResultSet FMDBResoltSet object
 *  
 *  @return A list of <code>BaseData</code> objects
 *
 *  @discussion Parsing a FMDBResoltSet object to a list of <code>BaseData</code> objects
 *
 */
+ (NSArray *)modelsFromFMResultSetArray:(FMResultSet *)FMResultSet;

/*!
 *  @method save
 *
 *  @discussion Persistent this object into store. Updating model in database if the primaryId or serverId of the model mach with the database record. otherwise, insert the model to database
 */
- (BOOL)save;

/*!
 *  @method saveWhere:
 *  
 *  @param condition Updating model in database if the condition is satisfyed. otherwise, insert the model into database. if contition is nil, the same as <code>save</code>
 *
 *  @see where:
 *  @see save
 */
- (BOOL)saveWhere:(id)condition, ...;

/*!
 *  @method remove
 *  
 *  @discussion Remove this object form store
 */
- (BOOL)remove;

/*!
 *  @method insertBatchModels:
 *
 *  @param models A list of `BaseData` objects
 *
 *  @discussion Saving a batch of `BaseData` objects into store. This operation may be perform in sqlite transaction for performance. This function DONT perform updating for primaryId or serverId
 *
 */
+ (BOOL)insertBatchModels:(NSArray *)models;

/*!
 *  @method all
 *
 *  @return A list of `BaseData` objects
 *
 *  @discussion Finding all records in store for this Model
 */
+ (NSArray *)all;

/*!
 *  @method where:
 *
 *  @param condition query condition
 *
 *  @return A list of `BaseData` objects
 *
 *  @discussion Querying all `BaseData` satisfying the condition in the store
 */
+ (NSArray *)where:(id)condition, ...;

/*!
 *  @method order:where
 *  
 *  @param order order by
 *  @param where Qurey condition
 *
 *  @return A list of `BaseData` objects
 *
 *  @discussion Querying all `BaseData` satisfying the condition in store and order by `order`
 *
 */
+ (NSArray *)order:(id)order where:(id)condition, ...;

/*!
 *  @method find:
 *
 *  @param the find condition
 *
 *  @return An object of `BaseData`
 *
 *  @discussion Find An object of `BaseData` satisfying the condition in the store
 */
+ (id)find:(id)condition, ...;

/*!
 *  @method query:
 *
 *  @param the find  sql @{ select d.name as dishName,dy.name as dsihTypeName   from dish d,dish type dy where d.dishTypeId=dy.serverId }
 *
 * @ modelClass custom SSKModel
 *
 *  @return An object of `Simple Customer SSKModel`
 *
 *  @discussion Find An object of `BaseData` satisfying the condition in the store
 */
+ (NSArray *)query:(Class)modelClass sql:(NSString *)sql;

/*!
 *  @method findLimit:order:where
 *
 *  @param limit 
 *  @param order
 *  @param condition
 *
 *  @return An object of `BaseData`
 *
 *  @discussion
 */
+ (id)findLimit:(id)limit order:(id)order where:(id)condition, ...;

/*!
 *  @method limit:order:where
 *
 *  @param limit Query limit. The type SHOULD be `NSNumber` or `NSArray<NSNumber*>`. EX. `@100` or `@[@0,@100]`
 *
 *  @param order The type of param order SHOULD be `NSString` or `NSArray<NSString*>`. EX.
           `@"createdTime"`,`@[@"primaryId",@"createdTime"]`
    The suffix @"DESC" can be specified. EX. `@"createdTime DESC"`
 *
 *  @param condition The type of order param SHOULD be `NSString` or `NSSArray<NSString*>` or `NSDictionary<NSString*,NSString* or NSNumber*>`. EX.
         `@"deleted = '0' and status = 1`  <=>
         `@[@"deleted = '0'",@"status = 1"]` <=> 
         `@{@"deleted": @"0", @"status" : @1}`. 
         The key and value will be joined by `@"="` if the type is kind of key-value pair.
         The components will be joined by `@"AND"` if the type is kind of `NSArray` or `NSDictionary`
 *
 *  @param condition The query condition. support SQL bind syntax. EX. 
    `[Customer limit:nil order:nil where:@"deleted = '0' and createdTime < ?", [NSDate today]]`
 *
 *  @return A list of objects
 */
+ (NSArray *)limit:(id)limit order:(id)order where:(id)condition, ...;


/*!
 *  @method coutWhere:
 *
 *  @param condition Query condition
 *
 *  @return The count of objects satisfying the condition in the store
 *
 *  @discussion
 */
+ (NSUInteger)countWithSql:(NSString *)sql;

/*!
 *  @method coutWhere:
 *  
 *  @param condition Query condition
 *
 *  @return The count of objects satisfying the condition in the store
 *
 *  @discussion
 */
+ (NSUInteger)countWhere:(id)condition, ...;

/*!
 *  @method clear
 *
 *  @discussion Removing all records of this model from the store
 */
+ (BOOL)clear;


/*!
 *  @method excuteUpdateSql
 *
 *  @discussion update action
 */
+ (BOOL)excuteSql:(NSString *)sql;

/**
 *
 *  remove  table name cache
 */
+ (void)clearTableCache;

/**
 * remove data Cache
 */
+ (void)clearDataCache;

@end
