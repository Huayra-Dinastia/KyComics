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
        __weak typeof(self) weakSelf = self;
        [[KYNetManager manager] getShowkey:self.pageURL complection:^(NSString *showkey) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (strongSelf.isCancelled) {
                [strongSelf willChangeValueForKey:@"isFinished"];
                _finished = YES;
                [strongSelf didChangeValueForKey:@"isFinished"];
                return;
            }
            
            __weak typeof(strongSelf) weakSelf = strongSelf;
            [[KYNetManager manager] getImageURL:strongSelf.pageURL showkey:showkey completion:^(NSString *imgURL) {
                __strong typeof(weakSelf) strongSelf = weakSelf;
                if (strongSelf.isCancelled) {
                    [strongSelf willChangeValueForKey:@"isFinished"];
                    _finished = YES;
                    [strongSelf didChangeValueForKey:@"isFinished"];
                    return;
                }
                
                if (strongSelf.completion) {
                    strongSelf.completion(imgURL);
                }
                
                [strongSelf willChangeValueForKey:@"isExecuting"];
                _executing = NO;
                [strongSelf didChangeValueForKey:@"isExecuting"];
                
                [strongSelf willChangeValueForKey:@"isFinished"];
                _finished = YES;
                [strongSelf didChangeValueForKey:@"isFinished"];
                
            }];
        }];
    }
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
