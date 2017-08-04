//
//  KYReadingViewController.m
//  Kycomics
//
//  Created by HongYi on 2017/8/4.
//  Copyright © 2017年 kcvly. All rights reserved.
//

#import "KYReadingViewController.h"

#import "KYComicsModel.h"

@interface KYReadingViewController ()

@end

@implementation KYReadingViewController {
    KYComicsModel *_comic;
}

- (instancetype)initWithComic:(KYComicsModel *)comic {
    if (self = [super init]) {
        _comic = comic;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor orangeColor];
    NSLog(@"Reading =====> %@", _comic.title);
}

@end
