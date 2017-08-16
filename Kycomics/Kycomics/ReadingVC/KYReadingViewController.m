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
@property (nonatomic, strong) NSMutableArray *imgModels;

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
    [self loadImages];
}

- (void)loadImages {
    __weak typeof(self) weakSelf = self;
    [[KYNetManager manager] getImageURL:self.comic complection:^(KYImageModel *imageModel) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        [strongSelf.imgModels addObject:imageModel];
        [strongSelf.tableView reloadData];
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
    return self.imgModels.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    KYPageCell *cell = [tableView dequeueReusableCellWithIdentifier:KYPageCellId];
    
    KYImageModel *imageModel = self.imgModels[indexPath.row];
    cell.imageModel = imageModel;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    KYImageModel *imageModel = self.imgModels[indexPath.row];
    return imageModel.imgSize.height;
}

#pragma mark - dealloc
- (void)dealloc {
    NSLog(@"dealloc");
    [[KYNetManager manager] cancelAllDownloads];
//    [self.imgURLOperationQueue cancelAllOperations];
}
- (NSMutableArray *)imgModels {
    if (nil == _imgModels) {
        _imgModels = [NSMutableArray arrayWithCapacity:[self.comic.filecount integerValue]];
    }
    return _imgModels;
}

@end
