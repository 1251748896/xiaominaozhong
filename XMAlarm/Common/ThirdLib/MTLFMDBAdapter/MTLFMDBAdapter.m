//
//  MTLFMDBAdapter.m
//  TiVoto
//
//  Created by Valerio Santinelli on 16/07/14.
//  Copyright (c) 2014 Altralogica s.r.l. All rights reserved.
//

#import <objc/runtime.h>
#import <Mantle/Mantle.h>
#import <MTLEXTRuntimeExtensions.h>
#import <MTLEXTScope.h>
#import <Mantle/MTLReflection.h>
#import <FMDB/FMDB.h>
#import "MTLFMDBAdapter.h"

NSString * const MTLFMDBAdapterErrorDomain = @"MTLFMDBAdapterErrorDomain";
const NSInteger MTLFMDBAdapterErrorInvalidFMResultSet = 2;
const NSInteger MTLFMDBAdapterErrorInvalidFMResultSetMapping = 3;

// An exception was thrown and caught.
const NSInteger MTLFMDBAdapterErrorExceptionThrown = 1;

// Associated with the NSException that was caught.
static NSString * const MTLFMDBAdapterThrownExceptionErrorKey = @"MTLFMDBAdapterThrownException";

@interface MTLFMDBAdapter ()

// The MTLModel subclass being parsed, or the class of `model` if parsing has
// completed.
@property (nonatomic, strong, readonly) Class modelClass;

@property (nonatomic, copy, readonly) NSDictionary *FMDBColumnsByPropertyKey;

@end

@implementation MTLFMDBAdapter

#pragma mark Convenience methods

+ (id)modelOfClass:(Class)modelClass fromFMResultSet:(FMResultSet *)resultSet error:(NSError **)error {
	MTLFMDBAdapter *adapter = [[self alloc] initWithFMResultSet:resultSet modelClass:modelClass error:error];
	return adapter.model;
}

- (id)init {
	NSAssert(NO, @"%@ must be initialized with a FMResultSet or model object", self.class);
	return nil;
}

