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


static NSString *KYPageCellId = @"KYPageCellId";

@interface KYReadingViewController () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) KYComicsModel *comic;
@property (nonatomic, weak) IBOutlet UITableView *tableView;
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
    
    [[KYNetManager manager] getPageURLs:self.comic complection:^(NSArray *imgPageURLs) {
        for (NSString *imgPageURL in imgPageURLs) {
            if (self.showkey.length) {
                // 获取图片地址
                [[KYNetManager manager] getPageImage:imgPageURL showkey:self.showkey completion:^(NSString *imgURL) {
                    [[KYNetManager manager] loadImage:imgURL];
                    [self.tableView reloadData];
                }];
            } else {
                // 获取showkey
                [[KYNetManager manager] getShowkey:imgPageURL complection:^(NSString *showkey) {
                    self.showkey = showkey;
                    [[KYNetManager manager] getPageImage:imgPageURL showkey:self.showkey completion:^(NSString *imgURL) {
                        [[KYNetManager manager] loadImage:imgURL];
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
}

@end
