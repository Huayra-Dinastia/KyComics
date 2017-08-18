//
//  KYHomeViewController.m
//  Kycomics
//
//  Created by HongYi on 2017/8/3.
//  Copyright © 2017年 kcvly. All rights reserved.
//

#import "KYHomeViewController.h"

#import "KYListCell.h"
#import "KYComicsModel.h"
#import "KYReadingViewController.h"
#import "KYNetManager+EHentai.h"
#import <MJRefresh.h>

#define ITEM_MARGIN 3.0

@interface KYHomeViewController () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) NSMutableArray *comics;
@property (assign, nonatomic) NSInteger page;

@end

@implementation KYHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupUI];
    
    __weak typeof(self) weakSelf = self;
    self.collectionView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf getComics:self.page];
        strongSelf.page++;
    }];
    [self.collectionView.mj_footer beginRefreshing];
}

- (void)getComics:(NSInteger)page {
    __weak typeof(self) weakSelf = self;
    [[KYNetManager manager] getComics:page completion:^(NSArray *comics) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf.comics addObjectsFromArray:comics];
        [strongSelf.collectionView reloadData];
        
        [strongSelf.collectionView.mj_footer endRefreshing];
    }];
}

- (void)setupUI {
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.backgroundColor = [UIColor groupTableViewBackgroundColor];
}

#pragma mark - UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    KYComicsModel *comic = self.comics[indexPath.item];
    KYReadingViewController *readingVC = [KYReadingViewController instanceWithComic:comic];
    [self.navigationController pushViewController:readingVC animated:YES];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.comics.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    KYListCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"KYListCellId" forIndexPath:indexPath];
    cell.comic = self.comics[indexPath.item];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat itemW = (screenWidth - ITEM_MARGIN) * 0.5;
    CGFloat itemH = itemW * 1.45;
    return CGSizeMake(itemW, itemH);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return ITEM_MARGIN;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return ITEM_MARGIN;
}

#pragma mark - getter & setter
- (NSMutableArray *)comics {
    if (nil == _comics) {
        _comics = [NSMutableArray array];
    }
    return _comics;
}

@end