- (id)initWithFMResultSet:(FMResultSet *)resultSet modelClass:(Class)modelClass error:(NSError **)error {
	NSParameterAssert(modelClass != nil);
	NSParameterAssert([modelClass isSubclassOfClass:MTLModel.class]);
	NSParameterAssert([modelClass conformsToProtocol:@protocol(MTLFMDBSerializing)]);
    
	if (resultSet == nil || ![resultSet isKindOfClass:FMResultSet.class]) {
		if (error != NULL) {
			NSDictionary *userInfo = @{
                                       NSLocalizedDescriptionKey: NSLocalizedString(@"Missing FMResultSet", @""),
                                       NSLocalizedFailureReasonErrorKey: [NSString stringWithFormat:NSLocalizedString(@"%@ could not be created because an invalid result set was provided: %@", @""), NSStringFromClass(modelClass), resultSet.class],
                                       };
			*error = [NSError errorWithDomain:MTLJSONAdapterErrorDomain code:MTLJSONAdapterErrorInvalidJSONDictionary userInfo:userInfo];
		}
		return nil;
	}
    
    /*
	if ([modelClass respondsToSelector:@selector(classForParsingJSONDictionary:)]) {
		modelClass = [modelClass classForParsingJSONDictionary:JSONDictionary];
		if (modelClass == nil) {
			if (error != NULL) {
				NSDictionary *userInfo = @{
                                           NSLocalizedDescriptionKey: NSLocalizedString(@"Could not parse JSON", @""),
                                           NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"No model class could be found to parse the JSON dictionary.", @"")
                                           };
                
				*error = [NSError errorWithDomain:MTLJSONAdapterErrorDomain code:MTLJSONAdapterErrorNoClassFound userInfo:userInfo];
			}
            
			return nil;
		}
        
		NSAssert([modelClass isSubclassOfClass:MTLModel.class], @"Class %@ returned from +classForParsingJSONDictionary: is not a subclass of MTLModel", modelClass);
		NSAssert([modelClass conformsToProtocol:@protocol(MTLJSONSerializing)], @"Class %@ returned from +classForParsingJSONDictionary: does not conform to <MTLJSONSerializing>", modelClass);
	}
    */
    
	self = [super init];
	if (self == nil) return nil;
    
	_modelClass = modelClass;
	_FMDBColumnsByPropertyKey = [[modelClass FMDBColumnsByPropertyKey] copy];
    
	NSMutableDictionary *dictionaryValue = [[NSMutableDictionary alloc] initWithCapacity:self.FMDBDictionary.count];
    
	NSSet *propertyKeys = [self.modelClass propertyKeys];
    NSArray *Keys = [[propertyKeys allObjects] sortedArrayUsingSelector:@selector(compare:)];
    
	for (NSString *columnName in self.FMDBColumnsByPropertyKey) {
		if ([Keys containsObject:columnName]) continue;
        
		if (error != NULL) {
			NSDictionary *userInfo = @{
                                       NSLocalizedDescriptionKey: NSLocalizedString(@"Invalid FMDB mapping", nil),
                                       NSLocalizedFailureReasonErrorKey: [NSString stringWithFormat:NSLocalizedString(@"%1$@ could not be parsed because its FMDB mapping contains illegal property keys.", nil), modelClass]
                                       };
            
			*error = [NSError errorWithDomain:MTLFMDBAdapterErrorDomain code:MTLFMDBAdapterErrorInvalidFMResultSetMapping userInfo:userInfo];
		}
        
		return nil;
	}
    
	for (NSString *propertyKey in Keys) {
		NSString *columnName = [self FMDBColumnForPropertyKey:propertyKey];
		if (columnName == nil) continue;
        
        Class cls = [self propertyClassMapping][propertyKey];
		id value;
		@try {
            if ([cls isSubclassOfClass:[NSString class]]) {
                value = [resultSet stringForColumn:columnName];
            } else if ([cls isSubclassOfClass:[NSDate class]]) {
                value = [resultSet dateForColumn:columnName];
            } else if ([cls isSubclassOfClass:[NSNumber class]]) {
                value = [NSNumber numberWithDouble:[[resultSet stringForColumn:columnName] doubleValue]];
            } else {
                value = [resultSet dataForColumn:columnName];
            }
		} @catch (NSException *ex) {
			if (error != NULL) {
				NSDictionary *userInfo = @{
                                           NSLocalizedDescriptionKey: NSLocalizedString(@"Invalid FMResultSet", nil),
                                           NSLocalizedFailureReasonErrorKey: [NSString stringWithFormat:NSLocalizedString(@"%1$@ could not be parsed because an invalid dictionary was provided for column \"%2$@\"", nil), modelClass, columnName],
                                           MTLFMDBAdapterThrownExceptionErrorKey: ex
                                           };
                
				*error = [NSError errorWithDomain:MTLFMDBAdapterErrorDomain code:MTLFMDBAdapterErrorInvalidFMResultSet userInfo:userInfo];
			}
            
			return nil;
		}
        
		if (value == nil) continue;
        
		@try {
			NSValueTransformer *transformer = [self transformerMapping][propertyKey];
			if (transformer != nil) {
				// Map NSNull -> nil for the transformer, and then back for the
				// dictionary we're going to insert into.
				if ([value isEqual:NSNull.null]) value = nil;
				value = [transformer transformedValue:value] ?: NSNull.null;
			}
            
			dictionaryValue[propertyKey] = value;
		} @catch (NSException *ex) {
			NSLog(@"*** Caught exception %@ parsing column \"%@\" from: %@", ex, columnName, self.FMDBDictionary);
            
			// Fail fast in Debug builds.
#if DEBUG
			@throw ex;
#else
			if (error != NULL) {
				NSDictionary *userInfo = @{
                                           NSLocalizedDescriptionKey: ex.description,
                                           NSLocalizedFailureReasonErrorKey: ex.reason,
                                           MTLFMDBAdapterThrownExceptionErrorKey: ex
                                           };
                
				*error = [NSError errorWithDomain:MTLFMDBAdapterErrorDomain code:MTLFMDBAdapterErrorExceptionThrown userInfo:userInfo];
			}
            
			return nil;
#endif
		}
	}
    
    
	_model = [self.modelClass modelWithDictionary:dictionaryValue error:error];
	if (_model == nil) return nil;
    
	return self;
}


#pragma mark Serialization

