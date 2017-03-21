//
//  MPlotItem.m
//  TSApi
//
//  Created by mitake-cn on 2015/3/22.
//  Copyright (c) 2015年 Mitake. All rights reserved.
//

//#import "MPlot.h"
#import "_MPlot.h"
#import "MOHLCItem.h"
#import "MApiFormatter.h"

#define RISE_COLOR [UIColor redColor]
#define DROP_COLOR [UIColor greenColor]
#define LINE_COLOR [UIColor greenColor]

static NSString * const kMPlotException = @"MPlotException";
static NSString * const kValueNilDefaultString = @"一";
//isinf必须有值
bool MPlotRectIsValid(CGRect rect) {
    return !isinf(rect.origin.x) && !isnan(rect.origin.x) &&
           !isinf(rect.origin.y) && !isnan(rect.origin.y) &&
           !isinf(rect.size.width) && !isnan(rect.size.width) &&
           !isinf(rect.size.height) && !isnan(rect.size.height);
}

NS_INLINE bool MPlotPointIsValid(CGPoint point) {
    return !isinf(point.x) && !isnan(point.x) &&
           !isinf(point.y) && !isnan(point.y);
}
//处理无值数据
NS_INLINE double MPlotDouble(double inValue) {
    if (isinf(inValue) || isnan(inValue)) {
        return 0;
    }
    return inValue + 0.0000000001;
}
#pragma mark -- 获取当前要划的Y值 --
NS_INLINE CGFloat MPlotGetYPositionInRect(CGRect rect, CGFloat value, CGFloat maxValue, CGFloat minValue) {
    if (maxValue < minValue) {
        NSLog(@"# WARNING: In MPlotGetYPositionInRect, the maxValue is smaller than minValue.");
    }
    CGFloat scale = CGRectGetHeight(rect) / fabs(maxValue - minValue);
    if (isnan(scale) || isinf(scale) || isnan(value) || isinf(value)) {
        //NSLog(@"# WARNING: In MPlotGetYPositionInRect, the scale is not a valid float value, so return zero.");
        return 1;
    }
    return CGRectGetMinY(rect) + CGRectGetHeight(rect) - (fabs(value - minValue) * scale);
}
#pragma mark -- k棒高度 --
NS_INLINE CGFloat MPlotGetHeight(CGRect rect, CGFloat value, CGFloat maxValue, CGFloat minValue) {
    if (maxValue < minValue) {
        NSLog(@"# WARNING: In MPlotGetHeight, the maxValue is smaller than minValue.");
    }
    CGFloat scale = CGRectGetHeight(rect) / fabs(maxValue - minValue);
    if (isnan(scale) || isinf(scale) || isnan(value) || isinf(value)) {
        //NSLog(@"# WARNING: In MPlotGetHeight, the scale is not a valid float value, so return zero.");
        return 1;
    }
    return (fabs(value) * scale);
}
//开始点
NS_INLINE void MPlotBezierPathMoveToPoint(UIBezierPath *path, CGPoint point) {
    if (MPlotPointIsValid(point)) {
        [path moveToPoint:point];
    }
}
//点与点连线
NS_INLINE void MPlotBezierPathAddLineToPoint(UIBezierPath *path, CGPoint point) {
    if (MPlotPointIsValid(point)) {
        [path addLineToPoint:point];
    }
}


#pragma mark - MPlot
static const NSUInteger MPlotParameterMax = 10;
static UIColor *g_defaultLineColors[MPlotParameterMax];

@interface MPlot ()
{
    @package
    NSInteger params[MPlotParameterMax];   //参数值
    double *pValues[MPlotParameterMax];    //线点的值  在重置参数赋值（公式）
    UIBezierPath *paths[MPlotParameterMax];
    BOOL firstDrawing[MPlotParameterMax];
    UIColor *colors[MPlotParameterMax];
}

@property (nonatomic, assign) NSInteger yAxisLabelCount;
@property (nonatomic, strong) NSMutableArray<UILabel *> *valueLabels; //参数值label
@property (nonatomic, strong) NSMutableArray *yAxisLabels;
@property (nonatomic, assign) CGFloat labelMaxValue;
@property (nonatomic, assign) CGFloat labelMinValue;
@property (nonatomic, assign) double maxPrice;
@property (nonatomic, assign) double minPrice;
@property (nonatomic, assign) double maxVolume;
@property (nonatomic, assign) NSUInteger parameterCount; //参数个数（有几个划几条）


- (void)initializePaths;
- (void)setupDefaultValue;
- (UIColor *)colorAtIndex:(NSUInteger)index;
@end


@implementation MPlot

#pragma mark init

- (void)dealloc {
    for (int i = 0; i < MPlotParameterMax; i++) {
        if (pValues[i]) {
            free(pValues[i]);
            pValues[i] = NULL;
        }
    }
}

- (instancetype)init {
    return [self initWithYAxisLabelCount:3];
}

- (instancetype)initWithYAxisLabelCount:(NSInteger)yAxisLabelCount {
    self = [super init];
    if (self) {
        colors[0] = g_defaultLineColors[0] ?: [UIColor whiteColor];
        colors[1] = g_defaultLineColors[1] ?: [UIColor yellowColor];
        colors[2] = g_defaultLineColors[2] ?: [UIColor magentaColor];
        colors[3] = g_defaultLineColors[3] ?: [UIColor greenColor];
        
        _yAxisLabels = [[NSMutableArray alloc] init];
        _valueLabels = [[NSMutableArray alloc] init];
        _borderWidth = 1.0f;
        _parameterCount = 0;
        _yAxisLabelCount = yAxisLabelCount;
        [self setupDefaultValue];
    }
    return self;
}

#pragma mark life cycle
#pragma mark -- 创建y轴和参数label --
- (void)willSetup {
    NSAssert(
             (self.yAxisLabels.count == 0) &&
             (self.valueLabels.count == 0), @"YOU MUST call kill before setup plot item.");
    
    // create y axis label
    for (int i = 0; i < self.yAxisLabelCount; i++) {
        UILabel *label = [[UILabel alloc] init];
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_6_0
        label.textAlignment = NSTextAlignmentLeft;
        label.minimumScaleFactor = 0.5;
#else
        label.textAlignment = UITextAlignmentLeft;
        label.minimumFontSize = 6.0;
#endif
        label.adjustsFontSizeToFitWidth = YES;
        label.textColor = self.yAxisTextColor;
        label.font = self.yAxisFont;
        label.backgroundColor = [UIColor clearColor];
        [self.yAxisLabels addObject:label];
    }

    for (int i = 0; i < MPlotParameterMax; i++) {
        UILabel *label = [[UILabel alloc] init];
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_6_0
        label.textAlignment = NSTextAlignmentLeft;
        label.minimumScaleFactor = 0.5;
#else
        label.textAlignment = UITextAlignmentLeft;
        label.minimumFontSize = 6.0;
#endif
        @try {
            label.textColor = [self colorAtIndex:i];
        } @catch (NSException *exception) {}
        
        label.adjustsFontSizeToFitWidth = YES;
        label.font = [UIFont systemFontOfSize:10.0];
        label.backgroundColor = [UIColor clearColor];
        [self.valueLabels addObject:label];
    }
}
#pragma mark -- 终止对象 --
- (void)kill {
    self.drawingTarget = nil;
    
    for (UILabel *label in self.yAxisLabels) {
        [label removeFromSuperview];
    }
    [self.yAxisLabels removeAllObjects];
    
    for (UILabel *label in self.valueLabels) {
        [label removeFromSuperview];
    }
    [self.valueLabels removeAllObjects];
}
#pragma mark -- 重新分配参数 --
- (void)beginCalculateParameter {
    /// 父類重新分配記憶體，子類計算參數
    /// 參數賦值
    
    NSInteger numberOfRecords = [self numberOfRecords];
    size_t sz = sizeof(double) * numberOfRecords;

    /// 畫面顯示的數值及顏色
    for (int i = 0; i < [self numberOfDisplayValue]; i++) {
        if(pValues[i]) {
            free(pValues[i]);
            pValues[i] = NULL;
        }
        
        pValues[i] = malloc(sz);
        bzero(pValues[i], sz);
    }
}

#pragma mark - public 

- (void)redraw {
    [self.drawingTarget reloadData];
}

- (void)setParameters:(NSUInteger)param, ... {
    va_list args;
    va_start(args, param);
    NSUInteger idx = 0;
    for (NSUInteger arg = param;
         (void *)arg != nil && idx < MPlotParameterMax;
         arg = va_arg( args, NSUInteger), idx++)
    {
        params[idx] = arg;
    }
    va_end(args);
    self.parameterCount = idx;
    
    for (; idx < MPlotParameterMax; idx++) {
        params[idx] = 0;
    }
}
#pragma -- 外部设置参数 内部默认失效 --
- (void)setParametersFromArray:(NSArray *)_params {
    NSUInteger idx = 0;
    for (; idx < _params.count && idx < MPlotParameterMax; idx++) {
        params[idx] = (NSUInteger)[_params[idx] integerValue];
    }
    self.parameterCount = idx;
    
    for (; idx < MPlotParameterMax; idx++) {
        params[idx] = 0;
    }
}

- (void)setLineColors:(UIColor *)color, ... {
    va_list args;
    va_start(args, color);
    NSUInteger idx = 0;
    for (UIColor *arg = color;
         arg != nil && idx < MPlotParameterMax;
         arg = va_arg( args, UIColor *), idx++)
    {
        colors[idx] = arg;
    }
    va_end(args);
}

- (void)setLineColorsFromArray:(NSArray *)_colors {
    NSUInteger idx = 0;
    for (; idx < _colors.count && idx < MPlotParameterMax; idx++) {
        colors[idx] = _colors[idx];
    }
}

+ (void)setDefaultLineColors:(UIColor *)color, ... {
    va_list args;
    va_start(args, color);
    NSUInteger idx = 0;
    for (UIColor *arg = color;
         arg != nil && idx < MPlotParameterMax;
         arg = va_arg( args, UIColor *), idx++)
    {
        g_defaultLineColors[idx] = arg;
    }
    va_end(args);
}

#pragma mark getter

- (NSString *)labelStringFormat {
    return @"%.3f";
}

- (UIColor *)borderColor {
    if (!_borderColor) {
        _borderColor = [UIColor whiteColor];
    }
    return _borderColor;
}

- (double)minValue {
    return self.minPrice;
}

- (double)maxValue {
    return self.maxPrice;
}

#pragma mark public

- (void)layoutYAxisLabelsToView:(UIView *)view inRect:(CGRect)inRect font:(UIFont *)font {
    [self layoutYAxisLabelsToView:view inRect:inRect font:font textAlignment:NSTextAlignmentLeft];
}
#pragma mark --Y轴label创建 --
- (void)layoutYAxisLabelsToView:(UIView *)view inRect:(CGRect)inRect font:(UIFont *)font textAlignment:(NSTextAlignment)textAlignment {
    
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 70000
    CGFloat labelHeight = [@"0123" sizeWithAttributes:@{NSFontAttributeName:font}].height;
#else
    static double systemVer;
    if (systemVer <= 0) systemVer = [UIDevice currentDevice].systemVersion.doubleValue;
    CGFloat labelHeight;
    if (systemVer < 7) {
        labelHeight = [@"0123" sizeWithFont:font].height;
    } else {
        labelHeight = [@"0123" sizeWithAttributes:@{NSFontAttributeName:font}].height;
    }
#endif

    NSInteger index = 0;
    NSArray *labelHiddenParameter = self.options[@"Y_AXIS_LABELS_HIDDEN"];

    CGFloat ySpacing = CGRectGetHeight(inRect) / MAX(1, self.yAxisLabels.count - 1);
    for (UILabel *label in self.yAxisLabels) {
        
        if (index < labelHiddenParameter.count) {
            label.hidden = [labelHiddenParameter[index] boolValue];
        } else {
            label.hidden = NO;
        }
        
        label.textAlignment = textAlignment;
        label.font = font;
        CGFloat labelPositionY = 0;

        if (index == 0) {
            labelPositionY = CGRectGetMinY(inRect);
        }
        else if (index == self.yAxisLabels.count - 1) {
            labelPositionY = CGRectGetMinY(inRect) + CGRectGetHeight(inRect) - labelHeight;
        }
        else {
            labelPositionY = CGRectGetMinY(inRect) + (ySpacing * index) - (labelHeight / 2.0);
        }
        CGRect rect = CGRectMake(CGRectGetMinX(inRect),
                                 labelPositionY,
                                 CGRectGetWidth(inRect),
                                 labelHeight);
        label.frame = CGRectInset(rect, 2.0, 0);

        if (!label.superview) {
            [view addSubview:label];
        }
        index++;
    }
}
#pragma mark -- y轴label赋值 --
- (void)relabelIfNeeded {
    //获取均分值
    CGFloat decrease = (self.labelMaxValue - self.labelMinValue) / (self.yAxisLabels.count - 1);
    NSInteger index = 0;
    //给每个y轴label赋值
    for (UILabel *label in self.yAxisLabels) {
        double value = self.labelMaxValue - (decrease*index);
        NSString *string = kValueNilDefaultString;
        if ([self numberOfRecords]) {
            if (self.yAxisDisplayFormat) {
                string = self.yAxisDisplayFormat(value);
            } else {
                string = [NSString stringWithFormat:[self labelStringFormat], value];
            }
        }
        label.text = string;
        index++;
    }
}
#pragma mark -- 显示最后的查价信息 --
- (void)displayLastEnquiredInformation {
    //从新处理参数轴数据
    [self beginCalculateParameter];
    if ([self numberOfDisplayValue]) {
        NSAssert(pValues[[self numberOfDisplayValue] - 1] != NULL, @"pValue out of range");
    }
    //参数轴数据赋值
    [self displayEnquiredInformationAtIndex:NSNotFound];
}
#pragma mark --参数轴数据赋值 父类是子类没有这个方法的MPlot才调用--
- (void)displayEnquiredInformationAtIndex:(NSInteger)index {

    [self clearUnusedValueLabels];
    
    ///
    NSUInteger numberOfRecords = [self numberOfRecords];
    for (int i = 0; i < [self numberOfDisplayValue]; i++) {
        UILabel *label = self.valueLabels[i];
        NSMutableString *format = [NSMutableString stringWithFormat:@"%@%lu:", [self title], (unsigned long)params[i]];
        if (numberOfRecords) {
            [format appendString:[self labelStringFormat]];
            if (index == NSNotFound) {
                label.text = [NSString stringWithFormat:format, MPlotDouble(pValues[i][[self numberOfRecords] - 1])];
            } else {
                label.text = [NSString stringWithFormat:format, MPlotDouble(pValues[i][index])];
            }
        }
        else {
            label.text = [format stringByAppendingString:kValueNilDefaultString];
        }
    }
    [self layoutValueLabelSizeToFit];
}

- (NSUInteger)numberOfRecords {
    return [_dataSource numberOfRecordsForPlot:self];
}


#pragma mark private

- (void)initializePaths {
    for (int i = 0; i < [self numberOfDisplayValue]; i++) {
        @autoreleasepool {
            paths[i] = [UIBezierPath bezierPath];
            firstDrawing[i] = YES;
        }
    }
}
#pragma mark -- 参数轴label数据大小自适应 --
- (CGFloat)layoutValueLabelSizeToFit {
    CGFloat padding = 8.0;
    CGFloat width = 0.0;
    for (NSInteger index = 0; index < [self numberOfDisplayValue]; index++) {
        UILabel *label = self.valueLabels[index];
        CGRect frame = label.frame;
        
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 70000
        CGSize size = [label.text sizeWithAttributes:@{NSFontAttributeName:label.font}];
#else
        static double systemVer;
        if (systemVer <= 0) systemVer = [UIDevice currentDevice].systemVersion.doubleValue;
        CGSize size;
        if (systemVer < 7) {
            size = [label.text sizeWithFont:label.font];
        } else {
            size = [label.text sizeWithAttributes:@{NSFontAttributeName:label.font}];
        }
#endif
        
        frame.size.width = size.width;
        frame.size.height = CGRectGetHeight(self.valueLabelParentScrollView.frame);
        frame.origin.y = 0;
        if (index > 0) {
            UILabel *previousLabel = self.valueLabels[index - 1];
            frame.origin.x = CGRectGetMaxX(previousLabel.frame) + padding;
        }
        label.frame = frame;
        
        if (index == [self numberOfDisplayValue] - 1) {
            width = CGRectGetMaxX(frame);
        }
        if (!label.superview) {
            [self.valueLabelParentScrollView addSubview:label];
        }
    }
    self.valueLabelParentScrollView.contentSize =
    CGSizeMake(width, CGRectGetHeight(self.valueLabelParentScrollView.frame));
    return width;
}

- (MOHLCItem *)itemAtRecordIndex:(NSInteger)recordIndex {
    recordIndex = MAX(recordIndex, 0);
    recordIndex = MIN(recordIndex, [self numberOfRecords] - 1);
    id obj = [self.dataSource plot:self itemAtRecordIndex:recordIndex];
    return obj;
}
#pragma mark --清除没用到的valueLabel.text，例如参数由3个变1个的时候 内容滞空了--
- (void)clearUnusedValueLabels {
    /// 清除没用到的valueLabel.text，例如参数由3个变1个的时候，则清除第2~10的label.text。
    NSRange unusedLabelRange = NSMakeRange([self numberOfParams], self.valueLabels.count - [self numberOfParams]);
    [[self.valueLabels subarrayWithRange:unusedLabelRange] makeObjectsPerformSelector:@selector(setText:)
                                                                           withObject:nil];
}

- (void)setupDefaultValue {
    [NSException raise:kMPlotException
                format:@"%@ MUST override -(void)setupDefaultValue ...", NSStringFromClass(self.class)];
}

- (UIColor *)colorAtIndex:(NSUInteger)index {
    UIColor *color = colors[index];
    if (!color) {
        color = g_defaultLineColors[index] ?: [UIColor whiteColor];
    }
    return color;
}

#pragma mark MPlotDrawing

- (NSUInteger)numberOfParams {
    return self.parameterCount;
}

- (NSUInteger)numberOfDisplayValue {
    return [self numberOfParams];
}
#pragma mark -- 划边框和内部横线 --
- (void)drawBorderRect:(CGRect)borderRect inContext:(CGContextRef)context {
    CGContextSaveGState(context);

    CGFloat borderWidth = self.insideLineWidth;
    CGContextSetLineWidth(context, borderWidth);
    
    [self.insideLineColor set];
    NSInteger yAxisCcount = self.yAxisLabelCount;
    CGFloat ySpacing = CGRectGetHeight(borderRect) / (yAxisCcount - 1);
    CGFloat y = 0;
    for (int i = 1; i < yAxisCcount - 1; i++) {
        y = i * ySpacing;
        CGContextMoveToPoint(context, CGRectGetMinX(borderRect) + borderWidth, y);
        CGContextAddLineToPoint(context, CGRectGetMaxX(borderRect) - borderWidth, y);
    }
    CGContextStrokePath(context);
    
    //// border
    CGContextSaveGState(context);
    {
        borderWidth = self.borderWidth;
        CGContextSetLineWidth(context, borderWidth);
        [self.borderColor set];
        CGFloat offset = borderWidth/2;
        //设置拐角为直角，
        CGContextSetLineCap(context, kCGLineCapSquare);
        CGContextMoveToPoint(context, CGRectGetMinX(borderRect) + offset, CGRectGetMinY(borderRect) + offset);
        CGContextAddLineToPoint(context, CGRectGetMaxX(borderRect) - offset, CGRectGetMinY(borderRect) + offset);
        CGContextAddLineToPoint(context, CGRectGetMaxX(borderRect) - offset, CGRectGetMaxY(borderRect) - offset);
        CGContextAddLineToPoint(context, CGRectGetMinX(borderRect) + offset, CGRectGetMaxY(borderRect) - offset);
        CGContextAddLineToPoint(context, CGRectGetMinX(borderRect) + offset, CGRectGetMinY(borderRect) + offset);
        CGContextStrokePath(context);
    }
    CGContextRestoreGState(context);

    CGContextRestoreGState(context);
}


