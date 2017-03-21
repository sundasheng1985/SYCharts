//
//  MFundChartView.m
//  MAPI
//
//  Created by 陈志春 on 16/10/20.
//  Copyright © 2016年 Mitake. All rights reserved.
//

#import "MChartView.h"

#import "MApi.h"
#import "MApiFormatter.h"

#import "_MPlot.h"
#import "_MChartView.h"

#import "_MDispatchQueuePool.h"

#import "MChartView4Trend.h"

static NSCache *MFundChartImageCache() {
    static NSCache *cache;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cache = [[NSCache alloc] init];
        [cache setCountLimit:100];
    });
    return cache;
}


@implementation MFundChartView


#pragma mark life cycle

- (void)initialized {
    [super initialized];
    
    _priceRiseTextColor = _rangeRiseTextColor = [UIColor redColor];
    _priceFlatTextColor = _rangeFlatTextColor = [UIColor whiteColor];
    _priceDropTextColor = _rangeDropTextColor = [UIColor greenColor];
    
    _currentLineColor = [UIColor whiteColor];
    _currentLineWidth = 1;
    
    
    _datetimeLabels = [[NSMutableArray alloc] init];
    for (NSInteger i = 0; i < 5; i++) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
        label.font = self.xAxisFont;
        label.textColor = self.xAxisTextColor;
        [_datetimeLabels addObject:label];
        [self addSubview:label];
    }
    _leftLabels = [[NSMutableArray alloc] init];
    for (NSInteger i = 0; i < 5; i++) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
        label.adjustsFontSizeToFitWidth = YES;
        label.backgroundColor = [UIColor clearColor];
        label.minimumScaleFactor = 0.5;
        label.textAlignment = NSTextAlignmentLeft;
        label.text = @"一";
        if (i < 2) {
            label.textColor = self.priceRiseTextColor;
        } else if (i == 2) {
            label.textColor = self.priceFlatTextColor;
        } else {
            label.textColor = self.priceDropTextColor;
        }
        label.font = self.yAxisFont;
        [_leftLabels addObject:label];
        [self addSubview:label];
    }
    
    self.enquiryView = [MTrendChartEnquiryView bindView:self];
}


- (void)willMoveToSuperview:(UIView *)newSuperview {
    if (newSuperview) {
        [self _relaodData];
    } else {
        [MApi cancelRequest:self.snapRequest];
        [MApi cancelRequest:self.fundRequest];
    }
}

- (void)layoutSubviews {
    [self _relaodData];
}


#pragma mark public

- (void)reloadData {
    /// 先檔
    if (!self.code) {
        return;
    }
    
    [MApi cancelRequest:self.snapRequest];
    [MApi cancelRequest:self.fundRequest];
    
    self.snapRequest = [[MSnapQuoteRequest alloc] init];
    self.snapRequest.code = self.code;
    
    [MApi sendRequest:self.snapRequest completionHandler:^(MResponse *resp) {
        if (resp.status == MResponseStatusSuccess) {
            MStockItem *stockItem = ((MSnapQuoteResponse *)resp).stockItem;
            if (stockItem && stockItem.ID && stockItem.subtype && stockItem.preClosePrice.doubleValue > 0) {
                [self reloadDataWithStockItem:stockItem];
            }
        }
    }];
}

- (void)reloadDataWithStockItem:(MStockItem *)stockItem {
    
    
    if (!stockItem || !stockItem.ID || !stockItem.subtype || stockItem.preClosePrice.doubleValue == 0) {
        /// request snap 重新取stockitem
        if (self.code == nil) self.code = stockItem.ID;
        [self reloadData];
        return;
    }
    
    [MApi cancelRequest:self.snapRequest];
    [MApi cancelRequest:self.fundRequest];
    
    self.fundRequest = [[MFundValueRequest alloc] init];
    self.fundRequest.code = stockItem.ID;
    self.fundRequest.type = @"12";
    
    [MApi sendRequest:self.fundRequest completionHandler:^(MResponse *resp) {
        if (resp.status == MResponseStatusSuccess) {
            MFundValueResponse *response = (MFundValueResponse *)resp;
            if (!response.isCacheResponse)
            {
                self.stockItem = stockItem;
                self.allItems = response.items;
                if (response.items.count > 0) {
                    [self _sectionRange:response.items];
                }else{
                    self.items = response.items;
                }
                _chartViewFlags.contentNeedsUpdate = true;
                [self _relaodData];
            }
        }
    }];
}

