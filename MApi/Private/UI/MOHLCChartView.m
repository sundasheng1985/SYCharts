

#import "MChartView.h"

#import "MApi.h"

#import "MApiFormatter.h"
#import <objc/runtime.h>

#import "_MPlot.h"
#import "_MChartView.h"
#import <FMDB.h>
NSString * const MOHLCChartViewPreviousItemNotificationInfoKey = @"MOHLCChartViewPreviousItemNotificationInfoKey";
#pragma mark -- 转换时间格式xxxx/xx/xx,分钟k加时间 --
NS_INLINE NSString *MApiOHLCDatetime(MOHLCChartType type, NSString *datetime) {
    if (datetime.length >= 12) {
        switch (type) {
            case MOHLCChartTypeDay:
            case MOHLCChartTypeWeek:
            case MOHLCChartTypeMonth:
            {
                @autoreleasepool {
                    NSString *date = [datetime substringToIndex:8];
                    NSMutableString *dateString = [NSMutableString stringWithString:date];
                    [dateString insertString:@"/" atIndex:6];
                    [dateString insertString:@"/" atIndex:4];
                    return dateString;
                }
            }
            default: // 分钟
            {
                @autoreleasepool {
                    NSString *date = [datetime substringToIndex:8];
                    NSString *time = [datetime substringWithRange:NSMakeRange(8, 4)];
                    NSMutableString * dateString = [NSMutableString stringWithString:date];
                    [dateString insertString:@"/" atIndex:6];
                    [dateString insertString:@"/" atIndex:4];
                    NSMutableString * timeString = [NSMutableString stringWithString:time];
                    [timeString insertString:@":" atIndex:2];
                    return [NSString stringWithFormat:@"%@ %@", dateString, timeString];
                }
            }
        }
    }
    return @"";
}
#pragma mark -- 主图，副图都基于的view --
@interface MOHLCScrollableGraphView : UIScrollView <MPlotRequirement>

@property (nonatomic, weak) id <MPlotAttributes> attributesProvider;
@property (nonatomic, strong) MPlot *plot;

/// 畫面上最後一根的Index
@property (nonatomic, assign) NSInteger currentLastRecordIndex;
@property (nonatomic, weak) id <UIScrollViewDelegate> ownDelegate;
@property (nonatomic, assign) UIEdgeInsets drawingInset;
/// reloadData時, 用來檢查是否資料量不同
@property (nonatomic, assign) NSInteger previousPlotRecords;
@property (nonatomic, assign) BOOL lockToLastTick; //锁上勾
@end


@implementation MOHLCScrollableGraphView

#pragma mark init

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.indicatorStyle = UIScrollViewIndicatorStyleWhite;
        self.showsHorizontalScrollIndicator = NO;
        self.showsVerticalScrollIndicator = NO;
        self.opaque = YES;
    }
    return self;
}


#pragma mark life cycle

