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
@property (nonatomic, weak) IBOutlet UITableView *tableView;
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
    
    [self.tableView registerNib:[KYPageCell xx_nib] forCellReuseIdentifier:KYPageCellId];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    NSLog(@"Reading =====> %@", self.comic.title);
    
    [[KYNetManager manager] getPageURLs:self.comic complection:^(NSArray *imgPageURLs) {
        for (NSString *imgPageURL in imgPageURLs) {
            KYImageOperation *operation = [[KYImageOperation alloc] initWithURL:imgPageURL complection:^(NSString *imgURL) {
//                http://124.244.74.23:8484/h/659adba1360f9a1ea2618bf2834b8fdbfb50ad96-373906-851-1202-jpg/keystamp=1502769300-8f294c2d8d;fileindex=54577164;xres=org/p0.jpg
                
                // 配置图片Cell大小
                // 对图片排序
                [self.pages addObject:imgURL];
                [self.tableView reloadData];
            }];
            [self.operationQueue addOperation:operation];
//            break;
        }
    }];
}

- (CGSize)getCellHeight:(NSString *)imgURL {
    NSArray *strs = [imgURL componentsSeparatedByString:@"/"];
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
    return CGSizeMake(width * scale, height * scale);
}

#pragma UITableViewDelegate, UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.pages.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    KYPageCell *cell = [tableView dequeueReusableCellWithIdentifier:KYPageCellId];
    
    NSString *urlString = self.pages[indexPath.row];
    [cell setupWithImageURL:[NSURL URLWithString:urlString]];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *urlString = self.pages[indexPath.row];
    if (!urlString) {
        return 0;
    }
    return [self getCellHeight:urlString].height;
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