- (NSArray *)getALLFundValue{
    MFundValueRequest *request = [[MFundValueRequest alloc] init];
    request.code = self.code;
    request.type = @"12";
    [MApi sendRequest:request completionHandler:^(MResponse *resp) {
        if (resp.status == MResponseStatusSuccess) {
            MFundValueResponse *response = (MFundValueResponse *)resp;
            if (!response.isCacheResponse)
            {
                self.allItems = response.items;
            }
        }
    }];
    return _allItems;
}


#pragma mark private

- (void)_relaodData {
    
    bool isEnquiryLineModeNotToDisappear = (self.enquiryLineMode & MChartEnquiryLineModeNotToDisappear);
    
    /// 如果正在查價，就延遲reloadData
    if (_chartViewFlags.isEnquiring && !isEnquiryLineModeNotToDisappear) {
        _chartViewFlags.delayReloadData = true;
        return;
    }
    
    [self _layoutPriceLabels];
    [self _setupDatetimeLabels];
    [self contentNeedsUpdate];
    
    /// 长驻查价线模式，查价线重新绘制
    if (_chartViewFlags.isEnquiring && isEnquiryLineModeNotToDisappear) {
        [self _enquireX:_previousEnquireLocationX y:_previousEnquireLocationY];
    }
}

- (void)_enquireX:(CGFloat)xLocation y:(CGFloat)yLocation {
    //tick count
    NSInteger oneDayTickCount = self.items.count;
    // tick spacing --only
    CGFloat spacing = CGRectGetWidth([self drawingChartRect]) / oneDayTickCount;
    
    //计算手势占多少个间距
    NSInteger touchIndex = (NSInteger)round((xLocation - CGRectGetMinX([self drawingChartRect])) / spacing);
    
    touchIndex = MIN(lastIndex, touchIndex);
    
    xLocation = CGRectGetMinX([self drawingChartRect]) + (touchIndex * spacing);
    NSDictionary *fundItem = _items[touchIndex];
    
    if (fundItem) {
        double preClose = [self.stockItem.preClosePrice doubleValue];
        NSString *yAxisString = nil;
        NSString *xAxisString = nil;
        //Y轴查价线是否可以自动游走
        if (self.enquiryLineMode & MChartEnquiryLineModeNone) {
            if (CGRectContainsPoint(CGRectInset([self _priceChartRect], -1, 0), CGPointMake(xLocation, yLocation))) {
                MMarketInfo *info = [MApi marketInfoWithMarket:self.stockItem.market subtype:self.stockItem.subtype];
                double displayValue = preClose + (CGRectGetMidY([self _priceChartRect]) - yLocation) / [self _priceChartScale];
                yAxisString = [MApiFormatter mapi_formatPriceWithValue:displayValue marketInfo:info];
                
            }
        } else {
            yAxisString = [NSString stringWithFormat:@"%.3f",[fundItem[@"UnitNAV"] doubleValue]];
            xAxisString = fundItem[@"ENDDATE"];
            CGFloat maxY = CGRectGetMaxY([self _priceChartRect]) - ([self _upDownSpace]);
            yLocation = maxY - ([fundItem[@"UnitNAV"] doubleValue] - self.minValue) * [self _priceChartScale];
        }
        
        /// flags changed.
        _chartViewFlags.isEnquiring = true;
        
        _previousEnquireLocationX = xLocation;
        _previousEnquireLocationY = yLocation;
        
        CGPoint touchLocation = CGPointMake(xLocation, yLocation);
        /// 繪製查價線
        [self.enquiryView drawInRect:[self drawingChartRect]
                      priceChartRect:[self _priceChartRect]
                     volumeChartRect:CGRectZero
                         yAxisString:yAxisString
                         xAxisString:xAxisString
                       touchLocation:touchLocation
                         borderWidth:self.borderWidth
                    yAxisLabelInside:[self isYAxisLabelInside]];
        
        if (_previousEnquireIndex != touchIndex) {
            _previousEnquireIndex = touchIndex;
            /// 通知
            [[NSNotificationCenter defaultCenter] postNotificationName:MFundValueDidStartEnquiryNotification
                                                                object:fundItem
                                                              userInfo:nil];
        }
    } else {
        //            NSLog(@"NO QueryItem %zd", queryDatetime);
    }
}

