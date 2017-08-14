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
#import <UITableView+FDTemplateLayoutCell.h>


static NSString *KYPageCellId = @"KYPageCellId";

@interface KYReadingViewController () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) KYComicsModel *comic;
@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *pages;
@property (nonatomic, strong) NSOperationQueue *operationQueue;

@end

@implementation KYReadingViewController

+ (instancetype)instanceWithComic:(KYComicsModel *)comic {
    KYReadingViewController *vc = [KYReadingViewController xx_instantiateFromStoryboardNamed:@"KYReadingViewController"];
    vc.comic = comic;
    return vc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    self.view.backgroundColor = [UIColor orangeColor];
    NSLog(@"Reading =====> %@", self.comic.title);
    
    [[KYNetManager manager] getPageURLs:self.comic complection:^(NSArray *imgPageURLs) {
        for (NSString *imgPageURL in imgPageURLs) {
            KYImageOperation *operation = [[KYImageOperation alloc] initWithURL:imgPageURL complection:^(NSString *imgURL) {
//                http://1.249.129.170:6112/h/f77b22c7e8be53d8d2cc6799e524d6bd49c94ad3-441914-1280-1807-jpg/keystamp=1502713200-60cfbaa731;fileindex=54562424;xres=1280/000.jpg
                // 配置图片Cell大小
                [self.pages addObject:imgURL];
                [self.tableView reloadData];
//                [[SDWebImageManager sharedManager] loadImageWithURL:[NSURL URLWithString:imgURL]
//                                                            options:SDWebImageProgressiveDownload
//                                                           progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
//                                                               NSLog(@"%tu %tu %@", receivedSize, expectedSize, targetURL);
//                } completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
//                    if (finished) {
//                        [self.pages addObject:imageURL];
//                        [self.tableView reloadData];
//                    }
//                }];
            }];
            [self.operationQueue addOperation:operation];
            break;
        }
    }];
}

#pragma UITableViewDelegate, UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.pages.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    KYPageCell *cell = [tableView dequeueReusableCellWithIdentifier:KYPageCellId];
    
    NSString *urlString = self.pages[indexPath.row];
//    cell.imageView.image = self.pages[indexPath.row];
//    NSURL *imgURL = self.pages[indexPath.row];
//    [cell.imgView sd_setImageWithURL:imgURL];
    [cell setupWithImageURL:[NSURL URLWithString:urlString]];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *urlString = self.pages[indexPath.row];
    if (!urlString) {
        return 0;
    }
    return 200;
//    NSURL *imgURL = self.pages[indexPath.row];
//    return [tableView fd_heightForCellWithIdentifier:KYPageCellId configuration:^(KYPageCell *cell) {
//        [cell.imgView sd_setImageWithURL:imgURL];
//    }];
}

- (UITableView *)tableView {
    if (nil == _tableView) {
        UITableView *tableView = [[UITableView alloc] init];
        [tableView registerNib:[KYPageCell xx_nib] forCellReuseIdentifier:KYPageCellId];
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
