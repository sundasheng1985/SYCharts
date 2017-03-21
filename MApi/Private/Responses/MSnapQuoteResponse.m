//
//  MSnapQuoteResponse.m
//  TSApi
//
//  Created by Mitake on 2015/4/21.
//  Copyright (c) 2015年 Mitake. All rights reserved.
//

#import "MSnapQuoteResponse.h"
#import "MOrderQuantityResponse.h"
#import "MSnapQuoteRequest.h"
#import "MBrokerSeatResponse.h"
#import "MStockItem.h"

@implementation MSnapQuoteResponse

- (id)initWithData:(NSData *)data request:(MRequest *)request timestamp:(NSString *)timestamp headers:(NSDictionary *)headers {
    
    MSnapQuoteRequest *req = (MSnapQuoteRequest *)request;
    
    self = [super initWithData:data request:request timestamp:timestamp headers:headers];
    if (self) {
        MRESPONSE_TRY_PARSE_DATA_START
        NSArray *datas = [data componentsSeparatedByByte:0x04];
        
        MStockItem *stockItem = nil;
        //期权商品
        NSData *optionExtData = nil;
        if (datas.count > 3) {
            optionExtData = datas[3];
        }
        if (optionExtData.length > 0) {
            NSMutableData *stockData = [NSMutableData dataWithData:datas[0]];
            char szSep[] = { 0x02 };
            [stockData appendBytes:&szSep length:sizeof(szSep)];
            [stockData appendData:optionExtData];
            
            stockItem = [[MOptionItem alloc] initWithData:stockData];
        } else {
            stockItem = [[MStockItem alloc] initWithData:datas[0]];
        }
        
        NSString *market = stockItem.market;
        NSString *subtype = stockItem.subtype;
        
        //Ticks扩充
        if (datas.count > 1) {
            NSMutableArray *array = [[NSMutableArray alloc] init];
            NSArray *tickDatas = [datas[1] componentsSeparatedByByte:0x03];
            for (NSData *tickData in tickDatas) {
                MTickItem *tickItem = [[MTickItem alloc] initWithData:tickData market:stockItem.market subtype:stockItem.subtype];
                if (tickItem) {
                    [array addObject:tickItem];
                }
                stockItem.tickItems = array;
            }
        }
        //指数扩充
        if (datas.count > 2) {
            NSArray *indexDatas = [datas[2] componentsSeparatedByByte:0x02];
            if (indexDatas.count >= 3) {
                stockItem.advanceCount = [indexDatas[0] convertToUTF8String];
                stockItem.equalCount = [indexDatas[1] convertToUTF8String];
                stockItem.declineCount = [indexDatas[2] convertToUTF8String];
            }
        }
        
        if (req.type == MSnapQuoteRequestType1 || req.type == MSnapQuoteRequestType5) {
            //基金(Subtype)
            if (datas.count > 4) {
                stockItem.subtype2 = [datas[4] convertToUTF8String];
            }
        } else {
            
            if ([market isEqualToString:@"hk"]) {
                if (datas.count > 4) {
                    self.buyBrokerSeatItems = [MBrokerSeatResponse brokerSeatItemsWithData:datas[4]];
                    stockItem.brokerSeatBuyItems = self.buyBrokerSeatItems;
                }
                if (datas.count > 5) {
                    self.sellBrokerSeatItems = [MBrokerSeatResponse brokerSeatItemsWithData:datas[5]];
                    stockItem.brokerSeatSellItems = self.sellBrokerSeatItems;
                }
                // 总卖量[0x02]总买量[0x02]均买价[0x02]均卖价
                if (datas.count > 6) {
                    NSArray *indexDatas = [datas[6] componentsSeparatedByByte:0x02];
                    if (indexDatas.count > 0) {
                        stockItem.totalSellVolume = [[indexDatas[0] convertToUTF8String] transform_decodeString];
                        stockItem.totalSellVolume = [MApiHelper formatVolume:stockItem.totalSellVolume market:market subtype:subtype];
                    }
                    if (indexDatas.count > 1) {
                        stockItem.totalBuyVolume = [[indexDatas[1] convertToUTF8String] transform_decodeString];
                        stockItem.totalBuyVolume = [MApiHelper formatVolume:stockItem.totalBuyVolume market:market subtype:subtype];
                    }
                    if (indexDatas.count > 2) {
                        stockItem.averageBuyPrice = [[indexDatas[2] convertToUTF8String] transform_decodeString];
                        stockItem.averageBuyPrice = [MApiHelper formatPrice:stockItem.averageBuyPrice.doubleValue market:market subtype:subtype];
                    }
                    if (indexDatas.count > 3) {
                        stockItem.averageSellPrice = [[indexDatas[3] convertToUTF8String] transform_decodeString];
                        stockItem.averageSellPrice = [MApiHelper formatPrice:stockItem.averageSellPrice.doubleValue market:market subtype:subtype];
                    }
                }
                //基金(Subtype)
                if (datas.count > 7) {
                    stockItem.subtype2 = [datas[7] convertToUTF8String];
                }
            } else {
                // 买卖队列
                if (datas.count > 4) {
                    NSArray *buyItems = nil;
                    NSArray *sellItems = nil;
                    [MOrderQuantityResponse parseData:datas[4]
                                               market:market
                                              subtype:subtype
                                                  buy:&buyItems
                                                 sell:&sellItems];
                    self.orderQuantityBuyItems = buyItems;
                    self.orderQuantitySellItems = sellItems;
                    stockItem.orderQuantityBuyItems = self.orderQuantityBuyItems;
                    stockItem.orderQuantitySellItems = self.orderQuantitySellItems;
                }
                
                // 总卖量[0x02]总买量[0x02]均买价[0x02]均卖价
                if (datas.count > 5) {
                    NSArray *indexDatas = [datas[5] componentsSeparatedByByte:0x02];
                    if (indexDatas.count > 0) {
                        stockItem.totalSellVolume = [[indexDatas[0] convertToUTF8String] transform_decodeString];
                        stockItem.totalSellVolume = [MApiHelper formatVolume:stockItem.totalSellVolume market:market subtype:subtype];
                    }
                    if (indexDatas.count > 1) {
                        stockItem.totalBuyVolume = [[indexDatas[1] convertToUTF8String] transform_decodeString];
                        stockItem.totalBuyVolume = [MApiHelper formatVolume:stockItem.totalBuyVolume market:market subtype:subtype];
                    }
                    if (indexDatas.count > 2) {
                        stockItem.averageBuyPrice = [[indexDatas[2] convertToUTF8String] transform_decodeString];
                        stockItem.averageBuyPrice = [MApiHelper formatPrice:stockItem.averageBuyPrice.doubleValue market:market subtype:subtype];
                    }
                    if (indexDatas.count > 3) {
                        stockItem.averageSellPrice = [[indexDatas[3] convertToUTF8String] transform_decodeString];
                        stockItem.averageSellPrice = [MApiHelper formatPrice:stockItem.averageSellPrice.doubleValue market:market subtype:subtype];
                    }
                }
                //基金(Subtype)
                if (datas.count > 6) {
                    stockItem.subtype2 = [datas[6] convertToUTF8String];
                }
            }
        }
        
        self.stockItem = stockItem;
        MRESPONSE_TRY_PARSE_DATA_END
    }
    return self;
}

@end
