//
//  MTLFMDBAdapter.h
//  Mantle
//
//  Created by Valerio Santinelli on 16/07/14.
//  Copyright (c) 2014 Valerio Santinelli. All rights reserved.
//

#import "SSKModel.h"

@interface SSKModel (JSONSerializing)

/*!
 *  @method modelFromJSONDictionary:
 *
 *  @param JSONDictionary The json dictionary will be converted to <code>BaseData</code> object
 *
 *  @discussion Parsing a JSON dictionary into a <code>BaseData</code> object
 *
 *  @see modelsFromJSONArray:
 *
 */
+ (id) modelFromJSONDictionary:(NSDictionary*)JSONDictionary;

/*!
 *  @method modelsFromJSONArray:
 *
 *  @param JSONArray A list of `NSDictionary` objects
 *  
 *  @discussion Parsing a list of JSON dictionary into a list of <code>BaserData</code> objects
 *
 *  @see modelFromJSONDictionary:
 *
 */

+ (NSArray*) modelsFromJSONArray:(NSArray*)JSONArray;
/*!
 *  @method JSONDictionary
 *
 *  @return A JSON dictionary representing the object
 *
 */
- (NSDictionary*) JSONDictionary;

/*!
 *  @method JSONArrayFromModels:
 *
 *  @return A list of JSON dictionaries
 *
 *  @discussion Serializing a list of <code>BaseData</code> objects into a list of JSON dictionaries
 *
 */
+ (NSArray*) JSONArrayFromModels:(NSArray*)models;


@end