- (NSDictionary *)FMDBDictionary {
	NSDictionary *dictionaryValue = self.model.dictionaryValue;
	NSMutableDictionary *FMDBDictionary = [[NSMutableDictionary alloc] initWithCapacity:dictionaryValue.count];
    
	[dictionaryValue enumerateKeysAndObjectsUsingBlock:^(NSString *propertyKey, id value, BOOL *stop) {
		NSString *columnName = [self FMDBColumnForPropertyKey:propertyKey];
		if (columnName == nil) return;
        
		NSValueTransformer *transformer = [self FMDBTransformerForKey:propertyKey];
		if ([transformer.class allowsReverseTransformation]) {
			// Map NSNull -> nil for the transformer, and then back for the
			// dictionaryValue we're going to insert into.
			if ([value isEqual:NSNull.null]) value = nil;
			value = [transformer reverseTransformedValue:value] ?: NSNull.null;
		}
        
		NSArray *keyPathComponents = [columnName componentsSeparatedByString:@"."];
        
		// Set up dictionaries at each step of the key path.
		id obj = FMDBDictionary;
		for (NSString *component in keyPathComponents) {
			if ([obj valueForKey:component] == nil) {
				// Insert an empty mutable dictionary at this spot so that we
				// can set the whole key path afterward.
				[obj setValue:[NSMutableDictionary dictionary] forKey:component];
			}
            
			obj = [obj valueForKey:component];
		}
        
		[FMDBDictionary setValue:value forKeyPath:columnName];
	}];
    
	return FMDBDictionary;
}

+ (NSValueTransformer*) FMDBTransformerWithModelClass:(Class)modelClass forKey:(NSString*) key {
	NSParameterAssert(key != nil);
    
	SEL selector = MTLSelectorWithKeyPattern(key, "FMDBTransformer");
	if ([modelClass respondsToSelector:selector]) {
		NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[modelClass methodSignatureForSelector:selector]];
		invocation.target = modelClass;
		invocation.selector = selector;
		[invocation invoke];
        
		__unsafe_unretained id result = nil;
		[invocation getReturnValue:&result];
		return result;
	}
    
	if ([modelClass respondsToSelector:@selector(FMDBTransformerForKey:)]) {
		return [modelClass FMDBTransformerForKey:key];
	}
    
	return nil;
}

- (NSValueTransformer *)FMDBTransformerForKey:(NSString *)key {
	NSParameterAssert(key != nil);
    
	SEL selector = MTLSelectorWithKeyPattern(key, "FMDBTransformer");
	if ([self.modelClass respondsToSelector:selector]) {
		NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[self.modelClass methodSignatureForSelector:selector]];
		invocation.target = self.modelClass;
		invocation.selector = selector;
		[invocation invoke];
        
		__unsafe_unretained id result = nil;
		[invocation getReturnValue:&result];
		return result;
	}
    
	if ([self.modelClass respondsToSelector:@selector(FMDBTransformerForKey:)]) {
		return [self.modelClass FMDBTransformerForKey:key];
	}
    
	return nil;
}

- (NSString *)FMDBColumnForPropertyKey:(NSString *)key {
	NSParameterAssert(key != nil);
    
	id columnName = self.FMDBColumnsByPropertyKey[key];
	if ([columnName isEqual:NSNull.null]) return nil;
    
	if (columnName == nil) {
		return key;
	} else {
		return columnName;
	}
}

+ (NSString *)propertyKeyForModel:(MTLModel<MTLFMDBSerializing> *)model column:(NSString *)column
{
    NSDictionary *columns = [model.class FMDBColumnsByPropertyKey];
    NSArray *allValues = [columns allValues];
    NSArray *allPropertyKeys = [columns allKeys];
    NSString *propertyKey = nil;
    NSIndexSet *idx = [allValues indexesOfObjectsPassingTest:^BOOL(NSString *obj, NSUInteger idx, BOOL *stop) {
        if (![obj isKindOfClass:NSNull.class] && ([obj caseInsensitiveCompare:column] == NSOrderedSame)) return YES;
        return NO;
    }];
    if (idx.count > 0 ) propertyKey = allPropertyKeys[idx.firstIndex];
    return propertyKey ? : column;
}

+ (NSArray *)primaryKeysValues:(MTLModel<MTLFMDBSerializing> *)model {
    NSDictionary *dictionaryValue = model.dictionaryValue;
    NSArray *keys = [model.class FMDBPrimaryKeys];
    NSMutableArray *values = [NSMutableArray array];
    for (NSString *key in keys) {
        NSString *propertyKey = [self propertyKeyForModel:model column:key];
        [values addObject:[dictionaryValue valueForKey:propertyKey]];
    }
    
    return values;
}