- (void)_setupLayerContentsFromCacheImage:(MStockItem *)stockItem {
    CGImageRef cgimage = (__bridge_retained CGImageRef)(self.layer.contents);
    NSString *key = [NSString stringWithFormat:@"%@%@", stockItem.ID, NSStringFromCGRect(self.bounds)];
    UIImage *image = [MFundChartImageCache() objectForKey:key];
    self.layer.contents = (__bridge id _Nullable)(image.CGImage);
    if (cgimage) {
        dispatch_async(_MDispatchQueueGetForQOS(NSQualityOfServiceBackground), ^{
            CFRelease(cgimage);
        });
    }
}

- (void)_sectionRange:(NSArray *)items{
    if (self.startTime != nil || self.endTime != nil) {
        NSInteger startTime = [[self.startTime stringByReplacingOccurrencesOfString:@"-" withString:@""] integerValue];
        NSInteger endTime = [[self.endTime stringByReplacingOccurrencesOfString:@"-" withString:@""] integerValue];
        NSInteger startIndex = 0;
        NSInteger endIndex = 0;
        BOOL startTag = NO;
        BOOL endTag = NO;
        NSMutableArray *times = [NSMutableArray array];
        for (NSDictionary *dic in items) {
            NSString *time = [dic[@"ENDDATE"] stringByReplacingOccurrencesOfString:@"-" withString:@""];
            [times addObject:time];
        }
        NSArray *timeArr = [NSArray arrayWithArray:times];
        
        if (startTime > [[timeArr lastObject] integerValue] || endTime < [[timeArr firstObject] integerValue]) {
            self.items = nil;
        }else{
            
            if (startTime <= [[timeArr firstObject] integerValue]) {
                startIndex = 0;
                startTag = YES;
            }
            if (endTime >= [[timeArr lastObject] integerValue]) {
                endIndex = timeArr.count - 1;
                endTag = YES;
            }
            for (int i = 1; i < timeArr.count; i++) {
                if (!startTag) {
                    if (startTime > [timeArr[i-1] integerValue] && startTime <= [timeArr[i] integerValue]) {
                        startIndex = i;
                        startTag = YES;
                    }
                }
                if (!endTag) {
                    if (endTime > [timeArr[i-1] integerValue] && endTime <= [timeArr[i] integerValue]) {
                        endIndex = i;
                        endTag = YES;
                    }
                }
                if (startTag && endTag) {
                    break;
                }
            }
            self.items = [items subarrayWithRange:NSMakeRange(startIndex, endIndex - startIndex)];
        }
        
    }else{
        self.items = items;
    }
}


