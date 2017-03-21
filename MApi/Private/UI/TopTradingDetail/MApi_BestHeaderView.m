//
//  BestHeaderView.m
//  TSApi
//
//  Created by Louis on 2015/4/24.
//  Copyright (c) 2015年 Mitake. All rights reserved.
//

#import "MApi_BestHeaderView.h"

@implementation MApi_BestHeaderView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor =[UIColor clearColor];
    }
    return self;
}


- (void)drawRect:(CGRect)rect {
//    CGRect bounds =self.bounds;
//    CGContextRef context =UIGraphicsGetCurrentContext();//取得畫布
//    CGContextSetLineWidth(context, 0.1);//設定線的寬度為0.1
//    [[UIColor grayColor]set];//設定畫的顏色為灰色
//    
//    CGContextBeginPath(context);
//    CGContextMoveToPoint(context, 0,bounds.size.height/2);
//    CGContextAddLineToPoint(context, bounds.size.width,bounds.size.height/2);
//    CGContextClosePath(context);
//    CGContextStrokePath(context);
}


@end
