//
//  MOHLCResponse.m
//  TSApi
//
//  Created by Mitake on 2015/3/18.
//  Copyright (c) 2015年 Mitake. All rights reserved.
//

#import "MOHLCResponse.h"
#import "NSString+MApiAdditions.h"
#import "MApiFormatter.h"
#import "MOHLCItem.h"

typedef enum : NSUInteger {
    MOHLCProcessNew,
    MOHLCProcessModify,
} MOHLCProcessType;

@implementation MOHLCResponse

- (id)initWithData:(NSData *)data request:(MOHLCRequest *)request timestamp:(NSString *)timestamp headers:(NSDictionary *)headers {
    self = [super initWithData:data request:request timestamp:timestamp headers:headers];
    if (self) {
        MRESPONSE_TRY_PARSE_DATA_START
        MOHLCResponse *response = [(id<MApiCaching>)request cachedObject];
        NSMutableArray *cachedOHLCItems = [response.OHLCItems mutableCopy];
        
        self.market = [request.code pathExtension];
        self.subtype = request.subtype;
        self.priceAdjustedMode = request.priceAdjustedMode;
        
        NSMutableArray *OHLCItems = [NSMutableArray array];
        NSArray *dataRows = [data componentsSeparatedByByte:0x03];
        for (NSData *data in dataRows) {
            MOHLCItem *OHLCItem = [[MOHLCItem alloc] initWithData:data market:self.market subtype:request.subtype];
            if (OHLCItem) {
                [OHLCItems addObject:OHLCItem];
            }
        }
        if ([cachedOHLCItems count] > 0) {
            NSInteger lastIndex = [cachedOHLCItems count] - 1;
            MOHLCItem *lastCachedOHLCItem = [cachedOHLCItems lastObject];
            NSString *lastDateTime = lastCachedOHLCItem.datetime;
            for (MOHLCItem *item in OHLCItems) {
                NSString *datetime = item.datetime;
                if ([datetime longLongValue] > [lastDateTime longLongValue]) {
                    [cachedOHLCItems addObject:item];
                }
                else if ([datetime longLongValue] == [lastDateTime longLongValue]) {
                    [cachedOHLCItems replaceObjectAtIndex:lastIndex withObject:item];
                }
            }
            OHLCItems = cachedOHLCItems;
        }
        self.OHLCItems = OHLCItems;
        self.fq = response.fq;
        MRESPONSE_TRY_PARSE_DATA_END
    }
    return self;
}



- (NSString *)_pureDatetimeWithDatetime:(NSString *)datetime {
    if (datetime == nil) return nil;
    static NSRegularExpression *regex;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        regex = [NSRegularExpression regularExpressionWithPattern:@"[-: ]" options:NSRegularExpressionCaseInsensitive error:nil];
    });
    return [regex stringByReplacingMatchesInString:datetime options:0 range:NSMakeRange(0, [datetime length]) withTemplate:@""];
}

- (void)setFq:(NSArray *)fq {
    if (fq == nil) return; /// use cached fq
    if (_fq.count > fq.count) return; /// use cached fq
    _fq = fq;
}