- (void)_drawFundChartInContext:(CGContextRef)context rect:(CGRect)rect stockItem:(MStockItem *)stockItem fundItems:(NSArray *)fundItems  minPrice:(double)minPrice maxPrice:(double)maxPrice isCancelled:(BOOL(^)(void))isCancelled {
    
    CGFloat priceChartScale = [self _priceChartScaleWithMinValue:minPrice maxValue:maxPrice];
    double compareMax = maxPrice - minPrice;
    
    [self _setupPriceLabelsWithCompareMax:compareMax minPrice:minPrice];
    
    NSMutableArray *items = [fundItems mutableCopy];
    
    //走势视图
    CGFloat y = CGRectGetMidY([self _priceChartRect]);
    
    //走势视图宽度
    CGFloat timeZoneWidth = CGRectGetWidth([self _priceChartRect]);
    //self.items.count
    NSInteger oneDayTickCount = fundItems.count;
    // tick 间距
    CGFloat spacing = timeZoneWidth / (double)(oneDayTickCount - 1);
    
    lastIndex = 0;
    //渐层
    CGMutablePathRef gradient = CGPathCreateMutable();
    CGPathMoveToPoint(gradient, NULL, CGRectGetMinX([self _priceChartRect]),
                      CGRectGetMaxY([self _priceChartRect])); // y is price chart middle
    CGPathAddLineToPoint(gradient, NULL, CGRectGetMinX([self _priceChartRect]), y);
    CGFloat gradientX = CGRectGetMinX([self _priceChartRect]);
    
    //走势
    CGMutablePathRef pricePath = CGPathCreateMutable();
    
    CGFloat maxY = CGRectGetMaxY([self _priceChartRect]) - ([self _upDownSpace]);
    
    for (NSInteger i = 0; i < oneDayTickCount; i++) {
        if (isCancelled()) goto Cancelled;
        
        NSDictionary *item = items[i];
        
        y = maxY - ([item[@"UnitNAV"] doubleValue] - minPrice) * priceChartScale;
        ////
        CGFloat x = CGRectGetMinX([self _priceChartRect]) + (spacing * i);
        if (i==0) {
            CGPathMoveToPoint(pricePath, NULL, x, y);
        } else {
            CGPathAddLineToPoint(pricePath, NULL, x, y);
        }
        CGPathAddLineToPoint(gradient, NULL, (gradientX=x), y);
        lastIndex++;
        
    }
    
    
    if (isCancelled()) goto Cancelled; /// prepare to draw volume
    
    if (self.gradientColors) {
        CGPathAddLineToPoint(gradient, NULL, gradientX, CGRectGetMaxY([self _priceChartRect]));
        NSMutableArray *colors = [NSMutableArray array];
        for (UIColor *color in self.gradientColors) {
            [colors addObject:((__bridge id)color.CGColor)];
        }
        [self drawLinearGradient:context path:gradient colors:colors locations:self.gradientLocations type:0];
    }
    
    if (isCancelled()) goto Cancelled; /// prepare to draw price line
    ///线
    CGContextSaveGState(context);
    CGContextSetLineWidth(context, RETINA_LINE(self.currentLineWidth));
    CGContextSetStrokeColorWithColor(context, self.currentLineColor.CGColor);
    CGContextAddPath(context, pricePath);
    CGContextStrokePath(context);
    CGContextRestoreGState(context);
Cancelled:
    CGPathRelease(pricePath);
    CGPathRelease(gradient);
    lastIndex--;
    
}

- (void)_layoutPriceLabels {
    for (NSInteger i = 0; i < self.leftLabels.count; i++) {
        UILabel *label = self.leftLabels[i];
        label.hidden = NO;
        CGFloat height = (CGRectGetHeight([self _priceChartRect]) - ([self _upDownSpace] * 2)) / (self.leftLabels.count - 1);
        
        CGFloat x = 0;
        CGFloat width = 0;
        if ([self isYAxisLabelInside]) {
            width = CGRectGetWidth([self _priceChartRect]) / 2;;
            x = CGRectGetMinX([self _priceChartRect]);
            label.textAlignment = NSTextAlignmentLeft;
        } else {
            width = self.yAxisLabelInsets.left;
            x = 0;
            label.textAlignment = NSTextAlignmentRight;
        }
        
        label.frame = CGRectMake(x, CGRectGetMinY([self _priceChartRect]) + [self _upDownSpace] + (height * i) - (height / 2.0), width, height);
        
    }
}

/**
 *  时间设置,取当前数组的开始时间及结束时间
 */
- (void)_setupDatetimeLabels {
    [self.datetimeLabels makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.datetimeLabels makeObjectsPerformSelector:@selector(setText:) withObject:@"/"];
    
    CGFloat width = CGRectGetWidth([self _priceChartRect]) / 2;
    for (NSInteger i = 0; i < 2; i++) {
        UILabel *label = self.datetimeLabels[i];
        label.font = self.xAxisFont;
        label.textColor = self.xAxisTextColor;
        label.backgroundColor = [UIColor clearColor];
        
        NSString *timeString = @"一";
        if (i == 0) {
            label.textAlignment = NSTextAlignmentLeft;
            NSDictionary *dic = self.items[0];
            timeString = dic[@"ENDDATE"];
        } else {
            label.textAlignment = NSTextAlignmentRight;
            NSDictionary *dic = [self.items lastObject];
            timeString = dic[@"ENDDATE"];
        }
        label.text = timeString;
        
        [label sizeToFit];
        CGRect frame = label.frame;
        frame.size.width = width;
        frame.origin.x = CGRectGetMinX([self _priceChartRect]) + (i * width);
        frame.origin.y = CGRectGetMaxY([self chartRect]);
        label.frame = frame;
        [self insertSubview:label belowSubview:self.enquiryView];
    }
}

