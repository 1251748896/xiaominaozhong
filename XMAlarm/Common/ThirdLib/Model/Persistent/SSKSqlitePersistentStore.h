//
//  MTLFMDBAdapter.h
//  Mantle
//
//  Created by Valerio Santinelli on 16/07/14.
//  Copyright (c) 2014 Valerio Santinelli. All rights reserved.
//

#import "SSKModelPersistentStore.h"

extern NSString * const kSSKSqlitePersistentStoreErrorDomain;

@interface SSKSqlitePersistentStore : NSObject <SSKModelPersistentStore>

- (id) initWithPath:(NSString*)path;

@property (nonatomic, readonly) NSString* path;

@end