- (void)willMoveToSuperview:(UIView *)newSuperview {
    [super willMoveToSuperview:newSuperview];
    if (newSuperview) {
        //        [self reloadData:YES];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self _reloadData];
}

- (void)drawRect:(CGRect)rect {
    //没有plot，或者没有有效的rect就不绘图
    if (!self.plot || !MPlotRectIsValid(rect)) {
        return;
    }

    CGContextRef context = UIGraphicsGetCurrentContext();
    //bar的宽加间距
    CGFloat barWidthWithSpace = [_attributesProvider barWidth] + [_attributesProvider barSpacing];
    /// 後面擋
    //    NSInteger startIndex = MAX((NSInteger)round((self.contentOffset.x) / barWidthWithSpace), 0);
    //开始的点（默认是300根，竖屏显示40根）
    NSInteger startIndex = (NSInteger)round((self.contentOffset.x) / barWidthWithSpace);
    NSInteger numberOfRecords = [self.plot numberOfRecords];
    NSInteger numberOfVisibleRecords = (NSInteger)round(CGRectGetWidth([self drawingBounds]) / barWidthWithSpace);
    numberOfVisibleRecords = MIN(numberOfVisibleRecords, numberOfRecords - startIndex);
    //划框线
    [self.plot drawBorderRect:UIEdgeInsetsInsetRect(rect, [self graphInset])
                    inContext:context];

    if (!numberOfRecords) {
        return;
    }
    //初始化绘图路径，并获取最高点和最低点(副图）
    [self.plot willRedrawRect:[self drawingBounds]
                atRecordIndex:MAX(startIndex, 0) /// MARK:這個如果是在裡面擋(ps. continue), bouncing才有重新計算max min 值的感覺。
       numberOfVisibleRecords:numberOfVisibleRecords];
    
    
    NSInteger lastIndex = MIN((startIndex + numberOfVisibleRecords), numberOfRecords);
    for (NSInteger index = startIndex; index < lastIndex ; index++) { @autoreleasepool {
        
        CGFloat xPosition = CGRectGetMinX([self drawingBounds]) + ((index - startIndex) * barWidthWithSpace);
        
        CGRect xAxisRect = UIEdgeInsetsInsetRect(rect, [self graphInset]);
        xAxisRect.size.height = [self graphInset].bottom;
        xAxisRect.origin.y = CGRectGetHeight(rect) - [self graphInset].bottom;
        
        if (index == startIndex || index == lastIndex-1) {
            //图下面的时间赋值
            [self.plot handleXAxisWithIndex:index left:index == startIndex];
        }
        if (index < 0) continue;
        //划每个棒以及对应参数线
        [self.plot drawRect:[self drawingBounds]
                  inContext:context
              atRecordIndex:index /// 有區間 0 ~ (numberOfRecords - 1)
                  xPosition:xPosition
          attributeProvider:_attributesProvider];
    }}
    //调用父类方法结束绘制
    [self.plot endDrawingContext:context];
    //y轴label赋值
    [self.plot relabelIfNeeded];
}

#pragma mark getter
//这个是绘制的内容整体往内偏移一个borderwidth（与框无关）
- (UIEdgeInsets)drawingInset {
    return UIEdgeInsetsMake(_drawingInset.top + [self.attributesProvider borderWidth],
                            _drawingInset.left + [self.attributesProvider borderWidth],
                            _drawingInset.bottom + [self.attributesProvider borderWidth],
                            _drawingInset.right + [self.attributesProvider borderWidth]);
}

- (UIEdgeInsets)graphInset {
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

#pragma mark setter

- (void)setPlot:(MPlot *)plot {
    if (_plot != plot) {
        //避免从新创建y轴和参数轴label
        BOOL scrollToEnd = (!_plot);
        //移除所有label
        [_plot kill];
        //从新创建label
        [plot willSetup];
        _plot = plot;
        _plot.drawingTarget = self;
        [_plot displayLastEnquiredInformation];
        [self _reloadData:scrollToEnd];
    }
}

- (void)setFrame:(CGRect)frame {
    BOOL scrollToEnd = CGRectEqualToRect(self.frame, CGRectZero);
    BOOL needsReloadData = !CGRectEqualToRect(self.frame, frame);
    [super setFrame:frame];
    if (needsReloadData) {
        [self _reloadData:scrollToEnd];
    }
}


#pragma mark public

/// 公開的reloadData，包含計算參數&顯示最後一根的參數值。
- (void)reloadData {
    [self.plot displayLastEnquiredInformation];
    [self _reloadData:NO];
}
#pragma mark -- 查价线位置以及所对应的MOHLCItem --
- (MOHLCItem *)itemWithTouchLocation:(CGFloat*)xLocation yLocation:(CGFloat *)yLocation index:(NSInteger*)index {
    CGFloat barWidth = [_attributesProvider barWidth];
    CGFloat barSpacing = [_attributesProvider barSpacing];
    CGFloat startXAxis = *xLocation - CGRectGetMinX([self drawingFrame]);
    NSInteger f = startXAxis / (barWidth + barSpacing);
    NSInteger indexFromStartXAxis = (startXAxis - (barSpacing / 2 * f)) / (barWidth + (barSpacing/2));
    NSInteger visibleStartIndex = round(self.contentOffset.x / (barWidth + barSpacing));
    *index = visibleStartIndex + indexFromStartXAxis;
    *index = MAX(*index, visibleStartIndex);
    *index = MIN(*index, [self.plot numberOfRecords] - 1);
    
    *xLocation = CGRectGetMinX([self drawingFrame]) + (((*index - visibleStartIndex) * (barWidth + barSpacing)) + (barWidth / 2));
    MOHLCItem *item = [self.plot itemAtRecordIndex:*index];
    double close = [item.closePrice doubleValue];
    double yScale = CGRectGetHeight([self drawingFrame]) / fabs(self.plot.maxValue - self.plot.minValue);
    if (isinf(yScale)||isnan(yScale)) {
        yScale = 1;
    }
    if (yLocation) {
        *yLocation = CGRectGetMinY([self drawingFrame]) + fabs(CGRectGetHeight([self drawingFrame]) - (close - self.plot.minValue) * yScale);
    }
    return item;
}

- (CGRect)drawingBounds {
    return UIEdgeInsetsInsetRect(self.bounds, self.drawingInset);
}

- (CGRect)drawingFrame {
    return UIEdgeInsetsInsetRect(self.frame, self.drawingInset);
}


#pragma mark private
#pragma mark -- bar和间隙之和 --
- (CGFloat)barWidthWithSpace {
    CGFloat barWidthWithSpace = [_attributesProvider barWidth] + [_attributesProvider barSpacing];
    return barWidthWithSpace;
}
#pragma mark -- 当前显示的个数 --
- (NSInteger)numberOfVisibleRecords {
    NSInteger numberOfRecords = [self.plot numberOfRecords];
    CGFloat barWidthWithSpace = [_attributesProvider barWidth] + [_attributesProvider barSpacing];
    NSInteger startIndex = MAX((NSInteger)round(self.contentOffset.x / barWidthWithSpace), 0);
    NSInteger numberOfVisibleRecords = (NSInteger)(CGRectGetWidth(self.frame) / barWidthWithSpace);
    numberOfVisibleRecords = MIN(numberOfVisibleRecords, numberOfRecords - startIndex);
    return numberOfVisibleRecords;
}
#pragma mark -- 开始是第几个 --
- (NSInteger)visibleStartIndex {
    CGFloat barWidthWithSpace = [_attributesProvider barWidth] + [_attributesProvider barSpacing];
    NSInteger startIndex = MAX((NSInteger)round(self.contentOffset.x / barWidthWithSpace), 0);
    return startIndex;
}

/// 把scrollview移到最後一根資料的位置
- (void)scrollToLastRecord {
    //    NSLog(@"Scrooooooooool to end.");
    self.contentOffset = CGPointMake(self.contentSize.width - CGRectGetWidth(self.frame), 0);
    self.currentLastRecordIndex = [self visibleStartIndex] + [self numberOfVisibleRecords];
    //    NSLog(@"setContentOffset  currentLabtRecordIndex:%ld  nubmerOfRecords:%ld", (long)self.currentLastRecordIndex, (long)[self.plot numberOfRecords]);
}

/// 私有的reloadData僅更新畫面，不做參數計算。
- (void)_reloadData {
    [self _reloadData:NO];
}

- (void)_reloadData:(BOOL)scrollToEnd {
    if (CGRectEqualToRect(self.frame, CGRectZero) || !self.plot) {
        return;
    }

    ///
    CGSize previousContentSize = self.contentSize;
    CGPoint previousContentOffset = self.contentOffset;
    
    /// ContentSize小於自身的frame時，bounds會錯亂，所以這邊做MAX函式的處理。
    NSInteger numberOfRecords = [self.plot numberOfRecords];
    //疑问？
    CGFloat contentSizeWidth = MAX(CGRectGetWidth(self.frame), [_attributesProvider barWidth] * (CGFloat)(numberOfRecords) + [_attributesProvider barSpacing] * (CGFloat)(numberOfRecords) + ([_attributesProvider borderWidth]*2));
    CGFloat contentSizeHeight = MAX(CGRectGetHeight(self.frame), CGRectGetHeight(self.frame) - self.drawingInset.top - self.drawingInset.bottom);
    self.contentSize = CGSizeMake(contentSizeWidth, contentSizeHeight);
    
    /// 不可滾動時, 都保持在最右邊顯示最新tick
    scrollToEnd = scrollToEnd || (self.lockToLastTick);
    
    /// *********************
    /// scrollToEnd 等於 YES 的幾種情況：
    /// 1. frame 由 CGRectZero 變有值時
    /// 2. plot 由空變有值時
    /// 3. self.lockToLastTick 等於 YES 時
    /// *********************
    if (scrollToEnd) {
        [self scrollToLastRecord];
    }
    else if (!CGSizeEqualToSize(previousContentSize, self.contentSize)) {
        
        BOOL changeRecordCount = self.previousPlotRecords != [self.plot numberOfRecords];
        
        CGFloat x = [self barWidthWithSpace] * (self.currentLastRecordIndex - [self numberOfVisibleRecords]);
        x = MIN(x, self.contentSize.width - CGRectGetWidth(self.frame));
        if (isinf(x)) {
            NSLog(@"Error - %f   %f  %ld",
                  [_attributesProvider barWidth],
                  [_attributesProvider barSpacing],
                  (long)numberOfRecords);
        }
        /// 如果前一次reload的plot record數量與這次的不同
        else if (changeRecordCount) {
            /// 如果scrollView的contentOffset停在最後一筆record的範圍內(也就是最後一根tick有顯示的話)
            if (previousContentOffset.x + CGRectGetWidth(self.frame) > previousContentSize.width - [self barWidthWithSpace]) {
                [self scrollToLastRecord];
            }
            self.previousPlotRecords = [self.plot numberOfRecords];
        }
        else {
            self.contentOffset = CGPointMake(x, self.contentOffset.y);
        }
    }
    else {
        self.currentLastRecordIndex = [self visibleStartIndex] + [self numberOfVisibleRecords];
    }
    
    [self setNeedsDisplay];
}

@end


#pragma mark - OHLCEnquiryView 查价线视图--

@interface MOHLCEnquiryView : UIView
@property (nonatomic, assign) CGRect chartRect;           //视图的rect
@property (nonatomic, strong) NSArray <NSValue *> *chartRects;

@property (nonatomic, assign) CGPoint touchLocation;      //触摸的点
@property (nonatomic, strong) UILabel *xAxisLabel;        //x轴label
@property (nonatomic, strong) UILabel *yAxisLabel;        //y轴label
@property (nonatomic, strong) UIColor *lineColor;         //线的颜色
@property (nonatomic, strong) UIFont *labelTextFont;      //label的字体大小
@property (nonatomic, strong) UIColor *labelBackgroundColor; //label背景色
@property (nonatomic, strong) UIColor *labelTextColor;       //label字体颜色
@end


@implementation MOHLCEnquiryView

#pragma mark init

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled = NO;
        self.backgroundColor = [UIColor clearColor];
        self.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        self.lineColor = [UIColor whiteColor];
        self.labelTextFont = [UIFont systemFontOfSize:10.0];
        self.labelTextColor = [UIColor whiteColor];
        self.labelBackgroundColor = [UIColor grayColor];

        self.xAxisLabel = [self makeLabel];
        [self addSubview:self.xAxisLabel];
        self.yAxisLabel = [self makeLabel];
        [self addSubview:self.yAxisLabel];
    }
    return self;
}
#pragma mark -- 查价线绘图 --
- (void)drawRect:(CGRect)rect {
    //???:這整塊暫時這樣寫
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSaveGState(context);
    
    if (self.lineColor) {
        [self.lineColor set];
    }

    CGMutablePathRef path = CGPathCreateMutable();
    
    // X axis
//    if (CGRectContainsPoint(self.chartRect, self.touchLocation)) {
        for (NSValue *v in self.chartRects) {
            //判断触摸的点在rect内
            if (CGRectContainsPoint(v.CGRectValue, self.touchLocation)) {
                CGPathMoveToPoint(path, nil, CGRectGetMinX(v.CGRectValue), self.touchLocation.y);
                CGPathAddLineToPoint(path, nil, CGRectGetMaxX(v.CGRectValue), self.touchLocation.y);
            }
            // Y axis
            CGFloat xLocation = self.touchLocation.x;
            xLocation = MIN(CGRectGetMaxX(self.chartRect), xLocation);
            xLocation = MAX(CGRectGetMinX(self.chartRect), xLocation);
            CGPathMoveToPoint(path, nil, xLocation, CGRectGetMinY(v.CGRectValue));
            CGPathAddLineToPoint(path, nil, xLocation, CGRectGetMaxY(v.CGRectValue));
        }
//    }
    
    CGContextBeginPath(context);
    CGContextAddPath(context, path);
    CGContextStrokePath(context);
    CGPathRelease(path);
    CGContextRestoreGState(context);
}


#pragma mark factor 查价线图添加到view上
+ (instancetype)bindView:(UIView *)view {
    MOHLCEnquiryView *enquiryView = [[[self class] alloc] initWithFrame:view.bounds];
    [view addSubview:enquiryView];
    return enquiryView;
}
//创建label
- (UILabel *)makeLabel {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.backgroundColor = self.labelBackgroundColor;
    label.textColor = self.labelTextColor;
    label.font = self.labelTextFont;
    label.adjustsFontSizeToFitWidth = YES;
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_6_0
    label.minimumScaleFactor = 0.5;
    label.textAlignment = NSTextAlignmentCenter;
#else
    label.minimumFontSize = 6.0;
    label.textAlignment = UITextAlignmentCenter;
#endif
    return label;
}

#pragma mark setter
- (void)setLineColor:(UIColor *)lineColor {
    _lineColor = lineColor;
    [self setNeedsDisplay];
}

- (void)setLabelTextFont:(UIFont *)labelTextFont {
    _labelTextFont = self.xAxisLabel.font = self.yAxisLabel.font = labelTextFont;
}

- (void)setLabelBackgroundColor:(UIColor *)labelBackgroundColor {
    _labelBackgroundColor = self.xAxisLabel.backgroundColor = self.yAxisLabel.backgroundColor = labelBackgroundColor;
}

