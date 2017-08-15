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

- (void)loadImage:(NSString *)imgURL {
    KYImageModel *imageModel = [[KYImageModel alloc] init];
    imageModel.imgURL = imgURL;
    
    SDWebImageDownloadToken *downloadToken = [[SDWebImageDownloader sharedDownloader]
                                              downloadImageWithURL:[NSURL URLWithString:imgURL] options:SDWebImageDownloaderUseNSURLCache progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
                                                  // 下载进度
                                                  if (expectedSize <= 0 || receivedSize <= 0) {
                                                      return ;
                                                  }
                                                  
                                                  imageModel.progress = (double)receivedSize / (double)expectedSize;
                                              } completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, BOOL finished) {
                                                  if (!finished) {
                                                      return ;
                                                  }
                                                  
                                                  // 下载完成
                                                  imageModel.image = image;
                                              }];
    
    NSMutableArray *tmpArr = self.downloadingQueue;
    [tmpArr addObject:imageModel];
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