- (void)drawRect:(CGRect)rect inContext:(CGContextRef)context atRecordIndex:(NSInteger)recordIndex xPosition:(CGFloat)xPosition attributeProvider:(id<MPlotAttributes> __autoreleasing)attributeProvider {
    [NSException raise:@"miss implement" format:@"- (void)drawRect:(CGRect)rect inContext:(CGContextRef)context atRecordIndex:(NSInteger)recordIndex xPosition:(CGFloat)xPosition attributeProvider:(id<MPlotAttributes> __autoreleasing)attributeProvider;"];
}

- (void)handleXAxisWithIndex:(NSInteger)index left:(BOOL)left {
    MOHLCItem *item = [self itemAtRecordIndex:index];
    [self.dataSource updateXAxisString:item.datetime left:left];
}
#pragma mark -- 父类，初始化绘图路径并获取最高，最低点。
- (void)willRedrawRect:(CGRect)rect atRecordIndex:(NSInteger)recordIndex numberOfVisibleRecords:(NSInteger)numberOfVisibleRecords {
    
    /// 初始化
    [self initializePaths];
    
    /// 最大、最小值計算
    NSInteger numberOfRecords = [self numberOfRecords];
    double maxPrice = DBL_MIN;
    double minPrice = DBL_MAX;
    for (NSInteger index = recordIndex; index < MIN((recordIndex + numberOfVisibleRecords), numberOfRecords); index++) {
        for (int i = 0; i < [self numberOfDisplayValue]; i++) {
            if (pValues[i]) {
                double value = pValues[i][index];
//                if (value != 0)
                {
                    if(value > maxPrice) maxPrice = value;
                    if(value < minPrice) minPrice = value;
                }
            }
        }
    }
    self.maxPrice = maxPrice;
    self.minPrice = minPrice;
}
#pragma mark -- 父类结束绘制 --
- (void)endDrawingContext:(CGContextRef)context {
    for (int i = 0; i < [self numberOfDisplayValue]; i++) {
        UIColor *color = [self colorAtIndex:i];
        CGContextSetStrokeColorWithColor(context, color.CGColor);
        if (paths[i]) {
            [paths[i] stroke];
        }
    }
}

@end


#pragma mark - MA

@implementation MMAPlot

#pragma mark init

- (instancetype)init {
    return [self initWithYAxisLabelCount:5];
}

- (instancetype)initWithYAxisLabelCount:(NSInteger)yAxisLabelCount barFill:(BOOL)barFill {
    self = [super initWithYAxisLabelCount:yAxisLabelCount];
    if (self) {
        _barFill = barFill;
    }
    return self;
}


#pragma mark override

- (void)setupDefaultValue {
    //MA外部设置了参数，默认就无效
    params[0] = 6; params[1] = 12; params[2] = 24;
}
#pragma mark -- 显示当前index查价信息 --
- (void)displayEnquiredInformationAtIndex:(NSInteger)index {
    //滞空无用label
    [self clearUnusedValueLabels];
    
    ///
    NSUInteger numberOfRecords = [self numberOfRecords];
    for (int i = 0; i < [self numberOfDisplayValue]; i++) {
        UILabel *label = self.valueLabels[i];
        
        if (params[i] >= 0) {
            NSMutableString *format = [NSMutableString stringWithFormat:@"%@%lu:", [self title], (unsigned long)params[i]];
            if (numberOfRecords) {
                [format appendString:[self labelStringFormat]];
                if (index == NSNotFound) {
                    label.text = [NSString stringWithFormat:format, MPlotDouble(pValues[i][[self numberOfRecords] - 1])];
                } else {
                    label.text = [NSString stringWithFormat:format, MPlotDouble(pValues[i][index])];
                }
            }
            else {
                label.text = [format stringByAppendingString:kValueNilDefaultString];
            }
        } else {
            label.text = @"";
        }
        
    }
    [self layoutValueLabelSizeToFit];
}

#pragma mark life cycle
#pragma -- MA公式 --
- (void)beginCalculateParameter {
    [super beginCalculateParameter];
    //MA公式  范例5： 前5日的收盘价之和除以5
    NSInteger numberOfRecords = [self numberOfRecords];
    for (int idx = 0; idx < numberOfRecords; idx++) {
        for (int m = 0; m < [self numberOfParams]; m++) {
            double fsum = 0;
            if (params[m]>=0 && idx > (params[m] - 2)) {
                for (int j = idx; j > idx - params[m]; j--) {
                    if (j < 0) break;
                    MOHLCItem *item = [self itemAtRecordIndex:j];
                    fsum += [item.closePrice doubleValue];
                }
                if (params[m] != 0) {
                    pValues[m][idx] = (fsum / (double)params[m]);
                }
                else {
                    pValues[m][idx] = 0;
                }
            }
        }
    }
}


#pragma mark setter

- (void)setBarFill:(BOOL)barFill {
    _barFill = barFill;
    [self.drawingTarget reloadData];
}


#pragma mark getter

- (NSString *)title {
    return @"MA";
}

- (NSString *)labelStringFormat {
    if ([self.dataSource respondsToSelector:@selector(numberOfDecimalForPlot:)]) {
        return [NSString stringWithFormat:@"%%.%df", [self.dataSource numberOfDecimalForPlot:self]];
    }
    return @"%.2f";
}

- (UIColor *)flatColor {
    if (!_flatColor) {
        _flatColor = RISE_COLOR;
    }
    return _flatColor;
}

- (UIColor *)riseColor {
    if (!_riseColor) {
        _riseColor = RISE_COLOR;
    }
    return _riseColor;
}

- (UIColor *)dropColor {
    if (!_dropColor) {
        _dropColor = DROP_COLOR;
    }
    return _dropColor;
}


#pragma mark MPlotDrawing

- (NSUInteger)numberOfParams {
    if ([super numberOfParams]) return [super numberOfParams];
    return 0;
}
#pragma mark -- 初始化绘图路径并获取最高，最低点。
- (void)willRedrawRect:(CGRect)rect atRecordIndex:(NSInteger)recordIndex numberOfVisibleRecords:(NSInteger)numberOfVisibleRecords {
    //初始化划线路径
    [self initializePaths];
    
    NSInteger numberOfRecords = [self numberOfRecords];
    double maxPrice = DBL_MIN;
    double minPrice = DBL_MAX;
    
    for (NSInteger index = recordIndex; index < MIN((recordIndex + numberOfVisibleRecords), numberOfRecords); index++) {
        if (!self.kBarHidden) {
            MOHLCItem *item = [self itemAtRecordIndex:index];
            //获取当前显示的k棒最大值和最小值
            maxPrice = MAX([item.highPrice doubleValue], maxPrice);
            minPrice = MIN([item.lowPrice doubleValue], minPrice);
        }
        //线的最高和最低点，最终获取k线图的最高点和最低点。
        for (int i = 0; i < [self numberOfDisplayValue]; i++) {
            if (pValues[i]) {
                double ma = pValues[i][index];
                if (ma != 0) {
                    if (ma > maxPrice) maxPrice = ma;
                    if (ma < minPrice) minPrice = ma;
                }
            }
        }
    }
    //下面三个if是特殊情况下的值
    if (maxPrice == minPrice) {
        MStockItem *stockItem = [self.dataSource stockItemForPlot:self];
        maxPrice = MAX(stockItem.preClosePrice.doubleValue, maxPrice);
        minPrice = MIN(stockItem.preClosePrice.doubleValue, minPrice);
    }
    if (maxPrice == DBL_MIN) {
        maxPrice = 0;
    }
    if (minPrice == DBL_MAX) {
        minPrice = 0;
    }
    self.maxPrice = maxPrice;
    self.minPrice = minPrice;
}
#pragma mark -- 绘制MA图 --
- (void)drawRect:(CGRect)rect inContext:(CGContextRef)context atRecordIndex:(NSInteger)recordIndex xPosition:(CGFloat)xPosition attributeProvider:(id<MPlotAttributes>__autoreleasing)attributeProvider {
    //划蜡烛
    double minPrice = self.minPrice;
    double maxPrice = self.maxPrice;
    
    MOHLCItem *item = [self itemAtRecordIndex:recordIndex];
    double open = [item.openPrice doubleValue];
    double high = [item.highPrice doubleValue];
    double low = [item.lowPrice doubleValue];
    double close = [item.closePrice doubleValue];
    
    CGFloat barWidth = [attributeProvider barWidth];
    
    self.labelMaxValue = maxPrice;
    self.labelMinValue = minPrice;
    
    BOOL barFill = self.barFill;
    
    if (!self.kBarHidden) {
        CGContextSaveGState(context);
        CGRect barRect = CGRectZero;
        if (close > open) { //漲
            [self.riseColor set];
            //获取Y值和高度
            barRect = CGRectMake(xPosition,
                                 MPlotGetYPositionInRect(rect, close, maxPrice, minPrice),
                                 barWidth,
                                 MPlotGetHeight(rect, open - close, maxPrice, minPrice));
        }
        else {
            if (close < open) { //跌
                barFill = YES;
                [self.dropColor set];
                barRect = CGRectMake(xPosition,
                                     MPlotGetYPositionInRect(rect, open, maxPrice, minPrice),
                                     barWidth,
                                     MPlotGetHeight(rect, open - close, maxPrice, minPrice));
            }
            else {
                [self.flatColor set];
                barRect = CGRectMake(xPosition,
                                     MPlotGetYPositionInRect(rect, open, maxPrice, minPrice) - 1.0,
                                     barWidth,
                                     1.0);
            }
        }
        //是否填充
        if (barFill) {
            CGContextFillRect(context, barRect);
        }
        else {
            CGContextAddRect(context, barRect);
        }
        if (high != low) {
            //两种情况，如果都是填充就没必要区分两种情况了
            if (CGRectEqualToRect(barRect, CGRectZero)) {
                CGContextMoveToPoint(context,
                                     xPosition + (barWidth / 2),
                                     MPlotGetYPositionInRect(rect, high, maxPrice, minPrice));
                CGContextAddLineToPoint(context,
                                        xPosition + (barWidth / 2),
                                        MPlotGetYPositionInRect(rect, low, maxPrice, minPrice));
            }
            else {
                CGContextMoveToPoint(context,
                                     xPosition + (barWidth / 2),
                                     MPlotGetYPositionInRect(rect, high, maxPrice, minPrice));
                CGContextAddLineToPoint(context,
                                        xPosition + (barWidth / 2),
                                        CGRectGetMinY(barRect));
                CGContextMoveToPoint(context,
                                     xPosition + (barWidth / 2),
                                     CGRectGetMaxY(barRect));
                CGContextAddLineToPoint(context,
                                        xPosition + (barWidth / 2),
                                        MPlotGetYPositionInRect(rect, low, maxPrice, minPrice));
            }
        }
        CGContextStrokePath(context);
        CGContextRestoreGState(context);
    }
    
    //每个参数对应画的线（一个点一个点）
    for (int i = 0; i < [self numberOfDisplayValue]; i++) {
        double ma;
        if ((ma = pValues[i][recordIndex]) > 0) {
            CGPoint point = CGPointMake(xPosition + (barWidth / 2),
                                        MPlotGetYPositionInRect(rect, ma, maxPrice, minPrice));
            if (firstDrawing[i]) {
                firstDrawing[i] = NO;
                MPlotBezierPathMoveToPoint(paths[i], point);
            }
            else {
                MPlotBezierPathAddLineToPoint(paths[i], point);
            }
        }
    }
}

@end


#pragma mark - BOLL

@implementation MBOLLPlot

#pragma mark override

- (void)setupDefaultValue {
    params[0] = 20; params[1] = 2;
}

#pragma mark life cycle
#pragma mark -- BOOL公式 --
- (void)beginCalculateParameter {
    [super beginCalculateParameter];
    
    NSInteger numberOfRecords = [self numberOfRecords];
    //中轨线=N日的移动平均线   上轨线=中轨线＋两倍的标准差   下轨线=中轨线－两倍的标准差
    //（1）计算MA   MA=N日内的收盘价之和÷N  （2）计算标准差MD   MD=平方根(N-1)日的（C－MA）的两次方之和除以N    （3）计算MB、UP、DN线   MB=（N－1）日的MA   UP=MB＋k×MD   DN=MB－k×MD   （K为参数，可根据股票的特性来做相应的调整，一般默认为2）
    for (int idx = 0; idx < numberOfRecords; idx++) {
        //继承有MA,所以先走MA，获取pValues[0]
        if (idx > (params[0] - 2)) {
            //mid = pValues[0][idx]
            double sqsum = 0;
            for (int j = idx; j > idx - params[0]; j--) {
                if (j < 0) break;
                double close = [self itemAtRecordIndex:j].closePrice.doubleValue;
                double sq = close - pValues[0][idx];
                sqsum += sq*sq;
            }
            double md = 0;
            if (params[1] != 0) {
//                sqrt用来计算一个非负实数的平方根
                md = sqrt((sqsum / (double)params[0]));
            }
            pValues[1][idx] = pValues[0][idx] + params[1]*md;
            pValues[2][idx] = pValues[0][idx] - params[1]*md;
            
        }
    }
}

#pragma mark getter

- (NSString *)title {
    return @"BOLL";
}

- (NSUInteger)numberOfDisplayValue {
    return 3;
}

#pragma mark MPlotDrawing

- (NSUInteger)numberOfParams {
    if ([super numberOfParams]) return [super numberOfParams];
    return 2;
}

#pragma mark Override

- (void)displayEnquiredInformationAtIndex:(NSInteger)index {
    NSUInteger numberOfRecords = [self numberOfRecords];
    for (int i = 0; i < [self numberOfDisplayValue]; i++) {
        UILabel *label = self.valueLabels[i];
        NSMutableString *format = nil;
        switch (i) {
            case 0:
                format = [NSMutableString stringWithFormat:@"MID:"];
                break;
            case 1:
                format = [NSMutableString stringWithFormat:@"UP:"];
                break;
            case 2:
                format = [NSMutableString stringWithFormat:@"DN:"];
                break;
            default:
                return;
        }
        
        if (numberOfRecords) {
            [format appendString:[self labelStringFormat]];
            if (index == NSNotFound) {
                label.text = [NSString stringWithFormat:format, MPlotDouble(pValues[i][[self numberOfRecords] - 1])];
            } else {
                label.text = [NSString stringWithFormat:format, MPlotDouble(pValues[i][index])];
            }
        }
        else {
            label.text = [format stringByAppendingString:kValueNilDefaultString];
        }
    }
    [self layoutValueLabelSizeToFit];
}

@end


#pragma mark - VOL

@implementation MVOLPlot
@dynamic maxVolume;

#pragma mark init

- (instancetype)initWithYAxisLabelCount:(NSInteger)yAxisLabelCount {
    return [self initWithYAxisLabelCount:yAxisLabelCount barFill:NO];
}

- (instancetype)initWithYAxisLabelCount:(NSInteger)yAxisLabelCount barFill:(BOOL)barFill {
    self = [super initWithYAxisLabelCount:yAxisLabelCount];
    if (self) {
        _barFill = barFill;
        
        self.enquiredInfomationDisplayFormat = ^NSString *(CGFloat displayValue) {
            //格式化
            return [MApiFormatter mapi_formatChineseUnitWithValue:displayValue];
        };
        
        __weak MVOLPlot *weakSelf = self;
        __block NSString *unitString = nil;
        super.yAxisDisplayFormat = ^NSString *(CGFloat displayValue) {
            __strong MVOLPlot *strongSelf = weakSelf;
            NSString *formatString = [MApiFormatter mapi_formatChineseUnitWithValue:displayValue
                                                                           maxValue:strongSelf.maxVolume];
            
            static NSString * const units[3] = {@"", @"万", @"亿"};
            for (int i = 0; i < 3; i++) {
                if (strongSelf.maxVolume == displayValue &&
                    [formatString rangeOfString:units[i]].location != NSNotFound) {
                    unitString = units[i];
                }
                formatString = [formatString stringByReplacingOccurrencesOfString:units[i] withString:@""];
            }
            
            if (displayValue == 0) {
                return [unitString stringByAppendingString:@"手"];
            }
            
            return formatString;
        };
    }
    return self;
}


#pragma mark override

- (void)setupDefaultValue {

}


#pragma mark setter

- (void)setBarFill:(BOOL)barFill {
    _barFill = barFill;
    [self.drawingTarget reloadData];
}


#pragma mark getter

- (NSString *)title {
    return @"VOL";
}

- (NSString *)labelStringFormat {
    return @"%.0f";
}

- (UIColor *)flatColor {
    if (!_flatColor) {
        _flatColor = RISE_COLOR;
    }
    return _flatColor;
}

- (UIColor *)riseColor {
    if (!_riseColor) {
        _riseColor = RISE_COLOR;
    }
    return _riseColor;
}

- (UIColor *)dropColor {
    if (!_dropColor) {
        _dropColor = DROP_COLOR;
    }
    return _dropColor;
}

- (double)minValue {
    return 0;
}

- (double)maxValue {
    return self.maxVolume;
}

#pragma mark MPlotDrawing

- (NSUInteger)numberOfParams {
    if ([super numberOfParams]) return [super numberOfParams];
    return 0;
}

- (NSUInteger)numberOfDisplayValue {
    return 1;
}

- (void)willRedrawRect:(CGRect)rect atRecordIndex:(NSInteger)recordIndex numberOfVisibleRecords:(NSInteger)numberOfVisibleRecords {

    NSInteger numberOfRecords = [self numberOfRecords];
    double maxVolume = DBL_MIN;
    for (NSInteger index = recordIndex; index < MIN((recordIndex + numberOfVisibleRecords), numberOfRecords); index++) {
        double volume = [self itemAtRecordIndex:index].tradeVolume.doubleValue;
        maxVolume = MAX(volume, maxVolume);
    }
    self.maxVolume = maxVolume;
}

