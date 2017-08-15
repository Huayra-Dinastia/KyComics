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

@synthesize executing = _executing;
@synthesize finished  = _finished;

- (instancetype)initWithPageURL:(NSString *)pageURL withCompletion:(KYGETIMAGEURL_BLOCK)completion {
    
    if (self = [super init]) {
        self.pageURL = pageURL;
        self.completion = completion;
        _executing = NO;
        _finished  = NO;
    }
    return self;
}

- (void)start {
    if (self.isCancelled) {
        [self willChangeValueForKey:@"isFinished"];
        _finished = YES;
        [self didChangeValueForKey:@"isFinished"];
        
        return;
    }
    
    [self willChangeValueForKey:@"isExecuting"];
    
    [NSThread detachNewThreadSelector:@selector(main) toTarget:self withObject:nil];
    _executing = YES;
    [self didChangeValueForKey:@"isExecuting"];
}

- (void)main {
    @autoreleasepool {
        if (self.isCancelled) {
            [self willChangeValueForKey:@"isFinished"];
            _finished = YES;
            [self didChangeValueForKey:@"isFinished"];
            return;
        }
        
        NSLog(@"%@", [NSThread currentThread]);
        
        // 获取showkey
        [[KYNetManager manager] getShowkey:self.pageURL complection:^(NSString *showkey) {
            if (self.isCancelled) {
                return;
            }
            
            [[KYNetManager manager] getPageImage:self.pageURL showkey:showkey completion:^(NSString *imgURL) {
                if (self.isCancelled) {
                    return;
                }
                
                if (self.completion) {
                    self.completion(imgURL);
                }
                
                [self willChangeValueForKey:@"isExecuting"];
                _executing = NO;
                [self didChangeValueForKey:@"isExecuting"];
                
                [self willChangeValueForKey:@"isFinished"];
                _finished = YES;
                [self didChangeValueForKey:@"isFinished"];
                
            }];
        }];
    }
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

- (BOOL)isConcurrent {
    return YES;
}

- (BOOL)isExecuting {
    return _executing;
}

- (BOOL)isFinished {
    return _finished;
}

@end
