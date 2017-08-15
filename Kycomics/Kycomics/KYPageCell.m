//
//  KYPageCell.m
//  Kycomics
//
//  Created by HongYi on 2017/8/9.
//  Copyright © 2017年 kcvly. All rights reserved.
//

#import "KYPageCell.h"

@interface KYPageCell ()
@property (weak, nonatomic) UIView *progressView;

@end

@implementation KYPageCell

- (void)setupWithImageURL:(NSURL *)imgURL {
    [[SDWebImageManager sharedManager]
     loadImageWithURL:imgURL
     options:SDWebImageProgressiveDownload
     progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
         // 绘制进度条
         if (expectedSize <= 0 || receivedSize <= 0) {
             return ;
         }
         
         CGFloat progress = (double)receivedSize / (double)expectedSize;
         [self showProgress:progress];
     } completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
         if (!finished) {
             return ;
         }
         
         self.imgView.image = image;
         [self.progressView removeFromSuperview];
     }];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.progressView.backgroundColor = [UIColor clearColor];
}

- (void)showProgress:(CGFloat)progress {
    CGFloat progressViewW = [UIScreen mainScreen].bounds.size.width * progress;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.progressView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.offset(progressViewW);
        }];
        self.progressView.backgroundColor = [UIColor orangeColor];
    });
}

#pragma mark - getter & setter
- (UIView *)progressView {
    if (nil == _progressView) {
        UIView *progressView = [[UIView alloc] init];
        [self.contentView addSubview:progressView];
        
        [progressView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.bottom.equalTo(self.contentView);
            make.height.offset(2);
            make.width.offset(0);
        }];
        
        _progressView = progressView;
    }
    return _progressView;
}

@end
