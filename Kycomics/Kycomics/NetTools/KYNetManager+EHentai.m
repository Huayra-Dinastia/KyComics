//
//  KYNetManager+EHentai.m
//  Kycomics
//
//  Created by HongYi on 2017/8/14.
//  Copyright © 2017年 kcvly. All rights reserved.
//

#import "KYNetManager+EHentai.h"

#import <objc/runtime.h>
#import <JavaScriptCore/JavaScriptCore.h>
#import "KYComicsModel.h"
#import "KYImageModel.h"
#import "KYGETImageURLOperation.h"
#import "KYNetManager+Downloader.h"

NSString * const KYNetManagerEhentaiCancelLoadingNotification = @"KYNetManagerEhentaiCancelLoadingNotification";

@interface KYNetManager ()
@property (nonatomic, strong, readonly) NSOperationQueue *imgURLOperationQueue;

@end

@implementation KYNetManager (EHentai)

/// 抓取某一页的漫画列表
- (void)getComics:(NSInteger)page completion:(void (^)(NSArray *comics))completion {
    NSDictionary *parm = @{
                           @"page": @(page),
                           @"f_doujinshi": @(1),
                           @"f_manga": @(1),
                           @"f_artistcg": @(1),
                           @"f_gamecg": @(1),
                           @"f_western": @(1),
                           @"f_non-h": @(1),
                           @"f_imageset": @(1),
                           @"f_cosplay": @(1),
                           @"f_asianporn": @(1),
                           @"f_misc": @(1),
                           @"f_search": @"",
                           @"f_apply": @"Apply+Filter",
                           };
    
    __weak typeof(self) weakSelf = self;
    [self kyGET:parm withCompletion:^(id responseObject) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        // 抓取到网页
        TFHpple *doc = [[TFHpple alloc] initWithHTMLData:responseObject];
        NSArray<TFHppleElement *> *picElements = [doc searchWithXPathQuery:@"//div [@class='it5']//a"];
        
        if (0 == picElements.count) {
            return ;
        }
        
        NSMutableArray *ids = [NSMutableArray arrayWithCapacity:picElements.count];
        // 从 a 标签中提取 图片的URL
        for (TFHppleElement *pic in picElements) {
            NSString *urlString = pic.attributes[@"href"];
            
            //https://e-hentai.org/g/618395/0439fa3666/
            //                          -3        -2       -1
            NSArray *tmpArr = [urlString componentsSeparatedByString:@"/"];
            NSUInteger length = tmpArr.count;
            NSString *str1 = tmpArr[length - 3];
            NSString *str2 = tmpArr[length - 2];
            [ids addObject:@[str1, str2]];
        }
        
        [strongSelf getComicsWithIds:ids completion:completion];
    }];
}

- (void)getComicsWithIds:(NSArray *)ids completion:(void (^)(NSArray *comics))completion {
    NSDictionary *parm = @{
                           @"method": @"gdata",
                           @"gidlist": ids
                           };
    
    [self kyPOST:parm withCompletion:^(id responseObject) {
        id result = [responseObject mj_JSONObject];
        NSMutableArray *comics = [KYComicsModel mj_objectArrayWithKeyValuesArray:result[@"gmetadata"]];
        
        if (completion) {
            completion(comics);
        }
    }];
}

/// 获取图片页面URL
- (void)getPageURLs:(KYComicsModel *)comic complection:(KYSUCESS_BLOCK)complection {
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
        
        if (complection) {
            complection(imgPageUrls);
        }
    }];
}

/// 获取showkey
- (void)getShowkey:(NSString *)pageURL complection:(KYSUCESS_BLOCK)completion {

    NSString *gid = [[pageURL componentsSeparatedByString:@"/"].lastObject
                     componentsSeparatedByString:@"-"].firstObject;
    
    if (self.showkeys[gid]) {
        if (completion) {
            completion(self.showkeys[gid]);
        }
        return ;
    }
    
    [self kyGET:pageURL parameters:nil withCompletion:^(id responseObject) {
        // 解析网页
        TFHpple *doc = [[TFHpple alloc] initWithHTMLData:responseObject];
        NSArray<TFHppleElement *> *nodes = [doc searchWithXPathQuery:@"//script[@type='text/javascript']"];
        if (nodes.count <= 0) {
            return ;
        }
        
        for (NSUInteger i = nodes.count - 1; i > 0; i--) {
            TFHppleElement *node = nodes[i];
            if (nil == node.attributes[@"src"]) {
                JSContext *jsContext = [[JSContext alloc] init];
                [jsContext evaluateScript:node.content];
                
                // 获取到showkey
                JSValue *showkey = [jsContext evaluateScript:@"showkey"];
                if (![showkey.toString isEqualToString:@"undefined"]) {
                    self.showkeys[gid] = showkey.toString;

                    if (completion) {
                        completion(self.showkeys[gid]);
                    }
                    return ;
                }
            }
        }
    }];
}