- (void)drawRect:(CGRect)rect inContext:(CGContextRef)context atRecordIndex:(NSInteger)recordIndex xPosition:(CGFloat)xPosition attributeProvider:(id<MPlotAttributes>__autoreleasing)attributeProvider {
    
    MOHLCItem *item = [self itemAtRecordIndex:recordIndex];
    
    double volume = item.tradeVolume.doubleValue;
    double open = item.openPrice.doubleValue;
    double close = item.closePrice.doubleValue;
    double maxVolume = self.maxVolume;
    double yScale = CGRectGetHeight(rect) / maxVolume;
    CGFloat barWidth = [attributeProvider barWidth];
    
    self.labelMaxValue = maxVolume;
    self.labelMinValue = 0;
    
    BOOL barFill = self.barFill;

    if (close > open) {
        [self.riseColor set];
    }
    else {
        if (close < open) {
            barFill = YES;
            [self.dropColor set];
        }
        else {
            [self.flatColor set];
        }
    }
    
    double yClose = CGRectGetMinY(rect) + CGRectGetHeight(rect) - (volume * yScale);
    CGRect barRect = CGRectMake(xPosition, yClose, barWidth, volume*yScale);
    if (barFill) {
        CGContextFillRect(context, barRect);
    }
    else {
        CGContextStrokeRect(context, barRect);
    }
}


#pragma mark Override

- (void)displayEnquiredInformationAtIndex:(NSInteger)index {
    NSUInteger numberOfRecords = [self numberOfRecords];
    for (int i = 0; i < [self numberOfDisplayValue]; i++) {
        UILabel *label = self.valueLabels[i];
        if (numberOfRecords) {
            if (index == NSNotFound) {
                index = [self numberOfRecords] - 1;
            }
            double volume = [self itemAtRecordIndex:index].tradeVolume.doubleValue;
            if (self.enquiredInfomationDisplayFormat) {
                label.text = self.enquiredInfomationDisplayFormat(volume);
            } else {
                NSString *format = [NSString stringWithFormat:@"%@", [self labelStringFormat]];
                label.text = [NSString stringWithFormat:format, MPlotDouble(volume)];
            }
        }
        else {
            label.text = kValueNilDefaultString;
        }
    }
    [self layoutValueLabelSizeToFit];
}

@end

#pragma mark - AMO

@implementation MAMOPlot

- (instancetype)initWithYAxisLabelCount:(NSInteger)yAxisLabelCount barFill:(BOOL)barFill {
    self = [super initWithYAxisLabelCount:yAxisLabelCount barFill:barFill];
    if (self) {
        self.enquiredInfomationDisplayFormat = ^NSString *(CGFloat displayValue) {
            return [MApiFormatter mapi_formatChineseAmountWithValue:displayValue];
        };
        
        __weak MAMOPlot *weakSelf = self;
        __block NSString *unitString = nil;
        self.yAxisDisplayFormat = ^NSString *(CGFloat displayValue) {
            __strong MAMOPlot *strongSelf = weakSelf;
            NSString *formatString = [MApiFormatter mapi_formatChineseAmountWithValue:displayValue
                                                                             maxValue:strongSelf.maxVolume];
            
            static NSString * const units[3] = {@"", @"万", @"亿"};
            for (int i = 0; i < 3; i++) {
                if (strongSelf.maxVolume == displayValue &&
                    [formatString rangeOfString:units[i]].location != NSNotFound) {
                    unitString = units[i];
                }
                formatString = [formatString stringByReplacingOccurrencesOfString:units[i] withString:@""];
            }
            
            if (displayValue == 0) {
                return unitString;
            }
            
            return formatString;
        };
    }
    return self;
}

#pragma mark getter

- (NSString *)title {
    return @"AMO";
}

#pragma mark MPlotDrawing

- (void)willRedrawRect:(CGRect)rect atRecordIndex:(NSInteger)recordIndex numberOfVisibleRecords:(NSInteger)numberOfVisibleRecords {
    
    NSInteger numberOfRecords = [self numberOfRecords];
    long long maxVolume = 0;
    for (NSInteger index = recordIndex; index < MIN((recordIndex + numberOfVisibleRecords), numberOfRecords); index++) {
        double volume = [self itemAtRecordIndex:index].amount.doubleValue;
        maxVolume = MAX(volume, maxVolume);
    }
    self.maxVolume = maxVolume;
}

- (void)drawRect:(CGRect)rect inContext:(CGContextRef)context atRecordIndex:(NSInteger)recordIndex xPosition:(CGFloat)xPosition attributeProvider:(id<MPlotAttributes>__autoreleasing)attributeProvider {
    
    MOHLCItem *item = [self itemAtRecordIndex:recordIndex];
    
    double volume = item.amount.doubleValue;
    double open = item.openPrice.doubleValue;
    double close = item.closePrice.doubleValue;
    double maxVolume = self.maxVolume;
    double yScale = CGRectGetHeight(rect) / maxVolume;
    CGFloat barWidth = [attributeProvider barWidth];
    
    self.labelMaxValue = maxVolume;
    self.labelMinValue = 0;
    
    BOOL barFill = self.barFill;
    
    if (close > open) {
        [self.riseColor set];
    }
    else {
        if (close < open) {
            barFill = YES;
            [self.dropColor set];
        }
        else {
            [self.flatColor set];
        }
    }
    
    double yClose = CGRectGetMinY(rect) + CGRectGetHeight(rect) - (volume * yScale);
    CGRect barRect = CGRectMake(xPosition, yClose, barWidth, volume*yScale);
    if (barFill) {
        CGContextFillRect(context, barRect);
    }
    else {
        CGContextStrokeRect(context, barRect);
    }
}

#pragma mark Override

- (void)displayEnquiredInformationAtIndex:(NSInteger)index {
    NSUInteger numberOfRecords = [self numberOfRecords];
    for (int i = 0; i < [self numberOfDisplayValue]; i++) {
        UILabel *label = self.valueLabels[i];
        if (numberOfRecords) {
            if (index == NSNotFound) {
                index = [self numberOfRecords] - 1;
            }
            double volume = [self itemAtRecordIndex:index].amount.doubleValue;
            if (self.enquiredInfomationDisplayFormat) {
                label.text = self.enquiredInfomationDisplayFormat(volume);
            } else {
                NSString *format = [NSString stringWithFormat:@"%@", [self labelStringFormat]];
                label.text = [NSString stringWithFormat:format, MPlotDouble(volume)];
            }
        }
        else {
            label.text = kValueNilDefaultString;
        }
    }
    [self layoutValueLabelSizeToFit];
}

@end

#pragma mark - RSI

@implementation MRSIPlot

#pragma mark override

- (void)setupDefaultValue {
    params[0] = 6; params[1] = 12; params[2] = 24;
}

#pragma mark getter

- (NSString *)title {
    return @"RSI";
}

- (NSString *)labelStringFormat {
    return @"%.2f";
}


#pragma mark life cycle

- (void)beginCalculateParameter {
    [super beginCalculateParameter];
    
    NSInteger numberOfRecords = [self numberOfRecords];

    //// 大智慧算法
    /*
    for (NSInteger i = 0; i < numberOfRecords; i++) {
        for (NSInteger j = 0; j < [self numberOfParams]; j++) {
            if (i < params[j]) {
                continue;
            }
            double sumUp = 0;
            double sumDown = 0;
            if (i == numberOfRecords -2) {
                
            }
            for (NSInteger k = i; k > (i - (params[j])); k--) {
                double close    = [self itemAtRecordIndex:k].closePrice.doubleValue;
                double preClose = [self itemAtRecordIndex:(k - 1)].closePrice.doubleValue;
                if (close > preClose) {
                    sumUp += (close - preClose);
                }
                else if (close < preClose) {
                    sumDown += fabs(close - preClose);
                }
            }
            sumUp = sumUp / params[j];
            sumDown = sumDown / params[j];
            
            double RS = sumUp / sumDown;
            pValues[j][i] = 100 * (RS/(1+RS));
        }
    }
    */
    
    //疑问？跟网上不同
    for (int p = 0; p < [self numberOfParams]; p++) {
        double sumUp, sumDown;
        if (params[p] < numberOfRecords) {
            sumUp = 0; sumDown = 0;
            for (int i = 0; i < params[p] - 1; i++) {
                double close     = [self itemAtRecordIndex:i].closePrice.doubleValue;
                double nextClose = [self itemAtRecordIndex:(i + 1)].closePrice.doubleValue;
                
                if (nextClose > close) {
                    sumUp = (sumUp + (nextClose - close));
                }
                else if (nextClose < close) {
                    sumDown = (sumDown + (close - nextClose));
                }
            }
            if (sumUp == 0) {
                pValues[p][params[p]] = 0;
            }
            else if (sumDown == 0) {
                pValues[p][params[p]] = 100;
            }
            else {
                pValues[p][params[p]] = 100 - 100 / (sumUp / sumDown + 1);
            }
            sumUp = sumUp / params[p];
            sumDown = sumDown / params[p];
            
            for (NSInteger i = params[p] + 1; i < numberOfRecords; i++) {
                double close         = [self itemAtRecordIndex:i].closePrice.doubleValue;
                double previousClose = [self itemAtRecordIndex:(i - 1)].closePrice.doubleValue;
                //上升
                if (close > previousClose) {
                    sumUp = (sumUp * (params[p] - 1) + (close - previousClose)) / params[p];
                    sumDown = sumDown * (params[p] - 1) / params[p];
                }
                else {
                    sumUp = sumUp * (params[p] - 1) / params[p];
                    sumDown = (sumDown * (params[p] - 1) + (previousClose - close)) / params[p];
                }
                if (sumUp + sumDown != 0) {
                    pValues[p][i] = 100 * (sumUp / (sumUp + sumDown));
                }
                else {
                    pValues[p][i] = 50;
                }
            }
        }
    }
}


#pragma mark MPlotDrawing

- (NSUInteger)numberOfParams {
    if ([super numberOfParams]) return [super numberOfParams];
    return 3;
}

- (void)willRedrawRect:(CGRect)rect atRecordIndex:(NSInteger)recordIndex numberOfVisibleRecords:(NSInteger)numberOfVisibleRecords {
    [super willRedrawRect:rect atRecordIndex:recordIndex numberOfVisibleRecords:numberOfVisibleRecords];
//    [self initializePaths];
//    self.maxPrice = 100.0;
//    self.minPrice = 0;
}

- (void)drawRect:(CGRect)rect inContext:(CGContextRef)context atRecordIndex:(NSInteger)recordIndex xPosition:(CGFloat)xPosition attributeProvider:(id<MPlotAttributes>__autoreleasing)attributeProvider {
    
    double minPrice = self.minPrice;
    double maxPrice = self.maxPrice;
    
    double yScale = CGRectGetHeight(rect) / fabs(maxPrice - minPrice);
    
    CGFloat barWidth = [attributeProvider barWidth];
    
    self.labelMaxValue = maxPrice;
    self.labelMinValue = minPrice;
    for (int i = 0; i < [self numberOfDisplayValue]; i++) {
        double ma = pValues[i][recordIndex];
        if (ma > 0 && ma <= maxPrice) {
            CGPoint point = CGPointMake(xPosition + (barWidth / 2),
                                        CGRectGetMinY(rect) + CGRectGetHeight(rect) - (ma - minPrice) * yScale);
            if (firstDrawing[i]) {
                firstDrawing[i] = NO;
                MPlotBezierPathMoveToPoint(paths[i], point);
            } else {
                MPlotBezierPathAddLineToPoint(paths[i], point);
            }
        }
    }
}

@end


#pragma mark - KDJ

@implementation MKDJPlot

#pragma mark override

- (void)setupDefaultValue {
    params[0] = 9; params[1] = 3; params[2] = 3; params[3] = 0;
}

#pragma mark getter

- (NSString *)title {
    return @"KDJ";
}

- (NSString *)labelStringFormat {
    return @"%.2f";
}

#pragma mark life cycle

- (void)beginCalculateParameter {
    [super beginCalculateParameter];
    
    NSInteger numberOfRecords = [self numberOfRecords];
    //KDJ公式：RSV＝(Ct－L9)／(H9－L9)×100 Ct-------当日收盘价L9-------9天内最低价H9-------9天内最高价
    //Kt＝RSV／3＋2×Kt-1／3   Dt＝Kt／3＋2×Dt-1／3    Jt＝3×Dt－2×Kt
    for (NSInteger i = params[0] - 1; i < numberOfRecords; i++) {
        double close = [self itemAtRecordIndex:i].closePrice.doubleValue;
        double RSV;
        double hi = 0;
        double low = 999999;
        for (NSInteger j = i; j >= (i - (params[0] - 1)); j--) {
            MOHLCItem *item = [self itemAtRecordIndex:j];
            double j_high = item.highPrice.doubleValue;
            double j_low  = item.lowPrice.doubleValue;
            if (j_high > hi) hi = j_high;
            if (j_low < low) low = j_low;
        }
        
        if (hi > low) {
            RSV = ((close - low) / (hi - low)) * 100.0;
        }
        else {
            RSV = 0;
        }
        
        double k_ratio32 = (double)(params[1] - 1) / (double)params[1]; //  2/3
        double k_ratio31 = (double)(1) / (double)params[1];             //  1/3
        double d_ratio32 = (double)(params[2] - 1) / (double)params[2]; //  2/3
        double d_ratio31 = (double)(1) / (double)params[2];             //  1/3
        
        // 第一次計算時，前一日的KD皆以50代替
        if (i == params[0]-1) {
            pValues[0][i] = (double)(RSV / (double)params[1] + ((double)params[1] - 1) * 50.0 / (double)params[1]);
            pValues[1][i] = (double)(pValues[0][i] / (double)params[2] + ((double)params[2] - 1) * 50.0 / (double)params[2]);
        }
        else {
            pValues[0][i] = (double)( (pValues[0][i-1] *k_ratio32) + (RSV * k_ratio31) );
            pValues[1][i] = (double)( (pValues[0][i] *d_ratio31) + (pValues[1][i-1] * d_ratio32) );
        }
        pValues[2][i] = [self calculateJWithK:pValues[0][i] andD:pValues[1][i]];
    }
}


#pragma mark private

- (double)calculateJWithK:(double)K andD:(double)D {
    double J = 0;
    //0-->3K-2D, 1-->3D-2K
    if (params[3]==0) {
        J = (double)((3 * K) - (2 * D));
    }
    else {
        J = (double)((3 * D) - (2 * K));
    }
    return J;
}


#pragma mark MPlotDrawing

- (NSUInteger)numberOfParams {
    if ([super numberOfParams]) return [super numberOfParams];
    return 4;
}

- (NSUInteger)numberOfDisplayValue {
    return 3;
}

- (void)willRedrawRect:(CGRect)rect atRecordIndex:(NSInteger)recordIndex numberOfVisibleRecords:(NSInteger)numberOfVisibleRecords {

    [self initializePaths];
    
    NSInteger numberOfRecords = [self numberOfRecords];
    double maxPrice = DBL_MIN;
    double minPrice = DBL_MAX;
    for (NSInteger index = recordIndex; index < MIN((recordIndex + numberOfVisibleRecords), numberOfRecords); index++) {
        for(int i=0; i<[self numberOfParams]; i++)
        {
            if(pValues[i])
            {
                double kdj = pValues[i][index];
//                if(kdj != 0)
                {
                    if(kdj > maxPrice) maxPrice = kdj;
                    if(kdj < minPrice) minPrice = kdj;
                }
            }
        }
    }
    self.maxPrice = maxPrice;
    self.minPrice = minPrice;
}

- (void)drawRect:(CGRect)rect inContext:(CGContextRef)context atRecordIndex:(NSInteger)recordIndex xPosition:(CGFloat)xPosition attributeProvider:(id<MPlotAttributes>__autoreleasing)attributeProvider {
    
    double minPrice = self.minPrice;
    double maxPrice = self.maxPrice;
    double yScale = CGRectGetHeight(rect) / fabs(maxPrice - minPrice);
    CGFloat barWidth = [attributeProvider barWidth];
    
    self.labelMaxValue = maxPrice;
    self.labelMinValue = minPrice;
    for (int i = 0; i < [self numberOfDisplayValue]; i++) {
        double rsi = pValues[i][recordIndex];
        //if (rsi >= 0 && rsi <= maxPrice) {
            CGPoint point = CGPointMake(xPosition + (barWidth / 2),
                                        CGRectGetMinY(rect) + CGRectGetHeight(rect) - (rsi - minPrice) * yScale);
            if (firstDrawing[i]) {
                firstDrawing[i] = NO;
                MPlotBezierPathMoveToPoint(paths[i], point);
            } else {
                MPlotBezierPathAddLineToPoint(paths[i], point);
            }
        //}
    }
}


#pragma mark Override

- (void)displayEnquiredInformationAtIndex:(NSInteger)index {
    NSUInteger numberOfRecords = [self numberOfRecords];
    for (int i = 0; i < [self numberOfDisplayValue]; i++) {
        UILabel *label = self.valueLabels[i];
        NSMutableString *format = nil;
        switch (i) {
            case 0:
                format = [NSMutableString stringWithFormat:@"K%lu:", (unsigned long)params[0]];
                break;
            case 1:
                format = [NSMutableString stringWithFormat:@"D%lu:", (unsigned long)params[0]];
                break;
            case 2:
                format = [NSMutableString stringWithFormat:@"J%lu:", (unsigned long)params[0]];
                break;
            default:
                return;
        }
        
        if (numberOfRecords) {
            [format appendString:[self labelStringFormat]];
            if (index == NSNotFound) {
                label.text = [NSString stringWithFormat:format, MPlotDouble(pValues[i][[self numberOfRecords] - 1])];
            } else {
                label.text = [NSString stringWithFormat:format, MPlotDouble(pValues[i][index])];
            }
        }
        else {
            label.text = [format stringByAppendingString:kValueNilDefaultString];
        }
    }
    [self layoutValueLabelSizeToFit];
}

@end


#pragma mark - MACD

@implementation MMACDPlot {
    double _MACDMaxValue;
    double _MACDMinValue;
}

#pragma mark override

- (void)setupDefaultValue {
    params[0] = 12; params[1] = 26; params[2] = 9;
}


#pragma mark getter

- (NSString *)title {
    return @"MACD";
}

- (NSString *)labelStringFormat {
    return @"%.2f";
}

- (UIColor *)riseColor {
    if (!_riseColor) {
        _riseColor = RISE_COLOR;
    }
    return _riseColor;
}

- (UIColor *)dropColor {
    if (!_dropColor) {
        _dropColor = DROP_COLOR;
    }
    return _dropColor;
}


