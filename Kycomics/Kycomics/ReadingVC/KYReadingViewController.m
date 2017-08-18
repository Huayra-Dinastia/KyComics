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
#import "UITableView+FDTemplateLayoutCell.h"
#import "KYImageModel.h"
#import <MJRefresh.h>

static NSString *KYPageCellId = @"KYPageCellId";
static NSInteger preloadingPageCount = 2;

@interface KYReadingViewController () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) KYComicsModel *comic;
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, weak) IBOutlet UILabel *labPageIndex;
@property (nonatomic, strong) NSMutableArray *imgModels;
@property (nonatomic, assign) NSInteger currentPageIndex;
@property (nonatomic, assign) NSInteger loadedIndex;

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

    [self loadImagesWithIndex:self.loadedIndex];
}

- (void)loadImagesWithIndex:(NSInteger)index {
    __weak typeof(self) weakSelf = self;
    [[KYNetManager manager] getImageURL:self.comic
                                  index:index
                            complection:^(KYImageModel *imageModel) {
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
    
    self.labPageIndex.backgroundColor = [UIColor colorWithWhite:0.5 alpha:0.5];
    self.labPageIndex.textColor = [UIColor whiteColor];
    self.labPageIndex.layer.masksToBounds = YES;
    self.labPageIndex.layer.cornerRadius = self.labPageIndex.bounds.size.height * 0.5;
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

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    KYImageModel *imageModel = nil;
    /// 加载方法似乎有点问题
    NSInteger rowCount = [self tableView:tableView numberOfRowsInSection:0];
    for (NSInteger index = indexPath.row; index < rowCount - 1; index ++) {
        if (index > indexPath.row + preloadingPageCount) {
            break;
        }
        
        imageModel = self.imgModels[index];
        [[KYNetManager manager] loadImage:imageModel];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    // 计算当前页数
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:scrollView.contentOffset];
    if (indexPath) {
        self.currentPageIndex = indexPath.row + 1;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    KYImageModel *imageModel = self.imgModels[indexPath.row];
    return imageModel.imgSize.height;
}

#pragma mark - dealloc
- (void)dealloc {
    NSLog(@"dealloc");
    [[NSNotificationCenter defaultCenter] postNotificationName:KYNetManagerEhentaiCancelLoadingNotification object:nil];
}
- (NSMutableArray *)imgModels {
    if (nil == _imgModels) {
        _imgModels = [NSMutableArray arrayWithCapacity:[self.comic.filecount integerValue]];
    }
    return _imgModels;
}

- (void)setCurrentPageIndex:(NSInteger)currentPageIndex {
    _currentPageIndex = currentPageIndex;
    
    self.labPageIndex.text = [NSString stringWithFormat:@"   %tu / %tu   ", self.currentPageIndex, [self.comic.filecount integerValue]];
}

@end
