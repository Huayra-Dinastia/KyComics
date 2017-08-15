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
}

- (instancetype)initWithPageURL:(NSString *)pageURL imgURL:(NSString *)imgURL {
    if (self = [super init]) {
        self.pageURL = pageURL;
        self.imgURL = imgURL;
    }
    return self;
}

- (CGSize)imgSize {
    if (CGSizeEqualToSize(CGSizeZero, _imgSize)) {
        NSArray *strs = [self.imgURL componentsSeparatedByString:@"/"];
        for (NSInteger i = strs.count - 1; i >= 0; i--) {
            NSString *str = strs[i];
            if([str hasSuffix:@"-jpg"]){
                strs = [str componentsSeparatedByString:@"-"];
                break;
            }
        }
        
        CGFloat width = [strs[strs.count - 3] floatValue];
        CGFloat height = [strs[strs.count - 2] floatValue];
        
        CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
        
        CGFloat scale = screenWidth / width;
        _imgSize = CGSizeMake(width * scale, height * scale);
    }
    return _imgSize;
}

- (NSInteger)index {
    if (0 == _index) {
//        https://e-hentai.org/s/9ba7beaebf/1101469-1
         _index = [[self.pageURL componentsSeparatedByString:@"-"].lastObject integerValue];
    }
    return _index;
}

@end
