//
//  KYListCell.m
//  Kycomics
//
//  Created by HongYi on 2017/8/4.
//  Copyright © 2017年 kcvly. All rights reserved.
//

#import "KYListCell.h"

#import "KYComicsModel.h"
#import <UIImageView+WebCache.h>

@interface KYListCell ()
@property (weak, nonatomic) IBOutlet UILabel *labTitle;
@property (weak, nonatomic) IBOutlet UILabel *labFileCount;
@property (weak, nonatomic) IBOutlet UIImageView *thumbImageView;

@end

@implementation KYListCell
- (void)setComic:(KYComicsModel *)comic {
    _comic = comic;
    
    self.labTitle.text = _comic.title_jpn.length? _comic.title_jpn: _comic.title;
    self.labFileCount.text = _comic.filecount;
//    [self.thumbImageView sd_setImageWithURL:[NSURL URLWithString:_comic.thumb]];
}

@end
