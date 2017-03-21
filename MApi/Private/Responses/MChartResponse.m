//
//  MChartResponse.m
//  TSApi
//
//  Created by Mitake on 2015/3/18.
//  Copyright (c) 2015年 Mitake. All rights reserved.
//

#import "MChartResponse.h"
#import "NSString+MApiAdditions.h"

#import "MOHLCItem.h" /// because of rgbar property
#import "MBaseItem.h"

@implementation MChartResponse

- (id)initWithData:(NSData *)data request:(MChartRequest *)request timestamp:(NSString *)timestamp headers:(NSDictionary *)headers {
    self = [super initWithData:data request:request timestamp:timestamp headers:headers];
    if (self) {
        MRESPONSE_TRY_PARSE_DATA_START
        NSString *market = [request.code pathExtension];
        NSMutableArray *OHLCItems = [NSMutableArray array];
        NSArray *dataRows = [data componentsSeparatedByByte:0x03];
        NSMutableArray * tradeDates = [NSMutableArray array];
        
        for (NSData *dataRow in dataRows) {
            MOHLCItem *OHLCItem = [[MOHLCItem alloc] initWithChartData:dataRow market:market subtype:request.subtype];
            if (OHLCItem) {
                [OHLCItems addObject:OHLCItem];
            }
        }
        
        MChartResponse *response = [(id<MApiCaching>)request cachedObject];
        NSMutableArray *cachedOHLCItems = [response.OHLCItems mutableCopy];
        //cache补新资料
        if ([cachedOHLCItems count] > 0) {
            MOHLCItem *lastCachedOHLCItem = [cachedOHLCItems lastObject];
            for (MOHLCItem *item in OHLCItems) {
                if ([item.datetime longLongValue] > [lastCachedOHLCItem.datetime longLongValue]) {
                    [cachedOHLCItems addObject:item];
                }
                else if ([item.datetime longLongValue] == [lastCachedOHLCItem.datetime longLongValue]) {
                    [cachedOHLCItems replaceObjectAtIndex:[cachedOHLCItems count] - 1 withObject:item];
                }
            }
            OHLCItems = cachedOHLCItems;
        }
        
        //检查是否有过期数据需要剔除
        NSInteger numberOfDays = 0;
        if ([OHLCItems count] > 0) {
            /// 交易日加入
            NSString *tempDate = nil;
            
            /// 分时才做 因为要清cache
            if (market && request.chartType == MChartTypeOneDay) {
                tempDate = [MApiHelper sharedHelper].marketTradeDates[market];
                if (tempDate) {
                    [tradeDates addObject:tempDate];
                }
            }
            
            ///
            if (tradeDates.count == 0) {
                tempDate = [[[OHLCItems lastObject] datetime] date8];
                [tradeDates addObject:tempDate];
            }
            
            for (NSInteger index = OHLCItems.count - 1; index >= 0; index--) {
                MOHLCItem *item = OHLCItems[index];
                if (![[item.datetime date8] isEqualToString:tempDate]) {
                    tempDate = [item.datetime date8];
                    [tradeDates addObject:tempDate];
                    numberOfDays++;
                }
                //一日线超过一日的数据要剔除
                if (request.chartType == MChartTypeOneDay) {
                    if (numberOfDays == 1) {
                        [OHLCItems removeObjectsInRange:NSMakeRange(0, index + 1)];
                        [tradeDates removeLastObject];
                        break;
                    }
                }
                //五日线超过五日的数据要剔除
                else if (request.chartType == MChartTypeFiveDays) {
                    if (numberOfDays == 5) {
                        [OHLCItems removeObjectsInRange:NSMakeRange(0, index + 1)];
                        [tradeDates removeLastObject];
                        break;
                    }
                }
            }
        }
        
        
        if (tradeDates.count == 1 &&
            ([request.code isEqualToString:@"000001.sh"] || [request.code isEqualToString:@"399001.sz"] ||
             [request.code isEqualToString:@"399006.sz"] || [request.code isEqualToString:@"399005.sz"])) {
            //        A:=EMA(C,2); B:=EMA(C,3); MD:=A-B; D:=DYNAINFO(3);
            //        STICKLINE(A>B,D,D+MD*2,0,0),COLORRED;
            //        STICKLINE(A<B,D,D+MD*2,0,0),COLOR00FF00;
            //
            //        A赋值:收盘价的2日指数移动平均(即大盘领先指数的值)
            //        B赋值:收盘价的3日指数移动平均(即大盘领先指数的值)
            //        MD赋值:A-B
            //        D赋值:前收盘价
            //        当满足条件A>B时,在D和D+MD*2位置之间画柱状线,宽度为0,0不为0则画空心柱.,画红色
            //        当满足条件A<B时,在D和D+MD*2位置之间画柱状线,宽度为0,0不为0则画空心柱.,COLOR00FF00
            //        EMA解释：若Y=EMA(X，N)，则Y=[2*X+(N-1)*Y']/(N+1)，其中Y'表示上一周期Y值
            
            double a = 0;
            double b = 0;
            for (NSInteger idx = 1; idx < OHLCItems.count; idx++) {
                MOHLCItem *item = OHLCItems[idx];
                MOHLCItem *prevItem = OHLCItems[idx-1];
                double va =idx==1?prevItem.averagePrice.doubleValue: a;
                double vb =idx==1?prevItem.averagePrice.doubleValue: b;
                a = (2*item.averagePrice.doubleValue+va)/3;
                b = (2*item.averagePrice.doubleValue+2*vb)/4;
                double md = a-b;
                item.rgbar = [NSString stringWithFormat:@"%f", md];
            }
        }
        
        self.tradeDates = tradeDates;
        self.OHLCItems = OHLCItems;
        
        self.systemDatetime = [headers[@"it"] transform_decodeString];
        MRESPONSE_TRY_PARSE_DATA_END
    }
    return self;
}

@end
