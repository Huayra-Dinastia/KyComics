//
//  ViewController.m
//  Kycomics
//
//  Created by HongYi on 2017/8/3.
//  Copyright © 2017年 kcvly. All rights reserved.
//

#import "ViewController.h"

#import <TFHpple.h>
#import "KYNetManager.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
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
            id result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:nil];
            NSLog(@"%@", result);
            
        }];
    }];
    
}

@end
