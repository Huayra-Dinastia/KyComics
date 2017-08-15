//
//  KYGETImageURLOperation.h
//  Kycomics
//
//  Created by HongYi on 2017/8/15.
//  Copyright © 2017年 kcvly. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^KYGETIMAGEURL_BLOCK)(NSString *imgURL);

@interface KYGETImageURLOperation : NSOperation

- (instancetype)initWithPageURL:(NSString *)pageURL withCompletion:(KYGETIMAGEURL_BLOCK)completion;

@end
