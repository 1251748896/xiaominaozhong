//
//  Api.m
//  Car
//
//  Created by bo.chen on 17/7/26.
//  Copyright © 2017年 com.smaradio. All rights reserved.
//

#import "Api.h"
#import "NSArray+Ext.h"
#import <QNResolver.h>
#import <QNDnspodEnterprise.h>
#import <QNDnspodFree.h>
#import <QNNetworkInfo.h>

@interface ApiClient ()
@property (nonatomic, strong) QNDnsManager *dnsManager;
@property (atomic, strong) NSMutableDictionary *domainIpDict;
@property (nonatomic, strong) NSLock *lock;
@end

@implementation ApiClient

+ (instancetype)sharedInstance {
    static ApiClient *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] initWithBaseURL:nil];
    });
    return instance;
}

- (id)initWithBaseURL:(NSURL *)url {
    self = [super initWithBaseURL:url];
    if (self) {
        [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];
        self.requestSerializer = [AFJSONRequestSerializer serializer];
        [self.requestSerializer setValue:@"gzip" forHTTPHeaderField:@"Accept-Encoding"];
        [self.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        self.responseSerializer = [AFJSONResponseSerializer serializer];
        self.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/html", @"text/plain", @"text/javascript", @"text/json", @"application/gzip", nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkDidChange:) name:AFNetworkingReachabilityDidChangeNotification object:nil];
        
        self.cookieUtil = [[CookieUtil alloc] init];
    }
    return self;
}

- (void)networkDidChange:(NSNotification *)notification {
    [self queryIpAddress];
}

/**
 * 初始化httpdns配置
 */
- (void)initHTTPDns {
    NSMutableArray *array = [[NSMutableArray alloc] init];
    if ([QNDnsManager needHttpDns]) {
        //如果是国内的话，优先使用Dnspod的解析器
        [array addObject:[[QNDnspodFree alloc] init]];
        [array addObject:[QNResolver systemResolver]];
    } else {
        //如果是国外的话，使用系统的dns解析器和google的
        [array addObject:[QNResolver systemResolver]];
        [array addObject:[[QNResolver alloc] initWithAddress:@"8.8.8.8"]];
    }
    self.dnsManager = [[QNDnsManager alloc] init:array networkInfo:[QNNetworkInfo normal]];
    self.domainIpDict = [NSMutableDictionary dictionary];
}

- (void)queryIpAddress {
    AsyncRun(^{
        NSURL *syncUrl = [NSURL URLWithString:kAPIServer];
        NSURL *ipUrl = [self.dnsManager queryAndReplaceWithIP:syncUrl];
        if ([ipUrl.host isIpAddress]) {
            [self.lock lock];
            self.domainIpDict[syncUrl.host] = ipUrl.host;
            [self.lock unlock];
        }
    });
}

- (NSString *)ipAddressForDomain:(NSString *)domain {
    [self.lock lock];
    NSString *ipAddr = self.domainIpDict[domain];
    [self.lock unlock];
    return ipAddr;
}

@end

@implementation Api

+ (void)handleSuccess:(AFHTTPRequestOperation *)operation responseObject:(id)responseObject successBlock:(SuccessBlock)success failBlock:(FailBlock)fail {
    NSString *requestUrlString = operation.request.URL.absoluteString;
    if ([operation.request valueForHTTPHeaderField:@"Host"]) {
        //把ip换成域名来打印
        requestUrlString = [requestUrlString stringByReplacingOccurrencesOfString:operation.request.URL.host withString:[operation.request valueForHTTPHeaderField:@"Host"]];
    }
#ifdef DEBUG
    DEBUG_LOG(@"\n%@--\n%@", requestUrlString, [responseObject JSONString_JSONKit]);
#endif
    NSInteger code = [responseObject[@"code"] integerValue];
    if (100 == code) {
        if (success) {
//            id data = [NSDictionary recursiveRemoveNSNull:responseObject[@"body"]];
            success(responseObject[@"body"]);
        }
    } else {
        if (fail) {
            fail(responseObject[@"message"], code);
        }
    }
}

+ (void)handleFailure:(AFHTTPRequestOperation *)operation error:(NSError *)error failBlock:(FailBlock)fail {
    NSString *requestUrlString = operation.request.URL.absoluteString;
    if ([operation.request valueForHTTPHeaderField:@"Host"]) {
        //把ip换成域名来打印
        requestUrlString = [requestUrlString stringByReplacingOccurrencesOfString:operation.request.URL.host withString:[operation.request valueForHTTPHeaderField:@"Host"]];
    }
#ifdef DEBUG
    DEBUG_LOG(@"%@\n%@", requestUrlString, error);
#endif
    if (fail) {
        if (NSURLErrorNotConnectedToInternet == error.code) {
            fail(@"网络断开，请检查网络", error.code);
        } else {
            fail(@"连接服务器失败", error.code);
        }
    }
}

/**
 * 创建一个HttpRequestOperation
 */
+ (AFHTTPRequestOperation *)createRequestOperation:(SuccessBlock)success fail:(FailBlock)fail bodyDict:(NSDictionary *)bodyDict service:(NSString *)serviceName image:(UIImage *)image baseUrl:(NSString *)baseUrl method:(NSString *)method {
#ifdef DEBUG
    DEBUG_LOG(@"\n%@--\n%@", serviceName, [bodyDict isKindOfClass:[NSString class]] ? bodyDict : [bodyDict JSONString_JSONKit]);
#endif
    ApiClient *apiClient = [ApiClient sharedInstance];
    NSURL *url = [NSURL URLWithString:baseUrl];
    url = [NSURL URLWithString:serviceName relativeToURL:url];
    NSString *urlStr = [url absoluteString];
    NSString *ipAddrStr = [apiClient ipAddressForDomain:url.host];
    if (ipAddrStr) {
        [apiClient.requestSerializer setValue:url.host forHTTPHeaderField:@"Host"];//使用HttpDNS后需要设置Host
        //使用HttpDNS来替换
        urlStr = [urlStr stringByReplacingOccurrencesOfString:url.host withString:ipAddrStr];
    }
    
    NSMutableURLRequest *request = nil;
    if ([method isEqualToString:@"GET"] || [method isEqualToString:@"POST"]) {
        request = [apiClient.requestSerializer requestWithMethod:method URLString:urlStr parameters:bodyDict error:NULL];
        request.timeoutInterval = 30;
    } else if ([method isEqualToString:@"POST-FORM"]) {
        request = [apiClient.requestSerializer multipartFormRequestWithMethod:@"POST" URLString:urlStr parameters:bodyDict constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
            if (image) {
                NSData *imageData = UIImagePNGRepresentation(image);
                NSString *fileName = [[NSString uuid] stringByAppendingString:@".png"];
                [formData appendPartWithFileData:imageData name:@"file" fileName:fileName mimeType:@"image/png"];
            }
        } error:NULL];
        request.timeoutInterval = 120;
    }
    
    AFHTTPRequestOperation *operation = [apiClient HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self handleSuccess:operation responseObject:responseObject successBlock:success failBlock:fail];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self handleFailure:operation error:error failBlock:fail];
    }];
    return operation;
}

