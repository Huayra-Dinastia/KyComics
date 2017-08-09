//
//  KYReadingViewController.m
//  Kycomics
//
//  Created by HongYi on 2017/8/4.
//  Copyright © 2017年 kcvly. All rights reserved.
//

#import "KYReadingViewController.h"

#import "KYComicsModel.h"

#import <JavaScriptCore/JavaScriptCore.h>

@interface KYReadingViewController () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *pages;

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
        
        NSMutableArray *imgPageUrls = [NSMutableArray arrayWithCapacity:nodes.count];
        for (TFHppleElement *node in nodes) {
            NSString *urlString = node.attributes[@"href"];
            [imgPageUrls addObject:urlString];
        }
        
        NSLog(@"%@", imgPageUrls);
        
        // 抓取showPhoto网页
        NSString *urlStr = imgPageUrls.lastObject;
        [[KYNetManager manager] kyGET:urlStr parameters:nil withCompletion:^(id responseObject) {
            // 解析网页
            TFHpple *doc = [[TFHpple alloc] initWithHTMLData:responseObject];
            NSArray<TFHppleElement *> *nodes = [doc searchWithXPathQuery:@"//script[@type='text/javascript']"];
            
            for (NSUInteger i = nodes.count - 1; i > 0; i--) {
                TFHppleElement *node = nodes[i];
                if (nil == node.attributes[@"src"]) {
                    NSLog(@"%@", node.content);
                    JSContext *jsContext = [[JSContext alloc] init];
                    [jsContext evaluateScript:node.content];
                    
                    // 获取到showkey
                    JSValue *showkey = [jsContext evaluateScript:@"showkey"];
                    if (![showkey.toString isEqualToString:@"undefined"]) {
                        NSLog(@"%@", showkey.toString);
                        
                        //https://e-hentai.org/s/1a8e31f2c6/1029334-2
                        //                          -2        -1
                        NSArray *strs = [urlStr componentsSeparatedByString:@"/"];
                        NSArray *strs2 = [strs.lastObject componentsSeparatedByString:@"-"];
                        NSString *gid = strs2.firstObject;
                        NSString *page = strs2.lastObject;
                        NSString *imgkey = strs[strs.count - 2];
                        
                        NSDictionary *parm = @{
                                               @"method": @"showpage",
                                               @"gid": gid,
                                               @"page": page,
                                               @"imgkey": imgkey,
                                               @"showkey": showkey.toString,
                                               };
                        [[KYNetManager manager] kyPOST:parm withCompletion:^(id responseObject) {
                            id i3 = [responseObject mj_JSONObject][@"i3"];
                            TFHpple *doc = [[TFHpple alloc] initWithHTMLData:[i3 mj_JSONData]];
                            TFHppleElement *node = [doc searchWithXPathQuery:@"//a/img"].lastObject;
                            
                            NSString *src = node.attributes[@"src"];
                            NSLog(@"%@", src);
                            [self.pages addObject:src];
//                            [self.tableView reloadData];
                            UIImageView *imageView = [[UIImageView alloc] init];
                            [imageView sd_setImageWithURL:[NSURL URLWithString:src]];
                            imageView.bounds = self.view.bounds;
                            [self.view addSubview:imageView];
                        }];
                        
                        return ;
                    }
                }
            }
        }];
    }];
}

#pragma UITableViewDelegate, UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
    if (nil == cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UITableViewCell"];
    }
    
    NSString *urlString = self.pages.lastObject;
    [cell.imageView sd_setImageWithURL:[NSURL URLWithString:urlString]];
    
    return cell;
}

- (UITableView *)tableView {
    if (nil == _tableView) {
        UITableView *tableView = [[UITableView alloc] init];
        tableView.bounds = self.view.bounds;
        tableView.delegate = self;
        tableView.dataSource = self;
        [self.view addSubview:tableView];
        
        _tableView = tableView;
    }
    return _tableView;
}

- (NSMutableArray *)pages {
    if (nil == _pages) {
        _pages = [NSMutableArray array];
    }
    return _pages;
}

@end
