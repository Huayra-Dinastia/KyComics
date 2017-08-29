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
    if ([keyPath isEqualToString:KEYPATH_progress]) {
        [self showProgress:self.imageModel.progress];
    } else if ([keyPath isEqualToString:KEYPATH_isfinished]) {
        if (!self.imageModel.isfinished) {
            return;
        }
        
        self.imgView.image = self.imageModel.image;
    }
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.progressView.backgroundColor = [UIColor clearColor];
}

- (void)showProgress:(CGFloat)progress {
    CGFloat progressViewW = [UIScreen mainScreen].bounds.size.width * progress;
    
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf.progressView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.offset(progressViewW);
        }];
        strongSelf.progressView.backgroundColor = [UIColor orangeColor];
        
        if (progress >= 1) {
            [strongSelf.progressView removeFromSuperview];
        }
    });
}

#pragma mark - getter & setter
- (UIView *)progressView {
    if (nil == _progressView) {
        UIView *progressView = [[UIView alloc] init];
        [self.contentView addSubview:progressView];
        
        [progressView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.top.equalTo(self.contentView);
            make.height.offset(2);
            make.width.offset(0);
        }];
        
        _progressView = progressView;
    }
    return _progressView;
}

- (void)setImageModel:(KYImageModel *)imageModel {
    [_imageModel removeObserver:self forKeyPath:KEYPATH_isfinished];
    [_imageModel removeObserver:self forKeyPath:KEYPATH_progress];
    
    _imageModel = imageModel;
    [self showProgress:_imageModel.progress];
    self.imgView.image = _imageModel.image;
    
    // 添加观察者
    [_imageModel addObserver:self forKeyPath:KEYPATH_isfinished options:NSKeyValueObservingOptionOld context:nil];
    [_imageModel addObserver:self forKeyPath:KEYPATH_progress options:NSKeyValueObservingOptionOld context:nil];
}

- (void)dealloc {
    [self.imageModel removeObserver:self forKeyPath:KEYPATH_isfinished];
    [self.imageModel removeObserver:self forKeyPath:KEYPATH_progress];
}

@end
