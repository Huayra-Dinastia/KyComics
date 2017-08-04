//
//  KYReadingViewController.m
//  Kycomics
//
//  Created by HongYi on 2017/8/4.
//  Copyright © 2017年 kcvly. All rights reserved.
//

#import "KYReadingViewController.h"

#import "KYComicsModel.h"

@interface KYReadingViewController ()

@end

@implementation KYReadingViewController {
    KYComicsModel *_comic;
}

- (instancetype)initWithComic:(KYComicsModel *)comic {
    if (self = [super init]) {
        _comic = comic;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor orangeColor];
    NSLog(@"Reading =====> %@", _comic.title);
    [self requestData];
}

- (void)requestData {
//    https://e-hentai.org/g/1095675/956b248cf6/
    NSString *urlString = [NSString stringWithFormat:@"g/%@/%@", _comic.gid, _comic.token];
    [[KYNetManager manager] kyGET:urlString parameters:nil withCompletion:^(id responseObject) {
        // 解析网页
        TFHpple *doc = [[TFHpple alloc] initWithHTMLData:responseObject];
        NSArray<TFHppleElement *> *nodes = [doc searchWithXPathQuery:@"//div [@class='gdtm']//a"];
        
        if (0 == nodes.count) {
            return ;
        }
        
        NSMutableArray *imgPages = [NSMutableArray arrayWithCapacity:nodes.count];
        for (TFHppleElement *node in nodes) {
            NSString *urlString = node.attributes[@"href"];
            [imgPages addObject:urlString];
        }
        
        NSLog(@"%@", imgPages);
    }];
}

@end