- (void)setLabelTextColor:(UIColor *)labelTextColor {
    _labelTextColor = self.xAxisLabel.textColor = self.yAxisLabel.textColor = labelTextColor;
}

#pragma mark public 绘制查价线 yAxisInside:y轴是否在线内(查价线使用）
- (void)drawInRect:(CGRect)rect
        limitRects:(NSArray *)limitRects
       xAxisString:(NSString *)xAxisString
       yAxisString:(NSString *)yAxisString
     touchLocation:(CGPoint)touchLocation
       borderWidth:(CGFloat)borderWidth
       yAxisInside:(BOOL)yAxisInside
        yAxisWidth:(CGFloat)yAxisWidth
     xAxisLbelMode:(NSInteger)xAxisLbelMode /// 0: 线在中间, 1: 线在左边
{

    self.hidden = NO;
    //层次管理：bringSubviewToFront 将self显示在最前面
    [self.superview bringSubviewToFront:self];
    self.chartRect = rect;
    self.chartRects = limitRects;
    self.touchLocation = touchLocation;
    
    CGRect currentRect = CGRectZero;
    for (NSValue *v in limitRects) {
        if (CGRectContainsPoint(v.CGRectValue, touchLocation)) {
            currentRect = v.CGRectValue;
            break;
        }
    }
    
    if (yAxisString && !CGRectEqualToRect(currentRect, CGRectZero)) {
        self.yAxisLabel.text = yAxisString;
        [self.yAxisLabel sizeToFit];
        CGFloat labelHeight = CGRectGetHeight(self.yAxisLabel.frame);
        CGFloat y = self.touchLocation.y - (labelHeight / 2);
        y = MIN(y, (CGRectGetMaxY(currentRect) - labelHeight));
        y = MAX(y, CGRectGetMinY(currentRect));
        CGRect frame = self.yAxisLabel.frame;
        frame.origin = (CGPoint){
            yAxisInside ? CGRectGetMinX(currentRect) : CGRectGetMinX(currentRect) - CGRectGetWidth(frame) - borderWidth - 1,
            y
        };
        frame = CGRectInset(frame, -1, -1);
        if (MPlotRectIsValid(frame)) {
            self.yAxisLabel.frame = frame;
        }
        self.yAxisLabel.hidden = NO;
    } else {
        self.yAxisLabel.hidden = YES;
    }

    self.xAxisLabel.text = xAxisString;
    [self.xAxisLabel sizeToFit];
    CGFloat labelWidth = CGRectGetWidth(self.xAxisLabel.frame) + 5.0;
    CGFloat x;
    if (xAxisLbelMode == 1) {
        x = self.touchLocation.x;
    } else {
        x = self.touchLocation.x - (CGRectGetWidth(self.xAxisLabel.frame) / 2);
    }
    x = MIN(x, (CGRectGetMaxX(rect) - labelWidth));
    x = MAX(x, CGRectGetMinX(rect));
    self.xAxisLabel.frame = CGRectMake(x,
                                       CGRectGetMaxY(rect) + borderWidth,
                                       labelWidth,
                                       CGRectGetHeight(self.xAxisLabel.frame));
    [self setNeedsDisplay];
}

- (void)clear {
    self.hidden = YES;
}

@end


#pragma mark - OHLCChartView

@interface MOHLCChartView () <MPlotAttributes, UIScrollViewDelegate, UIGestureRecognizerDelegate, UIActionSheetDelegate, MPlotDataSource>
{
    @package
    MOHLCScrollableGraphView *_majorGraphView;  //主图
    MOHLCScrollableGraphView *_minorGraphView;  //副图
    
    struct {
        unsigned int isPinching:1;         //缩放
        unsigned int isEnquiring:1;        //查价
        unsigned int delayReloadData:1;    //延时刷新
    } _chartViewFlags; //线图的标识
    
    NSInteger _previousEnquireIndex;       //之前查询的下标
    CGFloat _previousEnquireLocationX;     //之前查询的x轴
    CGFloat _previousEnquireLocationY;     //之前查询的Y轴
    NSUInteger _previousVisibleRecords;    //之前显示的对象个数
}

@property (nonatomic, strong) NSMutableArray *majorPlots_;  //主图plots
@property (nonatomic, strong) NSMutableArray *minorPlots_;  //副图plots
@property (nonatomic, strong) UIPinchGestureRecognizer *zoomGestureRecognizer;
@property (nonatomic, strong) UILongPressGestureRecognizer *longPressGestureRecognizer;
@property (nonatomic, strong) UIPanGestureRecognizer *panGestureRecognizer;
@property (nonatomic, strong) UITapGestureRecognizer *tapGestureRecognizer;

@property (nonatomic, strong) MOHLCEnquiryView *enquiryView;    //查价线图

@property (nonatomic, strong) UIScrollView *majorValueScrollView; //主图参数视图
@property (nonatomic, strong) UIScrollView *minorValueScrollView; //副图参数视图

@property (nonatomic, strong) UILabel *xAxisLeftLabel;    //时间轴左侧label
@property (nonatomic, strong) UILabel *xAxisRightLabel;   //时间轴右侧label

@property (nonatomic, strong) MSnapQuoteRequest *snapRequest;
@property (nonatomic, strong) MOHLCRequest *OHLCRequest;
// OHLCItems
@property (nonatomic, strong) NSArray *items;        //k线图数组
@property (nonatomic, strong) MStockItem *stockItem;
@property (nonatomic, strong)FMDatabase *db;
@property (nonatomic, assign)NSInteger index;

@end


@implementation MOHLCChartView
@synthesize majorGraphView = _majorGraphView;
@synthesize minorGraphView = _minorGraphView;

#pragma mark MPlotDataSource 代理

- (UInt8)numberOfDecimalForPlot:(MPlot *)plot {
    MMarketInfo *info = [MApi marketInfoWithMarket:self.stockItem.market subtype:self.stockItem.subtype];
    return info.decimal;
}
#pragma mark -- 时间轴赋值 --
- (void)updateXAxisString:(NSString *)xAxisString left:(BOOL)left {
    @autoreleasepool {
        NSString *datetime = MApiOHLCDatetime(self.type, xAxisString);
        if (left) {
            self.xAxisLeftLabel.text = datetime;
        } else {
            self.xAxisRightLabel.text = datetime;
        }
    }
}

- (NSUInteger)numberOfRecordsForPlot:(MPlot *)plot {
    return self.items.count;
}

- (MOHLCItem *)plot:(MPlot *)plot itemAtRecordIndex:(NSUInteger)index {
    return self.items[index];
}

- (MStockItem *)stockItemForPlot:(MPlot *)plot {
    return self.stockItem;
}

#pragma mark init

- (void)initialized {
    [super initialized];
    self.index = 0;
    NSString *path = [[(NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES)) lastObject]stringByAppendingPathComponent:@"shuijing.sqlite"];
    
    self.db = [FMDatabase databaseWithPath:path];
    NSLog(@"databaseWithPath==%@",path);
    BOOL open = [_db open];
    if (open) {
        NSLog(@"数据库打开成功");
    }

    NSString *content = @"(closePrice varchar,tradeVolume varchar,datetime varchar,averagePrice varchar,highPrice varchar,lowPrice varchar,openPrice varchar ,preClosePrice varchar,referencePrice varchar,amount varchar)";
    NSString *create = [NSString stringWithFormat:@"create table if not exists %@%@",@"t_user",content];
    BOOL c1 = [_db executeUpdate:create];
    if (c1) {
        NSLog(@"第一个表成功");
    }
    _barFill = NO;
    _zoomEnabled = YES;
    _numberOfVisibleRecords = 20;//工程版外部传了40
    _scrollEnabled = YES;
    _yAxisTextColor = [UIColor whiteColor];
    
    _majorPlots_ = [[NSMutableArray alloc] init];
    _minorPlots_ = [[NSMutableArray alloc] init];
    //缩放外部写
    _zoomGestureRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self
                                                                       action:@selector(handleZoomGestureRecognizer:)];
    _zoomGestureRecognizer.delegate = self;
    [self addGestureRecognizer:self.zoomGestureRecognizer];
    
    _longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                                                action:@selector(handleLongPressGestureRecognizer:)];
    _longPressGestureRecognizer.numberOfTouchesRequired = 1;
    _longPressGestureRecognizer.delegate = self;
    [self addGestureRecognizer:self.longPressGestureRecognizer];
    
    
    //////// 查价线用
    _panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                    action:@selector(handleGestureRecognizerForEnquireWithGesture:)];
    _panGestureRecognizer.delegate = self;
    
    _tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                    action:@selector(handleGestureRecognizerForEnquireWithGesture:)];
    _tapGestureRecognizer.delegate = self;
    //////// 查价线用
    
    //
    _majorValueScrollView = [[UIScrollView alloc] initWithFrame:CGRectZero];
    _majorValueScrollView.backgroundColor = [UIColor clearColor];
    _majorValueScrollView.showsHorizontalScrollIndicator = NO;
    _majorValueScrollView.showsVerticalScrollIndicator = NO;
     [self addSubview:_majorValueScrollView];
    
    _minorValueScrollView = [[UIScrollView alloc] initWithFrame:CGRectZero];
    _minorValueScrollView.backgroundColor = [UIColor clearColor];
    _minorValueScrollView.showsHorizontalScrollIndicator = NO;
    _minorValueScrollView.showsVerticalScrollIndicator = NO;
    [self addSubview:_minorValueScrollView];

    _xAxisLeftLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _xAxisLeftLabel.textAlignment = NSTextAlignmentLeft;
    _xAxisRightLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _xAxisRightLabel.textAlignment = NSTextAlignmentRight;
    for (UILabel *label in @[_xAxisLeftLabel, _xAxisRightLabel]) {
        label.backgroundColor = [UIColor clearColor];
        label.font = self.xAxisFont;
        label.textColor = self.xAxisTextColor;
        label.text = @"一";
        [label sizeToFit];
        [self addSubview:label];
    }
    
    _enquiryView = [MOHLCEnquiryView bindView:self];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initialized];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self initialized];
}


