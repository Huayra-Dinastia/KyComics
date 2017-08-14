//
//  KYNetManager+EHentai.h
//  Kycomics
//
//  Created by HongYi on 2017/8/14.
//  Copyright © 2017年 kcvly. All rights reserved.
//

#import "KYNetManager.h"

@class KYComicsModel;

@interface KYNetManager (EHentai)

- (void)getPageURLs:(KYComicsModel *)comic;
@end
