//
//  KYNetManager+Downloader.m
//  Kycomics
//
//  Created by HongYi on 2017/8/15.
//  Copyright © 2017年 kcvly. All rights reserved.
//

#import "KYNetManager+Downloader.h"

#import "KYImageModel.h"

@interface KYNetManager ()
//@property (nonatomic, strong) NSDictionary *downloadingComics;

@end

@implementation KYNetManager (Downloader)

- (void)loadImage:(KYImageModel *)imageModel {
    
    __weak typeof(self) weakSelf = self;
    [[SDWebImageManager sharedManager] cachedImageExistsForURL:imageModel.pageURL
                                                    completion:^(BOOL isInCache) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (isInCache) {
            return ;
        }
        
        [strongSelf downloadImage:imageModel];
    }];
}

- (void)downloadImage:(KYImageModel *)imageModel {
    SDWebImageDownloadToken *downloadToken = [[SDWebImageDownloader sharedDownloader]
                                              downloadImageWithURL:imageModel.imgURL
                                              options:SDWebImageDownloaderUseNSURLCache
                                              progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
                                                  // 下载进度
                                                  if (expectedSize <= 0 || receivedSize <= 0) {
                                                      return ;
                                                  }
                                                  
                                                  imageModel.progress = (double)receivedSize / (double)expectedSize;
                                                  NSLog(@"%.2f", imageModel.progress);
                                              } completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, BOOL finished) {
                                                  if (!finished) {
                                                      return ;
                                                  }
                                                  
                                                  // 下载完成
                                                  // 将下载好的图片存储到缓存中
                                                  [[SDWebImageManager sharedManager] saveImageToCache:image forURL:imageModel.pageURL];

                                                  imageModel.isfinished = finished;
                                              }];
    
    NSMutableArray *tmpArr = self.downloadingQueue;
    [tmpArr addObject:imageModel];
    [tmpArr sortUsingComparator:^NSComparisonResult(KYImageModel * _Nonnull obj1, KYImageModel * _Nonnull obj2) {
        return obj1.index > obj2.index;
    }];
}

- (void)cancelAllDownloads {
    [[SDWebImageDownloader sharedDownloader] cancelAllDownloads];
    self.downloadingQueue = nil;
}

#pragma mark - getter & setter
- (NSMutableArray *)downloadingQueue {
    if (nil == objc_getAssociatedObject(self, @"downloadingQueue")) {
        NSMutableArray *downloadingQueue = [NSMutableArray array];
        objc_setAssociatedObject(self, @"downloadingQueue", downloadingQueue, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return objc_getAssociatedObject(self, @"downloadingQueue");
}

- (void)setDownloadingQueue:(NSMutableArray *)downloadingQueue {
    objc_setAssociatedObject(self, @"downloadingQueue", downloadingQueue, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