#pragma mark - setter

- (void)setXAxisFont:(UIFont *)xAxisFont {
    [super setXAxisFont:xAxisFont];
    self.xAxisLeftLabel.font = self.xAxisRightLabel.font = self.xAxisFont;
//    [self.xAxisLeftLabel sizeToFit];
//    [self.xAxisRightLabel sizeToFit];
    if (self.window) {
        [self setNeedsLayout];
    }
}

- (void)setXAxisTextColor:(UIColor *)xAxisTextColor {
    [super setXAxisTextColor:xAxisTextColor];
    self.xAxisLeftLabel.textColor = self.xAxisRightLabel.textColor = self.xAxisTextColor;
}

#pragma mark life cycle

- (void)willMoveToSuperview:(UIView *)newSuperview {
    if (newSuperview) {
        [self checkMajorPlotIndexAndMinorPlotIndex];
    } else {
        [MApi cancelRequest:self.snapRequest];
        [MApi cancelRequest:self.OHLCRequest];
    }
}
#pragma mark -- 视图的布局 --
- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat generalPosYPadding = 2.0;
    CGFloat valueScrollViewDefaultHeight = 15.0;
    CGFloat buttonSpacing = 5.0;
    
    CGFloat yAxisWidth = [self _isYAxisLabelInside] ? 0 : self.yAxisLabelInsets.left;
    
    CGFloat graphHeight = CGRectGetHeight(self.bounds);
//根据系统版本确定x轴宽度
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 70000
    CGSize xAxisSize = [@"0123456789" sizeWithAttributes:@{NSFontAttributeName:self.xAxisFont}];
#else
    static double systemVer;
    if (systemVer <= 0) systemVer = [UIDevice currentDevice].systemVersion.doubleValue;
    CGSize xAxisSize;
    if (systemVer < 7) {
        xAxisSize = [@"0123456789" sizeWithFont:self.xAxisFont];
    } else {
        xAxisSize = [@"0123456789" sizeWithAttributes:@{NSFontAttributeName:self.xAxisFont}];
    }
#endif
    
    self.xAxisLeftLabel.frame = CGRectMake(yAxisWidth,
                                           CGRectGetHeight(self.bounds) - CGRectGetHeight(self.xAxisLeftLabel.frame),
                                           (CGRectGetWidth(self.bounds) - yAxisWidth) / 2,
                                           xAxisSize.height);
    self.xAxisRightLabel.frame = CGRectMake(CGRectGetMaxX(self.xAxisLeftLabel.frame),
                                           CGRectGetHeight(self.bounds) - CGRectGetHeight(self.xAxisRightLabel.frame),
                                           (CGRectGetWidth(self.bounds) - yAxisWidth) / 2,
                                           xAxisSize.height);
    //减去x轴文字高和 y轴间隙 = 图形高度
    graphHeight -= CGRectGetHeight(self.xAxisRightLabel.frame);
    graphHeight -= generalPosYPadding;
    
    /////////////////////////

    CGFloat majorButtonMaxSpacing = MAX(CGRectGetHeight(self.majorPlotChangeIndexButton.frame),
                                        CGRectGetHeight(self.majorPlotSettingButton.frame));
    majorButtonMaxSpacing = MAX(majorButtonMaxSpacing, CGRectGetHeight(self.majorPlotPriceAdjustedButton.frame));
    majorButtonMaxSpacing = MAX(majorButtonMaxSpacing, valueScrollViewDefaultHeight);
    graphHeight -= majorButtonMaxSpacing;

    self.majorPlotChangeIndexButton.frame = self.majorPlotChangeIndexButton.bounds;
    
    ///////////
    if (self.majorPlotChangeIndexButton) {
        //均线button
        self.majorPlotSettingButton.frame =
        CGRectMake(CGRectGetMaxX(self.majorPlotChangeIndexButton.frame) + buttonSpacing,
                   0,
                   CGRectGetWidth(self.majorPlotSettingButton.frame),
                   CGRectGetHeight(self.majorPlotSettingButton.frame));
    } else {
        self.majorPlotSettingButton.frame = self.majorPlotSettingButton.bounds;
    }

    /// majorPlotPriceAdjustedButton
    if (self.majorPlotSettingButton) {
        //复权button
        self.majorPlotPriceAdjustedButton.frame =
        CGRectMake(CGRectGetMaxX(self.majorPlotSettingButton.frame) + buttonSpacing,
                   0,
                   CGRectGetWidth(self.majorPlotPriceAdjustedButton.frame),
                   CGRectGetHeight(self.majorPlotPriceAdjustedButton.frame));
    } else if (self.majorPlotChangeIndexButton) {
        self.majorPlotPriceAdjustedButton.frame =
        CGRectMake(CGRectGetMaxX(self.majorPlotChangeIndexButton.frame) + buttonSpacing,
                   0,
                   CGRectGetWidth(self.majorPlotPriceAdjustedButton.frame),
                   CGRectGetHeight(self.majorPlotPriceAdjustedButton.frame));
    } else {
        self.majorPlotPriceAdjustedButton.frame = self.majorPlotPriceAdjustedButton.bounds;
    }
    
    /// majorValueScrollView
    if (self.majorPlotPriceAdjustedButton) {
        self.majorValueScrollView.frame =
        CGRectMake(CGRectGetMaxX(self.majorPlotPriceAdjustedButton.frame) + buttonSpacing,
                   0,
                   CGRectGetWidth(self.frame) - (CGRectGetMaxX(self.majorPlotPriceAdjustedButton.frame) + buttonSpacing),
                   majorButtonMaxSpacing);
    }
    else if (self.majorPlotSettingButton) {
        self.majorValueScrollView.frame =
        CGRectMake(CGRectGetMaxX(self.majorPlotSettingButton.frame) + buttonSpacing,
                   0,
                   CGRectGetWidth(self.frame) - (CGRectGetMaxX(self.majorPlotSettingButton.frame) + buttonSpacing),
                   majorButtonMaxSpacing);
    }
    else if (self.majorPlotChangeIndexButton) {
        self.majorValueScrollView.frame =
        CGRectMake(CGRectGetMaxX(self.majorPlotChangeIndexButton.frame) + buttonSpacing,
                   0,
                   CGRectGetWidth(self.frame) - (CGRectGetMaxX(self.majorPlotChangeIndexButton.frame) + buttonSpacing),
                   majorButtonMaxSpacing);
    }
    else {
        self.majorValueScrollView.frame =
        CGRectMake(0,
                   0,
                   CGRectGetWidth(self.frame),
                   valueScrollViewDefaultHeight);
    }
    graphHeight -= generalPosYPadding;
    
    //////////////////////////
    graphHeight -= generalPosYPadding;
    
    CGFloat minorButtonMaxSpacing = MAX(CGRectGetHeight(self.minorPlotChangeIndexButton.frame),
                                        valueScrollViewDefaultHeight);
    graphHeight -= minorButtonMaxSpacing;
    if (self.minorPlotChangeIndexButton) {

    }
    else {
    
    }
    
    graphHeight -= generalPosYPadding;
    ///////////////////////////
    
    if (self.minorGraphView.superview) {
        self.majorGraphView.frame = CGRectMake(yAxisWidth,
                                               majorButtonMaxSpacing + (generalPosYPadding * 2),
                                               CGRectGetWidth(self.frame) - yAxisWidth,
                                               graphHeight*(2.0/3.0));
    } else {
        self.majorGraphView.frame = CGRectMake(yAxisWidth,
                                               majorButtonMaxSpacing + (generalPosYPadding * 2),
                                               CGRectGetWidth(self.frame) - yAxisWidth,
                                               graphHeight);
    }

    ////////////////////////////////
    

    /////////////////////////////////////
    
    self.minorPlotChangeIndexButton.frame = self.minorPlotChangeIndexButton.bounds;

    if (self.minorPlotChangeIndexButton) {
        self.minorPlotChangeIndexButton.frame = CGRectMake(0,
                                                           CGRectGetMaxY(self.majorGraphView.frame) + generalPosYPadding,
                                                           CGRectGetWidth(self.minorPlotChangeIndexButton.frame),
                                                           CGRectGetHeight(self.minorPlotChangeIndexButton.frame));
        
        self.minorValueScrollView.frame = CGRectMake(CGRectGetMaxX(self.minorPlotChangeIndexButton.frame) + 5.0,
                                                     CGRectGetMinY(self.minorPlotChangeIndexButton.frame),
                                                     CGRectGetWidth(self.frame) - (CGRectGetMaxX(self.minorPlotChangeIndexButton.frame) + buttonSpacing),
                                                     CGRectGetHeight(self.minorPlotChangeIndexButton.frame));
    } else {
        self.minorValueScrollView.frame =
        CGRectMake(0,
                   CGRectGetMaxY(self.majorGraphView.frame),
                   CGRectGetWidth(self.frame),
                   valueScrollViewDefaultHeight);
    }

    /// version_2 工程版没有 优理宝有：横屏按钮
    if (self.minorPlotRightButtons) {
        CGFloat buttonX = CGRectGetMaxX(self.majorGraphView.frame) + 5.0/*ignore lastest button padding*/;
        CGFloat rightButtonsTotalWidth = 0;
        CGRect scrollViewFrame = self.minorValueScrollView.frame;
        for (UIButton *button in [[self.minorPlotRightButtons reverseObjectEnumerator] allObjects]) {
            CGRect buttonFrame = button.frame;
            buttonFrame.origin.x = buttonX - CGRectGetWidth(buttonFrame) - 5.0;
            buttonFrame.origin.y = CGRectGetMaxY(self.majorGraphView.frame) + generalPosYPadding;
            button.frame = buttonFrame;
            
            buttonX = CGRectGetMinX(buttonFrame);
            rightButtonsTotalWidth += (CGRectGetWidth(buttonFrame) + 5.0);
        }
        scrollViewFrame.size.width -= rightButtonsTotalWidth;
        self.minorValueScrollView.frame = scrollViewFrame;
    }
    
    CGFloat minorGraphPosY = MAX(CGRectGetMaxY(self.minorPlotChangeIndexButton.frame),
                                 CGRectGetMaxY(self.minorValueScrollView.frame));
    self.minorGraphView.frame = CGRectMake(yAxisWidth,
                                           minorGraphPosY + generalPosYPadding,
                                           CGRectGetWidth(self.frame) - yAxisWidth,
                                           graphHeight*(1.0/3.0));


    /// left site labels layout
    //主图Y轴label布局
    [self layoutMajorPlotYAxisLabelsAndValueLabels];
    //副图Y轴label布局
    [self layoutMinorPlotYAxisLabelsAndValueLabels];

}
#pragma mark -- 工程版副图标题右侧没有按钮 --
- (void)setMinorPlotRightButtons:(NSArray *)minorPlotRightButtons {
    if (_minorPlotRightButtons != minorPlotRightButtons || _minorPlotRightButtons.count != minorPlotRightButtons.count) {
        [_minorPlotRightButtons makeObjectsPerformSelector:@selector(removeFromSuperview)];
        _minorPlotRightButtons = minorPlotRightButtons;
        for (UIButton *button in _minorPlotRightButtons) {
            [self addSubview:button];
        }
    }
}
#pragma mark lazy loading