- (void)_XR_calculate {
#define _xr_format(v) [MApiFormatter mapi_formatPriceWithValue:v marketInfo:marketInfo]

    if (self.fq == nil) return;
    
    MMarketInfo *marketInfo = [MApiHelper marketInfoWithMarket:self.market subtype:self.subtype];
    
    if (self.priceAdjustedMode == MOHLCPriceAdjustedModeForward) {
        
        void (^ForwardingItem)(MOHLCItem *) = ^(MOHLCItem *item) {
            double open = item.openPrice.doubleValue;
            double high = item.highPrice.doubleValue;
            double low = item.lowPrice.doubleValue;
            double close = item.closePrice.doubleValue;
            double reference = item.referencePrice.doubleValue;
            // s：股票名 ， a：日期， b ：每股红利，c：送转股比例，d：配股价格，e：实际配股比例
            for (NSDictionary *dict in self.fq) {
                NSString *datetime = [self _pureDatetimeWithDatetime:dict[@"a"]];
                if (datetime.longLongValue/1000000 > item.datetime.longLongValue/1000000) {
                    
                    double (^ForwardingString)(double) = ^double(double current) {
                        double b = [dict[@"b"] doubleValue];
                        double c = [dict[@"c"] doubleValue];
                        double d = [dict[@"d"] doubleValue];
                        double e = [dict[@"e"] doubleValue];
                        // 前复权价格 = (当前价格 - (每股红利 - 配股价格 * 配股比例)) / ( 1 + 送股比例 + 配股比例)
                        //          = (current - (b - (d * e))) / (1 + c + e)
                        return (current - (b - (d * e))) / (1 + c + e);
                    };
                    
                    open = ForwardingString(open);
                    high = ForwardingString(high);;
                    low = ForwardingString(low);;
                    close = ForwardingString(close);;
                    reference = ForwardingString(reference);
                }
            }
            
            item.openPrice = _xr_format(open);
            item.highPrice = _xr_format(high);
            item.lowPrice = _xr_format(low);
            item.closePrice = _xr_format(close);
            item.referencePrice = _xr_format(reference);
            item.xred = YES;
        };
        
        for (MOHLCItem *item in self.OHLCItems) {
            if (!item.xred) {
                ForwardingItem(item);
            }
        }
    }
    else if (self.priceAdjustedMode == MOHLCPriceAdjustedModeBackward) {
        
        void (^BackwardingItem)(MOHLCItem *) = ^(MOHLCItem *item) {
            double open = item.openPrice.doubleValue;
            double high = item.highPrice.doubleValue;
            double low = item.lowPrice.doubleValue;
            double close = item.closePrice.doubleValue;
            double reference = item.referencePrice.doubleValue;
            
            // s：股票名 ， a：日期， b ：每股红利，c：送转股比例，d：配股价格，e：实际配股比例
            for (NSInteger i = self.fq.count - 1; i >= 0; i--) {
                NSDictionary *dict = self.fq[i];
                NSString *datetime = [self _pureDatetimeWithDatetime:dict[@"a"]];
                if (datetime.longLongValue/1000000 <= item.datetime.longLongValue/1000000) {
                    
                    double (^BackwardingString)(double) = ^double(double current) {
                        double b = [dict[@"b"] doubleValue];
                        double c = [dict[@"c"] doubleValue];
                        double d = [dict[@"d"] doubleValue];
                        double e = [dict[@"e"] doubleValue];
                        // 后复权价格 = 当前价格 * (1 + 送股比例 + 配股比例) + (每股红利 - 配股价格 * 配股比例)
                        return current * (1 + c + e) + (b - (d * e));
                    };
                    
                    open = BackwardingString(open);
                    high = BackwardingString(high);
                    low = BackwardingString(low);
                    close = BackwardingString(close);
                    reference = BackwardingString(reference);
                }
            }
            
            item.openPrice = _xr_format(open);
            item.highPrice = _xr_format(high);
            item.lowPrice = _xr_format(low);
            item.closePrice = _xr_format(close);
            item.referencePrice = _xr_format(reference);
            item.xred = YES;
        };
        
        for (MOHLCItem *item in self.OHLCItems) {
            if (!item.xred) {
                BackwardingItem(item);
            }
        }
    }
#undef _xr_format
}