/// 获取一本漫画中所有图片的真实URL，comlection每次回调一张图片URL
- (void)getImageURL:(KYComicsModel *)comic complection:(void (^)(KYImageModel *imageModel))complection {
    __weak typeof(self) weakSelf = self;
    [[KYNetManager manager] getPageURLs:comic
                            complection:^(NSArray *pageURLs) {
                                __strong typeof(weakSelf) strongSelf = weakSelf;
                                
                                for (NSString *pageURLstr in pageURLs) {
                                    KYGETImageURLOperation *operation = [[KYGETImageURLOperation alloc]
                                                                         initWithPageURL:pageURLstr
                                                                         withCompletion:^(NSString *imgURLstr) {
                                                                             KYImageModel *imageModel = [[KYImageModel alloc] initWithPageURLstr: pageURLstr imgURLstr:imgURLstr];
                                                                             
                                                                             [[KYNetManager manager] loadImage:imageModel];
                                                                             
                                                                             if (complection) {
                                                                                 complection(imageModel);
                                                                             }
                                                                         }];
                                    
                                    [strongSelf.imgURLOperationQueue addOperation:operation];
                                }
                            }];
}

/// 获取一张图片的实际的URL
- (void)getImageURL:(NSString *)urlString showkey:(NSString *)showkey completion:(KYSUCESS_BLOCK)complection {
    //https://e-hentai.org/s/1a8e31f2c6/1029334-2
    //                          -2        -1
    NSArray *strs = [urlString componentsSeparatedByString:@"/"];
    NSArray *strs2 = [strs.lastObject componentsSeparatedByString:@"-"];
    NSString *gid = strs2.firstObject;
    NSString *page = strs2.lastObject;
    NSString *imgkey = strs[strs.count - 2];
    
    NSDictionary *parm = @{
                           @"method": @"showpage",
                           @"gid": gid,
                           @"page": page,
                           @"imgkey": imgkey,
                           @"showkey": showkey
                           };
    
    [[KYNetManager manager] kyPOST:parm withCompletion:^(id responseObject) {
        id i3 = [responseObject mj_JSONObject][@"i3"];
        TFHpple *doc = [[TFHpple alloc] initWithHTMLData:[i3 mj_JSONData]];
        TFHppleElement *node = [doc searchWithXPathQuery:@"//a/img"].lastObject;
        
        NSString *src = node.attributes[@"src"];
//        NSLog(@"========> %@", src);
        
        if (complection) {
            complection(src);
        }
    }];
}

/// 取消所有下载和获取图片URL操作
- (void)cancelAllDownloadsAndOperations {
    [[KYNetManager manager] cancelAllDownloads];
    [self.imgURLOperationQueue cancelAllOperations];
}

#pragma mark - getter & setter
- (NSOperationQueue *)imgURLOperationQueue {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSOperationQueue *imgURLOperationQueue = [[NSOperationQueue alloc] init];
        imgURLOperationQueue.maxConcurrentOperationCount = 1;
        objc_setAssociatedObject(self, _cmd, imgURLOperationQueue, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(cancelAllDownloadsAndOperations)
                                                     name:KYNetManagerEhentaiCancelLoadingNotification
                                                   object:nil];
    });
    return objc_getAssociatedObject(self, _cmd);
}

- (NSMutableDictionary *)showkeys {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSMutableDictionary *showkeys = [NSMutableDictionary dictionary];
        objc_setAssociatedObject(self, _cmd, showkeys, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    });
    return objc_getAssociatedObject(self, _cmd);
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