#pragma mark life cycle
#define MACDPRELEHGTH 38
- (void)beginCalculateParameter {
    [super beginCalculateParameter];
    
    NSInteger numberOfRecords = [self numberOfRecords];
    int nMACDPrelength = 0;
    
    double pEMAN[numberOfRecords];
    double pEMAM[numberOfRecords];
    //获取EMA值
    [self getEMAWithStart:0 withEnd:numberOfRecords - 1 withParam:params[0] withpEMA:(double *)&pEMAN];
    [self getEMAWithStart:0 withEnd:numberOfRecords - 1 withParam:params[1] withpEMA:(double *)&pEMAM];
    //计算离差值（DIF）      DIF=今日EMA（12）－今日EMA（26）
    //今日DEA（MACD） =前一日DEA×8/（9+1）＋今日DIF×2/（9+1）
    double dif, beforeMACD = 0;
    //疑问？nMACDPrelength = 0 还需要for循环？
    for (int n = 0; n <= nMACDPrelength; n++) {
        dif = pEMAN[n] - pEMAM[n];
        if (n == 0) {
            beforeMACD = dif * 2 / (params[2] + 1);
        }
        else {
            beforeMACD = beforeMACD + (dif - beforeMACD) * 2 / (params[2] + 1);
        }
    }
    
    for (int i = 0; i < numberOfRecords ; i++) {
        if (i < 0 || i >= numberOfRecords)
            continue;
        pValues[0][i] = (float)(pEMAN[i + nMACDPrelength] - pEMAM[i + nMACDPrelength]);
        
        if (i == 0) {
            pValues[1][i] = (float)beforeMACD;
        }
        else {
            pValues[1][i] = (float)(pValues[1][i-1] + (pValues[0][i] - pValues[1][i-1]) * 2 / (params[2] + 1));
        }
        
        pValues[2][i] = (pValues[0][i] - pValues[1][i]) * 2;
        
        if (i <= MACDPRELEHGTH)
            continue;
    }
}


#pragma mark private
#pragma mark -- EMA公式 --
- (void)getEMAWithStart:(CGFloat)start withEnd:(CGFloat)end withParam:(CGFloat)Param withpEMA:(double *)pEMA {

    int		i,j,k;
    double	sum;
    BOOL	bStartFlag;
    //EMA:12日EMA的算式为：  EMA（12）=前一日EMA（12）×11/（12+1）＋今日收盘价×2/（12+1）  26日EMA的算式为 ：  EMA（26）=前一日EMA（26）×25/（26+1）＋今日收盘价×2/（26+1）计算涉及到EMA的初值，也就是计算的第一个EMA的值。一般以收盘价代替EMA的初值
    bStartFlag = FALSE;
    for (i = start; i <= end; i++) {
        MOHLCItem *item = [self itemAtRecordIndex:i];
        double high  = item.highPrice.doubleValue;
        double low   = item.lowPrice.doubleValue;
        double close = item.closePrice.doubleValue;

        k = i - start;
        if (bStartFlag) {
            pEMA[k] = (pEMA[k-1]*(double)(Param-1)/ (double)(Param+1)) + (close * 2 / (double)(Param+1));
        }
        else {
            double di = (high + low + (close * 2)) / 4;
            sum = 0;
            //疑问？前几个就是di值，为什么还要写？
            for (j = 0; j < Param; j++) {
                if (k - j < 0) {
                    break;
                }
                sum += di;
            }
            
            if (j != 0) {
                pEMA[k] = sum / (double)j;
            }
            else {
                pEMA[k] = 0;
            }
            
            if (j >= Param) {
                bStartFlag = TRUE;
            }
        }
    }
}


#pragma mark MPlotDrawing

- (NSUInteger)numberOfParams {
    if ([super numberOfParams]) return [super numberOfParams];
    return 3;
}

- (void)willRedrawRect:(CGRect)rect atRecordIndex:(NSInteger)recordIndex numberOfVisibleRecords:(NSInteger)numberOfVisibleRecords {

    [self initializePaths];
    
    NSInteger numberOfRecords = [self numberOfRecords];
    double maxPrice = DBL_MIN;
    double minPrice = DBL_MAX;
    for (NSInteger index = recordIndex; index < MIN((recordIndex + numberOfVisibleRecords), numberOfRecords); index++) {
        for (int i = 0; i < [self numberOfDisplayValue]; i++) {
            if (pValues[i]) {
                double macd = pValues[i][index];
                if (macd != 0) {
                    if(macd > maxPrice) maxPrice = macd;
                    if(macd < minPrice) minPrice = macd;
                    if (maxPrice < 0 && minPrice < 0) {
                        maxPrice = 0;
                    }
                }
                
                /// MACD柱狀圖
                if (i == [self numberOfDisplayValue] - 1) {
                    _MACDMaxValue = MAX(_MACDMaxValue, macd);
                    _MACDMinValue = MIN(_MACDMinValue, macd);
                }
            }
        }
    }
    self.maxPrice = maxPrice;
    self.minPrice = MIN(0, minPrice);
}

- (void)drawRect:(CGRect)rect inContext:(CGContextRef)context atRecordIndex:(NSInteger)recordIndex xPosition:(CGFloat)xPosition attributeProvider:(id<MPlotAttributes>__autoreleasing)attributeProvider {
    
    double minPrice = self.minPrice;
    double maxPrice = self.maxPrice;
    CGFloat barWidth = [attributeProvider barWidth];
    
    self.labelMaxValue = maxPrice;
    self.labelMinValue = minPrice;
    
    double macd = 0;
    //蜡烛图值
    if ((macd = pValues[2][recordIndex]) > 0) {
        [self.riseColor set];
    }
    else {
        [self.dropColor set];
    }
    
    double zeroPosY = MPlotGetYPositionInRect(rect, 0, maxPrice, minPrice);
    CGContextFillRect(context, CGRectMake(xPosition,
                                          zeroPosY,
                                          barWidth,
                                          MPlotGetYPositionInRect(rect, macd, maxPrice, minPrice) - zeroPosY)
                      );

    for (int i = 0; i < [self numberOfDisplayValue] - 1; i++) {
        macd = pValues[i][recordIndex];
        CGPoint point = CGPointMake(xPosition + (barWidth / 2),
                                    MPlotGetYPositionInRect(rect, macd, maxPrice, minPrice));
        if (firstDrawing[i]) {
            firstDrawing[i] = NO;
            MPlotBezierPathMoveToPoint(paths[i], point);
        }
        else {
            MPlotBezierPathAddLineToPoint(paths[i], point);
        }
    }
}
#pragma mark -- 结束MA绘制 这个没有，全走父类方法--
- (void)endDrawingContext:(CGContextRef)context {
    for (int i = 0; i < [self numberOfDisplayValue] - 1; i++) {
        UIColor *color = [self colorAtIndex:i];
        CGContextSetStrokeColorWithColor(context, color.CGColor);
        if (paths[i]) {
            [paths[i] stroke];
        }
    }
}


#pragma mark Override 

- (void)displayEnquiredInformationAtIndex:(NSInteger)index {
    NSUInteger numberOfRecords = [self numberOfRecords];
    for (int i = 0; i < [self numberOfDisplayValue]; i++) {
        UILabel *label = self.valueLabels[i];
        NSMutableString *format = nil;
        switch (i) {
            case 0:
                format = [NSMutableString stringWithFormat:@"DIF:"];
                break;
            case 1:
                format = [NSMutableString stringWithFormat:@"DEA:"];
                break;
            case 2:
                format = [NSMutableString stringWithFormat:@"M:"];
                break;
            default:
                return;
        }
        
        if (numberOfRecords) {
            [format appendString:[self labelStringFormat]];
            if (index == NSNotFound) {
                label.text = [NSString stringWithFormat:format, MPlotDouble(pValues[i][[self numberOfRecords] - 1])];
            } else {
                label.text = [NSString stringWithFormat:format, MPlotDouble(pValues[i][index])];
            }
        }
        else {
            label.text = [format stringByAppendingString:kValueNilDefaultString];
        }
    }
    [self layoutValueLabelSizeToFit];
}

@end


#pragma mark - BIAS

@implementation MBIASPlot

#pragma mark override

- (void)setupDefaultValue {
    params[0] = 5; params[1] = 10; params[2] = 20;
}

#pragma mark getter

- (NSString *)title {
    return @"BIAS";
}

- (NSString *)labelStringFormat {
    return @"%.2f";
}


#pragma mark life cycle

- (void)beginCalculateParameter {
    [super beginCalculateParameter];
    
    NSInteger numberOfRecords = [self numberOfRecords];
    //乖离率=[(当日收盘价-N日平均价)/N日平均价]*100%
    double sum, ave;
    ave = 0.;
    for (int m = 0; m < [self numberOfParams]; m++) {
        for (int i = 0; i < numberOfRecords; i++) {
            sum = 0.;
            for (int j = i; j > (i - params[m]); j--) {
                double close = [self itemAtRecordIndex:j].closePrice.doubleValue;
                sum += close;
            }
            if (params[m] == 0) {
                break;
            }
            else {
                ave = sum / params[m];
            }
            
            if(ave == 0) {
                pValues[m][i] = 0;
            }
            else {
                double close = [self itemAtRecordIndex:i].closePrice.doubleValue;
                pValues[m][i] = 100.0 * (close - ave) / ave;
            }
        }
    }
    
}


#pragma mark MPlotDrawing

- (NSUInteger)numberOfParams {
    if ([super numberOfParams]) return [super numberOfParams];
    return 3;
}

//- (void)willRedrawRect:(CGRect)rect atRecordIndex:(NSInteger)recordIndex numberOfVisibleRecords:(NSInteger)numberOfVisibleRecords { // Override if needed. }

- (void)drawRect:(CGRect)rect inContext:(CGContextRef)context atRecordIndex:(NSInteger)recordIndex xPosition:(CGFloat)xPosition attributeProvider:(id<MPlotAttributes>__autoreleasing)attributeProvider {
    
    double minPrice = self.minPrice;
    double maxPrice = self.maxPrice;
    double yScale = CGRectGetHeight(rect) / fabs(maxPrice - minPrice);
    CGFloat barWidth = [attributeProvider barWidth];
    
    self.labelMaxValue = maxPrice;
    self.labelMinValue = minPrice;
    
    double bias = 0;
    
    for (int i = 0; i < [self numberOfDisplayValue]; i++) {
        if ((bias = pValues[i][recordIndex]) <= maxPrice) {
            CGPoint point = CGPointMake(xPosition + (barWidth / 2),
                                        CGRectGetMinY(rect) + CGRectGetHeight(rect) - (bias - minPrice) * yScale);
            if (firstDrawing[i]) {
                firstDrawing[i] = NO;
                MPlotBezierPathMoveToPoint(paths[i], point);
            }
            else {
                MPlotBezierPathAddLineToPoint(paths[i], point);
            }
        }
    }
}

@end


#pragma mark - CCI

@implementation MCCIPlot

#pragma mark override

- (void)setupDefaultValue {
    params[0] = 14;
}

#pragma mark getter

- (NSString *)title {
    return @"CCI";
}

- (NSString *)labelStringFormat {
    return @"%.2f";
}


#pragma mark life cycle

- (void)beginCalculateParameter {
    [super beginCalculateParameter];
//????: 陸股這邊參數是14?
    NSInteger numberOfRecords = [self numberOfRecords];
    
    double factor = params[0];
    //CCI公式：CCI（N日）=（AP－MA）÷MD÷0.015其中，AP=（最高价+最低价+收盘价）÷3 MA=近N日收盘价的累计之和÷N  MD=近N日（MA－收盘价）的累计之和÷N   0.015为计算系数，N为计算周期
    double *APs = (double *)malloc(numberOfRecords * sizeof(double));
    //将已开辟内存空间 APs 的首 numberOfRecords 个字节的值设为值 0
    memset(APs, 0, numberOfRecords);
    double *MAPs = (double *)malloc(numberOfRecords * sizeof(double));
    memset(MAPs, 0, numberOfRecords);
    double *MDs = (double *)malloc(numberOfRecords * sizeof(double));
    memset(MDs, 0, numberOfRecords);
    
    // 計算APs
    for (int i = 0; i < numberOfRecords; i++) {
        MOHLCItem *item = [self itemAtRecordIndex:i];
        double high = item.highPrice.doubleValue;
        double low = item.lowPrice.doubleValue;
        double close = item.closePrice.doubleValue;
        
        APs[i] = (high + low + close) / 3.;
        if (i >= factor) {
            // 計算MAPs
            double totalAP = 0.;
            for (int j = i; j > (i - factor); j--) {
                totalAP += APs[j];
            }
            MAPs[i] = totalAP / factor;

            // 計算MDs
            double totalMD = 0.;
            for (int j = i; j > (i - factor); j--) {
                totalMD += fabs(APs[j] - MAPs[i]);
            }
            MDs[i] = totalMD / factor;

            if (MDs[i] > 0.) {
                double upValue = APs[i] - MAPs[i];
                double dnValue = 0.015 * MDs[i];
                pValues[0][i] = upValue / dnValue;
            }
        }

    }
    //14之前默认值 = 0
    free(MDs);MDs = NULL;
    free(MAPs);MAPs = NULL;
    free(APs);APs = NULL;
}


#pragma mark MPlotDrawing

- (NSUInteger)numberOfParams {
    if ([super numberOfParams]) return [super numberOfParams];
    return 1;
}

//- (void)willRedrawRect:(CGRect)rect atRecordIndex:(NSInteger)recordIndex numberOfVisibleRecords:(NSInteger)numberOfVisibleRecords { //Override if needed. }

- (void)drawRect:(CGRect)rect inContext:(CGContextRef)context atRecordIndex:(NSInteger)recordIndex xPosition:(CGFloat)xPosition attributeProvider:(id<MPlotAttributes>__autoreleasing)attributeProvider {
    
    double minPrice = self.minPrice;
    double maxPrice = self.maxPrice;
    double yScale = CGRectGetHeight(rect) / fabs(maxPrice - minPrice);
    CGFloat barWidth = [attributeProvider barWidth];
    
    self.labelMaxValue = maxPrice;
    self.labelMinValue = minPrice;
    
    double cci = 0;
    
    for (int i = 0; i < [self numberOfDisplayValue]; i++) {
        if ((cci = pValues[i][recordIndex]) <= maxPrice) {
            CGPoint point = CGPointMake(xPosition + (barWidth / 2),
                                        CGRectGetMinY(rect) + CGRectGetHeight(rect) - (cci - minPrice) * yScale);
            if (firstDrawing[i]) {
                firstDrawing[i] = NO;
                MPlotBezierPathMoveToPoint(paths[i], point);
            }
            else {
                MPlotBezierPathAddLineToPoint(paths[i], point);
            }
        }
    }
}

@end


#pragma mark - WR

@implementation MWRPlot

#pragma mark override

- (void)setupDefaultValue {
    params[0] = 10; params[1] = 5;
}

#pragma mark getter

- (NSString *)title {
    return @"WR";
}

- (NSString *)labelStringFormat {
    return @"%.2f";
}


#pragma mark life cycle

- (void)beginCalculateParameter {
    [super beginCalculateParameter];
    
    NSInteger numberOfRecords = [self numberOfRecords];
    //WR公式：WR1一般是10天买卖强弱指标；以N日威廉指标为例，WR(N) = 100 * [ HIGH(N)-C ] / [ HIGH(N)-LOW(N) ]C：当日收盘价 HIGH(N)：N日内的最高价  LOW(n)：N日内的最低价
    for (int m = 0; m < [self numberOfParams]; m++) {
        for (int i = 0; i < numberOfRecords; i++) {
            if (i >= params[m]) {
                double maxHigh = DBL_MIN;
                double maxLow = DBL_MAX;
                
                for (int j = i; j > (i - params[m]); j--) {
                    MOHLCItem *item = [self itemAtRecordIndex:j];
                    double high = item.highPrice.doubleValue;
                    double low = item.lowPrice.doubleValue;
                    if (high > maxHigh) maxHigh = high;
                    if (low < maxLow) maxLow = low;
                }
                double close = [self itemAtRecordIndex:i].closePrice.doubleValue;
                pValues[m][i] = 100.0 * ((maxHigh - close) / (maxHigh - maxLow));
            }
            else {
                pValues[m][i] = 0;
            }
        }
    }
}


#pragma mark MPlotDrawing

- (NSUInteger)numberOfParams {
    if ([super numberOfParams]) return [super numberOfParams];
    return 2;
}

//- (void)willRedrawRect:(CGRect)rect atRecordIndex:(NSInteger)recordIndex numberOfVisibleRecords:(NSInteger)numberOfVisibleRecords { // Override if needed. }

- (void)drawRect:(CGRect)rect inContext:(CGContextRef)context atRecordIndex:(NSInteger)recordIndex xPosition:(CGFloat)xPosition attributeProvider:(id<MPlotAttributes>__autoreleasing)attributeProvider {
    
    double minPrice = self.minPrice;
    double maxPrice = self.maxPrice;
    double yScale = CGRectGetHeight(rect) / fabs(maxPrice - minPrice);
    CGFloat barWidth = [attributeProvider barWidth];
    
    self.labelMaxValue = maxPrice;
    self.labelMinValue = minPrice;
    
    for (int i = 0; i < [self numberOfDisplayValue]; i++) {
        if (recordIndex >= params[i]) {
            double wr = pValues[i][recordIndex];
            CGPoint point = CGPointMake(xPosition + (barWidth / 2),
                                        CGRectGetMinY(rect) + CGRectGetHeight(rect) - (wr - minPrice) * yScale);
            if (firstDrawing[i]) {
                firstDrawing[i] = NO;
                MPlotBezierPathMoveToPoint(paths[i], point);
            }
            else {
                MPlotBezierPathAddLineToPoint(paths[i], point);
            }
        }
    }
}

@end


#pragma mark - AD

@interface MADPlot : MPlot

@end

@implementation MADPlot

#pragma mark override

- (void)setupDefaultValue {
    params[0] = 5;
}

#pragma mark getter

- (NSString *)title {
    return @"AD";
}

- (NSString *)labelStringFormat {
    return @"%.2f";
}


#pragma mark life cycle
/// CLV:2*收盤價-最高價-最低價 (若最高價=最低價,CLV=0)
/// ADV(今日ADV=昨日ADV+成交量*CLV)
- (void)beginCalculateParameter {
    [super beginCalculateParameter];
    
    NSInteger numberOfRecords = [self numberOfRecords];
    
    for (int i = 0; i < numberOfRecords; i++) {
        MOHLCItem *item = [self itemAtRecordIndex:i];
        double high = item.highPrice.doubleValue;
        double low = item.lowPrice.doubleValue;
        double close = item.closePrice.doubleValue;
        double volume = item.tradeVolume.doubleValue;
        double CLV = 0.;
        if (low == high) {
            CLV = 0;
        }
        else {
            CLV = ((2 * close) - high - low);
        }
        
        if (i==0) {
            pValues[0][i] = volume * CLV;
        }
        else {
            pValues[0][i] = pValues[0][i-1] + (volume * CLV);
        }
    }
}


#pragma mark MPlotDrawing

- (NSUInteger)numberOfParams {
    if ([super numberOfParams]) return [super numberOfParams];
    return 0;
}

- (NSUInteger)numberOfDisplayValue {
    return 1;
}

//- (void)willRedrawRect:(CGRect)rect atRecordIndex:(NSInteger)recordIndex numberOfVisibleRecords:(NSInteger)numberOfVisibleRecords { // Override if needed. }

