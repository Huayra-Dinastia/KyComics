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

#define ITEM_MARGIN 3.0

@interface KYHomeViewController () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) NSMutableArray *comics;

@end

@implementation KYHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    [self requestData];
    
}

- (void)requestData {
    NSDictionary *parm = @{
                           @"page": @(0),
                           @"f_doujinshi": @(1),
                           @"f_manga": @(1),
                           @"f_artistcg": @(1),
                           @"f_gamecg": @(1),
                           @"f_western": @(1),
                           @"f_non-h": @(1),
                           @"f_imageset": @(1),
                           @"f_cosplay": @(1),
                           @"f_asianporn": @(1),
                           @"f_misc": @(1),
                           @"f_search": @"",
                           @"f_apply": @"Apply+Filter",
                           };
    
    KYNetManager *netManager = [KYNetManager manager];
    [netManager kyGET:parm withCompletion:^(id responseObject) {
        // 抓取到网页
        TFHpple *doc = [[TFHpple alloc] initWithHTMLData:responseObject];
        NSArray<TFHppleElement *> *picElements = [doc searchWithXPathQuery:@"//div [@class='it5']//a"];
        
        if (0 == picElements.count) {
            return ;
        }
        
        NSMutableArray *ids = [NSMutableArray arrayWithCapacity:picElements.count];
        // 从 a 标签中提取 图片的URL
        for (TFHppleElement *pic in picElements) {
            NSString *urlString = pic.attributes[@"href"];
            
            //https://e-hentai.org/g/618395/0439fa3666/
            //                          -3        -2       -1
            NSArray *tmpArr = [urlString componentsSeparatedByString:@"/"];
            NSUInteger length = tmpArr.count;
            NSString *str1 = tmpArr[length - 3];
            NSString *str2 = tmpArr[length - 2];
            [ids addObject:@[str1, str2]];
        }
        
        NSDictionary *parm = @{
                               @"method": @"gdata",
                               @"gidlist": ids
                               };
        
        [netManager kyPOST:parm withCompletion:^(id responseObject) {
            id result = [responseObject mj_JSONObject];
            NSLog(@"%@", result);
            NSMutableArray *comics = [KYComicsModel mj_objectArrayWithKeyValuesArray:result[@"gmetadata"]];
            [self.comics addObjectsFromArray:comics];
            [self.collectionView reloadData];
        }];
    }];
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
