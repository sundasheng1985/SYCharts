//
//  MTrendChartView.m
//  Pods
//
//  Created by FanChiangShihWei on 2016/3/25.
//
//

#import "MChartView.h"

#import "MApi.h"
#import "MApiFormatter.h"

#import "_MPlot.h"
#import "_MChartView.h"

#import "_MDispatchQueuePool.h"

#import <libkern/OSAtomic.h>
#import "MOHLCItem.h" /// because of rgbar property

#import "Defines.h"

#import "MChartView4Trend.h"

#import "NSString+MApiAdditions.h"
#import "MChartResponse.h"

static NSCache *MTrendChartImageCache() {
    static NSCache *cache;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cache = [[NSCache alloc] init];
        [cache setCountLimit:100];
    });
    return cache;
}

static NSString *VolumeChartString(double displayValue, double maxVol) {
    NSString *formatString = [MApiFormatter mapi_formatChineseUnitWithValue:displayValue
                                                              maxValue:maxVol];
    static NSString * const units[3] = {@"", @"万", @"亿"};
    for (int i = 0; i < 3; i++) {
        if (maxVol == displayValue &&
            [formatString rangeOfString:units[i]].location != NSNotFound) {
        }
        formatString = [formatString stringByReplacingOccurrencesOfString:units[i] withString:@""];
    }
    return formatString;
}


enum {
    MTrendChartTypeList = 9001001,
    MTrendChartTypeBigWord = 9001002
};


@implementation MTrendChartView


#pragma mark life cycle

- (void)initialized {
    [super initialized];
    
    _numberFormatter = [[NSNumberFormatter alloc] init];
    _numberFormatter.numberStyle = kCFNumberFormatterNoStyle;
    _numberFormatter.formatWidth = 2;
    _numberFormatter.paddingCharacter = @"0";
    
    _priceRiseTextColor = _rangeRiseTextColor = [UIColor redColor];
    _priceFlatTextColor = _rangeFlatTextColor = [UIColor whiteColor];
    _priceDropTextColor = _rangeDropTextColor = [UIColor greenColor];
    
    _volumeTextColor = [UIColor whiteColor];
    _currentLineColor = [UIColor whiteColor];
    _currentLineWidth = 1;
    _averageLineColor = [UIColor yellowColor];
    _averageLineWidth = 1;
    
    _volumeRiseColor = [UIColor redColor];
    _volumeDropColor = [UIColor greenColor];
    
    _datetimeLabels = [[NSMutableArray alloc] init];
    
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
    _rightLabels = [[NSMutableArray alloc] init];
    for (NSInteger i = 0; i < 5; i++) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
        label.adjustsFontSizeToFitWidth = YES;
        label.backgroundColor = [UIColor clearColor];
        label.minimumScaleFactor = 0.5;
        label.textAlignment = NSTextAlignmentRight;
        label.text = @"一";
        if (i < 2) {
            label.textColor = self.rangeRiseTextColor;
        } else if (i == 2) {
            label.textColor = self.rangeFlatTextColor;
        } else {
            label.textColor = self.rangeDropTextColor;
        }
        label.font = self.yAxisFont;
        [_rightLabels addObject:label];
        [self addSubview:label];
    }
    _volumeLabels = [[NSMutableArray alloc] init];
    for (NSInteger i = 0; i < 3; i++) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
        label.adjustsFontSizeToFitWidth = YES;
        label.backgroundColor = [UIColor clearColor];
        label.minimumScaleFactor = 0.5;
        label.textAlignment = NSTextAlignmentLeft;
        label.font = self.yAxisFont;
        label.text = @"一";
        label.textColor = self.volumeTextColor;
        [_volumeLabels addObject:label];
        [self addSubview:label];
    }
    
    self.enquiryView = [MTrendChartEnquiryView bindView:self];
}

- (void)setYAxisLabelInsets:(UIEdgeInsets)yAxisLabelInsets {
    [super setYAxisLabelInsets:yAxisLabelInsets];
    
    _chartViewFlags.chartFrameChanged = true;
    NSMutableArray *labels = [[NSMutableArray alloc] initWithArray:self.leftLabels];
    [labels addObjectsFromArray:self.volumeLabels];

    if ([self isYAxisLabelInside]) {
        [labels enumerateObjectsUsingBlock:^(UILabel *label, NSUInteger idx, BOOL * _Nonnull stop) {
            label.textAlignment = NSTextAlignmentLeft;
        }];
        [self.rightLabels enumerateObjectsUsingBlock:^(UILabel *label, NSUInteger idx, BOOL * _Nonnull stop) {
            label.textAlignment = NSTextAlignmentRight;
        }];
    } else {
        [labels enumerateObjectsUsingBlock:^(UILabel *label, NSUInteger idx, BOOL * _Nonnull stop) {
            label.textAlignment = NSTextAlignmentRight;
        }];
        [self.rightLabels enumerateObjectsUsingBlock:^(UILabel *label, NSUInteger idx, BOOL * _Nonnull stop) {
            label.textAlignment = NSTextAlignmentLeft;
        }];
    }
    
    if (self.window) {
        [self _relaodData];
    }
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    if (newSuperview) {
        [self _relaodData];
    } else {
        [MApi cancelRequest:self.snapRequest];
        [MApi cancelRequest:self.chartRequest];
    }
}

- (void)layoutSubviews {
    [self _relaodData];
}


#pragma mark public

- (void)reloadDataWithStockItem:(MStockItem *)stockItem {
    if (self.type == (MTrendChartType)MTrendChartTypeList || self.type == (MTrendChartType)MTrendChartTypeBigWord) {
        if (![self.stockItem.ID isEqualToString:stockItem.ID]) {
            [self _clear];
            [self _setupLayerContentsFromCacheImage:stockItem];
        }
    }
    
    if (!stockItem || !stockItem.ID || !stockItem.subtype || stockItem.preClosePrice.doubleValue == 0) {
        /// request snap 重新取stockitem
        if (self.code == nil) self.code = stockItem.ID;
        [self reloadData];
        return;
    }
    
    [MApi cancelRequest:self.snapRequest];
    [MApi cancelRequest:self.chartRequest];
    
    MChartType requestType;
    switch ((NSInteger)self.type) {
        case MTrendChartTypeOneDay:
        case MTrendChartTypeList:
        case MTrendChartTypeBigWord:
        default:
        {
            requestType = MChartTypeOneDay;
            break;
        }
        case MTrendChartTypeFiveDays:
        {
            requestType = MChartTypeFiveDays;
            break;
        }
    }
    
    self.chartRequest = [[MChartRequest alloc] init];
    self.chartRequest.code = stockItem.ID;
    self.chartRequest.subtype = stockItem.subtype;
    self.chartRequest.chartType = requestType;
    
    [MApi sendRequest:self.chartRequest completionHandler:^(MResponse *resp) {
        if (resp.status == MResponseStatusSuccess) {
            MChartResponse *response = (MChartResponse *)resp;
            if (!response.isCacheResponse)
            {
                self.stockItem = stockItem;
                self.items = response.OHLCItems;
                self.dates = [response.tradeDates sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
                    return [obj1 integerValue] > [obj2 integerValue];
                }];
                
                /// 无数据(停牌, 涨跌停...), 无成交时补线
                /// 优先取指数交易时间(response.systemDatetime)来补
                NSString *serverSysDt = response.systemDatetime ?: stockItem.datetime;
                if (serverSysDt.length >= 12) {
                    /// 停牌
                    if (self.items.count == 0 && self.dates.count == 0) {
                        MOHLCItem *item = [[MOHLCItem alloc] init];
                        item.openPrice = stockItem.preClosePrice;
                        item.closePrice = stockItem.preClosePrice;
                        item.averagePrice = stockItem.preClosePrice;
                        item.datetime = [serverSysDt substringToIndex:12];
                        
                        self.items = @[item];
                        self.dates = @[[serverSysDt substringToIndex:8]];
                    }
                    /// 无成交
                    else {
                        MOHLCItem *lastItem = self.items.lastObject;
                        long long nowSystemDatetime = [serverSysDt longLongValue];
                        long long lastTickDatetime = [lastItem.datetime longLongValue];
                        NSString *systemTradeDateString = [serverSysDt substringToIndex:8];
                        NSString *tickTradeDateString = [self.dates lastObject];
                        if ([systemTradeDateString isEqualToString:tickTradeDateString]) {
                            /// *100 因为秒
                            if ((lastTickDatetime * 100) < nowSystemDatetime) {
                                MOHLCItem *item = [lastItem copy];
                                item.tradeVolume = nil; /// 只拷贝最后一根的价格, 所以把量置空
                                item.datetime = [serverSysDt substringToIndex:12];
                                self.items = [self.items arrayByAddingObject:item];
                            }
                        }
                    }
                }
                //////////////////////////////////////////////////
                
                _chartViewFlags.contentNeedsUpdate = true;
                [self _relaodData];
            }
        }
    }];
}