- (void)drawRect:(CGRect)rect inContext:(CGContextRef)context atRecordIndex:(NSInteger)recordIndex xPosition:(CGFloat)xPosition attributeProvider:(id<MPlotAttributes>__autoreleasing)attributeProvider {
    
    double minPrice = self.minPrice;
    double maxPrice = self.maxPrice;
    double yScale = CGRectGetHeight(rect) / fabs(maxPrice - minPrice);
    CGFloat barWidth = [attributeProvider barWidth];
    
    self.labelMaxValue = maxPrice;
    self.labelMinValue = minPrice;
    
    for (int i = 0; i < [self numberOfDisplayValue]; i++) {
        double wr = pValues[i][recordIndex];
        CGPoint point = CGPointMake(xPosition + (barWidth / 2),
                                    CGRectGetMinY(rect) + CGRectGetHeight(rect) - (wr - minPrice) * yScale);
        if (firstDrawing[i]) {
            firstDrawing[i] = NO;
            MPlotBezierPathMoveToPoint(paths[i], point);
        }
        else {
            MPlotBezierPathAddLineToPoint(paths[i], point);
        }
    }
}

@end


#pragma mark - AR

@implementation MARPlot

#pragma mark override

- (void)setupDefaultValue {
    params[0] = 13; params[1] = 26;
}

#pragma mark getter

- (NSString *)title {
    return @"AR";
}

- (NSString *)labelStringFormat {
    return @"%.2f";
}


#pragma mark life cycle

- (void)beginCalculateParameter {
    [super beginCalculateParameter];
    //AR=N日内（当日最高价—当日开市价）之和 / N日内（当日开市价—当日最低价）之和
    NSInteger numberOfRecords = [self numberOfRecords];
    
    double sum1, sum2;
    for (int i = 0; i < numberOfRecords; i++) {
        for (int m = 0; m < [self numberOfParams]; m++) {
            sum1 = 0;
            sum2 = 0;
            if (i >= params[m]) {
                for (int j = i; j > (i - params[m]); j--) {
                    MOHLCItem *item = [self itemAtRecordIndex:j];
                    double high = item.highPrice.doubleValue;
                    double low = item.lowPrice.doubleValue;
                    double open = item.openPrice.doubleValue;
                    sum1 += high - open;
                    sum2 += open - low;
                }
                
                if(sum2 == 0) {
                    pValues[m][i] = -10000.0;
                    break;
                }
                else {
                    pValues[m][i] = (sum1 / sum2) * 100.0;
                }
            }
        }
    }
}


#pragma mark MPlotDrawing

- (NSUInteger)numberOfParams {
    if ([super numberOfParams]) return [super numberOfParams];
    return 2;
}

//- (void)willRedrawRect:(CGRect)rect atRecordIndex:(NSInteger)recordIndex numberOfVisibleRecords:(NSInteger)numberOfVisibleRecords { // Override if needed. }

- (void)drawRect:(CGRect)rect inContext:(CGContextRef)context atRecordIndex:(NSInteger)recordIndex xPosition:(CGFloat)xPosition attributeProvider:(id<MPlotAttributes>__autoreleasing)attributeProvider {
    
    double minPrice = self.minPrice;
    double maxPrice = self.maxPrice;
    double yScale = CGRectGetHeight(rect) / fabs(maxPrice - minPrice);
    CGFloat barWidth = [attributeProvider barWidth];
    
    self.labelMaxValue = maxPrice;
    self.labelMinValue = minPrice;
    
    for (int i = 0; i < [self numberOfDisplayValue]; i++) {
        if (recordIndex >= params[0]) {
            double ar = pValues[i][recordIndex];
            CGPoint point = CGPointMake(xPosition + (barWidth / 2),
                                        CGRectGetMinY(rect) + CGRectGetHeight(rect) - (ar - minPrice) * yScale);
            if (firstDrawing[i]) {
                firstDrawing[i] = NO;
                MPlotBezierPathMoveToPoint(paths[i], point);
            }
            else {
                MPlotBezierPathAddLineToPoint(paths[i], point);
            }
        }
    }
}

@end


#pragma mark - BBI

@implementation MBBIPlot

#pragma mark override

- (void)setupDefaultValue {
    params[0] = 3; params[1] = 6; params[2] = 12; params[3] = 24;
}

#pragma mark getter

- (NSString *)title {
    return @"BBI";
}

- (NSString *)labelStringFormat {
    return @"%.2f";
}


#pragma mark life cycle
/// BBI (3日均+6日均+12日均+24日均)/4
- (void)beginCalculateParameter {
    [super beginCalculateParameter];
    
    NSInteger numberOfRecords = [self numberOfRecords];
    
    for (int i = 0; i < numberOfRecords; i++) {
        if (i >= params[0] && i >= params[1] && i >= params[2] && i >= params[3]) {
            double close = [self itemAtRecordIndex:i].closePrice.doubleValue;

            pValues[0][i] = close;
            /// TODO: 优化for loop
            double ma3 = 0, ma6 = 0, ma12 = 0, ma24 = 0;
            for (int j = i; j > (i - params[0]); j--) {
                ma3 += [self itemAtRecordIndex:j].closePrice.doubleValue;
            }
            ma3 /= params[0];
            
            for (int j = i; j > (i - params[1]); j--) {
                ma6 += [self itemAtRecordIndex:j].closePrice.doubleValue;
            }
            ma6 /= params[1];
            
            for (int j = i; j > (i - params[2]); j--) {
                ma12 += [self itemAtRecordIndex:j].closePrice.doubleValue;
            }
            ma12 /= params[2];
            
            for (int j = i; j > (i - params[3]); j--) {
                ma24 += [self itemAtRecordIndex:j].closePrice.doubleValue;
            }
            ma24 /= params[3];
            
            //BBI
            pValues[0][i] = (ma3 + ma6 + ma12 + ma24) / 4.0;
        }
        else {
//            pValues[0][i] = [[self objectAtRecordIndex:i field:MPlotFieldClose] doubleValue];
        }
    }
}


#pragma mark MPlotDrawing

- (NSUInteger)numberOfParams {
    if ([super numberOfParams]) return [super numberOfParams];
    return 4;
}

- (NSUInteger)numberOfDisplayValue {
    return 1;
}

//- (void)willRedrawRect:(CGRect)rect atRecordIndex:(NSInteger)recordIndex numberOfVisibleRecords:(NSInteger)numberOfVisibleRecords { // Override if needed. }

- (void)drawRect:(CGRect)rect inContext:(CGContextRef)context atRecordIndex:(NSInteger)recordIndex xPosition:(CGFloat)xPosition attributeProvider:(id<MPlotAttributes>__autoreleasing)attributeProvider {
    
    double minPrice = self.minPrice;
    double maxPrice = self.maxPrice;
    double yScale = CGRectGetHeight(rect) / fabs(maxPrice - minPrice);
    if (isinf(yScale)) {
        return;
    }
    
    CGFloat barWidth = [attributeProvider barWidth];
    
    self.labelMaxValue = maxPrice;
    self.labelMinValue = minPrice;
    
    double ar = pValues[0][recordIndex];
    if (ar != 0) {
        CGPoint point = CGPointMake(xPosition + (barWidth / 2),
                                    CGRectGetMinY(rect) + CGRectGetHeight(rect) - (ar - minPrice) * yScale);
        if (firstDrawing[0]) {
            firstDrawing[0] = NO;
            MPlotBezierPathMoveToPoint(paths[0], point);
        }
        else {
            MPlotBezierPathAddLineToPoint(paths[0], point);
        }
    }
}


#pragma mark Override

- (void)displayEnquiredInformationAtIndex:(NSInteger)index {
    NSUInteger numberOfRecords = [self numberOfRecords];
    for (int i = 0; i < [self numberOfDisplayValue]; i++) {
        UILabel *label = self.valueLabels[i];
        NSMutableString *format = nil;
        switch (i) {
            case 0:
                format = [NSMutableString stringWithFormat:@"BBI:"];
                break;
            default:
                return;
        }
        
        if (numberOfRecords) {
            [format appendString:[self labelStringFormat]];
            if (index == NSNotFound) {
                label.text = [NSString stringWithFormat:format, MPlotDouble(pValues[i][[self numberOfRecords] - 1])];
            } else {
                label.text = [NSString stringWithFormat:format, MPlotDouble(pValues[i][index])];
            }
        }
        else {
            label.text = [format stringByAppendingString:kValueNilDefaultString];
        }
    }
    [self layoutValueLabelSizeToFit];
}

@end


#pragma mark - BR

@implementation MBRPlot

#pragma mark override

- (void)setupDefaultValue {
    params[0] = 13; params[1] = 26;
}

#pragma mark getter

- (NSString *)title {
    return @"BR";
}

- (NSString *)labelStringFormat {
    return @"%.2f";
}


#pragma mark life cycle
/// Ｎ日內SUM（最高－昨收）/Ｎ日內SUM（昨收－最低）*100
- (void)beginCalculateParameter {
    [super beginCalculateParameter];
    
    NSInteger numberOfRecords = [self numberOfRecords];
    
    double sum1, sum2;
    for (int i = 0; i < numberOfRecords; i++) {
        for (int m = 0; m < [self numberOfParams]; m++) {
            sum1 = 0;
            sum2 = 0;
            if (i >= params[m]) {
                for (int j = i; j > (i - params[m]); j--) {
                    MOHLCItem *item = [self itemAtRecordIndex:j];
                    double high = item.highPrice.doubleValue;
                    double low = item.lowPrice.doubleValue;
                    double pre_close = [self itemAtRecordIndex:(j - 1)].closePrice.doubleValue;
                    sum1 += high - pre_close;
                    sum2 += pre_close - low;
                }
                
                if(sum2 == 0) {
                    pValues[m][i] = -10000.0;
                    break;
                }
                else {
                    pValues[m][i] = (sum1 / sum2) * 100.0;
                }
            }
        }
    }
}


#pragma mark MPlotDrawing

- (NSUInteger)numberOfParams {
    if ([super numberOfParams]) return [super numberOfParams];
    return 2;
}

//- (void)willRedrawRect:(CGRect)rect atRecordIndex:(NSInteger)recordIndex numberOfVisibleRecords:(NSInteger)numberOfVisibleRecords { /* Override if needed. */}

- (void)drawRect:(CGRect)rect inContext:(CGContextRef)context atRecordIndex:(NSInteger)recordIndex xPosition:(CGFloat)xPosition attributeProvider:(id<MPlotAttributes>__autoreleasing)attributeProvider {
    
    double minPrice = self.minPrice;
    double maxPrice = self.maxPrice;
    double yScale = CGRectGetHeight(rect) / fabs(maxPrice - minPrice);
    CGFloat barWidth = [attributeProvider barWidth];
    
    self.labelMaxValue = maxPrice;
    self.labelMinValue = minPrice;
    
    for (int i = 0; i < [self numberOfDisplayValue]; i++) {
        if (recordIndex >= params[i]) {
            double br = pValues[i][recordIndex];
            CGPoint point = CGPointMake(xPosition + (barWidth / 2),
                                        CGRectGetMinY(rect) + CGRectGetHeight(rect) - (br - minPrice) * yScale);
            if (firstDrawing[i]) {
                firstDrawing[i] = NO;
                MPlotBezierPathMoveToPoint(paths[i], point);
            }
            else {
                MPlotBezierPathAddLineToPoint(paths[i], point);
            }
        }
    }
}

@end


#pragma mark - KD

@implementation MKDPlot

#pragma mark override

- (void)setupDefaultValue {
    params[0] = 9;
}

#pragma mark getter

- (NSString *)title {
    return @"KD";
}

- (NSString *)labelStringFormat {
    return @"%.2f";
}


#pragma mark life cycle

- (void)beginCalculateParameter {
    [super beginCalculateParameter];
    
    NSInteger numberOfRecords = [self numberOfRecords];
    //kd公式：参考KDJ公式
    for (NSInteger i = params[0]-1; i < numberOfRecords; i++) {
        double RSV;
        double maxHigh = 0;
        double minLow = 999999;
        
        for(NSInteger j = i; j >= (i - (params[0]-1)); j--) {
            MOHLCItem *item = [self itemAtRecordIndex:j];
            double high = item.highPrice.doubleValue;
            double low = item.lowPrice.doubleValue;
            if (high > maxHigh) maxHigh = high;
            if (low < minLow) minLow = low;
        }
        
        if (maxHigh > minLow) {
            double close = [self itemAtRecordIndex:i].closePrice.doubleValue;
            RSV = ((close - minLow) / (maxHigh - minLow)) * 100.0;
        }
        else {
            RSV = 0;
        }
        
        if (i == (params[0]-1)) {
            pValues[0][i] = (double)(50.0 * 2.0 / 3.0 + (RSV / 3.0));
            pValues[1][i] = (double)(50.0 * 2.0 / 3.0 + (pValues[0][i] / 3.0));
        }
        else {
            pValues[0][i] = (double)(pValues[0][i-1] * 2.0 / 3.0 + (RSV / 3.0));
            pValues[1][i] = (double)(pValues[1][i-1] * 2.0 / 3.0 + (pValues[0][i] / 3.0));
        }
    }
}


#pragma mark MPlotDrawing

- (NSUInteger)numberOfParams {
    if ([super numberOfParams]) return [super numberOfParams];
    return 1;
}

- (NSUInteger)numberOfDisplayValue {
    return 2;
}

- (void)willRedrawRect:(CGRect)rect atRecordIndex:(NSInteger)recordIndex numberOfVisibleRecords:(NSInteger)numberOfVisibleRecords {
    [self initializePaths];
    self.maxPrice = 100.0;
    self.minPrice = 0;
}

- (void)drawRect:(CGRect)rect inContext:(CGContextRef)context atRecordIndex:(NSInteger)recordIndex xPosition:(CGFloat)xPosition attributeProvider:(id<MPlotAttributes>__autoreleasing)attributeProvider {
    
    double minPrice = self.minPrice;
    double maxPrice = self.maxPrice;
    double yScale = CGRectGetHeight(rect) / fabs(maxPrice - minPrice);
    CGFloat barWidth = [attributeProvider barWidth];
    
    self.labelMaxValue = maxPrice;
    self.labelMinValue = minPrice;
    
    for (int i = 0; i < [self numberOfDisplayValue]; i++) {
        if (pValues[i][recordIndex] > minPrice && pValues[i][recordIndex] <= maxPrice) {
            double kd = pValues[i][recordIndex];
            CGPoint point = CGPointMake(xPosition + (barWidth / 2),
                                        CGRectGetMinY(rect) + CGRectGetHeight(rect) - (kd - minPrice) * yScale);
            if (firstDrawing[i]) {
                firstDrawing[i] = NO;
                MPlotBezierPathMoveToPoint(paths[i], point);
            }
            else {
                MPlotBezierPathAddLineToPoint(paths[i], point);
            }
        }
    }
}

#pragma mark Override

- (void)displayEnquiredInformationAtIndex:(NSInteger)index {
    NSUInteger numberOfRecords = [self numberOfRecords];
    for (int i = 0; i < [self numberOfDisplayValue]; i++) {
        UILabel *label = self.valueLabels[i];
        NSMutableString *format = nil;
        switch (i) {
            case 0:
                format = [NSMutableString stringWithFormat:@"K%lu:", (unsigned long)params[0]];
                break;
            case 1:
                format = [NSMutableString stringWithFormat:@"D%lu:", (unsigned long)params[0]];
                break;
            default:
                return;
        }
        
        if (numberOfRecords) {
            [format appendString:[self labelStringFormat]];
            if (index == NSNotFound) {
                label.text = [NSString stringWithFormat:format, MPlotDouble(pValues[i][[self numberOfRecords] - 1])];
            } else {
                label.text = [NSString stringWithFormat:format, MPlotDouble(pValues[i][index])];
            }
        }
        else {
            label.text = [format stringByAppendingString:kValueNilDefaultString];
        }
    }
    [self layoutValueLabelSizeToFit];
}


@end


#pragma mark - DMI

@implementation MDMIPlot

#pragma mark override

- (void)setupDefaultValue {
    params[0] = 10;
}

#pragma mark getter

- (NSString *)title {
    return @"DMI";
}

- (NSString *)labelStringFormat {
    return @"%.2f";
}


#pragma mark life cycle

- (void)beginCalculateParameter {
    [super beginCalculateParameter];
    
    NSInteger numberOfRecords = [self numberOfRecords];
    
    double sumTR = 0, TR ,sumP_DM = 0, sumM_DM = 0, sumDx;
    for (int i = 0; i < numberOfRecords; i++) {
        if (i >= params[0]) {
            if (i == params[0]) {
                sumTR = 0;
                sumP_DM = 0;
                sumM_DM = 0;
                for (int j = i; j > (i - params[0]); j--) {
                    TR = 0;
                    MOHLCItem *item = [self itemAtRecordIndex:j];
                    MOHLCItem *pre_item = [self itemAtRecordIndex:(j - 1)];
                    double high = item.highPrice.doubleValue;
                    double low = item.lowPrice.doubleValue;
                    double pre_close = pre_item.closePrice.doubleValue;
                    double pre_high = pre_item.highPrice.doubleValue;
                    double pre_low = pre_item.lowPrice.doubleValue;
                    //TR = 最高 - 最低
                    TR = MAX(fabs(high - low), fabs(high - pre_close));
                    TR = MAX(fabs(pre_close - low), TR);
                    
                    sumTR += TR;
                    double P_DM = MAX(0, high - pre_high);
                    double M_DM = MAX(0, pre_low - low);
                    
                    if (P_DM > M_DM) M_DM = 0;
                    else if (P_DM < M_DM) P_DM = 0;
                    else {}// 无动向
                        
                    sumP_DM += P_DM;
                    sumM_DM += M_DM;
                }
                
                sumTR /= params[0];
                sumP_DM /= params[0];
                sumM_DM /= params[0];
                
                pValues[0][i] = (sumP_DM / sumTR * 100.0);
                pValues[1][i] = (sumM_DM / sumTR * 100.0);
                pValues[2][i] = 0;
            }
            else
            {
                TR = 0;
                MOHLCItem *item = [self itemAtRecordIndex:i];
                MOHLCItem *pre_item = [self itemAtRecordIndex:(i - 1)];
                double high = item.highPrice.doubleValue;
                double low = item.lowPrice.doubleValue;
                double pre_close = pre_item.closePrice.doubleValue;
                double pre_high = pre_item.highPrice.doubleValue;
                double pre_low = pre_item.lowPrice.doubleValue;
                
                TR = MAX(fabs(high - low), fabs(high - pre_close));
                TR = MAX(fabs(pre_close - low), TR);
                //sumTR是i=10获得
                sumTR = ((sumTR * (params[0]-1)) + TR) / (params[0]);
                
                
                double P_DM = round(MAX(0, high - pre_high) * 10000000)/10000000;
                double M_DM = round(MAX(0, pre_low - low)   * 10000000)/10000000;
                
                if (P_DM > M_DM) M_DM = 0;
                else if (P_DM < M_DM) P_DM = 0;
                else { P_DM = 0; M_DM = 0;}// 无动向
                
                sumP_DM = ((sumP_DM * (params[0]-1)) + P_DM) / (params[0]);
                sumM_DM = ((sumM_DM * (params[0]-1)) + M_DM) / (params[0]);
                //+DI值  -DI值
                pValues[0][i] = (sumP_DM / sumTR * 100.0);
                pValues[1][i] = (sumM_DM / sumTR * 100.0);
                //ADX = ((+DI) - (-DI))/((+DI) + (-DI))
                if (i == params[0] * 2) {
                    sumDx = 0;
                    NSUInteger start = i - params[0];
                    for (int j = i; j > start; j--) {
                        double DX = 0;
                        if (pValues[0][j] && pValues[1][j]) {
                            DX = (pValues[0][j] - pValues[1][j]) / (pValues[0][j] + pValues[1][j]);
                        }
                        if (DX < 0) {
                            DX = (-1) * DX;
                        }
                        sumDx += DX;
                    }
                    pValues[2][i] = (sumDx / params[0] * 100.);
                }
                
                if (i > params[0] * 2) {
                    double DX = 0;
                    if (pValues[0][i] && pValues[1][i]) {
                        DX = (pValues[0][i] - pValues[1][i]) / (pValues[0][i] + pValues[1][i]);
                    }
                    if (DX < 0) {
                        DX = (-1) * DX;
                    }
                    pValues[2][i] = (pValues[2][i-1] * (params[0] - 1) + DX * 100.) / params[0];
                }
                else if (i < params[0] * 2) {
                    pValues[2][i] = 0;
                }
            }
            
//            ADXR=（当日的ADX+前一日的ADX）÷2
            double s = 0;
            for (int m = i; m > i-6; m--) {
                s += pValues[2][m];
                
            }
            pValues[3][i] = s / 6;
        }
        else 
        {   //前10个默认值0；
            pValues[0][i] = 0;
            pValues[1][i] = 0;
            pValues[2][i] = 0;
            pValues[3][i] = 0;
        }
        
    }
}


