//
//  MChartView4Trend.h
//  MAPI
//
//  Created by FanChiangShihWei on 2016/12/23.
//  Copyright © 2016年 Mitake. All rights reserved.
//

#import "MChartView.h"
#import "_MAsyncLayer.h"

#define RETINA_LINE(lineWidth) (((CGFloat)lineWidth))

@class MTrendChartEnquiryView;

@interface MChartView4Trend () <UIGestureRecognizerDelegate, _MAsyncLayerDelegate>
{
    @package
    
    struct {
        unsigned int isPinching:1;         //加紧（没用）
        unsigned int isEnquiring:1;        //正在查价
        unsigned int delayReloadData:1;    //延时刷新
        unsigned int contentNeedsUpdate:1; //需要更新
        unsigned int chartFrameChanged:1;  //frame改变
    } _chartViewFlags;
    NSInteger lastIndex;
    NSInteger _previousEnquireIndex;       //以前的查价下标
    NSUInteger _previousVisibleRecords;    //以前的查价总个数
    
    CGFloat _previousEnquireLocationX;     //查价X坐标
    CGFloat _previousEnquireLocationY;     //查价Y坐标
    
    CGRect _chartRect;                     //rect
}
@property (nonatomic, strong) MStockItem *stockItem;
@property (nonatomic, strong) MTrendChartEnquiryView *enquiryView; //查价视图

@property (nonatomic, assign) double minValue;                     //最大值
@property (nonatomic, assign) double maxValue;                     //最小值

@property (nonatomic, strong) UILongPressGestureRecognizer *longPressGestureRecognizer;                                    //长按手势
@property (nonatomic, strong) UIPanGestureRecognizer *panGestureRecognizer; //平移手势
@property (nonatomic, strong) UITapGestureRecognizer *tapGestureRecognizer; //轻拍手势
@property (nonatomic, strong) NSTimer *delayCloseEnquiryLineTimer; //定时器（延时关闭查价线）

- (CGRect)drawingChartRect;  //去除时间轴高度的rect内偏移边框宽
- (CGRect)chartRect;         //去除时间轴高度的rect
- (BOOL)isYAxisLabelInside;  //判断Y轴label在内外
- (void)contentNeedsUpdate;  //需要重绘

- (void)drawLinearGradient:(CGContextRef)context
                      path:(CGPathRef)path
                    colors:(NSArray *)colors
                 locations:(CGFloat *)locations
                      type:(NSInteger)type;       //没看到用

- (void)drawLinearGradient:(CGContextRef)context
                      path:(CGPathRef)path
                startColor:(CGColorRef)startColor
                  midColor:(CGColorRef)midColor
                  endColor:(CGColorRef)endColor
                      type:(NSInteger)type;       //没看到用

/// override it
- (void)override_endEnquire;  //结束查价
- (void)override_startEnquireWithGesture:(UIGestureRecognizer *)gestureRecognizer; //开始查价
- (_MAsyncLayerDisplayTask *)override_newAsyncDisplayTask;
@end

#pragma mark --  分时查价线图 --
@interface MTrendChartEnquiryView : UIView
@property (nonatomic, assign) CGRect priceChartRect;          //价格rect
@property (nonatomic, assign) CGRect volumeChartRect;         //量rect
@property (nonatomic, assign) CGPoint touchLocation;          //触摸的点
@property (nonatomic, strong) UILabel *xAxisLabel;            //x轴label
@property (nonatomic, strong) UILabel *yAxisLabel;            //Y轴label
@property (nonatomic, strong) UIColor *lineColor;             //线颜色
@property (nonatomic, strong) UIFont *labelTextFont;          //label字体大小
@property (nonatomic, strong) UIColor *labelBackgroundColor;  //label背景色
@property (nonatomic, strong) UIColor *labelTextColor;        //label字体颜色

+ (instancetype)bindView:(UIView *)view;      //创建并添加到view上

- (void)drawInRect:(CGRect)rect
    priceChartRect:(CGRect)priceChartRect
   volumeChartRect:(CGRect)volumeChartRect
       yAxisString:(NSString *)yAxisString
       xAxisString:(NSString *)xAxisString
     touchLocation:(CGPoint)touchLocation
       borderWidth:(CGFloat)borderWidth
  yAxisLabelInside:(BOOL)yAxisLabelInside;    //绘制查价线

- (void)clear;   //隐藏

@end
