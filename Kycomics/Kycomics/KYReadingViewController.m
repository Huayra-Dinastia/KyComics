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
#import <UITableView+FDTemplateLayoutCell.h>


static NSString *KYPageCellId = @"KYPageCellId";

@interface KYReadingViewController () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) KYComicsModel *comic;
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *pages;
@property (nonatomic, strong) NSOperationQueue *operationQueue;
@property (nonatomic, copy) NSString *showkey;

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
    
    NSLog(@"Reading =====> %@", self.comic.title);
    
    [[KYNetManager manager] getPageURLs:self.comic complection:^(NSArray *imgPageURLs) {
        for (NSString *imgPageURL in imgPageURLs) {
            if (self.showkey.length) {
                // 获取图片地址
                [[KYNetManager manager] getPageImage:imgPageURL showkey:self.showkey completion:^(NSString *imgURL) {
                    [self.pages addObject:imgURL];
                    [self.tableView reloadData];
                }];
            } else {
                // 获取showkey
                [[KYNetManager manager] getShowkey:imgPageURL complection:^(NSString *showkey) {
                    self.showkey = showkey;
                    [[KYNetManager manager] getPageImage:imgPageURL showkey:self.showkey completion:^(NSString *imgURL) {
                        [self.pages addObject:imgURL];
                        [self.tableView reloadData];
                    }];
                }];
            }
//            break;
        }
    }];
}

- (void)setupUI {
    [self.tableView registerNib:[KYPageCell xx_nib] forCellReuseIdentifier:KYPageCellId];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
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
