//
//  Api.h
//  Car
//
//  Created by bo.chen on 17/7/26.
//  Copyright © 2017年 com.smaradio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QNDnsManager.h>
typedef void (^SuccessBlock)(id body);
typedef void (^FailBlock)(NSString *message, NSInteger code);
typedef void (^UploadProgBlock)(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite);

#import "CookieUtil.h"

@interface ApiClient : AFHTTPRequestOperationManager
+ (instancetype)sharedInstance;
- (void)initHTTPDns;
- (void)queryIpAddress;
- (NSString *)ipAddressForDomain:(NSString *)domain;
@property (nonatomic, strong) CookieUtil *cookieUtil;
@end

@interface Api : NSObject

+ (AFHTTPRequestOperation *)cityList:(SuccessBlock)success failBlock:(FailBlock)fail;
+ (AFHTTPRequestOperation *)limitCityList:(SuccessBlock)success failBlock:(FailBlock)fail;
+ (AFHTTPRequestOperation *)holidayList:(SuccessBlock)success failBlock:(FailBlock)fail;
+ (AFHTTPRequestOperation *)queryCity:(id)content successBlock:(SuccessBlock)success failBlock:(FailBlock)fail;
+ (AFHTTPRequestOperation *)checkUpdatedCity:(id)content successBlock:(SuccessBlock)success failBlock:(FailBlock)fail;

+ (AFHTTPRequestOperation *)register:(id)content successBlock:(SuccessBlock)success failBlock:(FailBlock)fail;
+ (AFHTTPRequestOperation *)login:(id)content successBlock:(SuccessBlock)success failBlock:(FailBlock)fail;
+ (AFHTTPRequestOperation *)resetPwd:(id)content successBlock:(SuccessBlock)success failBlock:(FailBlock)fail;
+ (AFHTTPRequestOperation *)modifyPwd:(id)content successBlock:(SuccessBlock)success failBlock:(FailBlock)fail;

+ (AFHTTPRequestOperation *)saveSuggest:(id)content successBlock:(SuccessBlock)success failBlock:(FailBlock)fail;
+ (AFHTTPRequestOperation *)checkVersion:(id)content successBlock:(SuccessBlock)success failBlock:(FailBlock)fail;

+ (AFHTTPRequestOperation *)uploadAlarmNum:(id)content successBlock:(SuccessBlock)success failBlock:(FailBlock)fail;

@end