- (void)reloadData {
    /// 先檔
    if (!self.code) {
        return;
    }
    
    [MApi cancelRequest:self.snapRequest];
    [MApi cancelRequest:self.chartRequest];
    
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


#pragma mark private

- (void)_relaodData {
    
    bool isEnquiryLineModeNotToDisappear = (self.enquiryLineMode & MChartEnquiryLineModeNotToDisappear);
    
    /// 如果正在查價，就延遲reloadData
    if (_chartViewFlags.isEnquiring && !isEnquiryLineModeNotToDisappear) {
        _chartViewFlags.delayReloadData = true;
        return;
    }
    
    switch ((NSInteger)_type) {
        case MTrendChartTypeOneDay:
        case MTrendChartTypeFiveDays:
            [self _layoutPriceLabels];
            [self _layoutVolumeLabels];
            [self _setupDatetimeLabels];
            break;
        case MTrendChartTypeBigWord:
            [self _setupDatetimeLabels];
        default:
            break;
    }
    [self contentNeedsUpdate];
    
    /// 长驻查价线模式，查价线重新绘制
    if (_chartViewFlags.isEnquiring && isEnquiryLineModeNotToDisappear) {
        [self _enquireX:_previousEnquireLocationX y:_previousEnquireLocationY];
    }
}

- (NSInteger)_hourFromTime:(NSInteger)intTime {
    return (NSInteger)((float)intTime / 100.0);
}

- (NSInteger)_minFromTime:(NSInteger)intTime {
    float a = ((float)intTime / 100.0);
    NSInteger min = roundf((a-floorf(a)) * 100.0);
    return min;
}

- (NSInteger)_convertMinByInteger:(NSInteger)intTime {
    NSInteger hour = [self _hourFromTime:intTime];
    NSInteger min = [self _minFromTime:intTime];
    return (min + (hour * 60));
}


- (NSInteger)_integerTime:(NSInteger)intTime byAddingMin:(NSInteger)intMin {
    NSInteger hour = [self _hourFromTime:intTime];
    NSInteger min = [self _minFromTime:intTime];
    min += (intMin % 60);
    hour += (intMin / 60) + (min / 60);
    return (hour * 100) + (min % 60);
}

- (NSInteger)_tickCountWithTimezone:(MTimeZone *)timezone {
    NSInteger closeMin = [self _convertMinByInteger:[timezone.closeTime integerValue]];
    NSInteger openMin = [self _convertMinByInteger:[timezone.openTime integerValue]];
    return (closeMin - openMin + 1);
}

- (void)_enquireX:(CGFloat)xLocation y:(CGFloat)yLocation {
    MMarketInfo *info = [MApi marketInfoWithMarket:self.stockItem.market subtype:self.stockItem.subtype];
    
    
    NSInteger oneDayTickCount = [self _tickCount];
    
    NSMutableArray *timezones = [info.timezones mutableCopy];
    NSInteger days;
    CGFloat spacing ;
    /// MARK: spacing 计算
    if (self.type == MTrendChartTypeFiveDays) {
        days = 5;
        spacing = CGRectGetWidth([self drawingChartRect]) / (double)((oneDayTickCount*days));
        [timezones addObjectsFromArray:info.timezones];
        [timezones addObjectsFromArray:info.timezones];
        [timezones addObjectsFromArray:info.timezones];
        [timezones addObjectsFromArray:info.timezones];
    } else {
        spacing = CGRectGetWidth([self drawingChartRect]) / (double)((oneDayTickCount - 1	));
        days = 1;
    }
    
    
    NSInteger touchIndex = (NSInteger)round((xLocation - CGRectGetMinX([self drawingChartRect])) / spacing);
    
    touchIndex = MIN(lastIndex, touchIndex);
    NSInteger inWhichDay = (touchIndex / oneDayTickCount);
    
    
    NSInteger inDayTickIndex = touchIndex % oneDayTickCount;
    __block NSInteger inTimezone = 0;// (touchIndex / 1);
    __block NSInteger inTimezoneTickIndex = inDayTickIndex;
    [info.timezones enumerateObjectsUsingBlock:^(MTimeZone *timezone, NSUInteger idx, BOOL * _Nonnull stop) {
        NSInteger zoneTickCount = [self _tickCountWithTimezone:timezone];
        if (inTimezoneTickIndex >= zoneTickCount) {
            inTimezone++;
            inTimezoneTickIndex -= zoneTickCount;
        } else {
            *stop = YES;
        }
    }];
    
    MTimeZone *timezone = nil;
    if (inTimezone < timezones.count) {
        timezone = timezones[inTimezone];
    }
    if (!timezone) {
        return;
    }
    
    if (inWhichDay >= self.dates.count) {
        return;
    }
    
    xLocation = CGRectGetMinX([self drawingChartRect]) + (touchIndex * spacing);
    //转换时间 1110表示11：10
    NSInteger integerTime = [self _integerTime:[timezone.openTime integerValue]
                                   byAddingMin:inTimezoneTickIndex];
    
    
    __block MOHLCItem *queryItem = nil;
    long long queryDatetime = ([self.dates[inWhichDay] longLongValue] * 10000) + integerTime;
    
    [self.items enumerateObjectsUsingBlock:^(MOHLCItem *item, NSUInteger idx, BOOL * _Nonnull stop) {
        @autoreleasepool {
            if ([item.datetime longLongValue] == queryDatetime) {
                queryItem = [item copy];
                *stop = YES;
            }
            else if ([item.datetime longLongValue] > queryDatetime) {
                /// 从第一根就开始没交易量的特殊处理 ,不是第一根用之前的数据代替
                if (idx == 0) {
                    queryItem = [MOHLCItem new];
                    queryItem.closePrice = self.stockItem.preClosePrice;
                    queryItem.averagePrice = self.stockItem.preClosePrice;
                } else {
                    queryItem = [self.items[idx-1] copy];
                }
                NSLog(@"idx = %ld",idx);
                NSLog(@"closePrice = %@",queryItem.closePrice);
                queryItem.tradeVolume = nil;
                queryItem.datetime = [NSString stringWithFormat:@"%@", @(queryDatetime)];
                *stop = YES;
            }
            else if (idx == (self.items.count - 1)) {
                queryItem = [item copy];
                queryItem.tradeVolume = nil;
                queryItem.datetime = [NSString stringWithFormat:@"%@", @(queryDatetime)];
                *stop = YES;
            }
        }
    }];
    
    if (queryItem) {
        double preClose = [self.stockItem.preClosePrice doubleValue];
        NSString *yAxisString = nil;
        if (self.enquiryLineMode & MChartEnquiryLineModeNone) {
            if (CGRectContainsPoint(CGRectInset([self _priceChartRect], -1, 0), CGPointMake(xLocation, yLocation))) {
                MMarketInfo *info = [MApi marketInfoWithMarket:self.stockItem.market subtype:self.stockItem.subtype];
                double displayValue = preClose + (CGRectGetMidY([self _priceChartRect]) - yLocation) / [self _priceChartScale];
                yAxisString = [MApiFormatter mapi_formatPriceWithValue:displayValue marketInfo:info];
                
            } else if (CGRectContainsPoint(CGRectInset([self _volumeChartRect], -1, 0), CGPointMake(xLocation, yLocation))) {
                double maxVol = self.maxVol;
                CGFloat volumeChartScale = 1.0;
                if (maxVol > 0) {
                    volumeChartScale = (CGRectGetHeight([self _volumeChartRect]) / maxVol);
                }
                double displayValue = maxVol + (CGRectGetMinY([self _volumeChartRect]) - yLocation) / volumeChartScale;
                yAxisString = VolumeChartString(displayValue, maxVol);
            }
        } else {
            yAxisString = queryItem.closePrice;
            yLocation = CGRectGetMidY([self _priceChartRect]) + ((preClose - [queryItem.closePrice doubleValue]) * [self _priceChartScale]);
        }
        
        /// flags changed.
        _chartViewFlags.isEnquiring = true;
        
        _previousEnquireLocationX = xLocation;
        _previousEnquireLocationY = yLocation;
        
        CGPoint touchLocation = CGPointMake(xLocation, yLocation);
        /// 繪製查價線
        [self.enquiryView drawInRect:[self drawingChartRect]
                      priceChartRect:[self _priceChartRect]
                     volumeChartRect:[self _volumeChartRect]
                         yAxisString:yAxisString
                         xAxisString:[NSString stringWithFormat:@"%@:%@",
                                      [_numberFormatter stringFromNumber:@([self _hourFromTime:integerTime])],
                                      [_numberFormatter stringFromNumber:@([self _minFromTime:integerTime])]]
                       touchLocation:touchLocation
                         borderWidth:self.borderWidth
                    yAxisLabelInside:[self isYAxisLabelInside]];
        
        if (_previousEnquireIndex != touchIndex) {
            _previousEnquireIndex = touchIndex;
            /// 通知
            [[NSNotificationCenter defaultCenter] postNotificationName:MChartDidStartEnquiryNotification
                                                                object:queryItem
                                                              userInfo:nil];
        }
    } else {
        //            NSLog(@"NO QueryItem %zd", queryDatetime);
    }
}

- (void)_setupLayerContentsFromCacheImage:(MStockItem *)stockItem {
    CGImageRef cgimage = (__bridge_retained CGImageRef)(self.layer.contents);
    NSString *key = [NSString stringWithFormat:@"%@%@%@",@(self.type), stockItem.ID, NSStringFromCGRect(self.bounds)];
    UIImage *image = [MTrendChartImageCache() objectForKey:key];
    self.layer.contents = (__bridge id _Nullable)(image.CGImage);
    if (cgimage) {
        dispatch_async(_MDispatchQueueGetForQOS(NSQualityOfServiceBackground), ^{
            CFRelease(cgimage);
        });
    }
}
#pragma mark -- 默认绘制走势图 --
- (void)_drawDefaultChartInContext:(CGContextRef)context rect:(CGRect)rect stockItem:(MStockItem *)stockItem OHLCItems:(NSArray *)OHLCItems dates:(NSArray *)dates minPrice:(double)minPrice maxPrice:(double)maxPrice maxVol:(double)maxVol rgMinValue:(double)rgMinValue rgMaxValue:(double)rgMaxValue isCancelled:(BOOL(^)(void))isCancelled {
   
    CGFloat rgScale = ((CGRectGetHeight([self _priceChartRect]) - ([self _upDownSpace]*2)) / 4) / MAX(fabs(rgMinValue), fabs(rgMaxValue));
    
    if (isnan(rgScale) || isinf(rgScale)) {
        rgScale = 0;
    }
    
    BOOL isOption = stockItem.isOption;
    //交易额label赋值
    [self _setupVolumeLabelsValue:maxVol];
    
    double preClose = [stockItem.preClosePrice doubleValue];
    
    double compareMax;
    CGFloat priceChartScale = [self _priceChartScaleWithCompareMax:&compareMax stockItem:stockItem minValue:minPrice maxValue:maxPrice];
    //价格label赋值
    [self _setupPriceLabelsWithCompareMax:compareMax preClose:preClose];
    
    CGFloat volumeChartScale = 1.0;
    if (maxVol > 0) {
        volumeChartScale = (CGRectGetHeight([self _volumeChartRect]) / maxVol);
    }
    
    NSInteger days;
    
    if (self.type == MTrendChartTypeFiveDays) {
        days = 5;
    } else {
        days = 1;
    }
    
    MMarketInfo *info = [MApi marketInfoWithMarket:stockItem.market subtype:stockItem.subtype];
    NSMutableArray *timezone = [info.timezones mutableCopy];
    if (self.type == MTrendChartTypeFiveDays) {
        [timezone addObjectsFromArray:info.timezones];
        [timezone addObjectsFromArray:info.timezones];
        [timezone addObjectsFromArray:info.timezones];
        [timezone addObjectsFromArray:info.timezones];
    }
    if (timezone.count == 0) {
        return;
    }
    NSInteger openTime = [((MTimeZone *)[timezone firstObject]).openTime integerValue];
    NSInteger hour = (NSInteger)openTime / 100;
    NSInteger min = (NSInteger) (((float)(openTime / 100.0) - (float)hour) * 100);
    NSInteger closeTime = [((MTimeZone *)[timezone firstObject]).closeTime integerValue];
    [timezone removeObjectAtIndex:0];
    NSMutableArray *items = [OHLCItems mutableCopy];
    //    NSLog(@"tickCount:%@", @([self tickCount]));
    
    CGFloat x = 0;
    CGFloat y = CGRectGetMidY([self _priceChartRect]);
    CGFloat avgY = CGRectGetMidY([self _priceChartRect]);
    
    double preTickPrice = preClose;
    
    CGFloat timeZoneWidth = CGRectGetWidth([self _priceChartRect]) / (double)days;
    
    NSInteger oneDayTickCount = [self _tickCountWithStockItem:stockItem];
    /// MARK: 注意这边减timezone count
    CGFloat spacing;
    if (self.type == MTrendChartTypeFiveDays) {
        spacing = CGRectGetWidth([self _priceChartRect]) / (double)((oneDayTickCount*days));
    } else {
        spacing = timeZoneWidth / (double)(oneDayTickCount - 1);
    }
    
    
    lastIndex = 0;
    
    CGMutablePathRef gradient = CGPathCreateMutable();
    CGPathMoveToPoint(gradient, NULL, CGRectGetMinX([self _priceChartRect]),
                      CGRectGetMaxY([self _priceChartRect])); // y is price chart middle
    CGPathAddLineToPoint(gradient, NULL, CGRectGetMinX([self _priceChartRect]), y);
    CGFloat gradientX = CGRectGetMinX([self _priceChartRect]);
    
    CGMutablePathRef pricePath = CGPathCreateMutable();
    CGMutablePathRef avgPricePath = CGPathCreateMutable();
    CGMutablePathRef riseVolumePath = CGPathCreateMutable();
    CGMutablePathRef dropVolumePath = CGPathCreateMutable();
    CGMutablePathRef risePath = CGPathCreateMutable();
    CGMutablePathRef dropPath = CGPathCreateMutable();
    
    for (NSInteger dayIndex = 0; dayIndex < dates.count; dayIndex++) {
//        if (isCancelled())  goto Cancelled;
        
        NSString *tickTradeDateString = dates[dayIndex];
        
        long long dateInteger = [tickTradeDateString longLongValue];
        dateInteger *= 10000;
        
        for (NSInteger i = 0; i < oneDayTickCount; i++) {
//            if (isCancelled()) goto Cancelled;
            //每一个时间点 min自动加一
            long long tickDatetime = dateInteger + ((hour * 100) + min);
            
            MOHLCItem *item = [items firstObject];
            
            if (item && [item.datetime length] >= 12) {
                //对象交易时间
                long long itemDatetime = [item.datetime longLongValue];
                
                /// （dayIndex == 0）这里五日线根分时线一样只处理第一根, 五日线后续以前一天的最后一根为准
                if ((dayIndex == 0 && i == 0) && tickDatetime < itemDatetime) {
                    /// 處理30分第一根沒資料, 拿昨收当参考价
                    /// 从第一根就开始没交易量的特殊处理
                    y = CGRectGetMidY([self _priceChartRect]) + ((preClose - [stockItem.preClosePrice doubleValue]) * priceChartScale);
                    avgY = CGRectGetMidY([self _priceChartRect]) + ((preClose - [stockItem.preClosePrice doubleValue]) * priceChartScale);
                }
                else if (itemDatetime < tickDatetime) {
                    //这种是当前点时间 比数据时间点大
                    [items removeObjectAtIndex:0];
                    i--;
                    continue;
                }
                
                if (tickDatetime == itemDatetime) {
                    //相同就绘制这个点，并将其移除数组
                    [items removeObjectAtIndex:0];
                    y = CGRectGetMidY([self _priceChartRect]) + ((preClose - [item.closePrice doubleValue]) * priceChartScale);
                    avgY = CGRectGetMidY([self _priceChartRect]) + ((preClose - [item.averagePrice doubleValue]) * priceChartScale);
                    
                    //// Vol /////////////////////////////////////////////////
                    CGMutablePathRef volumePath = NULL;
                    if ([item.closePrice doubleValue] >= preTickPrice) {
                        volumePath = riseVolumePath;
                    } else {
                        volumePath = dropVolumePath;
                    }
                    
                    preTickPrice = [item.closePrice doubleValue];
                    CGFloat x = CGRectGetMinX([self _volumeChartRect]) + (timeZoneWidth * dayIndex) + (spacing * i);
                    CGPathMoveToPoint(volumePath, NULL, x,
                                      CGRectGetMaxY([self _volumeChartRect]) - ([item.tradeVolume doubleValue] * volumeChartScale));
                    CGPathAddLineToPoint(volumePath, NULL, x,
                                         CGRectGetMaxY([self _volumeChartRect]));
                    
                    //// 红绿柱
                    if (item.rgbar) {
                        CGMutablePathRef rgPath = NULL;
                        if ([item.rgbar doubleValue] >= 0) {
                            rgPath = risePath;
                        } else {
                            rgPath = dropPath;
                        }
                        CGPathMoveToPoint(rgPath, NULL, x,
                                          CGRectGetMidY([self _priceChartRect]) - ([item.rgbar doubleValue] * rgScale));
                        CGPathAddLineToPoint(rgPath, NULL, x,
                                             CGRectGetMidY([self _priceChartRect]));
                    }
                    //////////////////////////////////////////////////////////
                    
                }
            }
            else {
                break;
            }
            
            ////
            x = CGRectGetMinX([self _priceChartRect]) + (timeZoneWidth * dayIndex) + (spacing * i);
            if (self.options[@"FIVEDAY_LINE_CONTINUOUS"] && [self.options[@"FIVEDAY_LINE_CONTINUOUS"] boolValue]) {
                if (i==0 && dayIndex == 0) {
                    CGPathMoveToPoint(pricePath, NULL, x, y);
                    CGPathMoveToPoint(avgPricePath, NULL, x, avgY);
                } else {
                    CGPathAddLineToPoint(pricePath, NULL, x, y);
                    CGPathAddLineToPoint(avgPricePath, NULL, x, avgY);
                }
            } else {
                if (i==0) {
                    CGPathMoveToPoint(pricePath, NULL, x, y);
                    CGPathMoveToPoint(avgPricePath, NULL, x, avgY);
                } else {
                    CGPathAddLineToPoint(pricePath, NULL, x, y);
                    CGPathAddLineToPoint(avgPricePath, NULL, x, avgY);
                }
            }
            CGPathAddLineToPoint(gradient, NULL, (gradientX=x), y);
            
            lastIndex++;
            
            if (hour * 100 + min == closeTime) {
                openTime = [((MTimeZone *)[timezone firstObject]).openTime integerValue];
                closeTime = [((MTimeZone *)[timezone firstObject]).closeTime integerValue];
                hour = (NSInteger)openTime / 100;
                min = (NSInteger) (((float)(openTime / 100.0) - (float)hour) * 100);
                if (timezone.count) {
                    [timezone removeObjectAtIndex:0];
                }
            } else {
                //循环增加分钟
                min++;
                if (min >= 60) {
                    hour++;
                    min = 0;
                }
            }
        }
    }
//    if (isCancelled()) goto Cancelled; /// prepare to draw volume
    
    if (self.gradientColors) {
        CGPathAddLineToPoint(gradient, NULL, gradientX, CGRectGetMaxY([self _priceChartRect]));
        NSMutableArray *colors = [NSMutableArray array];
        for (UIColor *color in self.gradientColors) {
            [colors addObject:((__bridge id)color.CGColor)];
        }
        [self drawLinearGradient:context path:gradient colors:colors locations:self.gradientLocations type:0];
    }
    
    ///////////////// 量
    CGContextSaveGState(context);
    CGContextSetLineWidth(context, RETINA_LINE(MIN(1, spacing)));
    ///涨量
    [self.volumeRiseColor set];
    CGContextAddPath(context, riseVolumePath);
    CGContextStrokePath(context);
    ///跌量
    [self.volumeDropColor set];
    CGContextAddPath(context, dropVolumePath);
    CGContextStrokePath(context);
    CGContextRestoreGState(context);
    
    ///////////////// 红绿柱
    CGContextSaveGState(context);
    CGContextSetLineWidth(context, RETINA_LINE(MIN(1, spacing)));
    [self.volumeRiseColor set];
    CGContextAddPath(context, risePath);
    CGContextStrokePath(context);
    [self.volumeDropColor set];
    CGContextAddPath(context, dropPath);
    CGContextStrokePath(context);
    CGContextRestoreGState(context);
    
    
    
    if (!isOption) {
//        if (isCancelled()) goto Cancelled; /// prepare to draw average line
        ///均线
        CGContextSaveGState(context);
        CGContextSetLineWidth(context, RETINA_LINE(self.averageLineWidth));
        CGContextSetStrokeColorWithColor(context, self.averageLineColor.CGColor);
        CGContextAddPath(context, avgPricePath);
        CGContextStrokePath(context);
        CGContextRestoreGState(context);
    }
    
//    if (isCancelled()) goto Cancelled; /// prepare to draw price line
    ///线
    CGContextSaveGState(context);
    CGContextSetLineWidth(context, RETINA_LINE(self.currentLineWidth));
    CGContextSetStrokeColorWithColor(context, self.currentLineColor.CGColor);
    CGContextAddPath(context, pricePath);
    CGContextStrokePath(context);
    CGContextRestoreGState(context);
    
    {
        //// 最后一个亮点
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!self.lastBlinkDot.superview) {
                [self addSubview:self.lastBlinkDot];
            }
            self.lastBlinkDot.hidden = NO;
            self.lastBlinkDot.center = CGPointMake(x, y);
        });
    }
    
