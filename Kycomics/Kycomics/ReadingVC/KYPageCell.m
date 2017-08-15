//
//  KYPageCell.m
//  Kycomics
//
//  Created by HongYi on 2017/8/9.
//  Copyright © 2017年 kcvly. All rights reserved.
//

#import "KYPageCell.h"

#import "KYImageModel.h"

@interface KYPageCell ()
@property (weak, nonatomic) IBOutlet UIImageView *imgView;
@property (weak, nonatomic) UIView *progressView;

@end

@implementation KYPageCell

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"progress"]) {
        [self showProgress:self.imageModel.progress];
    } else if ([keyPath isEqualToString:@"image"]) {
        [self.progressView removeFromSuperview];
        self.imgView.image = self.imageModel.image;
        
//        [_imageModel removeObserver:self forKeyPath:@"image"];
//        [_imageModel removeObserver:self forKeyPath:@"progress"];
    }
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

- (void)setImageModel:(KYImageModel *)imageModel {
    [_imageModel removeObserver:self forKeyPath:@"image"];
    [_imageModel removeObserver:self forKeyPath:@"progress"];
    
    _imageModel = imageModel;
    
    // 添加观察者
    [_imageModel addObserver:self forKeyPath:@"image" options:NSKeyValueObservingOptionOld context:nil];
    [_imageModel addObserver:self forKeyPath:@"progress" options:NSKeyValueObservingOptionOld context:nil];
}

- (void)dealloc {
    [self.imageModel removeObserver:self forKeyPath:@"image"];
    [self.imageModel removeObserver:self forKeyPath:@"progress"];
}

@end
