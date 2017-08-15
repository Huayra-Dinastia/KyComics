//
//  KYGETImageURLOperation.m
//  Kycomics
//
//  Created by HongYi on 2017/8/15.
//  Copyright © 2017年 kcvly. All rights reserved.
//

#import "KYGETImageURLOperation.h"

#import "KYNetManager+EHentai.h"

@interface KYGETImageURLOperation ()
@property (nonatomic, copy) NSString *pageURL;
@property (nonatomic, copy) KYGETIMAGEURL_BLOCK completion;

@end

@implementation KYGETImageURLOperation

//+ (NSMutableDictionary *)showKeys {
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        objc_setAssociatedObject(self, _cmd, [NSMutableDictionary dictionary], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
//    });
//    return objc_getAssociatedObject(self, _cmd);
//}

- (instancetype)initWithPageURL:(NSString *)pageURL withCompletion:(KYGETIMAGEURL_BLOCK)completion {
    if (self = [super init]) {
        self.pageURL = pageURL;
        self.completion = completion;
    }
    return self;
}

- (void)main {
    // 获取showkey
    [[KYNetManager manager] getShowkey:self.pageURL complection:^(NSString *showkey) {
        [[KYNetManager manager] getPageImage:self.pageURL showkey:showkey completion:^(NSString *imgURL) {
            if (self.completion) {
                self.completion(imgURL);
            }
        }];
    }];
//    if (self.showkey.length) {
//        // 获取图片地址
//        [[KYNetManager manager] getPageImage:imgPageURL showkey:self.showkey completion:^(NSString *imgURL) {
//            KYImageModel *imageModel = [[KYImageModel alloc] initWithPageURL:imgPageURL imgURL:imgURL];
//            [[KYNetManager manager] loadImage:imageModel];
//            [self.tableView reloadData];
//        }];
//    } else {
//        // 获取showkey
//        [[KYNetManager manager] getShowkey:imgPageURL complection:^(NSString *showkey) {
//            self.showkey = showkey;
//            [[KYNetManager manager] getPageImage:imgPageURL showkey:self.showkey completion:^(NSString *imgURL) {
//                KYImageModel *imageModel = [[KYImageModel alloc] initWithPageURL:imgPageURL imgURL:imgURL];
//                [[KYNetManager manager] loadImage:imageModel];
//                [self.tableView reloadData];
//            }];
//        }];
//    }
}

@end