Cancelled:
    CGPathRelease(riseVolumePath);
    CGPathRelease(dropVolumePath);
    CGPathRelease(pricePath);
    CGPathRelease(avgPricePath);
    CGPathRelease(risePath);
    CGPathRelease(dropPath);
    CGPathRelease(gradient);
    lastIndex--;
}




- (void)_layoutVolumeLabels {
    NSArray *labelHiddenParameter = self.options[@"Y_AXIS_VOLUME_LABELS_HIDDEN"];
    
    CGFloat height = MIN(self.yAxisFont.pointSize + 5.0, CGRectGetHeight([self _volumeChartRect])/self.volumeLabels.count);
    for (NSInteger i = 0; i < self.volumeLabels.count; i++) {
        UILabel *label = self.volumeLabels[i];
        if (self.type == (MTrendChartType)MTrendChartTypeList || self.type == (MTrendChartType)MTrendChartTypeBigWord) {
            label.hidden = YES;
            continue;
        }
        
        if (i < labelHiddenParameter.count) {
            label.hidden = [labelHiddenParameter[i] boolValue];
        } else {
            label.hidden = NO;
        }
        
        CGRect frame = label.frame;
        
        if ([self isYAxisLabelInside]) {
            frame.origin.x = CGRectGetMinX([self _volumeChartRect]);
            frame.size.width = CGRectGetWidth([self _volumeChartRect]) / 2;
            label.textAlignment = NSTextAlignmentLeft;
        } else {
            frame.origin.x = 0;
            frame.size.width = self.yAxisLabelInsets.left;
            label.textAlignment = NSTextAlignmentRight;
        }
        
        if (i == 0) {
            frame.origin.y = CGRectGetMinY([self _volumeChartRect]);
        } else if (i == 1) {
            frame.origin.y = CGRectGetMinY([self _volumeChartRect]) + (CGRectGetHeight([self _volumeChartRect]) / 2.0) - (height / 2.0);
        } else {
            frame.origin.y = CGRectGetMinY([self _volumeChartRect]) + CGRectGetHeight([self _volumeChartRect]) - height;
        }
        
        frame.size.height = height;
        label.frame = frame;
    }
}
- (void)_layoutPriceLabels {
    NSArray *labelHiddenParameter = self.options[@"Y_AXIS_PRICE_LABELS_HIDDEN"];
    for (NSInteger i = 0; i < self.leftLabels.count; i++) {
        UILabel *label = self.leftLabels[i];
        if (self.type == (MTrendChartType)MTrendChartTypeList || self.type == (MTrendChartType)MTrendChartTypeBigWord) {
            label.hidden = YES;
            continue;
        }
        
        if (i < labelHiddenParameter.count) {
            label.hidden = [labelHiddenParameter[i] boolValue];
        } else {
            label.hidden = NO;
        }
        
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
    
    labelHiddenParameter = self.options[@"Y_AXIS_UDRATE_LABELS_HIDDEN"];
    for (NSInteger i = 0; i < self.rightLabels.count; i++) {
        UILabel *label = self.rightLabels[i];
        if (self.type == (MTrendChartType)MTrendChartTypeList || self.type == (MTrendChartType)MTrendChartTypeBigWord) {
            label.hidden = YES;
            continue;
        }
        
        if (i < labelHiddenParameter.count) {
            label.hidden = [labelHiddenParameter[i] boolValue];
        } else {
            label.hidden = NO;
        }
        
        CGFloat height = (CGRectGetHeight([self _priceChartRect]) - ([self _upDownSpace] * 2)) / (self.rightLabels.count - 1);
        CGFloat x = 0;
        CGFloat width = 0;
        if ([self isYAxisLabelInside]) {
            width = CGRectGetWidth([self _priceChartRect]) / 2;
            x = CGRectGetMaxX([self _priceChartRect]) - width;
            label.textAlignment = NSTextAlignmentRight;
        } else {
            width = self.yAxisLabelInsets.right;
            x = CGRectGetMaxX([self chartRect]);
            label.textAlignment = NSTextAlignmentLeft;
        }
        label.frame = CGRectMake(x, CGRectGetMinY([self _priceChartRect]) + [self _upDownSpace] + (height * i) - (height / 2.0), width, height);
        
    }
}

- (void)_generateDatetimeLabelsWithCount:(NSInteger)count {
    [self.datetimeLabels makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.datetimeLabels removeAllObjects];
    for (NSInteger i = 0; i < count; i++) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
        label.font = self.xAxisFont;
        label.textColor = self.xAxisTextColor;
        [self.datetimeLabels addObject:label];
        [self addSubview:label];
    }
}
#pragma mark -- 时间label赋值 --
- (void)_setupDatetimeLabels {
    
    [self.datetimeLabels makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    if (self.type == MTrendChartTypeFiveDays) {
        if (self.datetimeLabels.count < 5) {
            [self _generateDatetimeLabelsWithCount:5];
        }
        
        CGFloat width = CGRectGetWidth([self _priceChartRect]) / 5;
        for (NSInteger i = 0; i < 5; i++) {
            UILabel *label = self.datetimeLabels[i];
            label.font = self.xAxisFont;
            label.textColor = self.xAxisTextColor;
            label.backgroundColor = [UIColor clearColor];
            label.textAlignment = NSTextAlignmentCenter;
            label.text = @"/";
            
            if (i < self.dates.count) {
                NSString *datetime = self.dates[i];
                
                if (datetime.length >= 8) {
                    label.text = [NSString stringWithFormat:@"%@/%@", [datetime substringWithRange:NSMakeRange(4, 2)], [datetime substringWithRange:NSMakeRange(6, 2)]];
                }
                
            }
            
            [label sizeToFit];
            CGRect frame = label.frame;
            frame.size.width = width;
            frame.origin.x = CGRectGetMinX([self _priceChartRect]) + (i * width);
            frame.origin.y = CGRectGetMaxY([self chartRect]);
            label.frame = frame;
            
            [self insertSubview:label belowSubview:self.enquiryView];
        }
    }
    else if (self.options[@"CUSTOM_DATETIME"]) {
        NSArray *datetimes = self.options[@"CUSTOM_DATETIME"];
        if (self.datetimeLabels.count < datetimes.count) {
            [self _generateDatetimeLabelsWithCount:datetimes.count];
        }
        
        CGFloat width = CGRectGetWidth([self _priceChartRect]) / datetimes.count;
        for (NSInteger i = 0; i < datetimes.count; i++) {
            UILabel *label = self.datetimeLabels[i];
            label.font = self.xAxisFont;
            label.textColor = self.xAxisTextColor;
            label.backgroundColor = [UIColor clearColor];
            
            NSString *timeString = datetimes[i];
            if (i == 0) {
                label.textAlignment = NSTextAlignmentLeft;
            }
            else if (i == datetimes.count - 1) {
                label.textAlignment = NSTextAlignmentRight;
            }
            else {
                label.textAlignment = NSTextAlignmentCenter;
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
    else {
        if (self.datetimeLabels.count < 2) {
            [self _generateDatetimeLabelsWithCount:2];
        }
        CGFloat width = CGRectGetWidth([self _priceChartRect]) / 2;
        for (NSInteger i = 0; i < 2; i++) {
            UILabel *label = self.datetimeLabels[i];
            label.font = self.xAxisFont;
            label.textColor = self.xAxisTextColor;
            label.backgroundColor = [UIColor clearColor];
            MMarketInfo *info = [MApi marketInfoWithMarket:self.stockItem.market subtype:self.stockItem.subtype];
            
            NSString *timeString = @"一";
            if (i == 0) {
                label.textAlignment = NSTextAlignmentLeft;
                MTimeZone *firstZone = [info.timezones firstObject];
                if (firstZone.openTime.length >= 4) {
                    timeString = [NSString stringWithFormat:@"%@:%@", [firstZone.openTime substringToIndex:2], [firstZone.openTime substringFromIndex:2]];
                }
            } else {
                label.textAlignment = NSTextAlignmentRight;
                MTimeZone *lastZone = [info.timezones lastObject];
                if (lastZone.closeTime.length >= 4) {
                    timeString = [NSString stringWithFormat:@"%@:%@", [lastZone.closeTime substringToIndex:2], [lastZone.closeTime substringFromIndex:2]];
                }
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
}

- (NSInteger)_tickCount {
    MAPI_ASSERT_MAIN_THREAD();
    return [self _tickCountWithStockItem:self.stockItem];
}

- (NSInteger)_tickCountWithStockItem:(MStockItem *)stockItem {
    MMarketInfo *info = [MApi marketInfoWithMarket:stockItem.market subtype:stockItem.subtype];
    //    NSLog(@"info.timezones:%@", info.timezones);
    NSInteger tickCount = 0;
    for (MTimeZone *zone in info.timezones) {
        tickCount += MAX(0, [self _tickCountWithTimezone:zone]);
    }
    //    tickCount = (tickCount / 100) * 60 + 1;
    return tickCount;
}
#pragma mark -- 交易额label赋值 --
- (void)_setupVolumeLabelsValue:(double)maxVol {
    if (![NSThread isMainThread]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self _setupVolumeLabelsValue:maxVol];
        });
        return;
    }
    
    __block NSString *unitString = @"";
    
    for (NSInteger i = 0; i < self.volumeLabels.count; i++) {
        UILabel *label = self.volumeLabels[i];
        double displayValue = maxVol/(double)(i+1);
        NSString *formatString = [MApiFormatter mapi_formatChineseUnitWithValue:displayValue
                                                                       maxValue:maxVol];
        static NSString * const units[3] = {@"", @"万", @"亿"};
        for (int i = 0; i < 3; i++) {
            if (maxVol == displayValue &&
                [formatString rangeOfString:units[i]].location != NSNotFound) {
                unitString = units[i];
            }
            formatString = [formatString stringByReplacingOccurrencesOfString:units[i] withString:@""];
        }
        
        if (i == self.volumeLabels.count - 1) {
            label.text = [unitString stringByAppendingString:@"手"];
        } else {
            label.text = formatString;
        }
    }
    
}
#pragma mark -- 价格label赋值 --
- (void)_setupPriceLabelsWithCompareMax:(double)compareMax preClose:(double)preClose {
    if (![NSThread isMainThread]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self _setupPriceLabelsWithCompareMax:(double)compareMax preClose:(double)preClose];
        });
        return;
    }
    MMarketInfo *info = [MApi marketInfoWithMarket:self.stockItem.market subtype:self.stockItem.subtype];
    NSArray *prices = @[@(preClose + compareMax),
                        @(preClose + (compareMax / 2.0)),
                        @(preClose),
                        @(preClose - (compareMax / 2.0)),
                        @(preClose - compareMax)];
    NSArray *compares = @[@(compareMax), @(compareMax/2.0), @0, @(compareMax/2.0), @(compareMax)];
    for (NSInteger i = 0; i < prices.count; i++) { @autoreleasepool {
        UILabel *priceLabel = self.leftLabels[i];
        UILabel *rateLabel = self.rightLabels[i];
        NSString *priceString = nil;
        if ((priceString = [MApiFormatter mapi_formatPriceWithValue:[prices[i] doubleValue] marketInfo:info])) {
            priceLabel.text = priceString;
            double rate = ([compares[i] doubleValue] / preClose) * 100.0;
            
            NSString *formatString = @"%.2f%%";
            if (self.options[@"Y_AXIS_UDRATE_LABELS_FORMAT"]) {
                formatString = self.options[@"Y_AXIS_UDRATE_LABELS_FORMAT"][i];
            }
            rateLabel.text = [NSString stringWithFormat:formatString, rate + 0.0000001]; /// float fixes
            
        }
        else {
            priceLabel.text = @"一";
            rateLabel.text = @"一";
        }
    }}
}

- (CGFloat)_priceChartScale {
    MAPI_ASSERT_MAIN_THREAD();
    return [self _priceChartScaleWithStockItem:self.stockItem minValue:self.minValue maxValue:self.maxValue];
}

- (CGFloat)_priceChartScaleWithStockItem:(MStockItem *)stockItem minValue:(double)minValue maxValue:(double)maxValue {
    return [self _priceChartScaleWithCompareMax:NULL stockItem:stockItem minValue:minValue maxValue:maxValue];
}

- (CGFloat)_priceChartScaleWithCompareMax:(double *)compareMax stockItem:(MStockItem *)stockItem minValue:(double)minValue maxValue:(double)maxValue {
    
    double preClose = [stockItem.preClosePrice doubleValue];
    double cm = fabs(MAX(maxValue - preClose, preClose - minValue));
    CGFloat priceChartScale = 1.0;
    if (preClose > 0) {
        priceChartScale = ((CGRectGetHeight([self _priceChartRect]) - ([self _upDownSpace]*2)) / 2) / cm;
    }
    if (compareMax) {
        *compareMax = cm;
    }
    return isinf(priceChartScale)?1:priceChartScale;
}

- (void)_clear {
    self.stockItem = nil;
    self.items = nil;
    self.dates = nil;
    [self.datetimeLabels makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.leftLabels makeObjectsPerformSelector:@selector(setText:) withObject:@"一"];
    [self.rightLabels makeObjectsPerformSelector:@selector(setText:) withObject:@"一"];
    [self.volumeLabels makeObjectsPerformSelector:@selector(setText:) withObject:@"一"];
    self.lastBlinkDot.hidden = YES;
}

- (CGFloat)_upDownSpace {
    if (self.type == (MTrendChartType)MTrendChartTypeList) {
        return 0;
    }
    CGFloat upDownSpace = CGRectGetHeight([self _priceChartRect]) * 0.07;
    if (isinf(upDownSpace) || isnan(upDownSpace)) {
        return 0;
    }
    return upDownSpace;
}

- (CGRect)_priceChartRect {
    if (self.type == (MTrendChartType)MTrendChartTypeList || self.type == (MTrendChartType)MTrendChartTypeBigWord) {
        return CGRectInset([self chartRect], 1.0, 1.0);
    }
    CGFloat height = CGRectGetHeight([self chartRect]);
    height *= (3.0/4.0);
    CGRect rect = CGRectMake(CGRectGetMinX([self chartRect]) + self.borderWidth,
                             CGRectGetMinY([self chartRect]) + self.borderWidth,
                             CGRectGetWidth([self chartRect]) - (self.borderWidth * 2.0),
                             height - self.borderWidth - (self.insideLineWidth / 2.0) - 5/*上下图间距*/);
    return CGRectInset(rect, 1.0, 1.0);
}

- (CGRect)_volumeChartRect {
    if (self.type == (MTrendChartType)MTrendChartTypeList || self.type == (MTrendChartType)MTrendChartTypeBigWord) {
        return CGRectZero;
    }
    CGFloat height = CGRectGetHeight([self chartRect]);
    height *= (1.0/4.0);
    CGRect rect = CGRectMake(CGRectGetMinX([self chartRect]) + self.borderWidth,
                             CGRectGetMinY([self chartRect]) + CGRectGetHeight([self chartRect]) - height + (self.insideLineWidth / 2.0),
                             CGRectGetWidth([self chartRect]) - (self.borderWidth * 2.0),
                             height - self.borderWidth - (self.insideLineWidth / 2.0));
    return CGRectInset(rect, 1.0, 1.0);
}
#pragma mark -- X轴线 --
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
    
    if (self.type == (MTrendChartType)MTrendChartTypeBigWord) {
        goto XAXIS_END_STROKE;
    }
    
    CGFloat dash[] = {MAX(2, self.insideLineWidth), MAX(2, self.insideLineWidth)};
    CGContextSetLineDash (context, 0, dash, sizeof(dash) / sizeof(CGFloat));
    //虚线
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
    
    // volume
    y = CGRectGetMinY([self _volumeChartRect]) + (CGRectGetHeight([self _volumeChartRect]) / 2);
    CGContextMoveToPoint(context, CGRectGetMinX([self _volumeChartRect]), y);
    CGContextAddLineToPoint(context, CGRectGetMaxX([self _volumeChartRect]), y);
XAXIS_END_STROKE:
    CGContextStrokePath(context);
    CGContextRestoreGState(context);
}
#pragma mark -- Y轴线 --
- (void)_drawYAxisLineInRect:(CGRect)borderRect context:(CGContextRef)context stockItem:(MStockItem *)stockItem {
    CGContextSaveGState(context);
    CGContextSetStrokeColorWithColor(context, self.insideLineColor.CGColor);
    CGContextSetLineWidth(context, RETINA_LINE(self.insideLineWidth));
    NSUInteger part = 4;
    
    if (self.type == MTrendChartTypeFiveDays) {
        part = 5;
    }
    else if (self.options[@"CUSTOM_DATETIME"]) {
        NSArray *datetimes = self.options[@"CUSTOM_DATETIME"];
        part = datetimes.count - 1;
    }
    CGFloat spacing = CGRectGetWidth([self _priceChartRect]) / part;
    
    ///
    CGFloat solidLineTolerance = 0;
    NSMutableArray *yAxisForZone = [@[] mutableCopy];
    if (self.options[@"Y_AXIS_TICK_SPACING"] && self.type != MTrendChartTypeFiveDays) {
        part = 0;
        NSInteger tickSpacing = [self.options[@"Y_AXIS_TICK_SPACING"] integerValue];
        CGFloat perTickSpacing = CGRectGetWidth([self _priceChartRect]) / [self _tickCountWithStockItem:stockItem];
        solidLineTolerance = perTickSpacing;
        
        MMarketInfo *marketInfo = [MApiHelper marketInfoWithMarket:stockItem.market subtype:stockItem.subtype];
        CGFloat x = CGRectGetMinX([self _priceChartRect]);
        for (MTimeZone *zone in marketInfo.timezones) {
            NSInteger zoneTickCount = [self _tickCountWithTimezone:zone];
            part += (NSInteger)(zoneTickCount / tickSpacing);
            x += (perTickSpacing * zoneTickCount);
            [yAxisForZone addObject:@(x)];
        }
        spacing = tickSpacing * perTickSpacing;
    }
    
    CGFloat zoneStartX = CGRectGetMinX([self _priceChartRect]);
    
    BOOL drawSolid = NO;
    for (NSInteger i = 0, j = (i + 1); i < part && j < (part); i++) {
        CGFloat x = zoneStartX + (spacing * j);
        if (yAxisForZone.count > 0 && x + solidLineTolerance + 0.00000001/*because of [self _tickCountWithTimezone]*/ >= ([[yAxisForZone firstObject] doubleValue])) {
            zoneStartX = [[yAxisForZone firstObject] doubleValue];
            [yAxisForZone removeObjectAtIndex:0]; // pop
            j = 0;
            i--;
            drawSolid = YES;
            continue;
        }
        
        CGContextMoveToPoint(context, x, CGRectGetMinY([self _priceChartRect]));
        CGContextAddLineToPoint(context, x, CGRectGetMaxY([self _priceChartRect]));
        CGContextMoveToPoint(context, x, CGRectGetMinY([self _volumeChartRect]));
        CGContextAddLineToPoint(context, x, CGRectGetMaxY([self _volumeChartRect]));
        
        if (drawSolid) {
            drawSolid = NO;
            CGContextStrokePath(context);
        } else {
            CGContextSaveGState(context); {
                if (self.type != (MTrendChartType)MTrendChartTypeBigWord) {
                    CGFloat dash[] = {MAX(2, self.insideLineWidth), MAX(2, self.insideLineWidth)};
                    CGContextSetLineDash (context, 0, dash, sizeof(dash) / sizeof(CGFloat));
                }
                CGContextStrokePath(context);
            } CGContextRestoreGState(context);
        }
        j++;
    }
    CGContextRestoreGState(context);
}
#pragma mark -- 边框 --
- (void)_drawBorderRect:(CGRect)borderRect inContext:(CGContextRef)context {
    CGContextSaveGState(context);
    {
        CGContextSetStrokeColorWithColor(context, self.borderColor.CGColor);
        CGContextSetLineWidth(context, RETINA_LINE(self.borderWidth));
        CGFloat offset = self.borderWidth / 2;
        CGContextStrokeRect(context, CGRectInset([self _priceChartRect], -offset, -offset));
        CGContextStrokeRect(context, CGRectInset([self _volumeChartRect], -offset, -offset));
    } CGContextRestoreGState(context);
}


