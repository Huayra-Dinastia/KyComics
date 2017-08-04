//
//  KYComicsModel.h
//  Kycomics
//
//  Created by HongYi on 2017/8/4.
//  Copyright © 2017年 kcvly. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KYComicsModel : NSObject
@property (nonatomic, copy) NSString *gid;
@property (nonatomic, copy) NSString *token;
@property (nonatomic, copy) NSString *archiver_key;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *title_jpn;
@property (nonatomic, copy) NSString *category;
@property (nonatomic, copy) NSString *thumb;
@property (nonatomic, copy) NSString *uploader;
@property (nonatomic, copy) NSString *posted;
@property (nonatomic, copy) NSString *filecount;
@property (nonatomic, copy) NSString *filesize;
@property (nonatomic, assign) BOOL expunged;
@property (nonatomic, assign) double rating;
@property (nonatomic, assign) int torrentcount;
@property (nonatomic, strong) NSArray *tags;

@end
