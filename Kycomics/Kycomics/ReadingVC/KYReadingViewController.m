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
#import "KYNetManager+Downloader.h"
#import <UITableView+FDTemplateLayoutCell.h>
#import "KYImageModel.h"
#import "KYGETImageURLOperation.h"


static NSString *KYPageCellId = @"KYPageCellId";

@interface KYReadingViewController () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) KYComicsModel *comic;
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSOperationQueue *imgURLOperationQueue;

@end

@implementation KYReadingViewController

+ (instancetype)instanceWithComic:(KYComicsModel *)comic {
    KYReadingViewController *vc = [KYReadingViewController xx_instantiateFromStoryboardNamed:@"KYReadingViewController"];
    vc.comic = comic;
    return vc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupUI];
    
    __weak typeof(self) weakSelf = self;
    [[KYNetManager manager] getPageURLs:self.comic complection:^(NSArray *pageURLs) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        for (NSString *pageURL in pageURLs) {
            __weak typeof(strongSelf) weakSelf = strongSelf;
            KYGETImageURLOperation *operation = [[KYGETImageURLOperation alloc]
                                                 initWithPageURL:pageURL
                                                 withCompletion:^(NSString *imgURL) {
                                                     __weak typeof(weakSelf) strongSelf = weakSelf;
                                                     KYImageModel *imageModel = [[KYImageModel alloc] initWithPageURL:pageURL imgURL:imgURL];
                                                     [[KYNetManager manager] loadImage:imageModel];
                                                     [strongSelf.tableView reloadData];
                                                 }];
            
            [strongSelf.imgURLOperationQueue addOperation:operation];
        }
    }];
}

- (void)setupUI {
    [self.tableView registerNib:[KYPageCell xx_nib] forCellReuseIdentifier:KYPageCellId];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    self.title = self.comic.title_jpn;
}

#pragma UITableViewDelegate, UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [KYNetManager manager].downloadingQueue.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    KYPageCell *cell = [tableView dequeueReusableCellWithIdentifier:KYPageCellId];
    
    KYImageModel *imageModel = [KYNetManager manager].downloadingQueue[indexPath.row];
    cell.imageModel = imageModel;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    KYImageModel *imageModel = [KYNetManager manager].downloadingQueue[indexPath.row];
    return imageModel.imgSize.height;
}

#pragma mark - dealloc
- (void)dealloc {
    NSLog(@"dealloc");
    [[KYNetManager manager] cancelAllDownloads];
    [self.imgURLOperationQueue cancelAllOperations];
}

- (NSOperationQueue *)imgURLOperationQueue {
    if (nil == _imgURLOperationQueue) {
        _imgURLOperationQueue = [[NSOperationQueue alloc] init];
        _imgURLOperationQueue.maxConcurrentOperationCount = 1;
    }
    return _imgURLOperationQueue;
}

@end