#pragma mark getter

- (UIColor *)dropColor {
    return self.volumeDropColor;
}

- (UIColor *)riseColor {
    return self.volumeRiseColor;
}

- (NSArray *)items {
    MAPI_ASSERT_MAIN_THREAD();
    return _items;
}

- (NSArray *)dates {
    MAPI_ASSERT_MAIN_THREAD();
    return _dates;
}

- (double)maxVol {
    MAPI_ASSERT_MAIN_THREAD();
    return _maxVol;
}


#pragma mark setter

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

- (void)setRangeRiseTextColor:(UIColor *)rangeRiseTextColor {
    _rangeRiseTextColor = rangeRiseTextColor;
    for (NSInteger i = 0; i < 2; i++) {
        UILabel *label = self.rightLabels[i];
        label.textColor = rangeRiseTextColor;
    }
}

- (void)setRangeFlatTextColor:(UIColor *)rangeFlatTextColor {
    _rangeFlatTextColor = rangeFlatTextColor;
    if (self.rightLabels.count >= 3) {
        UILabel *label = self.rightLabels[2];
        label.textColor = rangeFlatTextColor;
    }
}

- (void)setRangeDropTextColor:(UIColor *)rangeDropTextColor {
    _rangeDropTextColor = rangeDropTextColor;
    if (self.rightLabels.count >= 3) {
        for (NSInteger i = 3; i < self.rightLabels.count; i++) {
            UILabel *label = self.rightLabels[i];
            label.textColor = rangeDropTextColor;
        }
    }
}