- (void)_setupPriceLabelsWithCompareMax:(double)compareMax minPrice:(double)minPrice{
    if (![NSThread isMainThread]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self _setupPriceLabelsWithCompareMax:(double)compareMax minPrice:(double)minPrice];
        });
        return;
    }
    NSArray *prices = @[@(minPrice + compareMax),
                        @(minPrice + (compareMax / 4.0 * 3)),
                        @(minPrice + (compareMax / 4.0 * 2)),
                        @(minPrice + (compareMax / 4.0 * 1)),
                        @(minPrice)];
    for (NSInteger i = 0; i < prices.count; i++) {
        UILabel *priceLabel = self.leftLabels[i];
        NSString *priceString = prices[i];
        if (priceString != nil ) {
            priceLabel.text = [NSString stringWithFormat:@"%.3f",[priceString doubleValue]];
        }
        else {
            priceLabel.text = @"一";
        }
    }
    
}

- (CGFloat)_priceChartScale {
    NSAssert([NSThread isMainThread], @"check point");
    return [self _priceChartScaleWithMinValue:self.minValue maxValue:self.maxValue];
}

- (CGFloat)_priceChartScaleWithMinValue:(double)minValue maxValue:(double)maxValue {
    CGFloat height =  CGRectGetHeight([self _priceChartRect]);
    return  (height - ([self _upDownSpace]*2) ) / (maxValue - minValue);
}

- (void)_clear {
    self.stockItem = nil;
    self.items = nil;
    [self.datetimeLabels makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.leftLabels makeObjectsPerformSelector:@selector(setText:) withObject:@"一"];
}

//价走势底部高度
- (CGFloat)_upDownSpace {
    CGFloat upDownSpace = CGRectGetHeight([self _priceChartRect]) * 0.07;
    if (isinf(upDownSpace) || isnan(upDownSpace)) {
        return 0;
    }
    return upDownSpace;
}

//价走势Rect
- (CGRect)_priceChartRect {
    CGFloat height = CGRectGetHeight([self chartRect]);
    CGRect rect = CGRectMake(CGRectGetMinX([self chartRect]) + self.borderWidth,
                             CGRectGetMinY([self chartRect]) + self.borderWidth,
                             CGRectGetWidth([self chartRect]) - (self.borderWidth * 2.0),
                             height - self.borderWidth - (self.insideLineWidth / 2.0) - 5/*上下图间距*/);
    return CGRectInset(rect, 1.0, 1.0);
}

//绘制X轴线
- (void)_drawXAxisLineInRect:(CGRect)borderRect context:(CGContextRef)context {
    CGContextSaveGState(context);
    CGContextSetStrokeColorWithColor(context, self.insideLineColor.CGColor);
    CGContextSetLineWidth(context, RETINA_LINE(self.insideLineWidth));
    
    CGFloat y = CGRectGetMinY([self _priceChartRect]) + (CGRectGetHeight([self _priceChartRect]) / 2.0);
    
    CGContextSaveGState(context);
    {
        /// 2nd
        if (self.options[@"YCLOSE_LINE_COLOR"]) {
            CGContextSetStrokeColorWithColor(context, [self.options[@"YCLOSE_LINE_COLOR"] CGColor]);
        }
        if (self.options[@"YCLOSE_LINE_DASH"]) {
            CGFloat dash[] = {6, 2};
            CGContextSetLineDash (context, 0, dash, sizeof(dash) / sizeof(CGFloat));
        }
        /// end 2nd
        CGContextMoveToPoint(context, CGRectGetMinX([self _priceChartRect]), y);
        CGContextAddLineToPoint(context, CGRectGetMaxX([self _priceChartRect]), y);
        CGContextStrokePath(context);
    } CGContextRestoreGState(context);
    
    
    CGFloat dash[] = {MAX(2, self.insideLineWidth), MAX(2, self.insideLineWidth)};
    CGContextSetLineDash (context, 0, dash, sizeof(dash) / sizeof(CGFloat));
    
    NSUInteger part = 5;
    CGFloat priceChartYSpacing = (CGRectGetHeight([self _priceChartRect]) - ([self _upDownSpace] * 2)) / (part - 1);
    for (NSInteger i = 0; i < part; i++) {
        if (i == 2) {
            continue;
        }
        CGFloat y = CGRectGetMinY([self _priceChartRect]) + [self _upDownSpace] + (priceChartYSpacing * i);
        CGContextMoveToPoint(context, CGRectGetMinX([self _priceChartRect]), y);
        CGContextAddLineToPoint(context, CGRectGetMaxX([self _priceChartRect]), y);
    }
    CGContextStrokePath(context);
    CGContextRestoreGState(context);
}

