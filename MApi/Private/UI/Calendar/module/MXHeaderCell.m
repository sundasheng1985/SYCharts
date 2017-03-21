//
//  MXHeaderCell.m
//  NewStock
//
//  Created by IOS_HMX on 16/7/1.
//  Copyright © 2016年 humingxing. All rights reserved.
//

#import "MXHeaderCell.h"
#import "MXDefine.h"
#import "UIView+Additions.h"
@implementation MXHeaderCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor =
        self.contentView.backgroundColor = [UIColor colorWithRed:16.0/255.0 green:20.0/255.0 blue:25.0/255.0 alpha:1];
    }
    return self;
}
-(void)layoutSubviews
{
    [super layoutSubviews];
    CGFloat width = (CGRectGetWidth(self.frame)-LEFT_PADDING*2)/4;
    CGFloat height = CGRectGetHeight(self.frame);
    for (int i =0; i<4; i++) {
        UILabel *label = [self.contentView viewWithTag:i+VIEW_TAG];
        if (label) {
            label.frame = CGRectMake(LEFT_PADDING+i*width, 0, width, height);
        }
    }
    [self setBorderWidth:1 withColor:_separatorClolor edgeInsets:UIEdgeInsetsMake(0, 10, 0, 10) direction:UIViewCustomBorderDirectionBottom];
}
-(void)setTitles:(NSArray *)titles
{
    _titles = titles;
    NSArray *const aliginment = @[@0,@1,@1,@2];
    if(!titles||titles.count != 4)return;
    for (int i=0; i<titles.count; i++) {
        UILabel *label = [self.contentView viewWithTag:VIEW_TAG+i];
        if (!label) {
            label = [[UILabel alloc]init];
            label.backgroundColor = _promptBackColor;
            label.font = [UIFont systemFontOfSize:_headerPromptFontSize];
            label.textColor = _headerPromptColor;
            label.textAlignment = [aliginment[i] integerValue];
            label.tag = VIEW_TAG+i;
            label.minimumScaleFactor = 0.5;
            label.adjustsFontSizeToFitWidth = YES;
            [self.contentView addSubview:label];
        }
        label.text = titles[i];
    }
}

@end
