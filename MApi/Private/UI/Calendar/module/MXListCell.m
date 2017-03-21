//
//  MXListCell.m
//  NewStock
//
//  Created by IOS_HMX on 16/7/1.
//  Copyright © 2016年 humingxing. All rights reserved.
//

#import "MXListCell.h"
#import "MXDefine.h"
#import "UIView+Additions.h"

@implementation MXListCell
-(void)layoutSubviews
{
    [super layoutSubviews];
    CGFloat width = (CGRectGetWidth(self.frame)-LEFT_PADDING*2)/4;
    CGFloat height = CGRectGetHeight(self.frame);
    for (int i =0; i<5; i++) {
        UILabel *label = [self.contentView viewWithTag:i+VIEW_TAG];
        if (label) {
            if(i==0)
            {
                label.frame = CGRectMake(LEFT_PADDING+i*width, 3, width, height*0.7);
            }else if (i==4)
            {
                label.frame = CGRectMake(LEFT_PADDING, height*0.7-3, width, height*0.3);
            }else
            {
                label.frame = CGRectMake(LEFT_PADDING+i*width, 0, width, height);
            }
        }
    }
}
-(void)setValues:(NSArray *)values
{
    _values = values;
    NSArray *const aliginment = @[@0,@1,@1,@2,@0];
    if(!values||values.count != 5)return;
    for (int i=0; i<values.count; i++) {
        UILabel *label = [self.contentView viewWithTag:VIEW_TAG+i];
        if (!label) {
            label = [[UILabel alloc]init];
            label.backgroundColor = [UIColor clearColor];
            if(i==4)
            {
                //股票代码
                label.font = [UIFont systemFontOfSize:_codeIdFontSize];
                label.textColor = _codeIdColor;
            }else
            {
                label.font = [UIFont systemFontOfSize:_cellFontSize];
                label.textColor = _cellTextColor;
            }
            label.textAlignment = [aliginment[i] integerValue];
            label.tag = VIEW_TAG+i;
            label.minimumScaleFactor = 0.5;
            label.adjustsFontSizeToFitWidth = YES;
            [self.contentView addSubview:label];
        }
        label.text = values[i];
    }
}
@end