//绘制Y轴线
- (void)_drawYAxisLineInRect:(CGRect)borderRect context:(CGContextRef)context {
    CGContextSaveGState(context);
    CGContextSetStrokeColorWithColor(context, self.insideLineColor.CGColor);
    
    CGFloat dash[] = {MAX(2, self.insideLineWidth), MAX(2, self.insideLineWidth)};
    CGContextSetLineDash (context, 0, dash, sizeof(dash) / sizeof(CGFloat));
    
    CGContextSetLineWidth(context, RETINA_LINE(self.insideLineWidth));
    NSUInteger part = 4;
    CGFloat spacing = CGRectGetWidth([self _priceChartRect]) / part;
    for (NSInteger i = 1; i < part; i++) {
        CGFloat x = CGRectGetMinX([self _priceChartRect]) + (spacing * i);
        CGContextMoveToPoint(context, x, CGRectGetMinY([self _priceChartRect]));
        CGContextAddLineToPoint(context, x, CGRectGetMaxY([self _priceChartRect]));
    }
    CGContextStrokePath(context);
    CGContextRestoreGState(context);
}

//绘制外框线
- (void)_drawBorderRect:(CGRect)borderRect inContext:(CGContextRef)context {
    CGContextSaveGState(context);
    {
        CGContextSetStrokeColorWithColor(context, self.borderColor.CGColor);
        CGContextSetLineWidth(context, RETINA_LINE(self.borderWidth));
        CGFloat offset = self.borderWidth / 2;
        CGContextStrokeRect(context, CGRectInset([self _priceChartRect], -offset, -offset));
    } CGContextRestoreGState(context);
}


#pragma mark getter

- (NSArray *)items {
    NSAssert([NSThread isMainThread], @"check point");
    return _items;
}

- (NSArray *)allItems{
    NSAssert([NSThread isMainThread], @"check point");
    return _allItems;
}

#pragma mark setter

- (void)setYAxisLabelInsets:(UIEdgeInsets)yAxisLabelInsets {
    [super setYAxisLabelInsets:yAxisLabelInsets];
    
    _chartViewFlags.chartFrameChanged = true;
    NSMutableArray *labels = [[NSMutableArray alloc] initWithArray:self.leftLabels];
    
    if ([self isYAxisLabelInside]) {
        [labels enumerateObjectsUsingBlock:^(UILabel *label, NSUInteger idx, BOOL * _Nonnull stop) {
            label.textAlignment = NSTextAlignmentLeft;
        }];
    } else {
        [labels enumerateObjectsUsingBlock:^(UILabel *label, NSUInteger idx, BOOL * _Nonnull stop) {
            label.textAlignment = NSTextAlignmentRight;
        }];
    }
    
    if (self.window) {
        [self _relaodData];
    }
}

- (void)setPriceRiseTextColor:(UIColor *)priceRiseTextColor {
    _priceRiseTextColor = priceRiseTextColor;
    for (NSInteger i = 0; i < 2; i++) {
        UILabel *label = self.leftLabels[i];
        label.textColor = priceRiseTextColor;
    }
}
- (void)setPriceFlatTextColor:(UIColor *)priceFlatTextColor {
    _priceFlatTextColor = priceFlatTextColor;
    if (self.leftLabels.count >= 3) {
        UILabel *label = self.leftLabels[2];
        label.textColor = priceFlatTextColor;
    }
}

