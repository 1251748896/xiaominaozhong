//
//  JSONKit.m
//  Kouxiaoer
//
//  Created by bo.chen on 14-8-26.
//  Copyright © 2015年 Kouxiaoer. All rights reserved.
//

@implementation NSString (JSONKitDeserializing)

- (id)objectFromJSONString_JSONKit
{
    return [self objectFromJSONStringWithParseOptions_JSONKit:NSJSONReadingAllowFragments error:NULL];
}

- (id)objectFromJSONStringWithParseOptions_JSONKit:(NSJSONReadingOptions)parseOptionFlags
{
    return [self objectFromJSONStringWithParseOptions_JSONKit:parseOptionFlags error:NULL];
}

- (id)objectFromJSONStringWithParseOptions_JSONKit:(NSJSONReadingOptions)parseOptionFlags error:(NSError **)error
{
    return [NSJSONSerialization JSONObjectWithData:[self dataUsingEncoding:NSUTF8StringEncoding] options:parseOptionFlags error:error];
}

- (id)mutableObjectFromJSONString_JSONKit
{
    return [self mutableObjectFromJSONStringWithParseOptions_JSONKit:NSJSONReadingAllowFragments error:NULL];
}

- (id)mutableObjectFromJSONStringWithParseOptions_JSONKit:(NSJSONReadingOptions)parseOptionFlags
{
    return [self mutableObjectFromJSONStringWithParseOptions_JSONKit:parseOptionFlags error:NULL];
}

- (id)mutableObjectFromJSONStringWithParseOptions_JSONKit:(NSJSONReadingOptions)parseOptionFlags error:(NSError **)error
{
    return [NSJSONSerialization JSONObjectWithData:[self dataUsingEncoding:NSUTF8StringEncoding] options:parseOptionFlags | NSJSONReadingMutableContainers error:error];
}

@end

@implementation NSData (JSONKitDeserializing)

- (id)objectFromJSONData_JSONKit
{
    return [self objectFromJSONDataWithParseOptions_JSONKit:NSJSONReadingAllowFragments error:NULL];
}

- (id)objectFromJSONDataWithParseOptions_JSONKit:(NSJSONReadingOptions)parseOptionFlags
{
    return [self objectFromJSONDataWithParseOptions_JSONKit:parseOptionFlags error:NULL];
}

- (id)objectFromJSONDataWithParseOptions_JSONKit:(NSJSONReadingOptions)parseOptionFlags error:(NSError **)error
{
    return [NSJSONSerialization JSONObjectWithData:self options:parseOptionFlags error:error];
}

- (id)mutableObjectFromJSONData_JSONKit
{
    return [self mutableObjectFromJSONDataWithParseOptions_JSONKit:NSJSONReadingAllowFragments error:NULL];
}

- (id)mutableObjectFromJSONDataWithParseOptions_JSONKit:(NSJSONReadingOptions)parseOptionFlags
{
    return [self mutableObjectFromJSONDataWithParseOptions_JSONKit:parseOptionFlags error:NULL];
}

- (id)mutableObjectFromJSONDataWithParseOptions_JSONKit:(NSJSONReadingOptions)parseOptionFlags error:(NSError **)error
{
    return [NSJSONSerialization JSONObjectWithData:self options:parseOptionFlags | NSJSONReadingMutableContainers error:error];
}

@end

@implementation NSString (JSONKitSerializing)

- (NSData *)JSONData_JSONKit
{
    return [self dataUsingEncoding:NSUTF8StringEncoding];
}

- (NSString *)JSONString_JSONKit
{
    return self;
}

@end

@implementation NSNumber (JSONKitSerializing)

- (NSData *)JSONData_JSONKit
{
    return [[self description] dataUsingEncoding:NSUTF8StringEncoding];
}

- (NSString *)JSONString_JSONKit
{
    return [self description];
}

@end

@implementation NSArray (JSONKitSerializing)

- (NSData *)JSONData_JSONKit
{
    return [self JSONDataWithOptions_JSONKit:0 error:NULL];
}

- (NSData *)JSONDataWithOptions_JSONKit:(NSJSONWritingOptions)serializeOptions error:(NSError **)error
{
    return [NSJSONSerialization dataWithJSONObject:self options:serializeOptions error:error];
}

- (NSString *)JSONString_JSONKit
{
    return [self JSONStringWithOptions_JSONKit:0 error:NULL];
}

- (NSString *)JSONStringWithOptions_JSONKit:(NSJSONWritingOptions)serializeOptions error:(NSError **)error
{
    NSData *data = [self JSONDataWithOptions_JSONKit:serializeOptions error:error];
    if (data) {
        return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    }
    return nil;
}

@end

@implementation NSDictionary (JSONKitSerializing)

- (NSData *)JSONData_JSONKit
{
    return [self JSONDataWithOptions_JSONKit:0 error:NULL];
}

- (NSData *)JSONDataWithOptions_JSONKit:(NSJSONWritingOptions)serializeOptions error:(NSError **)error
{
    return [NSJSONSerialization dataWithJSONObject:self options:serializeOptions error:error];
}

- (NSString *)JSONString_JSONKit
{
    return [self JSONStringWithOptions_JSONKit:0 error:NULL];
}

- (NSString *)JSONStringWithOptions_JSONKit:(NSJSONWritingOptions)serializeOptions error:(NSError **)error
{
    NSData *data = [self JSONDataWithOptions_JSONKit:serializeOptions error:error];
    if (data) {
        return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    }
    return nil;
}

@end