+ (NSArray *)columnValues:(MTLModel<MTLFMDBSerializing> *)model {
    NSDictionary *columns = [model.class FMDBColumnsByPropertyKey];
	NSSet *propertyKeys = [model.class propertyKeys];
    NSArray *Keys = [[propertyKeys allObjects] sortedArrayUsingSelector:@selector(compare:)];
    NSDictionary *dictionaryValue = model.dictionaryValue;
    NSMutableArray *values = [NSMutableArray array];
    for (NSString *propertyKey in Keys)
    {
		NSString *keyPath = columns[propertyKey];
        keyPath = keyPath ? : propertyKey;
        
        if (keyPath != nil && ![keyPath isEqual:[NSNull null]])
        {
            id value = [dictionaryValue valueForKey:propertyKey];
            
			NSValueTransformer* transformer = [self.class FMDBTransformerWithModelClass:model.class forKey:propertyKey];
			if (transformer != nil) {
				// Map NSNull -> nil for the transformer, and then back for the
				// dictionary we're going to insert into.
				if ([value isEqual:NSNull.null]) value = nil;
				value = [transformer reverseTransformedValue:value] ?: NSNull.null;
			}
            
            [values addObject:value];
        }
    }
    return values;
}

+ (NSString *)insertStatementForModel:(MTLModel<MTLFMDBSerializing> *)model {
    NSDictionary *columns = [model.class FMDBColumnsByPropertyKey];
	NSSet *propertyKeys = [model.class propertyKeys];
    NSArray *Keys = [[propertyKeys allObjects] sortedArrayUsingSelector:@selector(compare:)];
    NSMutableArray *stats = [NSMutableArray array];
    NSMutableArray *qmarks = [NSMutableArray array];
	for (NSString *propertyKey in Keys)
    {
		NSString *keyPath = columns[propertyKey];
        keyPath = keyPath ? : propertyKey;
        
        if (keyPath != nil && ![keyPath isEqual:[NSNull null]])
        {
            [stats addObject:keyPath];
            [qmarks addObject:@"?"];
        }
    }
    
    NSString *statement = [NSString stringWithFormat:@"insert into %@ (%@) values (%@)", [model.class FMDBTableName], [stats componentsJoinedByString:@", "], [qmarks componentsJoinedByString:@", "]];
    
    return statement;
}

+ (NSString *)updateStatementForModel:(MTLModel<MTLFMDBSerializing> *)model {
    // Build the where statement
    NSArray *keys = [model.class FMDBPrimaryKeys];
    NSMutableArray *where = [NSMutableArray array];
    for (NSString *key in keys) {
        NSString *s = [NSString stringWithFormat:@"%@ = ?", key];
        [where addObject:s];
    }

    NSDictionary *columns = [model.class FMDBColumnsByPropertyKey];
	NSSet *propertyKeys = [model.class propertyKeys];
    NSArray *Keys = [[propertyKeys allObjects] sortedArrayUsingSelector:@selector(compare:)];
    NSMutableArray *stats = [NSMutableArray array];
	for (NSString *propertyKey in Keys) {
		NSString *keyPath = columns[propertyKey];
        keyPath = keyPath ? : propertyKey;
        
        if (keyPath != nil && ![keyPath isEqual:[NSNull null]]) {
            NSString *s = [NSString stringWithFormat:@"%@ = ?", keyPath];
            [stats addObject:s];
        }
    }
    
    NSString *statement = [NSString stringWithFormat:@"update %@ set %@ where %@", [model.class FMDBTableName], [stats componentsJoinedByString:@", "], [where componentsJoinedByString:@", "]];
    
    return statement;
}

+ (NSString *)deleteStatementForModel:(MTLModel<MTLFMDBSerializing> *)model {
    NSParameterAssert([model.class conformsToProtocol:@protocol(MTLFMDBSerializing)]);
    
    NSArray *keys = [model.class FMDBPrimaryKeys];
    NSMutableArray *stats = [NSMutableArray array];
    for (NSString *key in keys) {
        NSString *s = [NSString stringWithFormat:@"%@ = ?", key];
        [stats addObject:s];
    }
    NSString *statement = [NSString stringWithFormat:@"delete from %@ where %@", [model.class FMDBTableName], [stats componentsJoinedByString:@" AND "]];
    
    return statement;
}