#pragma mark - 补资料
- (NSArray *)OHLCItemsByPeriodType:(MOHLCPeriod)period andSnapshotStockItem:(MStockItem *)snapshotStockItem {
    __block NSMutableArray *mutableArray = [@[] mutableCopy];
    __block MOHLCItem *lastItem = [self.OHLCItems lastObject];
    __block BOOL needsXRRecalculate = NO;

    BOOL (^setDateTimePriceVolumeToOHLCItem)(MOHLCItem *ohlcItem, MOHLCProcessType type) = ^(MOHLCItem *ohlcItem, MOHLCProcessType type) {
        ohlcItem.datetime = snapshotStockItem.datetime;
        
        
        if (type == MOHLCProcessModify) {
            
            /// 笔记笔记：如果是复权response, 就直接用snap的值, 因为后面还是会呼叫_XR_calculate重算
            if (self.priceAdjustedMode == MOHLCPriceAdjustedModeNone) {
                ohlcItem.highPrice = ohlcItem.highPrice.doubleValue > snapshotStockItem.highPrice.doubleValue?
                ohlcItem.highPrice:snapshotStockItem.highPrice;
                ohlcItem.lowPrice = ohlcItem.lowPrice.doubleValue < snapshotStockItem.lowPrice.doubleValue?
                ohlcItem.lowPrice:snapshotStockItem.lowPrice;
            } else {
                ohlcItem.highPrice = snapshotStockItem.highPrice;
                ohlcItem.lowPrice = snapshotStockItem.lowPrice;
            }
            
            /// 日
            if (period == MOHLCPeriodDay) {
                ohlcItem.openPrice = snapshotStockItem.openPrice;
                ohlcItem.tradeVolume = snapshotStockItem.volume;
                ohlcItem.amount = snapshotStockItem.amount;
                needsXRRecalculate = YES;
            }
            /// 周
            else if (period == MOHLCPeriodWeek) {
                double volume = [snapshotStockItem.volume doubleValue];
                double amount = [snapshotStockItem.amount doubleValue];
                MOHLCItem *lastOHLCItem = [self.OHLCItems lastObject];
                volume += [lastOHLCItem.tradeVolume doubleValue];
                amount += [lastOHLCItem.amount doubleValue];
                ohlcItem.tradeVolume = [NSString stringWithFormat:@"%.2f", volume];
                ohlcItem.amount = [NSString stringWithFormat:@"%@", @(amount)];
            }
            /// 月
            else if (period == MOHLCPeriodMonth) {
                double volume = [lastItem.tradeVolume doubleValue] + [snapshotStockItem.volume doubleValue];
                double amount = [lastItem.amount doubleValue] + [snapshotStockItem.amount doubleValue];
                ohlcItem.tradeVolume = [NSString stringWithFormat:@"%.2f", volume];
                ohlcItem.amount = [NSString stringWithFormat:@"%@", @(amount)];
            }
            
        } else {
            needsXRRecalculate = YES;
            ohlcItem.highPrice = snapshotStockItem.highPrice;
            ohlcItem.lowPrice = snapshotStockItem.lowPrice;
            
            ohlcItem.openPrice = snapshotStockItem.openPrice;
            ohlcItem.tradeVolume = snapshotStockItem.volume;
            ohlcItem.amount = snapshotStockItem.amount;
        }
        ohlcItem.closePrice = snapshotStockItem.lastPrice;
        
        if (needsXRRecalculate) {
            ohlcItem.xred = NO;
        }
        return needsXRRecalculate;
    };
    
    void(^modifyLastTick)() = ^(void) {
        [mutableArray removeAllObjects];
        setDateTimePriceVolumeToOHLCItem(lastItem, MOHLCProcessModify);
        [mutableArray addObjectsFromArray:self.OHLCItems];
    };
    
    void(^addNewTick)() = ^(void) {
        [mutableArray removeAllObjects];
        lastItem = [[MOHLCItem alloc] init];
        setDateTimePriceVolumeToOHLCItem(lastItem, MOHLCProcessNew);
        lastItem.averagePrice = @"";
        lastItem.referencePrice = snapshotStockItem.preClosePrice;
        [mutableArray addObjectsFromArray:self.OHLCItems];
        [mutableArray addObject:lastItem];
    };
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT+8:00"]];
    NSDate*(^formatedDateFromDateString)(NSString *dateString) = ^NSDate*(NSString *dateString) {
        NSDate *date;
        if (dateString.length == @"yyyyMMddHHmmss".length) {
            [formatter setDateFormat:@"yyyyMMddHHmmss"];
            date = [formatter dateFromString:dateString];
        }
        else if (dateString.length == @"yyyyMMddHmmss".length) {
            [formatter setDateFormat:@"yyyyMMddHmmss"];
            date = [formatter dateFromString:dateString];
        }
        return date;
    };
    
    NSDate *snapshotDate = formatedDateFromDateString(snapshotStockItem.datetime);
    NSDate *lastItemDate = formatedDateFromDateString(lastItem.datetime) ? formatedDateFromDateString(lastItem.datetime) : snapshotDate;
    
    [mutableArray addObjectsFromArray:self.OHLCItems];
    
    //尚未開盤
    if (!snapshotStockItem.openPrice) {
        
    }
    else if (self.OHLCItems.count == 0) {
        addNewTick();
    }
    else if (period == MOHLCPeriodDay) {
        /*
         * 日線:
         * 同一日須判斷成交量
         */
        if ([self snapshotDate:snapshotDate compareDateWithLastItemDate:lastItemDate] == NSOrderedSame && ([@([snapshotStockItem.volume doubleValue]) compare:@([lastItem.tradeVolume doubleValue])] == NSOrderedDescending)) {
            modifyLastTick();
        }
        else if ([self snapshotDate:snapshotDate compareDateWithLastItemDate:lastItemDate] == NSOrderedDescending){
            addNewTick();
        }
    }
    else if (period == MOHLCPeriodWeek) {
        /*
         * 周線:
         * 同一日則不處理
         * 新一日須判斷是否為同一周
         */
        if ([self snapshotDate:snapshotDate compareDateWithLastItemDate:lastItemDate] == NSOrderedDescending) {
            NSComparisonResult compareResult = [self snapshotDate:snapshotDate compareToDetermineWhetherTheSameWeekWithLastItemDate:lastItemDate];
            if (compareResult == NSOrderedSame) {
                modifyLastTick();
            }
            else if (compareResult == NSOrderedDescending) {
                addNewTick();
            }
        }
    }
    else if (period == MOHLCPeriodMonth) {
        /*
         * 月線:
         * 同一日則不處理
         * 新一日須判斷是否為同一月
         */
        if ([self snapshotDate:snapshotDate compareDateWithLastItemDate:lastItemDate] == NSOrderedDescending) {
            NSComparisonResult compareResult = [self snapshotDate:snapshotDate compareMonthWithLastItemDate:lastItemDate];
            if (compareResult == NSOrderedSame) {
                modifyLastTick();
            }
            else if (compareResult == NSOrderedDescending) {
                addNewTick();
            }
        }
    }
    self.OHLCItems = [mutableArray copy];
    if (needsXRRecalculate) {
        [self _XR_calculate];
    }
    return self.OHLCItems;
}

