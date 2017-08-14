//
//  KYImageOperation.h
//  Kycomics
//
//  Created by HongYi on 2017/8/14.
//  Copyright © 2017年 kcvly. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KYImageOperation : NSOperation
- (instancetype)initWithURL:(NSString *)imgPageURL complection:(void (^)(NSString *imgURL))complection;

@end
