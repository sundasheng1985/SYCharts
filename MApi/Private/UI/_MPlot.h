//
//  _MPlot.h
//  MAPI
//
//  Created by FanChiangShihWei on 2016/3/30.
//  Copyright © 2016年 Mitake. All rights reserved.
//

#ifndef _MPlot_h
#define _MPlot_h

#import <Foundation/Foundation.h>
#import "MChartView.h"

#define PLOT_BORDER_COLOR [UIColor whiteColor]

bool MPlotRectIsValid(CGRect rect);

@class MPlot;

@protocol MPlotRequirement <NSObject>
@required
- (void)reloadData;

@end

@protocol MPlotAttributes <NSObject>
@required
- (CGFloat)barWidth;       //bar宽
- (CGFloat)barSpacing;     //bar间隙
- (CGFloat)borderWidth;    //边框宽
- (CGFloat)insideLineWidth;//内部线宽
@end

@protocol MPlotDrawing <NSObject>
- (void)handleXAxisWithIndex:(NSInteger)index left:(BOOL)left; //赋值左右时间
- (void)willRedrawRect:(CGRect)rect atRecordIndex:(NSInteger)recordIndex numberOfVisibleRecords:(NSInteger)numberOfVisibleRecords; //初始化绘图路径并获取最高，最低点
- (void)drawBorderRect:(CGRect)borderRect inContext:(CGContextRef)context; //绘制边框
- (void)drawRect:(CGRect)rect inContext:(CGContextRef)context atRecordIndex:(NSInteger)recordIndex xPosition:(CGFloat)xPosition attributeProvider:(id<MPlotAttributes>)attributeProvider; //绘制内容
- (void)endDrawingContext:(CGContextRef)context;  //结束绘制
- (NSUInteger)numberOfParams;   //参数个数
- (NSUInteger)numberOfDisplayValue;
@end


@class MOHLCItem, MStockItem;

@protocol MPlotDataSource <NSObject>
@required
- (MStockItem *)stockItemForPlot:(MPlot *)plot; //获取当前股票的行情快照
- (MOHLCItem *)plot:(MPlot *)plot itemAtRecordIndex:(NSUInteger)index; //下标获取k棒值
- (NSUInteger)numberOfRecordsForPlot:(MPlot *)plot; //多少k棒
- (void)updateXAxisString:(NSString *)xAxisString left:(BOOL)left; //更新左右时间
- (UInt8)numberOfDecimalForPlot:(MPlot *)plot; //小数点
@end


#pragma mark - MPlot

typedef NSString *(^MPlotDisplayFormat)(CGFloat displayValue);
/// 查價数值显示前可以进行format
typedef MPlotDisplayFormat EnquiredInformationDisplayFormat;
/// y轴数值显示前可以进行format
typedef MPlotDisplayFormat YAxisDisplayFormat;

@interface MPlot () <MPlotDrawing>
{

}
@property (nonatomic, weak) UIScrollView *valueLabelParentScrollView;

@property (nonatomic, weak) id <MPlotDataSource> dataSource;
@property (nonatomic, weak) id <MPlotRequirement> drawingTarget;

@property (nonatomic, readonly) NSString * labelStringFormat;

@property (nonatomic, readonly, assign) double minValue;
@property (nonatomic, readonly, assign) double maxValue;

@property (nonatomic, assign) CGFloat borderWidth;     //边框宽
@property (nonatomic, strong) UIColor *borderColor;    //边框颜色
@property (nonatomic, assign) CGFloat insideLineWidth; //边框内横线
@property (nonatomic, strong) UIColor *insideLineColor; //边框内横线颜色
/** y軸文字格式化。 */
@property (nonatomic, copy) YAxisDisplayFormat yAxisDisplayFormat;

@property (nonatomic, strong) UIColor *yAxisTextColor;
@property (nonatomic, strong) UIFont *yAxisFont;


/*! @brief 針對y軸文字Label layout。
 *
 * 相對於傳入的view的大小去做排列。
 * @param view 相對應的view。
 * @param inRect 限制的範圍。
 */
- (void)layoutYAxisLabelsToView:(UIView *)view inRect:(CGRect)inRect font:(UIFont *)font;
- (void)layoutYAxisLabelsToView:(UIView *)view inRect:(CGRect)inRect font:(UIFont *)font textAlignment:(NSTextAlignment)textAlignment;

/*! @brief 設置y軸文字。
 *
 */
- (void)relabelIfNeeded;

/// Default is the last record.
- (void)displayLastEnquiredInformation;
- (void)displayEnquiredInformationAtIndex:(NSInteger)index;

/// override
- (void)willSetup; /// create label
- (void)kill; /// remove label
- (void)beginCalculateParameter NS_REQUIRES_SUPER;

- (CGFloat)layoutValueLabelSizeToFit;

/// data get
- (NSUInteger)numberOfRecords;
- (MOHLCItem *)itemAtRecordIndex:(NSInteger)recordIndex;

@end

@interface MMAPlot ()
@property (nonatomic, assign) BOOL barFill;
@end

@interface MVOLPlot ()
@property (nonatomic, assign) BOOL barFill;
@property (nonatomic, readonly) double maxVolume;

@property (nonatomic, copy) EnquiredInformationDisplayFormat enquiredInfomationDisplayFormat;
- (instancetype)initWithYAxisLabelCount:(NSInteger)yAxisLabelCount
                                barFill:(BOOL)barFill;

@end


@interface MMACDPlot()
@end


@interface MOBVPlot ()
@property (nonatomic, copy) EnquiredInformationDisplayFormat enquiredInfomationDisplayFormat;

@end
#endif /* _MPlot_h */
