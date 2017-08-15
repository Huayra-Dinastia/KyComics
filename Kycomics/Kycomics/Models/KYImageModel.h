//
//  KYImageModel.h
//  Kycomics
//
//  Created by HongYi on 2017/8/15.
//  Copyright © 2017年 kcvly. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KYImageModel : NSObject
@property (nonatomic, copy) NSString *imgURL;
@property (nonatomic, copy) NSString *pageURL;
@property (nonatomic, assign) double progress;
@property (nonatomic, strong) UIImage *image;

@property (nonatomic, assign, readonly) CGSize imgSize;
@property (nonatomic, assign, readonly) NSInteger index;

- (instancetype)initWithPageURL:(NSString *)pageURL imgURL:(NSString *)imgURL;

@end
