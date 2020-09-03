//
//  NSArray+Ext.h
//  OnMobile
//
//  Created by bo.chen on 16/8/29.
//  Copyright © 2016年 keruyun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (Ext)

/**
 * 拷贝数组和数组元素
 */
- (NSMutableArray *)copySelfAndElement;

@end

@interface NSDictionary (Ext)

/**
 * 递归移除NSNull对象
 */
+ (id)recursiveRemoveNSNull:(id)obj;

/**
 * 移除NSNull的字段
 */
- (NSDictionary *)removeNullValues;

/**
 * 移除NSArray的字段
 */
- (NSDictionary *)removeArrayValues;

/**
 * 返回一个需要的keys的新字典
 */
- (NSDictionary *)dictionaryByNeededKeys:(NSArray *)keys;

@end

@interface NSMutableArray (Ext)

- (void)addSaveObject:(id)anObject;

@end

@interface NSMutableDictionary (Ext)

- (void)setSaveValue:(id)value forKey:(NSString *)key;

@end
