//
//  KYImageModel.m
//  Kycomics
//
//  Created by HongYi on 2017/8/15.
//  Copyright © 2017年 kcvly. All rights reserved.
//

#import "KYImageModel.h"

@implementation KYImageModel {
    CGSize _imgSize;
    NSInteger _index;
    NSURL *_imgURL;
    NSURL *_pageURL;
}

- (instancetype)initWithPageURLstr:(NSString *)pageURLstr imgURLstr:(NSString *)imgURLstr {
    if (self = [super init]) {
        self.pageURLstr = pageURLstr;
        self.imgURLstr = imgURLstr;
        self.isfinished = NO;
    }
    return self;
}

- (NSURL *)imgURL {
    if (nil == _imgURL) {
        _imgURL = [NSURL URLWithString:self.imgURLstr];
    }
    return _imgURL;
}

- (NSURL *)pageURL {
    if (nil == _pageURL) {
        _pageURL = [NSURL URLWithString:self.pageURLstr];
    }
    return _pageURL;
}

- (CGSize)imgSize {
    if (CGSizeEqualToSize(CGSizeZero, _imgSize)) {
        NSArray *strs = [self.imgURLstr componentsSeparatedByString:@"/"];
        for (NSInteger i = strs.count - 1; i >= 0; i--) {
            NSString *str = strs[i];
            if([str hasSuffix:@"-jpg"]){
                strs = [str componentsSeparatedByString:@"-"];
                
                CGFloat width = [strs[strs.count - 3] floatValue];
                CGFloat height = [strs[strs.count - 2] floatValue];
                
                CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
                
                CGFloat scale = screenWidth / width;
                _imgSize = CGSizeMake(width * scale, height * scale);
                break;
            }
        }
    }
    return _imgSize;
}

- (NSInteger)index {
    if (0 == _index) {
//        https://e-hentai.org/s/9ba7beaebf/1101469-1
         _index = [[self.pageURLstr componentsSeparatedByString:@"-"].lastObject integerValue];
    }
    return _index;
}

- (UIImage *)image {
    NSString *cacheKey = [[SDWebImageManager sharedManager] cacheKeyForURL:self.pageURL];
    return [[[SDWebImageManager sharedManager] imageCache] imageFromCacheForKey:cacheKey];
}

@end
