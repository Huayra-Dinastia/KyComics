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
@property (nonatomic, assign) double progress;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, assign) CGSize imgSize;

@end