+ (AFHTTPRequestOperation *)getConnection:(SuccessBlock)success fail:(FailBlock)fail bodyDict:(NSDictionary *)bodyDict service:(NSString *)serviceName image:(UIImage *)image baseUrl:(NSString *)baseUrl method:(NSString *)method {
    AFHTTPRequestOperation *operation = [self createRequestOperation:success fail:fail bodyDict:bodyDict service:serviceName image:image baseUrl:baseUrl method:method];
    [[ApiClient sharedInstance].operationQueue addOperation:operation];
    return operation;
}

+ (AFHTTPRequestOperation *)getConnection:(SuccessBlock)success fail:(FailBlock)fail bodyDict:(NSDictionary *)bodyDict service:(NSString *)serviceName method:(NSString *)method {
    return [self getConnection:success fail:fail bodyDict:bodyDict service:serviceName image:nil baseUrl:kAPIServer method:method];
}

+ (AFHTTPRequestOperation *)cityList:(SuccessBlock)success failBlock:(FailBlock)fail {
    return [self getConnection:success fail:fail bodyDict:nil service:@"/service/cityList" method:@"POST"];
}

+ (AFHTTPRequestOperation *)limitCityList:(SuccessBlock)success failBlock:(FailBlock)fail {
    return [self getConnection:success fail:fail bodyDict:nil service:@"/service/limitCityList" method:@"POST"];
}

+ (AFHTTPRequestOperation *)holidayList:(SuccessBlock)success failBlock:(FailBlock)fail {
    return [self getConnection:success fail:fail bodyDict:nil service:@"/service/holidayList" method:@"POST"];
}

+ (AFHTTPRequestOperation *)queryCity:(id)content successBlock:(SuccessBlock)success failBlock:(FailBlock)fail {
    return [self getConnection:success fail:fail bodyDict:content service:@"/service/queryCity" method:@"POST"];
}

+ (AFHTTPRequestOperation *)checkUpdatedCity:(id)content successBlock:(SuccessBlock)success failBlock:(FailBlock)fail {
    return [self getConnection:success fail:fail bodyDict:content service:@"/service/checkUpdatedCity" method:@"POST"];
}

+ (AFHTTPRequestOperation *)register:(id)content successBlock:(SuccessBlock)success failBlock:(FailBlock)fail {
    return [self getConnection:success fail:fail bodyDict:content service:@"/service/register" method:@"POST"];
}

+ (AFHTTPRequestOperation *)login:(id)content successBlock:(SuccessBlock)success failBlock:(FailBlock)fail {
    return [self getConnection:success fail:fail bodyDict:content service:@"/service/login" method:@"POST"];
}

+ (AFHTTPRequestOperation *)resetPwd:(id)content successBlock:(SuccessBlock)success failBlock:(FailBlock)fail {
    return [self getConnection:success fail:fail bodyDict:content service:@"/service/resetPwd" method:@"POST"];
}

+ (AFHTTPRequestOperation *)modifyPwd:(id)content successBlock:(SuccessBlock)success failBlock:(FailBlock)fail {
    return [self getConnection:success fail:fail bodyDict:content service:@"/service/modifyPwd" method:@"POST"];
}

+ (AFHTTPRequestOperation *)saveSuggest:(id)content successBlock:(SuccessBlock)success failBlock:(FailBlock)fail {
    return [self getConnection:success fail:fail bodyDict:content service:@"/service/saveSuggest" method:@"POST"];
}

+ (AFHTTPRequestOperation *)checkVersion:(id)content successBlock:(SuccessBlock)success failBlock:(FailBlock)fail {
    return [self getConnection:success fail:fail bodyDict:content service:@"/service/checkVersion" method:@"POST"];
}

+ (AFHTTPRequestOperation *)uploadAlarmNum:(id)content successBlock:(SuccessBlock)success failBlock:(FailBlock)fail {
    return [self getConnection:success fail:fail bodyDict:content service:@"/service/uploadAlarmNum" method:@"POST"];
}

@end
