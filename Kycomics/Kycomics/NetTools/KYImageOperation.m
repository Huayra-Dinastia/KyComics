//
//  KYImageOperation.m
//  Kycomics
//
//  Created by HongYi on 2017/8/14.
//  Copyright © 2017年 kcvly. All rights reserved.
//

#import "KYImageOperation.h"

#import "KYNetManager+EHentai.h"

@interface KYImageOperation ()
@property (nonatomic, copy) void(^finish)(NSString *);

@end

@implementation KYImageOperation {
    NSString *_imgPageURL;
}

- (instancetype)initWithURL:(NSString *)imgPageURL complection:(void (^)(NSString *imgURL))complection{
    if (self = [super init]) {
        _imgPageURL = imgPageURL;
        self.finish = complection;
    }
    return self;
}

- (void)main {
    @autoreleasepool {
        [[KYNetManager manager] getShowkey:_imgPageURL complection:^(NSString *showkey) {
            [[KYNetManager manager] getPageImage:_imgPageURL showkey:showkey completion:^(NSString *imgURL) {
                if (self.finish) {
                    self.finish(imgURL);
                }
            }];
        }];
    }
}

@end
