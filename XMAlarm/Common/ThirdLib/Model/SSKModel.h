//
//  MTLFMDBAdapter.h
//  Mantle
//
//  Created by Valerio Santinelli on 16/07/14.
//  Copyright (c) 2014 Valerio Santinelli. All rights reserved.
//

#import "Mantle.h"
#import "MTLFMDBAdapter.h"

/*
 * 基础数据类型
 */
@interface SSKModel : MTLModel <MTLFMDBSerializing, MTLJSONSerializing>
@property (nonatomic, retain) NSNumber *primaryId;      // 本地Id号－自增
@property (nonatomic, retain) NSString *serverId;       // 服务器Id号

@end
