//
//  KYNetManager+Downloader.h
//  Kycomics
//
//  Created by HongYi on 2017/8/15.
//  Copyright © 2017年 kcvly. All rights reserved.
//

#import "KYNetManager.h"

@class KYImageModel;

@interface KYNetManager (Downloader)
@property (nonatomic, strong) NSMutableArray *downloadingQueue;

- (void)loadImage:(KYImageModel *)imageModel;
- (void)cancelAllDownloads;
@end
