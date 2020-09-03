//
//  NSArray+Ext.m
//  OnMobile
//
//  Created by bo.chen on 16/8/29.
//  Copyright © 2016年 keruyun. All rights reserved.
//

#import "NSArray+Ext.h"

@implementation NSArray (Ext)

/**
 * 拷贝数组和数组元素
 */
- (NSMutableArray *)copySelfAndElement {
    NSMutableArray *tmp = [NSMutableArray array];
    for (id obj in self) {
        if ([obj respondsToSelector:@selector(copy)]) {
            [tmp addObject:[obj copy]];
        } else {
            [tmp addObject:obj];
        }
    }
    return tmp;
}

@end

@implementation NSDictionary (Ext)

/**
 * 递归移除NSNull对象
 */
+ (id)recursiveRemoveNSNull:(id)obj {
    if ([obj isKindOfClass:[NSArray class]]) {
        NSMutableArray *array = [NSMutableArray array];
        for (id subObj in obj) {
            id newObj = [self recursiveRemoveNSNull:subObj];
            if (newObj) {
                [array addObject:newObj];
            }
        }
        return array;
    } else if ([obj isKindOfClass:[NSDictionary class]]) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        for (id key in [obj allKeys]) {
            dict[key] = [self recursiveRemoveNSNull:obj[key]];
        }
        return dict;
    } else if ([obj isKindOfClass:[NSNull class]]) {
        return nil;
    } else {
        return obj;
    }
}

/**
 * 移除NSNull的字段
 */
- (NSDictionary *)removeNullValues {
    NSMutableDictionary *newDict = [NSMutableDictionary dictionary];
    for (NSString *key in self.allKeys) {
        if (![self[key] isKindOfClass:[NSNull class]]) {
            newDict[key] = self[key];
        }
    }
    return newDict;
}

/**
 * 移除NSArray的字段
 */
- (NSDictionary *)removeArrayValues {
    NSMutableDictionary *newDict = [NSMutableDictionary dictionary];
    for (NSString *key in self.allKeys) {
        if (![self[key] isKindOfClass:[NSArray class]]) {
            newDict[key] = self[key];
        }
    }
    return newDict;
}

/**
 * 返回一个需要的keys的新字典
 */
- (NSDictionary *)dictionaryByNeededKeys:(NSArray *)keys {
    NSMutableDictionary *newDict = [NSMutableDictionary dictionary];
    for (NSString *key in keys) {
        newDict[key] = self[key];
    }
    return newDict;
}

@end

@implementation NSMutableArray (Ext)

- (void)addSaveObject:(id)anObject {
    if (anObject) {
        [self addObject:anObject];
    }
}

@end

@implementation NSMutableDictionary (Ext)

- (void)setSaveValue:(id)value forKey:(NSString *)key {
    if (value != nil) {
        [self setObject:value forKey:key];
    }
    else if (key != nil) {
        [self removeObjectForKey:key];
    }
}

@end