- (MOHLCScrollableGraphView *)majorGraphView {
    if (!_majorGraphView) {
        _majorGraphView = [[MOHLCScrollableGraphView alloc] initWithFrame:CGRectZero];
        _majorGraphView.attributesProvider = self;
        _majorGraphView.delegate = self;
        _majorGraphView.backgroundColor = [UIColor clearColor];
    }
    return _majorGraphView;
}

- (MOHLCScrollableGraphView *)minorGraphView {
    if (!_minorGraphView) {
        _minorGraphView = [[MOHLCScrollableGraphView alloc] initWithFrame:CGRectZero];
        _minorGraphView.attributesProvider = self;
        _minorGraphView.delegate = self;
        _minorGraphView.backgroundColor = [UIColor clearColor];
    }
    return _minorGraphView;
}


#pragma mark setter

- (void)setNumberOfVisibleRecords:(NSUInteger)numberOfVisibleRecords {
    /// 初始化还没addSubview的情况
    if (!self.window) {
        _numberOfVisibleRecords = numberOfVisibleRecords;
        return;
    }
    if (!self.majorGraphView || numberOfVisibleRecords < 10) {
        return;
    }
    CGFloat drawingWidth = CGRectGetWidth([_majorGraphView drawingBounds]);
    CGFloat cal_barWidth = (drawingWidth - (self.barSpacing * (numberOfVisibleRecords - 1))) / numberOfVisibleRecords;
    if (cal_barWidth >= 1) {
        _numberOfVisibleRecords = numberOfVisibleRecords;
        [self _reloadData];
    }
}

- (void)setMajorPlotIndex:(NSUInteger)majorPlotIndex {
    if (majorPlotIndex < self.majorPlots_.count) {
        _majorPlotIndex = majorPlotIndex;
        MPlot *plot = self.majorPlots_[_majorPlotIndex];
        [self setupMajorGraphPlot:plot];
        if (self.window) {
                    [self _reloadData];
        }

    } else {
        NSLog(@"ERROR: minorPlotSelectIndex out of range...");
    }
}
- (void)setMinorPlotIndex:(NSUInteger)minorPlotIndex {
    if (minorPlotIndex < self.minorPlots_.count) {
        _minorPlotIndex = minorPlotIndex;
        MPlot *plot = self.minorPlots_[_minorPlotIndex];
        [self setupMinorGraphPlot:plot];
        if (self.window) {
            [self _reloadData];
        }
        
    } else {
        NSLog(@"ERROR: minorPlotSelectIndex out of range...");
    }
}

- (void)setPriceAdjustedMode:(MOHLCChartPriceAdjustedMode)priceAdjustedMode {
    _priceAdjustedMode = priceAdjustedMode;
    if (self.window) {
        [self reloadDataWithStockItem:self.stockItem];
    }
}

- (void)setScrollEnabled:(BOOL)scrollEnabled {
    _scrollEnabled = scrollEnabled;
    [self _setScrollEnabled:scrollEnabled scrollToEnd:!scrollEnabled];
}
     
- (void)_setScrollEnabled:(BOOL)scrollEnabled scrollToEnd:(BOOL)scrollToEnd {
    ((MOHLCScrollableGraphView *)[self majorGraphView]).lockToLastTick =
    ((MOHLCScrollableGraphView *)[self minorGraphView]).lockToLastTick = scrollToEnd;
    ((MOHLCScrollableGraphView *)[self majorGraphView]).scrollEnabled =
    ((MOHLCScrollableGraphView *)[self minorGraphView]).scrollEnabled = scrollEnabled;
}

- (void)setEnquiryLineColor:(UIColor *)enquiryLineColor {
    self.enquiryView.lineColor = enquiryLineColor;
}
- (void)setEnquiryFrameColor:(UIColor *)enquiryFrameColor {
    self.enquiryView.labelBackgroundColor = enquiryFrameColor;
}
- (void)setEnquiryTextFont:(UIFont *)enquiryTextFont {
    self.enquiryView.labelTextFont = enquiryTextFont;
}
- (void)setEnquiryTextColor:(UIColor *)enquiryTextColor {
    self.enquiryView.labelTextColor = enquiryTextColor;
}

- (void)setMajorPlotChangeIndexButton:(UIButton *)majorPlotChangeIndexButton {
    if (!majorPlotChangeIndexButton) {
        [_majorPlotChangeIndexButton removeFromSuperview];
    }
    _majorPlotChangeIndexButton = majorPlotChangeIndexButton;
    if (!_majorPlotChangeIndexButton.superview) {
        [self addSubview:_majorPlotChangeIndexButton];
    }
    if (self.window) {
        [self setNeedsLayout];
    }
}

- (void)setMinorPlotChangeIndexButton:(UIButton *)minorPlotChangeIndexButton {
    if (!minorPlotChangeIndexButton) {
        [_minorPlotChangeIndexButton removeFromSuperview];
    }
    _minorPlotChangeIndexButton = minorPlotChangeIndexButton;
    if (!_minorPlotChangeIndexButton.superview) {
        [self addSubview:_minorPlotChangeIndexButton];
    }
    if (self.window) {
        [self setNeedsLayout];
    }
}

- (void)setMajorPlotSettingButton:(UIButton *)majorPlotSettingButton {
    if (!majorPlotSettingButton) {
        [_majorPlotSettingButton removeFromSuperview];
    }
    _majorPlotSettingButton = majorPlotSettingButton;
    if (!_majorPlotSettingButton.superview) {
        [self addSubview:_majorPlotSettingButton];
    }
    if (self.window) {
        [self setNeedsLayout];
    }
}

- (void)setMajorPlotPriceAdjustedButton:(UIButton *)majorPlotPriceAdjustedButton {
    if (!majorPlotPriceAdjustedButton) {
        [_majorPlotPriceAdjustedButton removeFromSuperview];
    }
    _majorPlotPriceAdjustedButton = majorPlotPriceAdjustedButton;
    if (!_majorPlotPriceAdjustedButton.superview) {
        [self addSubview:_majorPlotPriceAdjustedButton];
    }
    if (self.window) {
        [self setNeedsLayout];
    }
}