#pragma mark MPlotDrawing

- (NSUInteger)numberOfParams {
    if ([super numberOfParams]) return [super numberOfParams];
    return 1;
}

- (NSUInteger)numberOfDisplayValue {
    return 4;
}

- (void)willRedrawRect:(CGRect)rect atRecordIndex:(NSInteger)recordIndex numberOfVisibleRecords:(NSInteger)numberOfVisibleRecords {
    [super willRedrawRect:rect atRecordIndex:recordIndex numberOfVisibleRecords:numberOfVisibleRecords];
//    [self initializePaths];
//    self.maxPrice = 80.0;
//    self.minPrice = 0;
}

- (void)drawRect:(CGRect)rect inContext:(CGContextRef)context atRecordIndex:(NSInteger)recordIndex xPosition:(CGFloat)xPosition attributeProvider:(id<MPlotAttributes>__autoreleasing)attributeProvider {
    
    double minPrice = self.minPrice;
    double maxPrice = self.maxPrice;
    double yScale = CGRectGetHeight(rect) / fabs(maxPrice - minPrice);
    CGFloat barWidth = [attributeProvider barWidth];
    
    self.labelMaxValue = maxPrice;
    self.labelMinValue = minPrice;
    
    for (int i = 0; i < [self numberOfDisplayValue]; i++) {
        if (pValues[i][recordIndex] >= minPrice && pValues[i][recordIndex] <= maxPrice) {
            double dmi = pValues[i][recordIndex];
            CGPoint point = CGPointMake(xPosition + (barWidth / 2),
                                        CGRectGetMinY(rect) + CGRectGetHeight(rect) - (dmi - minPrice) * yScale);
            if (firstDrawing[i]) {
                firstDrawing[i] = NO;
                MPlotBezierPathMoveToPoint(paths[i], point);
            }
            else {
                MPlotBezierPathAddLineToPoint(paths[i], point);
            }
        }
    }
}


#pragma mark Override

- (void)displayEnquiredInformationAtIndex:(NSInteger)index {
    NSUInteger numberOfRecords = [self numberOfRecords];
    for (int i = 0; i < [self numberOfDisplayValue]; i++) {
        UILabel *label = self.valueLabels[i];
        NSMutableString *format = nil;
        switch (i) {
            case 0:
                format = [NSMutableString stringWithFormat:@"+DI%lu:", (unsigned long)params[0]];
                break;
            case 1:
                format = [NSMutableString stringWithFormat:@"-DI%lu:", (unsigned long)params[0]];
                break;
            case 2:
                format = [NSMutableString stringWithFormat:@"ADX%lu:", (unsigned long)params[0]];
                break;
            case 3:
                format = [NSMutableString stringWithFormat:@"ADXR%lu:", (unsigned long)params[0]];
                break;
            default:
                return;
        }
        
        if (numberOfRecords) {
            [format appendString:[self labelStringFormat]];
            if (index == NSNotFound) {
                label.text = [NSString stringWithFormat:format, MPlotDouble(pValues[i][[self numberOfRecords] - 1])];
            } else {
                label.text = [NSString stringWithFormat:format, MPlotDouble(pValues[i][index])];
            }
        }
        else {
            label.text = [format stringByAppendingString:kValueNilDefaultString];
        }
    }
    [self layoutValueLabelSizeToFit];
}

@end


#pragma mark - PSY

@implementation MPSYPlot

#pragma mark override

- (void)setupDefaultValue {
    params[0] = 12; params[1] = 24;
}

#pragma mark getter

- (NSString *)title {
    return @"PSY";
}

- (NSString *)labelStringFormat {
    return @"%.2f";
}


#pragma mark life cycle

- (void)beginCalculateParameter {
    [super beginCalculateParameter];
    //PSY=N日内上涨天数/N*100
    NSInteger numberOfRecords = [self numberOfRecords];
    
    int sum, i, j;
    for (i = 0; i < numberOfRecords; i++) {
        for (int m = 0; m < [self numberOfParams]; m++) {
            sum = 0;
            if (i >= params[m]) {
                for (j = i; j > (i - params[m]); j--) {
                    double close = [self itemAtRecordIndex:j].closePrice.doubleValue;
                    double pre_close = [self itemAtRecordIndex:(j - 1)].closePrice.doubleValue;
                    if (close > pre_close) {
                        sum += 1;
                    }
                }
                pValues[m][i] = (float)100 * sum / params[m];
            }
        }
    }
}


#pragma mark MPlotDrawing

- (NSUInteger)numberOfParams {
    if ([super numberOfParams]) return [super numberOfParams];
    return 2;
}

//- (void)willRedrawRect:(CGRect)rect atRecordIndex:(NSInteger)recordIndex numberOfVisibleRecords:(NSInteger)numberOfVisibleRecords { // Override if needed. }

- (void)drawRect:(CGRect)rect inContext:(CGContextRef)context atRecordIndex:(NSInteger)recordIndex xPosition:(CGFloat)xPosition attributeProvider:(id<MPlotAttributes>__autoreleasing)attributeProvider {
    
    double minPrice = self.minPrice;
    double maxPrice = self.maxPrice;
    double yScale = CGRectGetHeight(rect) / fabs(maxPrice - minPrice);
    CGFloat barWidth = [attributeProvider barWidth];
    
    self.labelMaxValue = maxPrice;
    self.labelMinValue = minPrice;
    
    for (int i = 0; i < [self numberOfDisplayValue]; i++) {
        if (pValues[i][recordIndex] > minPrice && pValues[i][recordIndex] <= maxPrice) {
            double psy = pValues[i][recordIndex];
            CGPoint point = CGPointMake(xPosition + (barWidth / 2),
                                        CGRectGetMinY(rect) + CGRectGetHeight(rect) - (psy - minPrice) * yScale);
            if (firstDrawing[i]) {
                firstDrawing[i] = NO;
                MPlotBezierPathMoveToPoint(paths[i], point);
            }
            else {
                MPlotBezierPathAddLineToPoint(paths[i], point);
            }
        }
    }
}

@end


#pragma mark - OBV

@implementation MOBVPlot

- (instancetype)initWithYAxisLabelCount:(NSInteger)yAxisLabelCount {
    self = [super initWithYAxisLabelCount:yAxisLabelCount];
    if (self) {
        self.enquiredInfomationDisplayFormat = self.yAxisDisplayFormat =
        ^NSString *(CGFloat displayValue) {
            return [MApiFormatter mapi_formatChineseUnitWithValue:displayValue];
        };
    }
    return self;
}

#pragma mark override

- (void)setupDefaultValue {

}

#pragma mark getter

- (NSString *)title {
    return @"OBV";
}

- (NSString *)labelStringFormat {
    return @"%.0f";
}


#pragma mark life cycle
/// 初始值 = volume
/// VA(今收大於昨收:+成交量,今收小於昨收:-成交量,今收等於昨收:0)
/// OBV(今日OBV = 昨日OBV+VA)
- (void)beginCalculateParameter {
    [super beginCalculateParameter];
    
    NSInteger numberOfRecords = [self numberOfRecords];
    
    for (int i = 0; i < numberOfRecords; i++) {
        MOHLCItem *item = [self itemAtRecordIndex:i];
        double close = item.closePrice.doubleValue;
        double volume = item.tradeVolume.doubleValue;
        
        if (i == 0) {
            pValues[0][i] = volume;
        }
        else {
            double pre_close = [self itemAtRecordIndex:(i - 1)].closePrice.doubleValue;
            //UP
            if (close > pre_close) {
                pValues[0][i] = pValues[0][i-1] + volume;
            }
            //DOWN
            else if (close < pre_close) {
                pValues[0][i] = pValues[0][i-1] - volume;
            }
            else {
                pValues[0][i] = pValues[0][i-1];
            }
        }
    }
}


#pragma mark MPlotDrawing

- (NSUInteger)numberOfParams {
    if ([super numberOfParams]) return [super numberOfParams];
    return 0;
}

- (NSUInteger)numberOfDisplayValue {
    return 1;
}

//- (void)willRedrawRect:(CGRect)rect atRecordIndex:(NSInteger)recordIndex numberOfVisibleRecords:(NSInteger)numberOfVisibleRecords { // Override if needed. }

- (void)drawRect:(CGRect)rect inContext:(CGContextRef)context atRecordIndex:(NSInteger)recordIndex xPosition:(CGFloat)xPosition attributeProvider:(id<MPlotAttributes>__autoreleasing)attributeProvider {
    
    double minPrice = self.minPrice;
    double maxPrice = self.maxPrice;
    double yScale = CGRectGetHeight(rect) / fabs(maxPrice - minPrice);
    CGFloat barWidth = [attributeProvider barWidth];
    
    self.labelMaxValue = maxPrice;
    self.labelMinValue = minPrice;
    
    for (int i = 0; i < [self numberOfDisplayValue]; i++) {
        if (pValues[i][recordIndex] >= minPrice && pValues[i][recordIndex] <= maxPrice) {
            double psy = pValues[i][recordIndex];
            CGPoint point = CGPointMake(xPosition + (barWidth / 2),
                                        CGRectGetMinY(rect) + CGRectGetHeight(rect) - (psy - minPrice) * yScale);
            if (firstDrawing[i]) {
                firstDrawing[i] = NO;
                MPlotBezierPathMoveToPoint(paths[i], point);
            }
            else {
                MPlotBezierPathAddLineToPoint(paths[i], point);
            }
        }
    }
}


#pragma mark Override

- (void)displayEnquiredInformationAtIndex:(NSInteger)index {
    NSUInteger numberOfRecords = [self numberOfRecords];
    for (int i = 0; i < [self numberOfDisplayValue]; i++) {
        UILabel *label = self.valueLabels[i];
        if (numberOfRecords) {
            if (index == NSNotFound) {
                index = [self numberOfRecords] - 1;
            }
            double volume = pValues[i][index];
            if (self.enquiredInfomationDisplayFormat) {
                label.text = self.enquiredInfomationDisplayFormat(volume);
            } else {
                NSString *format = [NSString stringWithFormat:@"%@", [self labelStringFormat]];
                label.text = [NSString stringWithFormat:format, MPlotDouble(volume)];
            }
        }
        else {
            label.text = kValueNilDefaultString;
        }
    }
    [self layoutValueLabelSizeToFit];
}

@end


#pragma mark - MTM

@implementation MMTMPlot

#pragma mark override

- (void)setupDefaultValue {
    params[0] = 12; params[1] = 6;
}

#pragma mark getter

- (NSString *)title {
    return @"MTM";
}

- (NSString *)labelStringFormat {
    return @"%.2f";
}


#pragma mark life cycle

- (void)beginCalculateParameter {
    [super beginCalculateParameter];

    NSInteger numberOfRecords = [self numberOfRecords];
   // MTM（N日）=C－CN式中，C=当日的收盘价  CN=N日前的收盘价
    for (int i = 0; i < numberOfRecords; i++) {
        if (i >= params[0]) {
            double close = [self itemAtRecordIndex:i].closePrice.doubleValue;
            double pre_close = [self itemAtRecordIndex:(i - params[0])].closePrice.doubleValue;
            pValues[0][i] = close - pre_close;
        }
        else {
            pValues[0][i] = 0.;
        }
        //MTM6值
        if (numberOfRecords > params[0]) {
            if (i >= params[0] + params[1]) {
                double sum = 0;
                for (int j = i; j > (i - params[1]); j--) {
                    sum += pValues[0][j];
                }
                
                if (params[1] != 0) {
                    pValues[1][i] = sum / params[1];
                }
                else {
                    pValues[1][i] = pValues[1][i-1];
                }
            }
            else {
                pValues[1][i] = 0.;
            }
        }
    }
}


#pragma mark MPlotDrawing

- (NSUInteger)numberOfParams {
    if ([super numberOfParams]) return [super numberOfParams];
    return 2;
}

//- (void)willRedrawRect:(CGRect)rect atRecordIndex:(NSInteger)recordIndex numberOfVisibleRecords:(NSInteger)numberOfVisibleRecords { // Override if needed. }

- (void)drawRect:(CGRect)rect inContext:(CGContextRef)context atRecordIndex:(NSInteger)recordIndex xPosition:(CGFloat)xPosition attributeProvider:(id<MPlotAttributes>__autoreleasing)attributeProvider {
    
    double minPrice = self.minPrice;
    double maxPrice = self.maxPrice;
    double yScale = CGRectGetHeight(rect) / fabs(maxPrice - minPrice);
    CGFloat barWidth = [attributeProvider barWidth];
    
    self.labelMaxValue = maxPrice;
    self.labelMinValue = minPrice;
    
    for (int i = 0; i < [self numberOfDisplayValue]; i++) {
        if (pValues[i][recordIndex] > minPrice && pValues[i][recordIndex] <= maxPrice) {
            double psy = pValues[i][recordIndex];
            CGPoint point = CGPointMake(xPosition + (barWidth / 2),
                                        CGRectGetMinY(rect) + CGRectGetHeight(rect) - (psy - minPrice) * yScale);
            if (firstDrawing[i]) {
                firstDrawing[i] = NO;
                MPlotBezierPathMoveToPoint(paths[i], point);
            }
            else {
                MPlotBezierPathAddLineToPoint(paths[i], point);
            }
        }
    }
}


#pragma mark Override

- (void)displayEnquiredInformationAtIndex:(NSInteger)index {
    NSUInteger numberOfRecords = [self numberOfRecords];
    for (int i = 0; i < [self numberOfDisplayValue]; i++) {
        UILabel *label = self.valueLabels[i];
        NSMutableString *format = nil;
        switch (i) {
            case 0:
                format = [NSMutableString stringWithFormat:@"MTM%lu:", (unsigned long)params[i]];
                break;
            case 1:
                format = [NSMutableString stringWithFormat:@"MA%lu:", (unsigned long)params[i]];
                break;
            default:
                return;
        }
        
        if (numberOfRecords) {
            [format appendString:[self labelStringFormat]];
            if (index == NSNotFound) {
                label.text = [NSString stringWithFormat:format, MPlotDouble(pValues[i][[self numberOfRecords] - 1])];
            } else {
                label.text = [NSString stringWithFormat:format, MPlotDouble(pValues[i][index])];
            }
        }
        else {
            label.text = [format stringByAppendingString:kValueNilDefaultString];
        }
    }
    [self layoutValueLabelSizeToFit];
}

@end


#pragma mark - VR

@implementation MVRPlot

#pragma mark override

- (void)setupDefaultValue {
    params[0] = 13; params[1] = 26;
}

#pragma mark getter

- (NSString *)title {
    return @"VR";
}

- (NSString *)labelStringFormat {
    return @"%.2f";
}


#pragma mark life cycle

- (void)beginCalculateParameter {
    [super beginCalculateParameter];
    
    NSInteger numberOfRecords = [self numberOfRecords];
    
    double up, down, flat;
    for (int i = 0; i < numberOfRecords; i++) {
        for (int m = 0; m < [self numberOfParams]; m++) {
            if (i >= params[m]) {
                up = 0;
                down = 0;
                flat = 0;
                for (int j = i; j > (i - params[m]); j--) {
                    MOHLCItem *item = [self itemAtRecordIndex:j];
                    double volume = item.tradeVolume.doubleValue;
                    double close = item.closePrice.doubleValue;
                    double pre_close = [self itemAtRecordIndex:(j - 1)].closePrice.doubleValue;
                    
                    if (close > pre_close) {
                        up += volume;
                    }
                    else if(close < pre_close) {
                        down += volume;
                    }
                    else {
                        flat += volume;
                    }
                }
                
                if(down + flat / 2 == 0) {
                    pValues[m][i] = -1.0;
                    break;
                }
                else {
                    pValues[m][i] = (up + flat / 2) / (down + flat / 2) * 100.0;
                }
            }
        }
    }
}


#pragma mark MPlotDrawing

- (NSUInteger)numberOfParams {
    if ([super numberOfParams]) return [super numberOfParams];
    return 2;
}

//- (void)willRedrawRect:(CGRect)rect atRecordIndex:(NSInteger)recordIndex numberOfVisibleRecords:(NSInteger)numberOfVisibleRecords { //Override if needed. }

- (void)drawRect:(CGRect)rect inContext:(CGContextRef)context atRecordIndex:(NSInteger)recordIndex xPosition:(CGFloat)xPosition attributeProvider:(id<MPlotAttributes>__autoreleasing)attributeProvider {
    
    double minPrice = self.minPrice;
    double maxPrice = self.maxPrice;
    double yScale = CGRectGetHeight(rect) / fabs(maxPrice - minPrice);
    CGFloat barWidth = [attributeProvider barWidth];
    
    self.labelMaxValue = maxPrice;
    self.labelMinValue = minPrice;
    
    for (int i = 0; i < [self numberOfParams]; i++) {
        if (pValues[i][recordIndex] > minPrice && pValues[i][recordIndex] <= maxPrice) {
            double psy = pValues[i][recordIndex];
            CGPoint point = CGPointMake(xPosition + (barWidth / 2),
                                        CGRectGetMinY(rect) + CGRectGetHeight(rect) - (psy - minPrice) * yScale);
            if (firstDrawing[i]) {
                firstDrawing[i] = NO;
                MPlotBezierPathMoveToPoint(paths[i], point);
            }
            else {
                MPlotBezierPathAddLineToPoint(paths[i], point);
            }
        }
    }
}

@end


#pragma mark - ROC

@implementation MROCPlot

#pragma mark override

- (void)setupDefaultValue {
    params[0] = 10;
}

#pragma mark getter

- (NSString *)title {
    return @"ROC";
}

