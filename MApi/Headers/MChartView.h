/////////////////////////////////////////////////////////
//                                                     //
// Copyright (c) 2016年 上证云平台. All rights reserved. //
//                                                     //
/////////////////////////////////////////////////////////


#import <UIKit/UIKit.h>

#pragma mark - 图型化接口

/** 注册查价线开始查询时的NotificationKey */
extern NSString * const MChartDidStartEnquiryNotification;
/** 注册查价线结束查询时的NotificationKey */
extern NSString * const MChartDidEndEnquiryNotification;

/** 注册基金净值查价线开始查询时的NotificationKey */
extern NSString * const MFundValueDidStartEnquiryNotification;
/** 注册基金净值查价线结束查询时的NotificationKey */
extern NSString * const MFundValueDidEndEnquiryNotification;

typedef NS_OPTIONS(NSInteger, MChartEnquiryLineMode) {
    MChartEnquiryLineModeNone = 1 << 0,
    MChartEnquiryLineModeSticky = 1 << 1,           //长按就移动
    
    MChartEnquiryLineModeNotToDisappear = 1 << 10,  //不立即消失
    MChartEnquiryLineModeDelayDisappear = 1 << 11,  //延迟不消失（几秒后自动消失,默认1秒）
    
    MChartEnquiryLineModeDelayAppear = 1 << 20,        //延时出现（sticky）
    MChartEnquiryLineModeAppearImmediately = 1 << 21   //立即出现（sticky）
};

#pragma mark - 线图父类

@class MStockItem;

/*! @brief 线图父类别
 */
@interface MChartView : UIView
/** 股票代码(包含市场别) 如：000001.sh */
@property (nonatomic, copy) NSString *code;
/** y轴文字风格 */
@property (nonatomic, strong) UIFont *yAxisFont;
/** x轴文字风格 */
@property (nonatomic, strong) UIFont *xAxisFont;
/** x轴文字颜色 */
@property (nonatomic, strong) UIColor *xAxisTextColor;
/** 外框线宽px */
@property (nonatomic, assign) CGFloat borderWidth;
/** 外框颜色 */
@property (nonatomic, strong) UIColor *borderColor;
/** 内部线宽px */
@property (nonatomic, assign) CGFloat insideLineWidth;
/** 内部线颜色 */
@property (nonatomic, strong) UIColor *insideLineColor;
/** 是否可使用查价线, 默认 YES */
@property (nonatomic, assign) BOOL enquiryEnabled;
/** 查价线颜色 */
@property (nonatomic, readwrite) UIColor *enquiryLineColor;
/** 查价线外框颜色 */
@property (nonatomic, readwrite) UIColor *enquiryFrameColor;
/** 查价线文字风格 */
@property (nonatomic, readwrite) UIFont *enquiryTextFont;
/** 查价线文字颜色 */
@property (nonatomic, readwrite) UIColor *enquiryTextColor;
/** 查价线模式, 默认 MChartEnquiryLineModeSticky */
@property (nonatomic, assign) MChartEnquiryLineMode enquiryLineMode;
/** 确定label位置 */
@property (nonatomic, strong) NSDictionary *options;
@property (nonatomic, assign) UIEdgeInsets yAxisLabelInsets;
/** 延时结束查价时间 */
@property (nonatomic, assign) NSTimeInterval delayEndEnquireTimeInterval;

/*! @brief 刷新线图
 *
 * 包含请求数据及计算指标。
 */
- (void)reloadData;
- (void)reloadDataWithStockItem:(MStockItem *)stockItem;

@end

@interface MChartView4Trend : MChartView
/** 渐层颜色位置 */
@property (nonatomic, readwrite) CGFloat *gradientLocations;

@end

#pragma mark - 走势图

typedef NS_ENUM(NSInteger, MTrendChartType) {
    MTrendChartTypeOneDay,
    MTrendChartTypeFiveDays,
};

@interface MChartDotView : UIView
@property (nonatomic, strong) UIColor *color;
+ (MChartDotView *)blinkDot;
@end

/*! @brief 走势图
 */
@interface MTrendChartView : MChartView4Trend
/** 走势图类型 @see MTrendChartType */
@property (nonatomic, assign) MTrendChartType type;
/** 价格涨文字颜色 */
@property (nonatomic, strong) UIColor *priceRiseTextColor;
/** 价格平盘文字颜色 */
@property (nonatomic, strong) UIColor *priceFlatTextColor;
/** 价格跌文字颜色 */
@property (nonatomic, strong) UIColor *priceDropTextColor;
/** 价格涨幅文字颜色 */
@property (nonatomic, strong) UIColor *rangeRiseTextColor;
/** 价格幅度平盘文字颜色 */
@property (nonatomic, strong) UIColor *rangeFlatTextColor;
/** 价格跌幅文字颜色 */
@property (nonatomic, strong) UIColor *rangeDropTextColor;
/** 量文字颜色 */
@property (nonatomic, strong) UIColor *volumeTextColor;
/** 价格线颜色 */
@property (nonatomic, strong) UIColor *currentLineColor;
/** 价格线宽px */
@property (nonatomic, assign) CGFloat currentLineWidth;
/** 均价线颜色 */
@property (nonatomic, strong) UIColor *averageLineColor;
/** 均价线宽px */
@property (nonatomic, assign) CGFloat averageLineWidth;
/** 量涨颜色 */
@property (nonatomic, strong) UIColor *volumeRiseColor;
/** 量跌颜色 */
@property (nonatomic, strong) UIColor *volumeDropColor;
/** 渐层颜色 */
@property (nonatomic, strong) NSArray *gradientColors;
/** 最后一个报价发亮点 */
@property (nonatomic, strong) UIView *lastBlinkDot;