- (void)setMajorPlots:(NSArray *)majorPlots {
    [majorPlots enumerateObjectsUsingBlock:^(MMAPlot *plot, NSUInteger idx, BOOL * _Nonnull stop) {
        //添加主视图plot时候，注意这里
        if (![plot isKindOfClass:[MMAPlot class]]) {
            [NSException raise:@"MPlotTypeError" format:@"majorPlots里必须为MMAPlot的子类别"];
        }
        [self addMajorPlot:plot];
    }];
}

- (void)setMinorPlots:(NSArray *)minorPlots {
    [minorPlots enumerateObjectsUsingBlock:^(MPlot *plot, NSUInteger idx, BOOL * _Nonnull stop) {
        [self addMinorPlot:plot];
    }];
}

- (void)setYAxisLabelInsets:(UIEdgeInsets)yAxisLabelInsets {
    [super setYAxisLabelInsets:yAxisLabelInsets];
    if (self.window) {
        [self setNeedsLayout];
    }
}

- (void)setEnquiryLineMode:(MChartEnquiryLineMode)enquiryLineMode {
    [super setEnquiryLineMode:enquiryLineMode];
    //设置查价线模式
    if (enquiryLineMode & MChartEnquiryLineModeAppearImmediately) {
        [self addGestureRecognizer:self.tapGestureRecognizer];
        [self removeGestureRecognizer:self.longPressGestureRecognizer];
    }
}

#pragma mark getter

- (UIColor *)enquiryLineColor {
    return self.enquiryView.lineColor;
}

- (UIColor *)enquiryFrameColor {
    return self.enquiryView.labelBackgroundColor;
}

- (UIFont *)enquiryTextFont {
    return self.enquiryView.labelTextFont;
}

- (UIColor *)enquiryTextColor {
    return self.enquiryView.labelTextColor;
}

- (NSArray *)minorPlots {
    return self.minorPlots_;
}
         
- (NSArray *)majorPlots {
 return self.majorPlots_;
}

#pragma mark event 缩放方法 没用到，外部有写

- (void)handleZoomGestureRecognizer:(UIPinchGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        _previousVisibleRecords = self.numberOfVisibleRecords;
        _chartViewFlags.isPinching = true;
    }
    else if (gestureRecognizer.state == UIGestureRecognizerStateEnded ||
             gestureRecognizer.state == UIGestureRecognizerStateCancelled ||
             gestureRecognizer.state == UIGestureRecognizerStateFailed) {
        _chartViewFlags.isPinching = false;
    }
    
    self.numberOfVisibleRecords = _previousVisibleRecords / gestureRecognizer.scale;
}
#pragma mark -- 手势触发（工程版没用到） --
- (void)handleGestureRecognizerForEnquireWithGesture:(UIGestureRecognizer *)gestureRecognizer {
    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        /// 查價線處理
        if (gestureRecognizer.state == UIGestureRecognizerStateBegan ||
            gestureRecognizer.state == UIGestureRecognizerStateChanged) {
            [self _startEnquire:gestureRecognizer];
        }
        else if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
            if (self.enquiryLineMode & MChartEnquiryLineModeDelayDisappear) {
                [self _gestureEnded:gestureRecognizer];
            }
        }

    } else if ([gestureRecognizer isKindOfClass:[UITapGestureRecognizer class]]) {
        if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
            
            if ((_chartViewFlags.isEnquiring ||
                 self.enquiryLineMode & MChartEnquiryLineModeAppearImmediately) &&
                self.enquiryLineMode & MChartEnquiryLineModeDelayDisappear) {
                //修复bug添加 研究下为什么（bug现象。轻拍出现查价下，点击同一个点没有发送通知
                _previousEnquireIndex = NSNotFound;
                [self _startEnquire:gestureRecognizer];
                [self _gestureEnded:gestureRecognizer]; /// 触发timer
            }
            else if (_chartViewFlags.isEnquiring &&
                     (!(self.enquiryLineMode & MChartEnquiryLineModeNotToDisappear) ||
                     (self.enquiryLineMode & MChartEnquiryLineModeAppearImmediately))) {
                [self _gestureEnded:gestureRecognizer];
            }
            else {
                [self _startEnquire:gestureRecognizer];
            }
            
        }
    }
}
#pragma mark -- 触发长按手势 --
- (void)handleLongPressGestureRecognizer:(UILongPressGestureRecognizer *)gestureRecognizer {
    
    //// 2nd
    BOOL is2nd = (self.options[@"ENQUIRE_MODE"] ||
                  (self.enquiryLineMode & MChartEnquiryLineModeNotToDisappear));
    
    /// 查價線處理
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan ||
        gestureRecognizer.state == UIGestureRecognizerStateChanged) {
    
        if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
            _previousEnquireIndex = NSNotFound;
            _previousEnquireLocationX = 0;
            _previousEnquireLocationY = 0;
            
            //// 2nd
            if (is2nd) {
                if (_chartViewFlags.isEnquiring) {
                    [self removeGestureRecognizer:self.tapGestureRecognizer];
                    [self _endEnquire];
                    
                    return; //// return, end enquire
                    
                } else {
                    [self addGestureRecognizer:self.tapGestureRecognizer];
                }
            } /// end 2nd
            
            /// 延迟消失
            if (self.enquiryLineMode & MChartEnquiryLineModeDelayDisappear) {
                
                if (_chartViewFlags.isEnquiring) {
                    
                    return; //// return, end enquire
                    
                } else {
                    //如果有延时消失功能 添加轻拍手势
                    [self addGestureRecognizer:self.tapGestureRecognizer];
                }
            }
        }
        
        if (!(self.enquiryLineMode & MChartEnquiryLineModeAppearImmediately)) {
            //开始查价线 （工程版）
            [self _startEnquire:gestureRecognizer];
        }
        
    }
    else if (gestureRecognizer.state == UIGestureRecognizerStateEnded ||
             gestureRecognizer.state == UIGestureRecognizerStateCancelled ||
             gestureRecognizer.state == UIGestureRecognizerStateFailed) {
        //// 2nd
        if (is2nd) {
            return;
        } /// end 2nd
        
        [self _gestureEnded:gestureRecognizer];
    }
}
#pragma mark -- 查价手势结束 --
- (void)_gestureEnded:(UIGestureRecognizer *)gestureRecognizer {
    /// 延迟消失
    if (self.enquiryLineMode & MChartEnquiryLineModeDelayDisappear) {
        //开启延时关闭定时器（工程版没用到）
        self.delayCloseEnquiryLineTimer = [NSTimer timerWithTimeInterval:self.delayEndEnquireTimeInterval target:self selector:@selector(_endEnquireForDelayMode) userInfo:nil repeats:NO];
        [[NSRunLoop currentRunLoop] addTimer:self.delayCloseEnquiryLineTimer forMode:NSRunLoopCommonModes];
        return;
    }
    [self _endEnquire];
}

#pragma mark private

- (void)setupPlotStyle:(MPlot *)plot {
    if ([plot respondsToSelector:@selector(barFill)]) {
        [((id)plot) setBarFill:self.barFill];
    }
    plot.yAxisFont = self.yAxisFont;
    plot.yAxisTextColor = self.yAxisTextColor;
    plot.borderWidth = self.borderWidth;
    plot.borderColor = self.borderColor;
    plot.insideLineWidth = self.insideLineWidth;
    plot.insideLineColor = self.insideLineColor;
}

