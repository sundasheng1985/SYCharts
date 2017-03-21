//
//  _MChartView.h
//  MAPI
//
//  Created by FanChiangShihWei on 2016/4/5.
//  Copyright © 2016年 Mitake. All rights reserved.
//

#ifndef _MChartView_h
#define _MChartView_h

#import "MChartView.h"
#pragma mark -- 缩放比例 --
static inline CGFloat MChartViewScreenScale() {
    static dispatch_once_t onceToken;
    static CGFloat scale;
    dispatch_once(&onceToken, ^{
        scale = [UIScreen mainScreen].scale;
    });
    return scale;
}

@interface MChartView ()
{
    
}
- (void)initialized; //初始化
@end

@class MSnapQuoteRequest, MChartRequest, MFundValueRequest;
@interface MTrendChartView() //走势
{
    @private
    NSNumberFormatter *_numberFormatter;
}
/// 暂时private如无，用volumeRiseColor or volumeDropColor
@property (nonatomic, strong) UIColor *riseColor;
@property (nonatomic, strong) UIColor *dropColor;

@property (nonatomic, strong) NSArray *items;
@property (nonatomic, strong) NSArray *dates;
@property (nonatomic, assign) double maxVol; //最大量


@property (nonatomic, strong) NSMutableArray *datetimeLabels; //时间labels
@property (nonatomic, strong) NSMutableArray *leftLabels;     //左labels；
@property (nonatomic, strong) NSMutableArray *rightLabels;    //右labels；
@property (nonatomic, strong) NSMutableArray *volumeLabels;   //量labels；

@property (nonatomic, strong) MSnapQuoteRequest *snapRequest; //行情快照请求
@property (nonatomic, strong) MChartRequest *chartRequest;    //走势请求

@end


@interface MFundChartView()
@property (nonatomic, strong) NSArray *items;//存储基金净值
@property (nonatomic, strong) NSArray *allItems;//存储基金净值

@property (nonatomic, strong) NSMutableArray *datetimeLabels;//时间数组
@property (nonatomic, strong) NSMutableArray *leftLabels;

@property (nonatomic, strong) MSnapQuoteRequest *snapRequest;
@property (nonatomic, strong) MFundValueRequest *fundRequest;
@end


@interface MOHLCChartView()
@property (nonatomic, strong) NSTimer *delayCloseEnquiryLineTimer; //延时关闭查价线的定时器
@end

#endif /* _MChartView_h */
