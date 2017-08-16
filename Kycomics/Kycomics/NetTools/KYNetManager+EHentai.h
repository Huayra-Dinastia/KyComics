//
//  KYNetManager+EHentai.h
//  Kycomics
//
//  Created by HongYi on 2017/8/14.
//  Copyright © 2017年 kcvly. All rights reserved.
//

#import "KYNetManager.h"

@class KYComicsModel, KYImageModel;

FOUNDATION_EXPORT NSString * const KYNetManagerEhentaiCancelLoadingNotification;

@interface KYNetManager (EHentai)
@property (nonatomic, strong, readonly) NSMutableDictionary *showkeys;

- (void)getImageURL:(KYComicsModel *)comic complection:(void (^)(KYImageModel *imageModel))complection;
- (void)getPageURLs:(KYComicsModel *)comic complection:(KYSUCESS_BLOCK)complection;
- (void)getShowkey:(NSString *)pageURL complection:(KYSUCESS_BLOCK)completion;
- (void)getPageImage:(NSString *)urlString showkey:(NSString *)showkey completion:(KYSUCESS_BLOCK)complection;
@end
