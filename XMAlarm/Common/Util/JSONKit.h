//
//  JSONKit.h
//  Kouxiaoer
//
//  Created by bo.chen on 14-8-26.
//  Copyright © 2015年 Kouxiaoer. All rights reserved.
//
// Use System's NSJSONSerialization

@interface NSString (JSONKitDeserializing)
- (id)objectFromJSONString_JSONKit;
- (id)objectFromJSONStringWithParseOptions_JSONKit:(NSJSONReadingOptions)parseOptionFlags;
- (id)objectFromJSONStringWithParseOptions_JSONKit:(NSJSONReadingOptions)parseOptionFlags error:(NSError **)error;
- (id)mutableObjectFromJSONString_JSONKit;
- (id)mutableObjectFromJSONStringWithParseOptions_JSONKit:(NSJSONReadingOptions)parseOptionFlags;
- (id)mutableObjectFromJSONStringWithParseOptions_JSONKit:(NSJSONReadingOptions)parseOptionFlags error:(NSError **)error;
@end

@interface NSData (JSONKitDeserializing)
// The NSData MUST be UTF8 encoded JSON.
- (id)objectFromJSONData_JSONKit;
- (id)objectFromJSONDataWithParseOptions_JSONKit:(NSJSONReadingOptions)parseOptionFlags;
- (id)objectFromJSONDataWithParseOptions_JSONKit:(NSJSONReadingOptions)parseOptionFlags error:(NSError **)error;
- (id)mutableObjectFromJSONData_JSONKit;
- (id)mutableObjectFromJSONDataWithParseOptions_JSONKit:(NSJSONReadingOptions)parseOptionFlags;
- (id)mutableObjectFromJSONDataWithParseOptions_JSONKit:(NSJSONReadingOptions)parseOptionFlags error:(NSError **)error;
@end

@interface NSString (JSONKitSerializing)
- (NSData *)JSONData_JSONKit;
- (NSString *)JSONString_JSONKit;
@end

@interface NSNumber (JSONKitSerializing)
- (NSData *)JSONData_JSONKit;
- (NSString *)JSONString_JSONKit;
@end

@interface NSArray (JSONKitSerializing)
- (NSData *)JSONData_JSONKit;
- (NSData *)JSONDataWithOptions_JSONKit:(NSJSONWritingOptions)serializeOptions error:(NSError **)error;
- (NSString *)JSONString_JSONKit;
- (NSString *)JSONStringWithOptions_JSONKit:(NSJSONWritingOptions)serializeOptions error:(NSError **)error;
@end

@interface NSDictionary (JSONKitSerializing)
- (NSData *)JSONData_JSONKit;
- (NSData *)JSONDataWithOptions_JSONKit:(NSJSONWritingOptions)serializeOptions error:(NSError **)error;
- (NSString *)JSONString_JSONKit;
- (NSString *)JSONStringWithOptions_JSONKit:(NSJSONWritingOptions)serializeOptions error:(NSError **)error;
@end
