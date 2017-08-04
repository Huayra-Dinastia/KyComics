//
//  KYNetManager.h
//  Kycomics
//
//  Created by HongYi on 2017/8/3.
//  Copyright © 2017年 kcvly. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KYNetManager : NSObject

+ (instancetype)manager;
- (void)kyGET:(NSString *)urlString parameters:(NSDictionary *)parameters withCompletion:(void (^)(id responseObject))completion;
- (void)kyGET:(NSDictionary *)parameters withCompletion:(void (^)(id responseObject))completion;
- (void)kyPOST:(NSDictionary *)parameters withCompletion:(void (^)(id responseObject))completion;

@end
