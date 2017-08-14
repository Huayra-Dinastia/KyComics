//
//  KYNetManager.h
//  Kycomics
//
//  Created by HongYi on 2017/8/3.
//  Copyright © 2017年 kcvly. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^KYSUCESS_BLOCK)(id responseObject);

@interface KYNetManager : NSObject

+ (instancetype)manager;
- (void)kyGET:(NSString *)urlString parameters:(NSDictionary *)parameters withCompletion:(KYSUCESS_BLOCK)completion;
- (void)kyGET:(NSDictionary *)parameters withCompletion:(KYSUCESS_BLOCK)completion;
- (void)kyPOST:(NSDictionary *)parameters withCompletion:(KYSUCESS_BLOCK)completion;

@end
