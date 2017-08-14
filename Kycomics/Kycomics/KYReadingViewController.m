//
//  KYReadingViewController.m
//  Kycomics
//
//  Created by HongYi on 2017/8/4.
//  Copyright © 2017年 kcvly. All rights reserved.
//

#import "KYReadingViewController.h"

#import "KYComicsModel.h"
#import "KYPageCell.h"
#import "KYNetManager+EHentai.h"
#import "KYImageOperation.h"

#import <JavaScriptCore/JavaScriptCore.h>

@interface KYReadingViewController () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *pages;
@property (nonatomic, strong) NSOperationQueue *operationQueue;

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
    
    [[KYNetManager manager] getPageURLs:_comic complection:^(NSArray *imgPageURLs) {
        for (NSString *imgPageURL in imgPageURLs) {
            KYImageOperation *operation = [[KYImageOperation alloc] initWithURL:imgPageURL complection:^(NSString *imgURL) {
                
                
                [[SDWebImageManager sharedManager] loadImageWithURL:[NSURL URLWithString:imgURL]
                                                            options:SDWebImageProgressiveDownload
                                                           progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
                    
                } completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
                    if (finished) {
                        [self.pages addObject:imageURL];
                        [self.tableView reloadData];
                    }
                }];
            }];
            [self.operationQueue addOperation:operation];
        }
    }];
}

#pragma UITableViewDelegate, UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.pages.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    KYPageCell *cell = [tableView dequeueReusableCellWithIdentifier:[KYPageCell xx_nibID]];
    
//    NSString *urlString = self.pages[indexPath.row];
//    cell.imageView.image = self.pages[indexPath.row];
    NSURL *imgURL = self.pages[indexPath.row];
    [cell.imgView sd_setImageWithURL:imgURL];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 120;
}

- (UITableView *)tableView {
    if (nil == _tableView) {
        UITableView *tableView = [[UITableView alloc] init];
        [tableView registerNib:[KYPageCell xx_nib] forCellReuseIdentifier:[KYPageCell xx_nibID]];
        tableView.delegate = self;
        tableView.dataSource = self;
        [self.view addSubview:tableView];
        
        [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.bottom.right.equalTo(self.view);
        }];
        
        _tableView = tableView;
    }
    return _tableView;
}

- (NSMutableArray *)pages {
    if (nil == _pages) {
        _pages = [NSMutableArray array];
    }
    return _pages;
}

- (NSOperationQueue *)operationQueue {
    if (nil == _operationQueue) {
        _operationQueue = [[NSOperationQueue alloc] init];
        _operationQueue.maxConcurrentOperationCount = 1;
    }
    return _operationQueue;
}

@end