- (NSString *)labelStringFormat {
    return @"%.2f";
}


#pragma mark life cycle

- (void)beginCalculateParameter {
    [super beginCalculateParameter];
    //ROC公式：ROC=(今天的收盘价-N日前的收盘价)/N日前的收盘价*100
    NSInteger numberOfRecords = [self numberOfRecords];
    NSUInteger factor = params[0];
    for (NSUInteger i = factor; i < numberOfRecords; i++) {
        double close = [self itemAtRecordIndex:i].closePrice.doubleValue;
        double nday_close = [self itemAtRecordIndex:(i - factor)].closePrice.doubleValue;
        if (nday_close == 0.) {
            pValues[0][i] = 0.;
        }
        else {
            pValues[0][i] = ((close - nday_close) / nday_close) * 100.;
        }
    }
}


#pragma mark MPlotDrawing

- (NSUInteger)numberOfParams {
    if ([super numberOfParams]) return [super numberOfParams];
    return 1;
}

//- (void)willRedrawRect:(CGRect)rect atRecordIndex:(NSInteger)recordIndex numberOfVisibleRecords:(NSInteger)numberOfVisibleRecords { // Override if needed. }

- (void)drawRect:(CGRect)rect inContext:(CGContextRef)context atRecordIndex:(NSInteger)recordIndex xPosition:(CGFloat)xPosition attributeProvider:(id<MPlotAttributes>__autoreleasing)attributeProvider {
    
    double minPrice = self.minPrice;
    double maxPrice = self.maxPrice;
    double yScale = CGRectGetHeight(rect) / fabs(maxPrice - minPrice);
    CGFloat barWidth = [attributeProvider barWidth];
    
    self.labelMaxValue = maxPrice;
    self.labelMinValue = minPrice;
    
    for (int i = 0; i < [self numberOfDisplayValue]; i++) {
        if (pValues[i][recordIndex] > minPrice && pValues[i][recordIndex] <= maxPrice) {
            double psy = pValues[i][recordIndex];
            CGPoint point = CGPointMake(xPosition + (barWidth / 2),
                                        CGRectGetMinY(rect) + CGRectGetHeight(rect) - (psy - minPrice) * yScale);
            if (firstDrawing[i]) {
                firstDrawing[i] = NO;
                MPlotBezierPathMoveToPoint(paths[i], point);
            }
            else {
                MPlotBezierPathAddLineToPoint(paths[i], point);
            }
        }
    }
}

@end


#pragma mark - WC

@interface MWCPlot : MPlot

@end

@implementation MWCPlot

#pragma mark override

- (void)setupDefaultValue {
    params[0] = 12;
}

#pragma mark getter

- (NSString *)title {
    return @"WC";
}

- (NSString *)labelStringFormat {
    return @"%.2f";
}


#pragma mark life cycle
/// WC:(C*2+H+L)/4
- (void)beginCalculateParameter {
    [super beginCalculateParameter];
    
    NSInteger numberOfRecords = [self numberOfRecords];
    for (int i = 0; i < numberOfRecords; i++) {
        MOHLCItem *item = [self itemAtRecordIndex:i];
        double close = item.closePrice.doubleValue;
        double high = item.highPrice.doubleValue;
        double low = item.lowPrice.doubleValue;
        pValues[0][i] = (close * 2 + high + low) / 4.;
    }
}


#pragma mark MPlotDrawing

- (NSUInteger)numberOfParams {
    if ([super numberOfParams]) return [super numberOfParams];
    return 1;
}

//- (void)willRedrawRect:(CGRect)rect atRecordIndex:(NSInteger)recordIndex numberOfVisibleRecords:(NSInteger)numberOfVisibleRecords { // Override if needed. }

- (void)drawRect:(CGRect)rect inContext:(CGContextRef)context atRecordIndex:(NSInteger)recordIndex xPosition:(CGFloat)xPosition attributeProvider:(id<MPlotAttributes>__autoreleasing)attributeProvider {
    
    double minPrice = self.minPrice;
    double maxPrice = self.maxPrice;
    double yScale = CGRectGetHeight(rect) / fabs(maxPrice - minPrice);
    CGFloat barWidth = [attributeProvider barWidth];
    
    self.labelMaxValue = maxPrice;
    self.labelMinValue = minPrice;
    
    for (int i = 0; i < [self numberOfParams]; i++) {
        if (pValues[i][recordIndex] > minPrice && pValues[i][recordIndex] <= maxPrice) {
            double psy = pValues[i][recordIndex];
            CGPoint point = CGPointMake(xPosition + (barWidth / 2),
                                        CGRectGetMinY(rect) + CGRectGetHeight(rect) - (psy - minPrice) * yScale);
            if (firstDrawing[i]) {
                firstDrawing[i] = NO;
                MPlotBezierPathMoveToPoint(paths[i], point);
            }
            else {
                MPlotBezierPathAddLineToPoint(paths[i], point);
            }
        }
    }
}

@end


#pragma mark - EOM

@interface MEOMPlot : MPlot

@end

@implementation MEOMPlot

#pragma mark override

- (void)setupDefaultValue {
    params[0] = 12;
}

#pragma mark getter

- (NSString *)title {
    return @"EOM";
}

- (NSString *)labelStringFormat {
    return @"%.2f";
}


#pragma mark life cycle

- (void)beginCalculateParameter {
    [super beginCalculateParameter];
    
    NSInteger numberOfRecords = [self numberOfRecords];
    
    NSUInteger period = params[0];
    for (NSUInteger i = period; i < numberOfRecords; i++) {
        MOHLCItem *item = [self itemAtRecordIndex:i];
        double high = item.highPrice.doubleValue;
        double low = item.lowPrice.doubleValue;
        double volume = item.tradeVolume.doubleValue;
        if (i == 0) {
            double midPointMove = (high + low) / 2.;
            double Vadj = volume / 10000.0;
            double BoxRatio = Vadj / (high - low);
            pValues[0][i] = midPointMove / BoxRatio;
        }
        else {
            MOHLCItem *pre_item = [self itemAtRecordIndex:(i - 1)];
            double pre_high = pre_item.highPrice.doubleValue;
            double pre_low = pre_item.lowPrice.doubleValue;
            double midPointMove = ((high + low) / 2.) - ((pre_high + pre_low) / 2.);
            double Vadj = volume / 10000.0;
            double BoxRatio = Vadj / (high - low);
            pValues[0][i] = midPointMove / BoxRatio;
        }
    }
}


#pragma mark MPlotDrawing

- (NSUInteger)numberOfParams {
    if ([super numberOfParams]) return [super numberOfParams];
    return 1;
}

//- (void)willRedrawRect:(CGRect)rect atRecordIndex:(NSInteger)recordIndex numberOfVisibleRecords:(NSInteger)numberOfVisibleRecords { // Override if needed. }

- (void)drawRect:(CGRect)rect inContext:(CGContextRef)context atRecordIndex:(NSInteger)recordIndex xPosition:(CGFloat)xPosition attributeProvider:(id<MPlotAttributes>__autoreleasing)attributeProvider {
    
    double minPrice = self.minPrice;
    double maxPrice = self.maxPrice;
    double yScale = CGRectGetHeight(rect) / fabs(maxPrice - minPrice);
    CGFloat barWidth = [attributeProvider barWidth];
    
    self.labelMaxValue = maxPrice;
    self.labelMinValue = minPrice;
    
    for (int i = 0; i < [self numberOfParams]; i++) {
        if (pValues[i][recordIndex] > minPrice && pValues[i][recordIndex] <= maxPrice) {
            double psy = pValues[i][recordIndex];
            CGPoint point = CGPointMake(xPosition + (barWidth / 2),
                                        CGRectGetMinY(rect) + CGRectGetHeight(rect) - (psy - minPrice) * yScale);
            if (firstDrawing[i]) {
                firstDrawing[i] = NO;
                MPlotBezierPathMoveToPoint(paths[i], point);
            }
            else {
                MPlotBezierPathAddLineToPoint(paths[i], point);
            }
        }
    }
}

@end


#pragma mark - NVI

@implementation MNVIPlot

#pragma mark override

- (void)setupDefaultValue {
    params[0] = 72;
}

#pragma mark getter

- (NSString *)title {
    return @"NVI";
}

- (NSString *)labelStringFormat {
    return @"%.2f";
}


#pragma mark life cycle
///NVI(今日成交量<昨日成交量:今日NVI=昨日NVI+今日漲跌幅(%),否則今日NVI=昨日NVI+0)
- (void)beginCalculateParameter {
    [super beginCalculateParameter];
    
    NSInteger numberOfRecords = [self numberOfRecords];
    
    for (int i = 0; i < numberOfRecords; i++) {
        if (i > 0) {
            MOHLCItem *item = [self itemAtRecordIndex:i];
            MOHLCItem *pre_item = [self itemAtRecordIndex:(i - 1)];
            double volume = item.tradeVolume.doubleValue;
            double close = item.closePrice.doubleValue;
            double pre_volume = pre_item.tradeVolume.doubleValue;
            double pre_close = pre_item.closePrice.doubleValue;
            if (volume < pre_volume) {
                pValues[0][i] = pValues[0][i-1] + ((close - pre_close) / (pre_close)) * pValues[0][i-1];
            }
            else {
                pValues[0][i] = pValues[0][i-1];
            }
        }
        else {
            pValues[0][i] = 100;
        }
    }
}


#pragma mark MPlotDrawing

- (NSUInteger)numberOfParams {
    if ([super numberOfParams]) return [super numberOfParams];
    return 0;
}

- (NSUInteger)numberOfDisplayValue {
    return 1;
}

//- (void)willRedrawRect:(CGRect)rect atRecordIndex:(NSInteger)recordIndex numberOfVisibleRecords:(NSInteger)numberOfVisibleRecords { // Override if needed. }

- (void)drawRect:(CGRect)rect inContext:(CGContextRef)context atRecordIndex:(NSInteger)recordIndex xPosition:(CGFloat)xPosition attributeProvider:(id<MPlotAttributes>__autoreleasing)attributeProvider {
    
    double minPrice = self.minPrice;
    double maxPrice = self.maxPrice;
    double yScale = CGRectGetHeight(rect) / fabs(maxPrice - minPrice);
    CGFloat barWidth = [attributeProvider barWidth];
    
    self.labelMaxValue = maxPrice;
    self.labelMinValue = minPrice;
    
    for (int i = 0; i < [self numberOfDisplayValue]; i++) {
        if (pValues[i][recordIndex] >= minPrice && pValues[i][recordIndex] <= maxPrice) {
            double psy = pValues[i][recordIndex];
            CGPoint point = CGPointMake(xPosition + (barWidth / 2),
                                        CGRectGetMinY(rect) + CGRectGetHeight(rect) - (psy - minPrice) * yScale);
            if (firstDrawing[i]) {
                firstDrawing[i] = NO;
                MPlotBezierPathMoveToPoint(paths[i], point);
            }
            else {
                MPlotBezierPathAddLineToPoint(paths[i], point);
            }
        }
    }
}

#pragma mark Override

- (void)displayEnquiredInformationAtIndex:(NSInteger)index {
    NSUInteger numberOfRecords = [self numberOfRecords];
    for (int i = 0; i < [self numberOfDisplayValue]; i++) {
        UILabel *label = self.valueLabels[i];
        if (numberOfRecords) {
            if (index == NSNotFound) {
                index = [self numberOfRecords] - 1;
            }
            double value = pValues[i][index];
            
            NSString *format = [NSString stringWithFormat:@"%@:%@", [self title], [self labelStringFormat]];
            label.text = [NSString stringWithFormat:format, MPlotDouble(value)];
            
        }
        else {
            label.text = kValueNilDefaultString;
        }
    }
    [self layoutValueLabelSizeToFit];
}


@end


#pragma mark - PVI

@implementation MPVIPlot

#pragma mark override

- (void)setupDefaultValue {
    params[0] = 72;
}

#pragma mark getter

- (NSString *)title {
    return @"PVI";
}

- (NSString *)labelStringFormat {
    return @"%.2f";
}


#pragma mark life cycle
/// PVI(今日成交量>昨日成交量:今日PVI=昨日PVI+今日漲跌幅(%),否則今日PVI=昨日PVI+0)
- (void)beginCalculateParameter {
    [super beginCalculateParameter];
    
    NSInteger numberOfRecords = [self numberOfRecords];
    
    for (int i = 0; i < numberOfRecords; i++) {
        if (i > 0) {
            MOHLCItem *item = [self itemAtRecordIndex:i];
            MOHLCItem *pre_item = [self itemAtRecordIndex:(i - 1)];
            double volume = item.tradeVolume.doubleValue;
            double close = item.closePrice.doubleValue;
            double pre_volume = pre_item.tradeVolume.doubleValue;
            double pre_close = pre_item.closePrice.doubleValue;
            if (volume > pre_volume) {
                pValues[0][i] = pValues[0][i-1] + ((close - pre_close) / (pre_close)) * pValues[0][i-1];
            }
            else {
                pValues[0][i] = pValues[0][i-1];
            }
        }
        else {
            pValues[0][i] = 100;
        }
    }
}


#pragma mark MPlotDrawing

- (NSUInteger)numberOfParams {
    if ([super numberOfParams]) return [super numberOfParams];
    return 0;
}

- (NSUInteger)numberOfDisplayValue {
    return 1;
}

//- (void)willRedrawRect:(CGRect)rect atRecordIndex:(NSInteger)recordIndex numberOfVisibleRecords:(NSInteger)numberOfVisibleRecords { // Override if needed. }

- (void)drawRect:(CGRect)rect inContext:(CGContextRef)context atRecordIndex:(NSInteger)recordIndex xPosition:(CGFloat)xPosition attributeProvider:(id<MPlotAttributes>__autoreleasing)attributeProvider {
    
    double minPrice = self.minPrice;
    double maxPrice = self.maxPrice;
    double yScale = CGRectGetHeight(rect) / fabs(maxPrice - minPrice);
    CGFloat barWidth = [attributeProvider barWidth];
    
    self.labelMaxValue = maxPrice;
    self.labelMinValue = minPrice;
    
    for (int i = 0; i < [self numberOfDisplayValue]; i++) {
        if (pValues[i][recordIndex] > minPrice && pValues[i][recordIndex] <= maxPrice) {
            double psy = pValues[i][recordIndex];
            CGPoint point = CGPointMake(xPosition + (barWidth / 2),
                                        CGRectGetMinY(rect) + CGRectGetHeight(rect) - (psy - minPrice) * yScale);
            if (firstDrawing[i]) {
                firstDrawing[i] = NO;
                MPlotBezierPathMoveToPoint(paths[i], point);
            }
            else {
                MPlotBezierPathAddLineToPoint(paths[i], point);
            }
        }
    }
}


#pragma mark Override

- (void)displayEnquiredInformationAtIndex:(NSInteger)index {
    NSUInteger numberOfRecords = [self numberOfRecords];
    for (int i = 0; i < [self numberOfDisplayValue]; i++) {
        UILabel *label = self.valueLabels[i];
        if (numberOfRecords) {
            if (index == NSNotFound) {
                index = [self numberOfRecords] - 1;
            }
            double value = pValues[i][index];
            
            NSString *format = [NSString stringWithFormat:@"%@:%@", [self title], [self labelStringFormat]];
            label.text = [NSString stringWithFormat:format, MPlotDouble(value)];
            
        }
        else {
            label.text = kValueNilDefaultString;
        }
    }
    [self layoutValueLabelSizeToFit];
}

@end


#pragma mark - VAO

@interface MVAOPlot : MPlot

@end

@implementation MVAOPlot

#pragma mark override

- (void)setupDefaultValue {
    params[0] = 12;
}

#pragma mark getter

- (NSString *)title {
    return @"VAO";
}

- (NSString *)labelStringFormat {
    return @"%.2f";
}


#pragma mark life cycle
/// VAO= ((Close-Low)-(High-Close)) / (High-Low) * Volume
- (void)beginCalculateParameter {
    [super beginCalculateParameter];
    
    NSInteger numberOfRecords = [self numberOfRecords];
    
    for (int i = 0; i < numberOfRecords; i++) {
        MOHLCItem *item = [self itemAtRecordIndex:i];
        double high = item.highPrice.doubleValue;
        double low = item.lowPrice.doubleValue;
        double close = item.closePrice.doubleValue;
        double volume = item.tradeVolume.doubleValue;
        if (high == low) {
            pValues[0][i] = 0.;
        }
        else {
            double tempValue = ((close - low) - (high - close)) / (high - low);
            pValues[0][i] = tempValue * volume;
        }
    }
}


#pragma mark MPlotDrawing

- (NSUInteger)numberOfParams {
    if ([super numberOfParams]) return [super numberOfParams];
    return 1;
}

//- (void)willRedrawRect:(CGRect)rect atRecordIndex:(NSInteger)recordIndex numberOfVisibleRecords:(NSInteger)numberOfVisibleRecords { // Override if needed. }

- (void)drawRect:(CGRect)rect inContext:(CGContextRef)context atRecordIndex:(NSInteger)recordIndex xPosition:(CGFloat)xPosition attributeProvider:(id<MPlotAttributes>__autoreleasing)attributeProvider {
    
    double minPrice = self.minPrice;
    double maxPrice = self.maxPrice;
    double yScale = CGRectGetHeight(rect) / fabs(maxPrice - minPrice);
    CGFloat barWidth = [attributeProvider barWidth];
    
    self.labelMaxValue = maxPrice;
    self.labelMinValue = minPrice;
    
    for (int i = 0; i < [self numberOfDisplayValue]; i++) {
        if (pValues[i][recordIndex] > minPrice && pValues[i][recordIndex] <= maxPrice) {
            double psy = pValues[i][recordIndex];
            CGPoint point = CGPointMake(xPosition + (barWidth / 2),
                                        CGRectGetMinY(rect) + CGRectGetHeight(rect) - (psy - minPrice) * yScale);
            if (firstDrawing[i]) {
                firstDrawing[i] = NO;
                MPlotBezierPathMoveToPoint(paths[i], point);
            }
            else {
                MPlotBezierPathAddLineToPoint(paths[i], point);
            }
        }
    }
}

@end


#pragma mark - SAR

//@interface MSARPlot : MPlot
//
//@end

@implementation MSARPlot

#pragma mark override

- (void)setupDefaultValue {
    params[0] = 12;
}

#pragma mark getter

- (NSString *)title {
    return @"SAR";
}

- (NSString *)labelStringFormat {
    return @"%.3f";
}


#pragma mark life cycle