- (void)_reloadData {
    [self _reloadData:NO];
}
#pragma mark -- 更新 --
- (void)_reloadData:(BOOL)recalculateParameter { /// 判斷是否重新計算參數或只是更新畫面(Redraw)
    
    BOOL is2nd = (self.options[@"ENQUIRE_MODE"] ||
                  (self.enquiryLineMode & MChartEnquiryLineModeNotToDisappear));

    /// 如果正在查價，就延遲reloadData
    if (_chartViewFlags.isEnquiring && !is2nd) {
        _chartViewFlags.delayReloadData = true;
        return;
    }
    
    //////////////////////////////////////////////
    for (MOHLCScrollableGraphView *graphView in @[self.majorGraphView, self.minorGraphView]) {
        [self setupPlotStyle:graphView.plot];
    }
    //////////////////////////////////////////////

    if (recalculateParameter) {
        [_majorGraphView reloadData];
        [_minorGraphView reloadData];
    } else {
        [_majorGraphView _reloadData];
        [_minorGraphView _reloadData];
    }
    
    /// 长驻查价线模式，查价线重新绘制
    if (_chartViewFlags.isEnquiring && is2nd) {
        [self _enquireX:_previousEnquireLocationX y:_previousEnquireLocationY];
    }
}
#pragma mark -- 主图Y轴和参数label布局
- (void)layoutMajorPlotYAxisLabelsAndValueLabels {
    CGRect rect;
    NSTextAlignment textAlignment;
    if (![self _isYAxisLabelInside]) {
        textAlignment = NSTextAlignmentRight;
        rect = CGRectMake(0,
                          CGRectGetMinY([_majorGraphView drawingFrame]),
                          self.yAxisLabelInsets.left,
                          CGRectGetHeight([_majorGraphView drawingFrame]));
    } else {
        textAlignment = NSTextAlignmentLeft;
        rect = CGRectMake(CGRectGetMinX([_majorGraphView drawingFrame]),
                          CGRectGetMinY([_majorGraphView drawingFrame]),
                          CGRectGetWidth(self.frame) / 2.0,
                          CGRectGetHeight([_majorGraphView drawingFrame]));
    }
    //布局Y轴label
    [_majorGraphView.plot layoutYAxisLabelsToView:self
                                           inRect:rect
                                             font:self.yAxisFont
                                    textAlignment:textAlignment];
    
    [_majorGraphView.plot layoutValueLabelSizeToFit];
}
#pragma mark -- 副图Y轴和参数label布局 --
- (void)layoutMinorPlotYAxisLabelsAndValueLabels {
    CGRect rect;
    NSTextAlignment textAlignment;
    if (![self _isYAxisLabelInside]) {
        textAlignment = NSTextAlignmentRight;
        rect = CGRectMake(0,
                          CGRectGetMinY([_minorGraphView drawingFrame]),
                          self.yAxisLabelInsets.left,
                          CGRectGetHeight([_minorGraphView drawingFrame]));
    } else {
        textAlignment = NSTextAlignmentLeft;
        rect = CGRectMake(CGRectGetMinX([_majorGraphView drawingFrame]),
                          CGRectGetMinY([_minorGraphView drawingFrame]),
                          CGRectGetWidth(self.frame) / 2.0,
                          CGRectGetHeight([_minorGraphView drawingFrame]));
    }
    [_minorGraphView.plot layoutYAxisLabelsToView:self
                                           inRect:rect
                                             font:self.yAxisFont
                                    textAlignment:textAlignment];
    
    [_minorGraphView.plot layoutValueLabelSizeToFit];
}

- (void)checkMajorPlotIndexAndMinorPlotIndex {
    if (self.majorPlots_.count && !_majorGraphView.plot) {
        [self setMajorPlotIndex:0];
    }
    if (self.minorPlots_.count && !_minorGraphView.plot) {
        [self setMinorPlotIndex:0];
    }
}
#pragma mark -- Y轴label显示内外关键（外部设置）--
- (BOOL)_isYAxisLabelInside {
    return UIEdgeInsetsEqualToEdgeInsets(self.yAxisLabelInsets, UIEdgeInsetsZero);
}
#pragma mark -- 开始查价 --
- (void)_startEnquire:(UIGestureRecognizer *)gestureRecognizer {
    
    [self.delayCloseEnquiryLineTimer invalidate];
    
    [self _setScrollEnabled:NO scrollToEnd:NO];

    if (gestureRecognizer != self.panGestureRecognizer) {
        [self addGestureRecognizer:self.panGestureRecognizer];
    }

    CGFloat xLocation = [gestureRecognizer locationInView:self].x;
    CGFloat yLocation = [gestureRecognizer locationInView:self].y;
    [self _enquireX:xLocation y:yLocation];
}
#pragma mark -- 绘制查价线 --
- (void)_enquireX:(CGFloat)xLocation y:(CGFloat)yLocation {
    CGRect chartRect = CGRectZero;
    if (self.minorGraphView) {
        //并集
        chartRect = CGRectUnion([_majorGraphView drawingFrame], [_minorGraphView drawingFrame]);
    } else {
        chartRect = [_majorGraphView drawingFrame];
    }
    xLocation = MIN(CGRectGetMaxX(chartRect), xLocation);
    xLocation = MAX(CGRectGetMinX(chartRect), xLocation);
    
    yLocation = MIN(CGRectGetMaxY(chartRect), yLocation);
    yLocation = MAX(CGRectGetMinY(chartRect), yLocation);
    
    NSInteger index = 0;
    MOHLCItem *item = nil;
    if (self.enquiryLineMode & MChartEnquiryLineModeNone) {
        item = [_majorGraphView itemWithTouchLocation:&xLocation
                                            yLocation:nil
                                                index:&index];
        
    } else {
        item = [_majorGraphView itemWithTouchLocation:&xLocation
                                            yLocation:&yLocation
                                                index:&index];
    }
    
    if (item) {
        /// flags changed.
        _chartViewFlags.isEnquiring = true;
        //主副图更新查价数据
        [_majorGraphView.plot displayEnquiredInformationAtIndex:index];
        [_minorGraphView.plot displayEnquiredInformationAtIndex:index];
        
        _previousEnquireLocationX = xLocation;
        _previousEnquireLocationY = yLocation;
        CGPoint touchLocation = CGPointMake(xLocation, yLocation);
        
        /// 繪製查價線
        NSString *xAxisString = MApiOHLCDatetime(self.type, item.datetime);
        NSString *yAxisString = nil;
        
        if (self.enquiryLineMode & MChartEnquiryLineModeNone) {
            CGRect r;
            MOHLCScrollableGraphView *graphView = nil;
            if (CGRectContainsPoint((r = [_majorGraphView drawingFrame]), touchLocation)) {
                graphView = _majorGraphView;
            } else if (CGRectContainsPoint((r = [_minorGraphView drawingFrame]), touchLocation)) {
                graphView = _minorGraphView;
            }
            
            if (graphView) {
                double displayValue = touchLocation.y - CGRectGetMinY(r);
                CGFloat scale = CGRectGetHeight(r) / fabs(graphView.plot.maxValue - graphView.plot.minValue);
                displayValue = graphView.plot.maxValue - (displayValue / scale);
                if (!isinf(displayValue) && !isnan(displayValue)) {
                    yAxisString = [NSString stringWithFormat:graphView.plot.labelStringFormat, displayValue];
                }
            }
            
        } else {
            yAxisString = [NSString stringWithFormat:_majorGraphView.plot.labelStringFormat, [item.closePrice doubleValue]];
        }
        
        //绘制查价线并赋值
        [self.enquiryView drawInRect:chartRect
                          limitRects:@[[NSValue valueWithCGRect:[_majorGraphView drawingFrame]],
                                       [NSValue valueWithCGRect:[_minorGraphView drawingFrame]]]
                         xAxisString:xAxisString
                         yAxisString:yAxisString
                       touchLocation:touchLocation
                         borderWidth:self.borderWidth
                         yAxisInside:[self _isYAxisLabelInside]
                          yAxisWidth:self.yAxisLabelInsets.left
                       xAxisLbelMode:self.options[@"ENQUIRE_XAXIS_MODE"] ? 1 : 0];
        
        if (_previousEnquireIndex != index) {
            _previousEnquireIndex = index;
            /// 通知
            NSInteger prevIndex = index - 1;
            MOHLCItem *prevItem = nil;
            if (prevIndex >= 0 && prevIndex < self.items.count) {
                prevItem = self.items[prevIndex];
            }
            //查价时候发通知传递数据
            [[NSNotificationCenter defaultCenter] postNotificationName:MChartDidStartEnquiryNotification
                                                                object:item
                                                              userInfo:prevItem?@{MOHLCChartViewPreviousItemNotificationInfoKey:prevItem}:nil];
        }
    }
    
}
#pragma mark -- 结束查价线 --
- (void)_endEnquire {

    [self removeGestureRecognizer:self.panGestureRecognizer];

    [self _setScrollEnabled:self.scrollEnabled scrollToEnd:NO];

    if (_chartViewFlags.isEnquiring) {
        
        /// flags changed.
        _chartViewFlags.isEnquiring = false;
        //疑问（意义）
        [_majorGraphView.plot displayLastEnquiredInformation];
        [_minorGraphView.plot displayLastEnquiredInformation];
        [self.enquiryView clear];
        //发送查价线结束通知
        [[NSNotificationCenter defaultCenter] postNotificationName:MChartDidEndEnquiryNotification
                                                            object:_majorGraphView.plot.labelStringFormat
                                                          userInfo:nil];
    }
    
    /// 查價時有執行reloadData的話會被擋掉，則結束查價時要重新執行reloadData。
    if (_chartViewFlags.delayReloadData) {
        _chartViewFlags.delayReloadData = false;
        [self reloadData];
    }
}

- (void)_endEnquireForDelayMode {
    if (!(self.enquiryLineMode & MChartEnquiryLineModeAppearImmediately)) {
        [self removeGestureRecognizer:self.tapGestureRecognizer];
    }
    
    [self _endEnquire];
}


#pragma mark public
#pragma mark -- 添加主视图plot --
- (void)addMajorPlot:(MMAPlot *)plot {
    if (![self.majorPlots_ containsObject:plot]) {
        plot.dataSource = self;
        [self setupPlotStyle:plot];
        [self.majorPlots_ addObject:plot];
        if (!self.majorGraphView.superview) {
            [self addSubview:self.majorGraphView];
        }
    }
//    if (!_majorGraphView.plot) {
//        [self setupMajorGraphPlot:plot];
//    }
}