@end


#pragma mark - k线图

@class MPlot, MMAPlot;
typedef NS_ENUM(NSInteger, MOHLCChartType) {
    MOHLCChartTypeDay,
    MOHLCChartTypeWeek,
    MOHLCChartTypeMonth,
    MOHLCChartTypeMin5,
    MOHLCChartTypeMin15,
    MOHLCChartTypeMin30,
    MOHLCChartTypeMin60,
    MOHLCChartTypeMin120
};


typedef NS_ENUM(NSInteger, MOHLCChartPriceAdjustedMode) {
    MOHLCChartPriceAdjustedModeNone,
    MOHLCChartPriceAdjustedModeForward,
    MOHLCChartPriceAdjustedModeBackward
};

typedef NS_ENUM(NSInteger, MOHLCChartEnquiryLineMovingDirection) {
    MOHLCChartEnquiryLineMovingDirectionLeft,
    MOHLCChartEnquiryLineMovingDirectionRight
};

extern NSString * const MOHLCChartViewPreviousItemNotificationInfoKey;

/*! @brief k线图
 */
@interface MOHLCChartView : MChartView
/** k线图类型 @see MOHLCChartType */
@property (nonatomic, assign) MOHLCChartType type;
/** 复权模式 默认不复权 */
@property (nonatomic, assign) MOHLCChartPriceAdjustedMode priceAdjustedMode;
/** 设置画面k棒笔数 */
@property (nonatomic, assign) NSUInteger numberOfVisibleRecords;
/** 主图当前索引值 */
@property (nonatomic, assign) NSUInteger majorPlotIndex;
/** 副图当前索引值 */
@property (nonatomic, assign) NSUInteger minorPlotIndex;
/** 主图设定按钮 */
@property (nonatomic, strong) UIButton *majorPlotSettingButton;
/** 主图切换索引按钮 */
@property (nonatomic, strong) UIButton *majorPlotChangeIndexButton;
/** 主图切换前后复权按钮 */
@property (nonatomic, strong) UIButton *majorPlotPriceAdjustedButton;
/** 副图切换索引按钮 */
@property (nonatomic, strong) UIButton *minorPlotChangeIndexButton;
/** 副图右边按钮 */
@property (nonatomic, strong) NSArray *minorPlotRightButtons;
/** 主图plot数组, 详见MPlot */
@property (nonatomic, readwrite) NSArray *majorPlots;
/** 副图plot数组, 详见MPlot */
@property (nonatomic, readwrite) NSArray *minorPlots;
/** k棒是否填充  默认 NO */
@property (nonatomic, readwrite) BOOL barFill;
/** 是否可滚动  默认 YES */
@property (nonatomic, assign) BOOL scrollEnabled;
/** 是否可缩放  默认 YES */
@property (nonatomic, assign) BOOL zoomEnabled;
/** 主图实例 */
@property (nonatomic, readonly) UIView *majorGraphView; //疑问，为什么不用scrollview
/** 副图实例 */
@property (nonatomic, readonly) UIView *minorGraphView;
/** y轴文字颜色 */
@property (nonatomic, strong) UIColor *yAxisTextColor;

/*! @brief 加入主图
 *
 * 设置主图，需为MMAPlot子类
 * @param plot 主图实例
 */
- (void)addMajorPlot:(MMAPlot *)plot;
- (void)addMajorPlots:(MMAPlot *)plots, ...;

/*! @brief 加入副图
 *
 * 设置附图，需为MPlot子类
 * @param plot 副图实例
 */
- (void)addMinorPlot:(MPlot *)plot;
- (void)addMinorPlots:(MPlot *)plots, ...;
//查价线向左或向右移动一个对象的距离
- (void)moveEnquiryLineToDirection:(MOHLCChartEnquiryLineMovingDirection)direction;
@end

#pragma mark - 基金净值走势图

/*! @brief 净值走势图
 */
