//
//  KYNetManager+EHentai.m
//  Kycomics
//
//  Created by HongYi on 2017/8/14.
//  Copyright © 2017年 kcvly. All rights reserved.
//

#import "KYNetManager+EHentai.h"

#import "KYComicsModel.h"
#import <objc/runtime.h>
#import <JavaScriptCore/JavaScriptCore.h>

@interface KYNetManager ()
@property (nonatomic, strong, readonly) NSOperationQueue *operationQueue;

@end

@implementation KYNetManager (EHentai)

- (void)getShowkeys:(NSArray *)imgPageURLs {
    for (NSString *imgPageURL in imgPageURLs) {
        NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
            [self getShowkey:imgPageURL];
        }];
        [self.operationQueue addOperation:operation];
    }
}

- (void)getPageURLs:(KYComicsModel *)comic {
    NSString *gid = comic.gid;
    NSString *token = comic.token;
    
    NSString *urlString = [NSString stringWithFormat:@"g/%@/%@", gid, token];
    [self kyGET:urlString parameters:nil withCompletion:^(id responseObject) {
        // 解析网页
        TFHpple *doc = [[TFHpple alloc] initWithHTMLData:responseObject];
        NSArray<TFHppleElement *> *nodes = [doc searchWithXPathQuery:@"//div [@class='gdtm']//a"];
        
        if (0 == nodes.count) {
            return ;
        }
        
        NSMutableArray *imgPageUrls = [NSMutableArray arrayWithCapacity:nodes.count];
        for (TFHppleElement *node in nodes) {
            NSString *urlString = node.attributes[@"href"];
            [imgPageUrls addObject:urlString];
        }
        
        NSLog(@"%@", imgPageUrls);
        [self getShowkeys:imgPageUrls];
    }];
}

- (void)getShowkey:(NSString *)imgPageURL {
    [self kyGET:imgPageURL parameters:nil withCompletion:^(id responseObject) {
        // 解析网页
        TFHpple *doc = [[TFHpple alloc] initWithHTMLData:responseObject];
        NSArray<TFHppleElement *> *nodes = [doc searchWithXPathQuery:@"//script[@type='text/javascript']"];
        
        for (NSUInteger i = nodes.count - 1; i > 0; i--) {
            TFHppleElement *node = nodes[i];
            if (nil == node.attributes[@"src"]) {
                JSContext *jsContext = [[JSContext alloc] init];
                [jsContext evaluateScript:node.content];
                
                // 获取到showkey
                JSValue *showkey = [jsContext evaluateScript:@"showkey"];
                if (![showkey.toString isEqualToString:@"undefined"]) {
#warning showkey不变，只需获取一次
                    NSLog(@"%@ ====> %@", imgPageURL, showkey.toString);
//                    [self requestPageImg:urlString showkey:showkey.toString];
                    
                    return ;
                }
            }
        }
    }];
}

- (NSOperationQueue *)operationQueue {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSOperationQueue *operationQueue = [[NSOperationQueue alloc] init];
        operationQueue.maxConcurrentOperationCount = 1;
        objc_setAssociatedObject(self, @"operationQueue", operationQueue, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    });
    return objc_getAssociatedObject(self, @"operationQueue");
}

@end
