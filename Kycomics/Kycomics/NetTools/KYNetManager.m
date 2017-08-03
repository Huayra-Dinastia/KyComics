//
//  KYNetManager.m
//  Kycomics
//
//  Created by HongYi on 2017/8/3.
//  Copyright © 2017年 kcvly. All rights reserved.
//

#import "KYNetManager.h"

#import <AFNetworking.h>
#import <TFHpple.h>

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

- (void)kyGET:(NSDictionary *)parameters withCompletion:(void (^)(id responseObject))completion {
    NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] requestWithMethod:@"GET"
                                                                                 URLString:domain
                                                                                parameters:parameters
                                                                                     error:nil];
    
    NSURLSessionDataTask *task = [_sessionManager dataTaskWithRequest:request
                                                    completionHandler:^(NSURLResponse * _Nonnull response,
                                                                        id  _Nullable responseObject,
                                                                        NSError * _Nullable error) {
                                                        if (completion) {
                                                            completion(responseObject);
                                                        }
    }];
    
    [task resume];
}

- (void)kyPOST:(NSDictionary *)parameters withCompletion:(void (^)(id responseObject))completion {
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
                                                            completion(responseObject);
                                                        }
                                                    }];
    
    [task resume];
}

@end
