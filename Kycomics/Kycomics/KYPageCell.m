//
//  KYPageCell.m
//  Kycomics
//
//  Created by HongYi on 2017/8/9.
//  Copyright © 2017年 kcvly. All rights reserved.
//

#import "KYPageCell.h"

@implementation KYPageCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.imgView.contentMode = UIViewContentModeScaleAspectFill;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