#pragma mark - property class cache
static void *MTLFMDBPropertyClassMappingKey = &MTLFMDBPropertyClassMappingKey;

- (NSDictionary*) propertyClassMapping {
    id m = objc_getAssociatedObject(self.modelClass, MTLFMDBPropertyClassMappingKey);
    if (m) return m;
    
    NSSet* propertyKeys = [self.modelClass propertyKeys];
    NSMutableDictionary* mapping = [[NSMutableDictionary alloc] initWithCapacity:propertyKeys.count];
    [propertyKeys enumerateObjectsUsingBlock:^(NSString* propertyKey, BOOL *stop) {
        NSString* propType = [self propTypeForClass:self.modelClass withProp:propertyKey];
        if ([self checkIntegerType:propType]) {
            [mapping setObject:[NSNumber class] forKey:propertyKey];
        } else if ([self checkTextType:propType]) {
            [mapping setObject:[NSString class] forKey:propertyKey];
        } else if ([self checkDateType:propType]) {
            [mapping setObject:[NSDate class] forKey:propertyKey];
        } else {
            [mapping setObject:[NSData class] forKey:propertyKey];
        }
    }];
    
    objc_setAssociatedObject(self.modelClass, MTLFMDBPropertyClassMappingKey, mapping, OBJC_ASSOCIATION_RETAIN);
    return mapping;
}

#pragma mark - property transformer cache
static void *MTLFMDBTransformerMappingKey = &MTLFMDBTransformerMappingKey;

- (NSDictionary*) transformerMapping {
    id dic = objc_getAssociatedObject(self.modelClass, MTLFMDBTransformerMappingKey);
    if (dic) return dic;
    
    NSMutableDictionary* mapping = [NSMutableDictionary dictionary];
    NSSet* propertyKeys = [self.modelClass propertyKeys];
    [propertyKeys enumerateObjectsUsingBlock:^(NSString* propertyKey, BOOL *stop) {
        NSValueTransformer *transformer = [self FMDBTransformerForKey:propertyKey];
        if (transformer) {
            [mapping setObject:transformer forKey:propertyKey];
        }
    }];
    
    objc_setAssociatedObject(self.modelClass, MTLFMDBTransformerMappingKey, mapping, OBJC_ASSOCIATION_RETAIN);
    return mapping;
    
}

#pragma mark - private
- (NSString*) propTypeForClass:(Class)modelClass withProp:(NSString*)prop {
    objc_property_t property_t = class_getProperty(modelClass, prop.UTF8String);
    NSString* attrs = [NSString stringWithUTF8String:property_getAttributes(property_t)];
    if ([attrs rangeOfString:@",R,"].location == NSNotFound) {
        NSArray* attrsComponets = [attrs componentsSeparatedByString:@","];
        return [[attrsComponets firstObject] substringFromIndex:1];
    }
    return nil;
}

- (BOOL) checkIntegerType:(NSString*)prop {
    NSString* p = [prop lowercaseString];
    if ([p isEqualToString:@"i"] || // int, unsigned int
        [p isEqualToString:@"l"] || // long , unsiged long
        [p isEqualToString:@"q"] || // long long
        [p isEqualToString:@"s"] || // short, unsigned short
        [p isEqualToString:@"b"])   // bool, _Bool
    {
        return YES;
    }
    
    if ([prop hasPrefix:@"@"]) {
        NSString* className = [prop substringWithRange:NSMakeRange(2, prop.length-3)];
        return [className isEqualToString:@"NSNumber"];
    }
    
    return NO;
}

- (BOOL) checkTextType:(NSString*)prop {
    if ([prop hasPrefix:@"@"]) {
        NSString* className = [prop substringWithRange:NSMakeRange(2, prop.length-3)];
        return [className isEqualToString:@"NSString"];
    }
    
    return NO;
}

- (BOOL) checkDateType:(NSString*)prop {
    if ([prop hasPrefix:@"@"]) {
        NSString* className = [prop substringWithRange:NSMakeRange(2, prop.length-3)];
        return [className isEqualToString:@"NSDate"];
    }
    
    return NO;
}

@end