@interface MFundChartView : MChartView4Trend
/** 价格涨文字颜色 */
@property (nonatomic, strong) UIColor *priceRiseTextColor;
/** 价格平盘文字颜色 */
@property (nonatomic, strong) UIColor *priceFlatTextColor;
/** 价格跌文字颜色 */
@property (nonatomic, strong) UIColor *priceDropTextColor;
/** 价格涨幅文字颜色 */
@property (nonatomic, strong) UIColor *rangeRiseTextColor;
/** 价格幅度平盘文字颜色 */
@property (nonatomic, strong) UIColor *rangeFlatTextColor;
/** 价格跌幅文字颜色 */
@property (nonatomic, strong) UIColor *rangeDropTextColor;
/** 价格线颜色 */
@property (nonatomic, strong) UIColor *currentLineColor;
/** 价格线宽px */
@property (nonatomic, assign) CGFloat currentLineWidth;
/** 渐层颜色 */
@property (nonatomic, strong) NSArray *gradientColors;
/** 开始时间 */
@property (nonatomic, copy) NSString *startTime;
/** 结束时间 */
@property (nonatomic, copy) NSString *endTime;

/*! @brief 获取净值数组
 *
 * 一年内所有净值信息
 */
- (NSArray *)getALLFundValue;

@end

#pragma mark - 图型物件

@interface MPlot : NSObject
/** 图型标题 */
@property (nonatomic, readonly) NSString *title;
/** 其他参数 */
@property (nonatomic, strong) NSDictionary *options;

/*! @brief 初始化
 *
 * 初始化并设置y轴Label个数
 * @param yAxisLabelCount y轴Label个数
 */
- (instancetype)initWithYAxisLabelCount:(NSInteger)yAxisLabelCount;

/*! @brief 重新绘制
 *
 * 重新计算并绘制
 */
- (void)redraw;

/*! @brief 设置参数
 *
 * 设置参数请参照各指标参数文档
 * @param param 参数值
 */
- (void)setParameters:(NSUInteger)param, ...;
- (void)setParametersFromArray:(NSArray *)params;

/*! @brief 设置线的颜色
 *
 * 设置线的颜色，与参数成对
 * @param color 线颜色
 */
- (void)setLineColors:(UIColor *)color, ...;
- (void)setLineColorsFromArray:(NSArray *)colors;

/*! @brief 设置全局线的颜色
 *
 * 设置线的颜色，与参数成对
 * @param color 线颜色
 */
+ (void)setDefaultLineColors:(UIColor *)color, ...;

@end


#pragma mark - MA
@interface MMAPlot : MPlot
/** 是否隐藏k棒, 默认NO */
@property (nonatomic, assign, getter=isKBarHidden) BOOL kBarHidden;

/** k棒平盘颜色 */
@property (nonatomic, strong) UIColor *flatColor;
/** k棒涨颜色 */
@property (nonatomic, strong) UIColor *riseColor;
/** k棒跌颜色 */
@property (nonatomic, strong) UIColor *dropColor;
@end


#pragma mark - BOLL
@interface MBOLLPlot : MMAPlot
@end


#pragma mark - VOL
@interface MVOLPlot : MPlot
/** k棒平盘颜色 */
@property (nonatomic, strong) UIColor *flatColor;
/** k棒涨颜色 */
@property (nonatomic, strong) UIColor *riseColor;
/** k棒跌颜色 */
@property (nonatomic, strong) UIColor *dropColor;
@end

#pragma mark - AMO
@interface MAMOPlot : MVOLPlot
@end

#pragma mark - RSI
@interface MRSIPlot : MPlot

@end

#pragma mark - KDJ
@interface MKDJPlot : MPlot

@end

#pragma mark - MACD
@interface MMACDPlot : MPlot
/** 涨颜色 */
@property (nonatomic, strong) UIColor *riseColor;
/** 跌颜色 */
@property (nonatomic, strong) UIColor *dropColor;
@end

#pragma mark - BIAS
@interface MBIASPlot : MPlot

@end

#pragma mark - CCI

@interface MCCIPlot : MPlot

@end

#pragma mark - WR

@interface MWRPlot : MPlot

@end


#pragma mark - AR

@interface MARPlot : MPlot

@end

#pragma mark - BBI

@interface MBBIPlot : MPlot

@end

#pragma mark - BR

@interface MBRPlot : MPlot

@end

#pragma mark - KD

@interface MKDPlot : MPlot

@end

#pragma mark - DMI

@interface MDMIPlot : MPlot

@end

#pragma mark - PSY

@interface MPSYPlot : MPlot

@end

#pragma mark - OBV

@interface MOBVPlot : MPlot

@end

#pragma mark - MTM

@interface MMTMPlot : MPlot

@end

#pragma mark - VR

@interface MVRPlot : MPlot

@end

#pragma mark - ROC

@interface MROCPlot : MPlot

@end


#pragma mark - NVI

@interface MNVIPlot : MPlot

@end

#pragma mark - PVI

@interface MPVIPlot : MPlot

@end

#pragma mark - DMA

@interface MDMAPlot : MPlot //工程版没用

@end

#pragma mark - CR

@interface MCRPlot : MPlot

@end

#pragma mark -- SAR
@interface MSARPlot :MPlot

@end