- (NSComparisonResult)snapshotDate:(NSDate *)snapshotDate compareMonthWithLastItemDate:(NSDate *)lastItemDate {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSInteger snapshotDateMonthNumber = [[calendar components:NSMonthCalendarUnit fromDate:snapshotDate] month];
    NSInteger lastItemDateMonthNumber = [[calendar components:NSMonthCalendarUnit fromDate:lastItemDate] month];
    return [@(snapshotDateMonthNumber) compare:@(lastItemDateMonthNumber)];
}

- (NSComparisonResult)snapshotDate:(NSDate *)snapshotDate compareToDetermineWhetherTheSameWeekWithLastItemDate:(NSDate *)lastItemDate {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    calendar.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT+8:00"];
    NSInteger snapshotDateWeekNumber = [[calendar components:NSWeekOfYearCalendarUnit fromDate:snapshotDate] weekOfYear];
    NSInteger lastItemDateWeekNumber = [[calendar components:NSWeekOfYearCalendarUnit fromDate:lastItemDate] weekOfYear];
    if ([self snapshotDate:snapshotDate compareYearWithLastItemDate:lastItemDate] != NSOrderedSame) {
        NSInteger weekDay = [[calendar components:NSWeekdayCalendarUnit fromDate:snapshotDate] weekday];
        NSTimeInterval period = [snapshotDate timeIntervalSinceDate:lastItemDate];
        NSUInteger numberOfDays = period / (24 * 60 * 60);
        return [self compareResultToDetermineWhetherInTheSameWeekByWeekDat:weekDay minusNumberOfTwoDays:numberOfDays];
    }
    return [@(snapshotDateWeekNumber) compare:@(lastItemDateWeekNumber)];
}

- (NSComparisonResult)compareResultToDetermineWhetherInTheSameWeekByWeekDat:(NSInteger)weekDay minusNumberOfTwoDays:(NSInteger)numberOfDays {
    //weekDay 2 == monday
    if (weekDay == 1 && weekDay == 2) {
        return NSOrderedDescending;
    }
    else {
        if (numberOfDays < weekDay - 1) {
            return NSOrderedSame;
        }
        else {
            return NSOrderedDescending;
        }
    }
}

- (NSComparisonResult)snapshotDate:(NSDate *)someDate1 compareYearWithLastItemDate:(NSDate *)someDate2 {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    calendar.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT+8:00"];
    NSInteger someDate1YearNumber = [[calendar components:NSYearCalendarUnit fromDate:someDate1] year];
    NSInteger someDate2YearNumber = [[calendar components:NSYearCalendarUnit fromDate:someDate2] year];
    return [@(someDate1YearNumber) compare:@(someDate2YearNumber)];
}

- (NSComparisonResult)snapshotDate:(NSDate *)snapshotDate compareDateWithLastItemDate:(NSDate *)lastItemDate {
    if ([self snapshotDate:snapshotDate compareYearWithLastItemDate:lastItemDate] != NSOrderedSame) {
        return [self snapshotDate:snapshotDate compareYearWithLastItemDate:lastItemDate];
    }
    if ([self snapshotDate:snapshotDate compareMonthWithLastItemDate:lastItemDate] != NSOrderedSame) {
        return [self snapshotDate:snapshotDate compareMonthWithLastItemDate:lastItemDate];
    }
    NSCalendar *calendar = [NSCalendar currentCalendar];
    calendar.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT+8:00"];
    NSInteger someDate1DayNumber = [[calendar components:NSCalendarUnitDay fromDate:snapshotDate] day];
    NSInteger someDate2DayNumber = [[calendar components:NSCalendarUnitDay fromDate:lastItemDate] day];
    return [@(someDate1DayNumber) compare:@(someDate2DayNumber)];
}

@end

