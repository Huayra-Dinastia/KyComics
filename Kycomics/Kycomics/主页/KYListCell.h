//
//  KYListCell.h
//  Kycomics
//
//  Created by HongYi on 2017/8/4.
//  Copyright © 2017年 kcvly. All rights reserved.
//

#import <UIKit/UIKit.h>

@class KYComicsModel;

@interface KYListCell : UICollectionViewCell
@property (nonatomic, strong) KYComicsModel *comic;

@end