- (void)setPriceDropTextColor:(UIColor *)priceDropTextColor {
    _priceDropTextColor = priceDropTextColor;
    if (self.leftLabels.count >= 3) {
        for (NSInteger i = 3; i < self.leftLabels.count; i++) {
            UILabel *label = self.leftLabels[i];
            label.textColor = priceDropTextColor;
        }
    }
}

- (void)setYAxisFont:(UIFont *)yAxisFont {
    [super setYAxisFont:yAxisFont];
    [self.leftLabels makeObjectsPerformSelector:@selector(setFont:) withObject:self.yAxisFont];
}

- (void)setXAxisFont:(UIFont *)xAxisFont {
    [super setXAxisFont:xAxisFont];
    _chartViewFlags.chartFrameChanged = true;
    if (self.window) {
        [self _setupDatetimeLabels];
        [self contentNeedsUpdate];
    }
}


#pragma mark override super

- (_MAsyncLayerDisplayTask *)override_newAsyncDisplayTask {

    
    _MAsyncLayerDisplayTask *task = [_MAsyncLayerDisplayTask new];
    
    MStockItem *stockItem = self.stockItem;//[self.stockItem copy];
    NSArray *items = self.items;//[self.items copy];

    
    task.display = ^(CGContextRef context, CGSize size, BOOL(^isCancelled)(void)) {
        
        CGRect rect = [self chartRect];
        //绘制内外框线
        [self _drawBorderRect:rect inContext:context];
        [self _drawXAxisLineInRect:rect context:context];
        [self _drawYAxisLineInRect:rect context:context];
        
        if (!items || items.count == 0 || !stockItem) {
            return;
        }
        NSDictionary *dic = [items firstObject];
        __block double maxValue = [dic[@"UnitNAV"] doubleValue];
        __block double minValue = [dic[@"UnitNAV"] doubleValue];
        
        [items enumerateObjectsUsingBlock:^(NSDictionary *item, NSUInteger idx, BOOL * _Nonnull stop) {
            
            if (isCancelled()) *stop = YES;
            
            NSString *fundValue = item[@"UnitNAV"];
            if ([fundValue doubleValue] > maxValue) {
                maxValue = [fundValue doubleValue];
            }
            else if ([fundValue doubleValue] < minValue) {
                minValue = [fundValue doubleValue];
            }
        }];
        
        if (isCancelled()) return;
        self.minValue = minValue;
        self.maxValue = maxValue;
        //绘制线图
        [self _drawFundChartInContext:context rect:rect stockItem:stockItem fundItems:items minPrice:minValue maxPrice:maxValue isCancelled:isCancelled];
        
    };
    
    return task;
}

- (void)override_startEnquireWithGesture:(UIGestureRecognizer *)gestureRecognizer {
    //确认XY轴坐标是否越界
    CGFloat xLocation = [gestureRecognizer locationInView:self].x;
    xLocation = MIN(CGRectGetMaxX([self drawingChartRect]), xLocation);
    xLocation = MAX(CGRectGetMinX([self drawingChartRect]), xLocation);
    
    CGFloat yLocation = [gestureRecognizer locationInView:self].y;
    yLocation = MIN(CGRectGetMaxY([self drawingChartRect]), yLocation);
    yLocation = MAX(CGRectGetMinY([self drawingChartRect]), yLocation);
    
    [self _enquireX:xLocation y:yLocation];
}

- (void)override_endEnquire {
    if (_chartViewFlags.isEnquiring) {
        
        /// flags changed.
        _chartViewFlags.isEnquiring = false;
        
        [self.enquiryView clear];
        //
        [[NSNotificationCenter defaultCenter] postNotificationName:MFundValueDidEndEnquiryNotification
                                                            object:nil
                                                          userInfo:nil];
    }
    
    /// 查價時有執行reloadData的話會被擋掉，則結束查價時要重新執行reloadData。
    if (_chartViewFlags.delayReloadData) {
        _chartViewFlags.delayReloadData = false;
        [self _relaodData];
    }
}

@end

