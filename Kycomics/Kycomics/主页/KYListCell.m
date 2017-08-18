//
//  KYListCell.m
//  Kycomics
//
//  Created by HongYi on 2017/8/4.
//  Copyright © 2017年 kcvly. All rights reserved.
//

#import "KYListCell.h"

#import "KYComicsModel.h"

@interface KYListCell ()
@property (weak, nonatomic) IBOutlet UILabel *labTitle;
@property (weak, nonatomic) IBOutlet UILabel *labRating;
@property (weak, nonatomic) IBOutlet UILabel *labFileCount;
@property (weak, nonatomic) IBOutlet UIImageView *thumbImageView;

@end

@implementation KYListCell
- (void)setComic:(KYComicsModel *)comic {
    _comic = comic;
    
    self.labTitle.text = _comic.title_jpn.length? _comic.title_jpn: _comic.title;
    self.labFileCount.text = _comic.filecount;
    self.labRating.text = [NSString stringWithFormat:@"%.2f", _comic.rating];
    self.contentView.backgroundColor = [UIColor colorWithRed:arc4random_uniform(256) / 255.0 green:arc4random_uniform(256) / 255.0 blue:arc4random_uniform(256) / 255.0 alpha:0.3];
    
    self.thumbImageView.alpha = 0;
    __weak typeof(self) weakSelf = self;
    [self.thumbImageView sd_setImageWithURL:[NSURL URLWithString:_comic.thumb]
                                  completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
                                      
                                      [UIView animateWithDuration:0.4 animations:^{
                                          __weak typeof(weakSelf) strongSelf = weakSelf;
                                          strongSelf.thumbImageView.alpha = 1.0;
                                          
                                      }];
    }];
}

@end