- (void)beginCalculateParameter {
    [super beginCalculateParameter];
    
    NSInteger numberOfRecords = [self numberOfRecords];
    
     int dayStep = 10;
    //SAR公式：SAR(Tn)=SAR(Tn-1)+AF(Tn)*[EP(Tn-1)-SAR(Tn-1)] 其中，SAR(Tn)为第Tn周期的SAR值，SAR(Tn-1)为第(Tn-1)周期的值,AF为加速因子(或叫加速系数)，EP为极点价(最高价或最低价)
    //pValues[0]:加速因子。 pValues[1]：买卖方向。pValues[2]：极点价。pValues[3]：SAR值
    for (int i = 0; i < numberOfRecords; i++) {
        if (i >= dayStep) {
            //11
            MOHLCItem *item = [self itemAtRecordIndex:i];
            double high = item.highPrice.doubleValue;
            double low = item.lowPrice.doubleValue;
            double close = item.closePrice.doubleValue;
            double pre_close = [self itemAtRecordIndex:(i - 1)].closePrice.doubleValue;

            if (i - dayStep == 0) {
                pValues[0][i] = 0.02;
                double his_close = [self itemAtRecordIndex:(i - dayStep)].closePrice.doubleValue;

                pValues[1][i] = pre_close > his_close ? 'b' : 's';
                if (pValues[1][i] == 'b') {
                    pValues[2][i] = DBL_MIN;
                    pValues[3][i] = DBL_MAX;
                } else {
                    pValues[2][i] = DBL_MAX;
                    pValues[3][i] = DBL_MIN;
                }
                for (int j = i - 1; j >= (i - dayStep); j--) {
                    MOHLCItem *j_item = [self itemAtRecordIndex:j];
                    if (pValues[1][i] == 'b') {
                        pValues[2][i] = MAX(pValues[2][i], j_item.highPrice.doubleValue);
                        pValues[3][i] = MIN(pValues[3][i], j_item.lowPrice.doubleValue);
                    } else {
                        pValues[2][i] = MIN(pValues[2][i], j_item.lowPrice.doubleValue);
                        pValues[3][i] = MAX(pValues[3][i], j_item.highPrice.doubleValue);
                    }
                }
            } else {
                /// 加速因子
                //=IF(OR(AND(L13="BUY",L14="SELL"),AND(L13="SELL",L14="BUY")),0.02,IF(I14=0.2,0.2,IF(L14="BUY",IF(D15>D14,I14+0.02,I14),IF(E15<E14,I14+0.02,I14))))
                MOHLCItem *pre_item = [self itemAtRecordIndex:(i - 1)];
                double pre_high = pre_item.highPrice.doubleValue;
                double pre_low = pre_item.lowPrice.doubleValue;
                //任何一次行情的转变，加速因子AF都必须重新由0.02起算
                if ((pValues[1][i-2] == 'b' && pValues[1][i-1] == 's') ||
                    (pValues[1][i-2] == 's' && pValues[1][i-1] == 'b')) {
                    pValues[0][i] = 0.02;
                }
                //加速因子AF最高不超过0.2
                else if (pValues[0][i-1] == 0.2) {
                    pValues[0][i] = 0.2;
                } else if (pValues[1][i-1]=='b') {
                    if (high > pre_high) {
                        pValues[0][i] = pValues[0][i-1] + 0.02;
                    } else {
                        pValues[0][i] = pValues[0][i-1];
                    }
                } else {
                    if (low < pre_low) {
                        pValues[0][i] = pValues[0][i-1] + 0.02;
                    } else {
                        pValues[0][i] = pValues[0][i-1];
                    }
                }
                
                /// 買賣訊號
                if (pValues[1][i-1] == 'b') {
                    pValues[1][i] = (close < pValues[3][i-1]) ? 's' : 'b';
                } else {
                    pValues[1][i] = (close > pValues[3][i-1]) ? 'b' : 's';
                }
                /// SAR
                //=IF(L14="BUY",IF(L15="BUY",K14+I15*(J14-K14),J14),IF(L15="BUY",J14,K14+I15*(J14-K14)))
                
                /// 區間極值
                if (pValues[1][i-1] == 'b') {
                    if (pValues[1][i] == 'b') {
                        pValues[2][i] = MAX(pre_high, pValues[2][i-1]);
                        pValues[3][i] = pValues[3][i-1]+pValues[0][i]*(pValues[2][i-1]-pValues[3][i-1]);
                    } else {
                        pValues[2][i] = DBL_MAX;
                        for (int j = i - 2; j >= (i - dayStep); j--) {
                            double his_low = [self itemAtRecordIndex:j].lowPrice.doubleValue;
                            pValues[2][i] = MIN(pValues[2][i], his_low);
                        }
                        pValues[3][i] = pValues[2][i-1];
                    }
                } else {
                    if (pValues[1][i] == 'b') {
                        pValues[2][i] = DBL_MIN;
                        for (int j = i - 2; j >= (i - dayStep); j--) {
                            double his_high = [self itemAtRecordIndex:j].highPrice.doubleValue;
                            pValues[2][i] = MAX(pValues[2][i], his_high);
                        }
                        pValues[3][i] = pValues[2][i-1];
                    } else {
                        pValues[2][i] = MIN(pre_low, pValues[2][i-1]);
                        pValues[3][i] = pValues[3][i-1] + pValues[0][i] * (pValues[2][i-1] - pValues[3][i-1]);
                    }
                }
            }
        }
    }
}


#pragma mark MPlotDrawing

- (NSUInteger)numberOfParams {
    if ([super numberOfParams]) return [super numberOfParams];
    return 1;
}

- (NSUInteger)numberOfDisplayValue {
    return 4;
}

- (void)willRedrawRect:(CGRect)rect atRecordIndex:(NSInteger)recordIndex numberOfVisibleRecords:(NSInteger)numberOfVisibleRecords {
    
    [self initializePaths];
    
    NSInteger numberOfRecords = [self numberOfRecords];
    double maxPrice = DBL_MIN;
    double minPrice = DBL_MAX;
    for (NSInteger index = recordIndex; index < MIN((recordIndex + numberOfVisibleRecords), numberOfRecords); index++) {
        if (pValues[3]) {
            double sar = pValues[3][index];
            if (sar != 0) {
                if(sar > maxPrice) maxPrice = sar;
                if(sar < minPrice) minPrice = sar;
            }
        }
    }
    self.maxPrice = maxPrice;
    self.minPrice = minPrice;
}

- (void)drawRect:(CGRect)rect inContext:(CGContextRef)context atRecordIndex:(NSInteger)recordIndex xPosition:(CGFloat)xPosition attributeProvider:(id<MPlotAttributes>__autoreleasing)attributeProvider {
    
    double minPrice = self.minPrice;
    double maxPrice = self.maxPrice;
    CGFloat barWidth = [attributeProvider barWidth];
    
    self.labelMaxValue = maxPrice;
    self.labelMinValue = minPrice;
    
    if (pValues[3][recordIndex] >= minPrice && pValues[3][recordIndex] <= maxPrice) {
        double sar = pValues[3][recordIndex];
        if (pValues[1][recordIndex] == 'b') {
            [RISE_COLOR set];
        } else {
            [DROP_COLOR set];
        }
        CGRect barRect = CGRectMake(xPosition,
                                    MPlotGetYPositionInRect(CGRectInset(rect, 0, barWidth), sar, maxPrice, minPrice),
                                    barWidth,
                                    barWidth);
        CGContextStrokeEllipseInRect(context, barRect);
    }
}

- (void)endDrawingContext:(CGContextRef)context {
    // do nothing
}


#pragma mark Override

- (void)displayEnquiredInformationAtIndex:(NSInteger)index {
    NSUInteger numberOfRecords = [self numberOfRecords];
    for (int i = 0; i < [self numberOfDisplayValue]; i++)
    {
        UILabel *label = self.valueLabels[i];
        NSMutableString *format = nil;
        switch (i) {
            case 0:
                format = [NSMutableString stringWithFormat:@"AF:"];
            [format appendString:[self labelStringFormat]];
                break;
            case 1:
                format = [NSMutableString stringWithFormat:@"BC:"];
                            [format appendString:@"%d"];
                break;
            case 2:
                format = [NSMutableString stringWithFormat:@"R:"];
                            [format appendString:[self labelStringFormat]];
                break;
            case 3:
                format = [NSMutableString stringWithFormat:@"SAR:"];
                            [format appendString:[self labelStringFormat]];
                break;
            default:
                return;
        }
        
        if (numberOfRecords) {
            if (index == NSNotFound) {
                label.text = [NSString stringWithFormat:format, MPlotDouble(pValues[i][[self numberOfRecords] - 1])];
            } else {
                label.text = [NSString stringWithFormat:format, MPlotDouble(pValues[i][index])];
            }
        }
        else {
            label.text = [format stringByAppendingString:kValueNilDefaultString];
        }
    }
    [self layoutValueLabelSizeToFit];
}

@end


#pragma mark - DMA

@implementation MDMAPlot

#pragma mark init

- (instancetype)init {
    return [self initWithYAxisLabelCount:5];
}

- (instancetype)initWithYAxisLabelCount:(NSInteger)yAxisLabelCount barFill:(BOOL)barFill {
    self = [super initWithYAxisLabelCount:yAxisLabelCount];
    if (self) {
        
    }
    return self;
}


#pragma mark override

- (void)setupDefaultValue {
    params[0] = 10; params[1] = 50; params[2] = 10;
}


#pragma mark life cycle

- (void)beginCalculateParameter {
    [super beginCalculateParameter];
    
    NSInteger numberOfRecords = [self numberOfRecords];
    
    size_t sz = sizeof(double) * numberOfRecords;
    NSInteger maSize = 2;
    double *ma[maSize];
    for (int i = 0; i < maSize; i++) {
        ma[i] = malloc(sz);
        bzero(ma[i], sz);
    }
    //DMA公式：DMA=股价短期平均值—股价长期平均值  AMA=DMA短期平均值  以求10日、50日为基准周期的DMA指标为例，其计算过程具体如下： DMA（10）=10日股价平均值—50日股价平均值 AMA（10）=10日DMA平均值
    for (int idx = 0; idx < numberOfRecords; idx++) {
        for (int m = 0; m < maSize; m++) {
            double fsum = 0;
            if (idx > (params[1] - 2)) {
                for (int j = idx; j > idx - params[m]; j--) {
                    if (j < 0) break;
                    MOHLCItem *item = [self itemAtRecordIndex:j];
                    fsum += [item.closePrice doubleValue];
                }
                
                if (params[m] != 0) {
                    ma[m][idx] = (fsum / (double)params[m]);
                }
                else {
                    ma[m][idx] = 0;
                }
            }
        }
        if (ma[0][idx] > 0 && ma[1][idx] > 0) {
            pValues[0][idx] = ma[0][idx] - ma[1][idx];
        }
        
        double fsum = 0;
        if (idx > ((params[1] + params[2]) - 1)) {
            for (int j = idx; j > idx - params[2]; j--) {
                if (j < 0) break;
                fsum += pValues[0][j];
            }
            pValues[1][idx] = (fsum / (double)params[2]);
        }
    }
    for (int i = 0; i < maSize; i++) {
        if (ma[i]) {
            free(ma[i]);
        }
    }
}


#pragma mark getter

- (NSString *)title {
    return @"DMA";
}

- (NSString *)labelStringFormat {
    if ([self.dataSource respondsToSelector:@selector(numberOfDecimalForPlot:)]) {
        return [NSString stringWithFormat:@"%%.%df", [self.dataSource numberOfDecimalForPlot:self]];
    }
    return @"%.2f";
}

#pragma mark MPlotDrawing

- (NSUInteger)numberOfDisplayValue {
    return 2;
}

- (NSUInteger)numberOfParams {
    if ([super numberOfParams]) return [super numberOfParams];
    return 2;
}

- (void)willRedrawRect:(CGRect)rect atRecordIndex:(NSInteger)recordIndex numberOfVisibleRecords:(NSInteger)numberOfVisibleRecords {
    [super willRedrawRect:rect atRecordIndex:recordIndex numberOfVisibleRecords:numberOfVisibleRecords];
}

- (void)drawRect:(CGRect)rect inContext:(CGContextRef)context atRecordIndex:(NSInteger)recordIndex xPosition:(CGFloat)xPosition attributeProvider:(id<MPlotAttributes>__autoreleasing)attributeProvider {
    
    double minPrice = self.minPrice;
    double maxPrice = self.maxPrice;
    
    CGFloat barWidth = [attributeProvider barWidth];
    
    self.labelMaxValue = maxPrice;
    self.labelMinValue = minPrice;
    
    for (int i = 0; i < [self numberOfDisplayValue]; i++) {
        double ma = pValues[i][recordIndex];
        if ((i == 0 && recordIndex >= params[1]) ||
            (i == 1 && recordIndex >= params[1] + params[2])) {
            CGPoint point = CGPointMake(xPosition + (barWidth / 2),
                                        MPlotGetYPositionInRect(rect, ma, maxPrice, minPrice));
            if (firstDrawing[i]) {
                firstDrawing[i] = NO;
                MPlotBezierPathMoveToPoint(paths[i], point);
            }
            else {
                MPlotBezierPathAddLineToPoint(paths[i], point);
            }
        }
    }
}

#pragma mark Override

- (void)displayEnquiredInformationAtIndex:(NSInteger)index {
    NSUInteger numberOfRecords = [self numberOfRecords];
    for (int i = 0; i < [self numberOfDisplayValue]; i++)
    {
        UILabel *label = self.valueLabels[i];
        NSMutableString *format = nil;
        switch (i) {
            case 0:
                format = [NSMutableString stringWithFormat:@"DIF:"];
                break;
            case 1:
                format = [NSMutableString stringWithFormat:@"DIFMA:"];
                break;
            default:
                return;
        }
        
        if (numberOfRecords) {
            [format appendString:[self labelStringFormat]];
            if (index == NSNotFound) {
                label.text = [NSString stringWithFormat:format, MPlotDouble(pValues[i][[self numberOfRecords] - 1])];
            } else {
                label.text = [NSString stringWithFormat:format, MPlotDouble(pValues[i][index])];
            }
        }
        else {
            label.text = [format stringByAppendingString:kValueNilDefaultString];
        }
    }
    [self layoutValueLabelSizeToFit];
}

@end


#pragma mark - CR

@implementation MCRPlot

#pragma mark init

- (instancetype)init {
    return [self initWithYAxisLabelCount:5];
}

- (instancetype)initWithYAxisLabelCount:(NSInteger)yAxisLabelCount barFill:(BOOL)barFill {
    self = [super initWithYAxisLabelCount:yAxisLabelCount];
    if (self) {
        
    }
    return self;
}


#pragma mark override

- (void)setupDefaultValue {
    params[0] = 26; params[1] = 10; params[2] = 20; params[3] = 40; params[4] = 62;
}


#pragma mark life cycle

- (void)beginCalculateParameter {
    [super beginCalculateParameter];
    //CR公式：CR（N日）=P1÷P2×100  P1=Σ（H－YM），表示N日以来多方力量的总和 。P2=Σ（YM－L），表示N日以来空方力量的总和。H表示今日的最高价，L表示今日的最低价YM表示昨日（上一个交易日）的中间价
    NSInteger numberOfRecords = [self numberOfRecords];

    for (int idx = 0; idx < numberOfRecords; idx++) {
        for (int m = 0; m < [self numberOfParams]; m++) {
            if (m == 0) {
                if (idx > (params[m] - 2)) {
                    double fsum_h = 0;
                    double fsum_l = 0;
                    for (int j = idx; j > idx - params[m]; j--) {
                        if (j <= 0) break;
                        MOHLCItem *prev_item = [self itemAtRecordIndex:j-1];
                        MOHLCItem *item = [self itemAtRecordIndex:j];

                        double mid = (prev_item.highPrice.doubleValue + prev_item.lowPrice.doubleValue) / 2.0;
                        fsum_h += MAX(0, item.highPrice.doubleValue - mid);
                        fsum_l += MAX(0, mid - item.lowPrice.doubleValue);
                    }
                    
                    if (params[m] != 0 && fsum_l > 0) {
                        pValues[m][idx] = fsum_h / fsum_l * 100.0;
                    }
                    else {
                        pValues[m][idx] = 0;
                    }
                }
            }
            else {
                //疑问？ 一定范围内的平均值
                if (idx > (params[0] + params[m] - 2)) {
                    double fsum = 0;
                    for (int j = idx; j > idx - params[m]; j--) {
                        if (j < 0) break;
                        fsum += pValues[0][j];
                    }
                    
                    if (params[m] != 0) {
                        pValues[m][idx] = (fsum / (double)params[m]);
                    }
                    else {
                        pValues[m][idx] = 0;
                    }
                }
            }
        }
    }
}


#pragma mark getter

- (NSString *)title {
    return @"CR";
}

- (NSString *)labelStringFormat {
    if ([self.dataSource respondsToSelector:@selector(numberOfDecimalForPlot:)]) {
        return [NSString stringWithFormat:@"%%.%df", [self.dataSource numberOfDecimalForPlot:self]];
    }
    return @"%.2f";
}

#pragma mark MPlotDrawing

- (NSUInteger)numberOfParams {
    if ([super numberOfParams]) return [super numberOfParams];
    return 5;
}

- (void)willRedrawRect:(CGRect)rect atRecordIndex:(NSInteger)recordIndex numberOfVisibleRecords:(NSInteger)numberOfVisibleRecords {
    [super willRedrawRect:rect atRecordIndex:recordIndex numberOfVisibleRecords:numberOfVisibleRecords];
}

- (void)drawRect:(CGRect)rect inContext:(CGContextRef)context atRecordIndex:(NSInteger)recordIndex xPosition:(CGFloat)xPosition attributeProvider:(id<MPlotAttributes>__autoreleasing)attributeProvider {
    
    double minPrice = self.minPrice;
    double maxPrice = self.maxPrice;
    
    CGFloat barWidth = [attributeProvider barWidth];
    
    self.labelMaxValue = maxPrice;
    self.labelMinValue = minPrice;
    
    for (int i = 0; i < [self numberOfDisplayValue]; i++) {
        double ma = pValues[i][recordIndex];
        if (ma > 0) {
            CGPoint point = CGPointMake(xPosition + (barWidth / 2),
                                        MPlotGetYPositionInRect(rect, ma, maxPrice, minPrice));
            if (firstDrawing[i]) {
                firstDrawing[i] = NO;
                MPlotBezierPathMoveToPoint(paths[i], point);
            }
            else {
                MPlotBezierPathAddLineToPoint(paths[i], point);
            }
        }
    }
}

#pragma mark Override

- (void)displayEnquiredInformationAtIndex:(NSInteger)index {
    NSUInteger numberOfRecords = [self numberOfRecords];
    for (int i = 0; i < [self numberOfDisplayValue]; i++)
    {
        UILabel *label = self.valueLabels[i];
        NSMutableString *format = nil;
        switch (i) {
            case 0:
                format = [NSMutableString stringWithFormat:@"CR%lu:", (unsigned long)params[i]];
                break;
            default:
                format = [NSMutableString stringWithFormat:@"MA%lu:", (unsigned long)params[i]];
                break;
        }
        
        if (numberOfRecords) {
            [format appendString:[self labelStringFormat]];
            if (index == NSNotFound) {
                label.text = [NSString stringWithFormat:format, MPlotDouble(pValues[i][[self numberOfRecords] - 1])];
            } else {
                label.text = [NSString stringWithFormat:format, MPlotDouble(pValues[i][index])];
            }
        }
        else {
            label.text = [format stringByAppendingString:kValueNilDefaultString];
        }
    }
    [self layoutValueLabelSizeToFit];
}

@end