- (void)addMajorPlots:(MMAPlot *)plots, ... {
    va_list arglist;
    id obj;
    if (plots) {
        [self addMajorPlot:plots];
        va_start(arglist, plots);
        while ((obj = va_arg(arglist, id)))
            if (obj) [self addMajorPlot:obj];
        va_end(arglist);
    }
}
#pragma mark -- 添加副图plot --
- (void)addMinorPlot:(MPlot *)plot {
    if (![self.minorPlots_ containsObject:plot]) {
        // TODO: data source;
        plot.dataSource = self;
        [self setupPlotStyle:plot];
        
        [self.minorPlots_ addObject:plot];
        if (!self.minorGraphView.superview) {
            [self addSubview:self.minorGraphView];
        }
    }
    
}

- (void)addMinorPlots:(MPlot *)plots, ... {
    va_list arglist;
    id obj;
    if (plots) {
        [self addMinorPlot:plots];
        va_start(arglist, plots);
        while ((obj = va_arg(arglist, id)))
            if (obj) [self addMinorPlot:obj];
        va_end(arglist);
    }
}

- (void)reloadDataWithStockItem:(MStockItem *)stockItem {
    if (!stockItem || !stockItem.ID || !stockItem.subtype || stockItem.preClosePrice.doubleValue == 0) {
        /// 重新取得 stockItem
        [self reloadData];
        return;
    }
    self.stockItem = stockItem;

    [MApi cancelRequest:self.snapRequest];
    [MApi cancelRequest:self.OHLCRequest];
    
    [self checkMajorPlotIndexAndMinorPlotIndex];
    
    MOHLCPeriod period;
    switch (self.type) {
        case MOHLCChartTypeDay: period = MOHLCPeriodDay; break;
        case MOHLCChartTypeWeek: period = MOHLCPeriodWeek; break;
        case MOHLCChartTypeMonth: period = MOHLCPeriodMonth; break;
        case MOHLCChartTypeMin5: period = MOHLCPeriodMin5; break;
        case MOHLCChartTypeMin15: period = MOHLCPeriodMin15; break;
        case MOHLCChartTypeMin30: period = MOHLCPeriodMin30; break;
        case MOHLCChartTypeMin60: period = MOHLCPeriodMin60; break;
        case MOHLCChartTypeMin120: period = MOHLCPeriodMin120; break;
    }

    MOHLCPriceAdjustedMode mode;
    switch (self.priceAdjustedMode) {
        case MOHLCChartPriceAdjustedModeNone: mode = MOHLCPriceAdjustedModeNone; break;
        case MOHLCChartPriceAdjustedModeForward: mode = MOHLCPriceAdjustedModeForward; break;
        case MOHLCChartPriceAdjustedModeBackward: mode = MOHLCPriceAdjustedModeBackward; break;
    }
    
    self.OHLCRequest = [[MOHLCRequest alloc] init];
    self.OHLCRequest.code = self.stockItem.ID;
    self.OHLCRequest.subtype = self.stockItem.subtype;
    self.OHLCRequest.period = period;
    self.OHLCRequest.priceAdjustedMode = mode;
    
    [MApi sendRequest:self.OHLCRequest completionHandler:^(MResponse *resp) {
        if (resp.status == MResponseStatusSuccess) {
            MOHLCResponse *response = (MOHLCResponse *)resp;
            
            /// 补最后一根 & get items
            self.items = [response OHLCItemsByPeriodType:period andSnapshotStockItem:self.stockItem];
            
            if (self.index != 10) {
                self.index = 10;
                for (int i = 0; i < self.items.count; i++) {
                    [self saveData:self.items[i]];
                }
            }
            
            
            [self _reloadData:YES];
        }
    }];
}
- (void)saveData:(MOHLCItem *)item{
    NSString *insertSql = [NSString stringWithFormat:@"insert into %@(closePrice,tradeVolume,datetime,averagePrice,highPrice,lowPrice,openPrice,preClosePrice,referencePrice,amount) values(?,?,?,?,?,?,?,?,?,?)",@"t_user"];
    bool flag = [self.db executeUpdate:insertSql,item.closePrice,item.tradeVolume,item.datetime,item.averagePrice,item.highPrice,item.lowPrice,item.openPrice,item.preClosePrice,item.referencePrice,item.amount];

    if (flag) {
        NSLog(@"成功");
    }
}
- (void)reloadData {
    
    /// 先檔
    if (!self.code) {
        return;
    }
    
    [MApi cancelRequest:self.snapRequest];
    [MApi cancelRequest:self.OHLCRequest];
    
    self.snapRequest = [[MSnapQuoteRequest alloc] init];
    self.snapRequest.code = self.code;

    [MApi sendRequest:self.snapRequest completionHandler:^(MResponse *resp) {
        if (resp.status == MResponseStatusSuccess) {
            MStockItem *stockItem = ((MSnapQuoteResponse *)resp).stockItem;
            if (stockItem && stockItem.ID && stockItem.subtype && stockItem.preClosePrice.doubleValue > 0) {
                [self reloadDataWithStockItem:((MSnapQuoteResponse *)resp).stockItem];
            }
        }
    }];
}

- (void)setupMajorGraphPlot:(MPlot *)plot {
    plot.valueLabelParentScrollView = self.majorValueScrollView;
    _majorGraphView.plot = plot;
    [self layoutMajorPlotYAxisLabelsAndValueLabels];
}

- (void)setupMinorGraphPlot:(MPlot *)plot {
    plot.valueLabelParentScrollView = self.minorValueScrollView;
    _minorGraphView.plot = plot;
    [self layoutMinorPlotYAxisLabelsAndValueLabels];
}
#pragma mark -- 向一个方向移动一个bar和间距的距离（用于显示查价线后向左或向右偏移，外部调用，工程版没有） --
- (void)moveEnquiryLineToDirection:(MOHLCChartEnquiryLineMovingDirection)direction {
    
    if (!_chartViewFlags.isEnquiring) {
        return;
    }
    CGFloat barWidth = [self barWidth];
    CGFloat barSpacing = [self barSpacing];
    CGPoint offset = _majorGraphView.contentOffset;
    
    CGRect chartRect = CGRectZero;
    if (self.minorGraphView) {
        chartRect = CGRectUnion([_majorGraphView drawingFrame], [_minorGraphView drawingFrame]);
    } else {
        chartRect = [_majorGraphView drawingFrame];
    }
    CGFloat xLocation;
    if (direction == MOHLCChartEnquiryLineMovingDirectionLeft) {
        offset.x -= (barWidth + barSpacing);
        xLocation = _previousEnquireLocationX-barWidth;
    } else {
        offset.x += (barWidth + barSpacing);
        xLocation = _previousEnquireLocationX+barWidth;
    }
    
    
    if (xLocation <= CGRectGetMinX(chartRect) || xLocation >= CGRectGetMaxX(chartRect)) {
        offset.x = MIN(offset.x, _majorGraphView.contentSize.width - _majorGraphView.frame.size.width);
        offset.x = MAX(offset.x, 0);
        [_majorGraphView setContentOffset:offset animated:NO];
    }
    xLocation = MIN(CGRectGetMaxX(chartRect), xLocation);
    xLocation = MAX(CGRectGetMinX(chartRect), xLocation);
    
    [self _enquireX:xLocation y:_previousEnquireLocationY];
    
}

#pragma mark MPlotAttributes

- (CGFloat)barSpacing {
    return 1.0;
}
#pragma mark -- 每个bar的宽度 --
- (CGFloat)barWidth {
    if (!self.majorGraphView) {
        return 0;
    }
    CGFloat drawingWidth = CGRectGetWidth([_majorGraphView drawingBounds]);
    CGFloat cal_barWidth = (drawingWidth - (self.barSpacing * (self.numberOfVisibleRecords - 1))) / self.numberOfVisibleRecords;
    return cal_barWidth;
}


#pragma mark UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.majorGraphView && self.minorGraphView) {
        for (MOHLCScrollableGraphView *graphView in @[self.majorGraphView, self.minorGraphView]) {
            if (scrollView != graphView) {
                graphView.contentOffset = scrollView.contentOffset;
            }
        }
    } else {
        /// MARK:這裡majorGraphView本身會執行LayoutSubviews
        //        [self.majorGraphView setNeedsLayout]; // reloadData原本
    }
}


#pragma mark UIGestureRecognizerDelegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if ([gestureRecognizer.view isKindOfClass:[MOHLCChartView class]]) {
        //// 避免截走其他view的手势
        if ((gestureRecognizer == self.longPressGestureRecognizer ||
             gestureRecognizer == self.tapGestureRecognizer ||
             gestureRecognizer == self.panGestureRecognizer) && self.enquiryEnabled) {
            CGPoint location = [gestureRecognizer locationInView:self];
            //CGRectUnion返回两个矩形的并集
            if (CGRectContainsPoint(CGRectUnion(self.majorGraphView.frame, self.minorGraphView.frame),
                                    location)) {
                return YES;
            }
        }
        else if (gestureRecognizer == self.zoomGestureRecognizer && self.zoomEnabled) {
            return YES;
        }
        return NO;
    }
    return YES;
}

@end

