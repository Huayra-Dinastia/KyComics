//
//  KYImageModel.h
//  Kycomics
//
//  Created by HongYi on 2017/8/15.
//  Copyright © 2017年 kcvly. All rights reserved.
//

#import <Foundation/Foundation.h>

FOUNDATION_EXPORT const NSString *KEYPATH_isfinished;
FOUNDATION_EXPORT const NSString *KEYPATH_progress;

@interface KYImageModel : NSObject
@property (nonatomic, copy) NSString *imgURLstr;
@property (nonatomic, strong, readonly) NSURL *imgURL;
@property (nonatomic, copy) NSString *pageURLstr;
@property (nonatomic, strong, readonly) NSURL *pageURL;
@property (nonatomic, assign) double progress;
@property (nonatomic, assign) BOOL isfinished;
@property (nonatomic, strong, readonly) UIImage *image;

@property (nonatomic, assign, readonly) CGSize imgSize;
@property (nonatomic, assign, readonly) NSInteger index;

- (instancetype)initWithPageURLstr:(NSString *)pageURLstr imgURLstr:(NSString *)imgURLstr;

@end
