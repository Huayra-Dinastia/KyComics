//
//  KYNetManager.m
//  Kycomics
//
//  Created by HongYi on 2017/8/3.
//  Copyright © 2017年 kcvly. All rights reserved.
//

#import "KYNetManager.h"

#import <AFNetworking.h>

#define domain @"https://e-hentai.org"

@interface KYNetManager ()
@property (nonatomic, copy) void (^completion)(id);

@end

@implementation KYNetManager {
    AFHTTPSessionManager *_sessionManager;
}

+ (instancetype)manager {
    static id instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (instancetype)init {
    if (self = [super init]) {
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        config.timeoutIntervalForRequest = 30.0;
        
        _sessionManager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:config];
        _sessionManager.responseSerializer = [AFHTTPResponseSerializer serializer];
        _sessionManager.securityPolicy.allowInvalidCertificates = NO;
        _sessionManager.securityPolicy.validatesDomainName = NO;
        _sessionManager.completionQueue = dispatch_queue_create("KYNetManager", DISPATCH_QUEUE_CONCURRENT);
    }
    return self;
}

#pragma mark - HTTPMethod: GET
- (void)kyGET:(NSDictionary *)parameters withCompletion:(KYSUCESS_BLOCK)completion {
    [self kyGET:nil parameters:parameters withCompletion:completion];
}

- (void)kyGET:(NSString *)urlString parameters:(NSDictionary *)parameters withCompletion:(KYSUCESS_BLOCK)completion {
    urlString = [urlString hasPrefix:domain]? urlString: [domain stringByAppendingPathComponent:urlString];
    NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] requestWithMethod:@"GET"
                                                                                 URLString:urlString
                                                                                parameters:parameters
                                                                                     error:nil];
    
    NSURLSessionDataTask *task = [_sessionManager dataTaskWithRequest:request
                                                    completionHandler:^(NSURLResponse * _Nonnull response,
                                                                        id  _Nullable responseObject,
                                                                        NSError * _Nullable error) {
                                                        if (completion) {
                                                            dispatch_async(dispatch_get_main_queue(), ^{
                                                                completion(responseObject);
                                                            });
                                                        }
                                                        
                                                    }];
    
    [task resume];
}

#pragma mark - HTTPMethod: POST
- (void)kyPOST:(NSDictionary *)parameters withCompletion:(KYSUCESS_BLOCK)completion {
    NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] requestWithMethod:@"POST"
                                                                                 URLString:[domain stringByAppendingPathComponent:@"api.php"]
                                                                                parameters:nil
                                                                                     error:nil];
    request.HTTPBody = [NSJSONSerialization dataWithJSONObject:parameters options:0 error:nil];
    
    NSURLSessionDataTask *task = [_sessionManager dataTaskWithRequest:request
                                                    completionHandler:^(NSURLResponse * _Nonnull response,
                                                                        id  _Nullable responseObject,
                                                                        NSError * _Nullable error) {
                                                        if (completion) {
//                                                            id result = [responseObject mj_JSONObject];
                                                            dispatch_async(dispatch_get_main_queue(), ^{
                                                                completion(responseObject);
                                                            });
                                                        }
                                                    }];
    
    [task resume];
}

@end