- (void)setVolumeTextColor:(UIColor *)volumeTextColor {
    _volumeTextColor = volumeTextColor;
    [self.volumeLabels makeObjectsPerformSelector:@selector(setTextColor:) withObject:volumeTextColor];
}

- (void)setXAxisFont:(UIFont *)xAxisFont {
    [super setXAxisFont:xAxisFont];
    _chartViewFlags.chartFrameChanged = true;
    if (self.window) {
        [self _setupDatetimeLabels];
//        [self contentNeedsUpdate];
    }
}

- (void)setYAxisFont:(UIFont *)yAxisFont {
    [super setYAxisFont:yAxisFont];
    [self.leftLabels makeObjectsPerformSelector:@selector(setFont:) withObject:self.yAxisFont];
    [self.rightLabels makeObjectsPerformSelector:@selector(setFont:) withObject:self.yAxisFont];
    [self.volumeLabels makeObjectsPerformSelector:@selector(setFont:) withObject:self.yAxisFont];
}

- (void)setType:(MTrendChartType)type {
    _type = type;
    [self _clear];
//    [self contentNeedsUpdate];
}

- (void)setLastBlinkDot:(UIView *)lastBlinkDot {
    if (_lastBlinkDot != lastBlinkDot) {
        [_lastBlinkDot removeFromSuperview];
        _lastBlinkDot = lastBlinkDot;
    }
}


#pragma mark UIGestureRecognizerDelegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    return [super gestureRecognizerShouldBegin:gestureRecognizer] &&
    !(self.type == (MTrendChartType)MTrendChartTypeList || self.type == (MTrendChartType)MTrendChartTypeBigWord);
}


#pragma mark override super 父类调用，是执行了自定义calay的代理

- (_MAsyncLayerDisplayTask *)override_newAsyncDisplayTask {
    if (self.type == (MTrendChartType)MTrendChartTypeList || self.type == (MTrendChartType)MTrendChartTypeBigWord) {
        if (_chartViewFlags.contentNeedsUpdate == false) return nil;
    }
    
    _MAsyncLayerDisplayTask *task = [_MAsyncLayerDisplayTask new];
    
    MStockItem *stockItem = self.stockItem;//[self.stockItem copy];
    NSArray *items = self.items;//[self.items copy];
    NSArray *dates = self.dates;//[self.dates copy];
    
    if (self.type == (MTrendChartType)MTrendChartTypeList || self.type == (MTrendChartType)MTrendChartTypeBigWord) {
        if (!stockItem) return nil;
    }
//    CGSize size = self.frame.size;
    task.display = ^(CGContextRef context, CGSize size, BOOL(^isCancelled)(void)) {
        
        CGRect rect = [self chartRect];
        
        switch ((NSInteger)self.type) {
            case MTrendChartTypeOneDay:
            case MTrendChartTypeFiveDays:
                [self _drawBorderRect:rect inContext:context];
                [self _drawXAxisLineInRect:rect context:context];
                [self _drawYAxisLineInRect:rect context:context stockItem:stockItem];
                break;
            case MTrendChartTypeBigWord:
                [self _drawBorderRect:rect inContext:context];
                [self _drawXAxisLineInRect:rect context:context];
                [self _drawYAxisLineInRect:rect context:context stockItem:stockItem];
                break;
                
        }
        
        if (!items || items.count == 0 || !stockItem) {
            return;
        }
        
        BOOL isOption = stockItem.isOption;
        double preClose = [stockItem.preClosePrice doubleValue];
        __block double maxValue = preClose;
        __block double minValue = preClose;
        __block double maxVol = 0;
        __block double rgMaxValue = DBL_MIN;
        __block double rgMinValue = DBL_MAX;
        
        if (items.count == 1) {
            double lp = stockItem.preClosePrice.doubleValue * 0.01;
            MMarketInfo *marketInfo = [MApiHelper marketInfoWithMarket:stockItem.market subtype:stockItem.subtype];

            maxValue = [[NSString mapi_stringWithValue:stockItem.preClosePrice.doubleValue + lp
                                               decimal:marketInfo.decimal] doubleValue];
            minValue = [[NSString mapi_stringWithValue:stockItem.preClosePrice.doubleValue - lp
                                               decimal:marketInfo.decimal] doubleValue];
        } else {
            //获取最大，最小值
            [items enumerateObjectsUsingBlock:^(MOHLCItem *item, NSUInteger idx, BOOL * _Nonnull stop) {
                
//                if (isCancelled()) *stop = YES;
                
                if ([item.tradeVolume doubleValue] > maxVol) {
                    maxVol = [item.tradeVolume doubleValue];
                }
                
                if ([item.closePrice doubleValue] > maxValue) {
                    maxValue = [item.closePrice doubleValue];
                }
                else if ([item.closePrice doubleValue] < minValue) {
                    minValue = [item.closePrice doubleValue];
                }
                else if (!isOption && self.type != (MTrendChartType)MTrendChartTypeList && self.type != (MTrendChartType)MTrendChartTypeBigWord) {
                    if ([item.averagePrice doubleValue] > maxValue) {
                        maxValue = [item.averagePrice doubleValue];
                    }
                    else if ([item.averagePrice doubleValue] < minValue) {
                        minValue = [item.averagePrice doubleValue];
                    }
                }
                //指数才有的
                if ([item.rgbar doubleValue] > rgMaxValue) {
                    rgMaxValue = [item.rgbar doubleValue];
                }
                if ([item.rgbar doubleValue] < rgMinValue) {
                    rgMinValue = [item.rgbar doubleValue];
                }
            }];
        }
//        if (isCancelled()) return;
        
        self.minValue = minValue;
        self.maxValue = maxValue;
        self.maxVol = maxVol;
        
        
        if (self.type == (MTrendChartType)MTrendChartTypeList || self.type == (MTrendChartType)MTrendChartTypeBigWord) {
//            [self _drawListChartInContext:context rect:rect stockItem:stockItem OHLCItems:items dates:dates minPrice:minValue maxPrice:maxValue isCancelled:isCancelled];
        } else {
            //默认绘图
            [self _drawDefaultChartInContext:context rect:rect stockItem:stockItem OHLCItems:items dates:dates minPrice:minValue maxPrice:maxValue maxVol:maxVol rgMinValue:rgMinValue rgMaxValue:rgMaxValue isCancelled:isCancelled];
        }
        
    };
    
    if (self.type == (MTrendChartType)MTrendChartTypeList || self.type == (MTrendChartType)MTrendChartTypeBigWord) {
        task.didDisplay = ^(CALayer *layer, BOOL finished) {
            if (finished) {
                NSString *key = [NSString stringWithFormat:@"%@%@%@",@(self.type), stockItem.ID, NSStringFromCGRect(self.bounds)];
                CGImageRef image = (__bridge CGImageRef)layer.contents;
                if (image) {
                    [MTrendChartImageCache() setObject:[UIImage imageWithCGImage:image] forKey:key];
                }
                _chartViewFlags.contentNeedsUpdate = false;
            }
        };
    }
    return task;
}

- (void)override_startEnquireWithGesture:(UIGestureRecognizer *)gestureRecognizer {
    CGFloat xLocation = [gestureRecognizer locationInView:self].x;
    xLocation = MIN(CGRectGetMaxX([self drawingChartRect]), xLocation);
    xLocation = MAX(CGRectGetMinX([self drawingChartRect]), xLocation);
    
    CGFloat yLocation = [gestureRecognizer locationInView:self].y;
    yLocation = MIN(CGRectGetMaxY([self drawingChartRect]), yLocation);
    yLocation = MAX(CGRectGetMinY([self drawingChartRect]), yLocation);
    [self _enquireX:xLocation y:yLocation];
}
#pragma mark -- 结束查价 --
- (void)override_endEnquire {
    
    [self removeGestureRecognizer:self.panGestureRecognizer];
    
    if (_chartViewFlags.isEnquiring) {
        
        /// flags changed.
        _chartViewFlags.isEnquiring = false;
        
        [self.enquiryView clear];
        //
        [[NSNotificationCenter defaultCenter] postNotificationName:MChartDidEndEnquiryNotification
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
