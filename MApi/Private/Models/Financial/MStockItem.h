//
//  MStockItem.h
//  TSApi
//
//  Created by Mitake on 2015/3/18.
//  Copyright (c) 2015年 Mitake. All rights reserved.
//

#import "MBaseItem.h"

@interface MStockItem (MApiQuoteTCP)
- (BOOL)update:(NSData *)data code:(NSString *)code;
@end

@interface MStockItem ()

//以下server无资料，也算不出来，故private起来不公开
/** 拼音 */
@property (nonatomic, copy) NSString *pinyin;
/** 均价 */
@property (nonatomic, copy) NSString *averageValue;

/// readonly
/** 最新价 */
@property (nonatomic, copy) NSString *lastPrice_;
/** 最高价 */
@property (nonatomic, copy) NSString *highPrice_;
/** 最低价 */
@property (nonatomic, copy) NSString *lowPrice_;
/** 今开价 */
@property (nonatomic, copy) NSString *openPrice_;
/** 昨收价 */
@property (nonatomic, copy) NSString *preClosePrice_;
/** 总量 */
@property (nonatomic, copy) NSString *volume_;
/** 涨停价 */
@property (nonatomic, copy) NSString *limitUp_;
/** 跌停价 */
@property (nonatomic, copy) NSString *limitDown_;
/** 买一价 */
@property (nonatomic, copy) NSString *buyPrice_;
/** 卖一价 */
@property (nonatomic, copy) NSString *sellPrice_;
/** 外盘量 */
@property (nonatomic, copy) NSString *buyVolume_;
/** 内盘量 */
@property (nonatomic, copy) NSString *sellVolume_;
/** 净资产 */
@property (nonatomic, copy) NSString *netAsset_;
/** 总股本 */
@property (nonatomic, copy) NSString *capitalization_;
/** 流通股 */
@property (nonatomic, copy) NSString *circulatingShare_;
/** 一、五、十档委买价 */
@property (nonatomic, strong) NSArray *buyPrices_;
/** 一、五、十档委买量 */
@property (nonatomic, strong) NSArray *buyVolumes_;
/** 一、五、十档委卖价 */
@property (nonatomic, strong) NSArray *sellPrices_;
/** 一、五、十档委卖量 */
@property (nonatomic, strong) NSArray *sellVolumes_;

/// ext
@property (nonatomic, strong) NSArray *orderQuantityBuyItems;
@property (nonatomic, strong) NSArray *orderQuantitySellItems;
@property (nonatomic, strong) NSArray *brokerSeatBuyItems;
@property (nonatomic, strong) NSArray *brokerSeatSellItems;


@property (nonatomic, readonly) NSArray *stockItemFields;
- (NSString *)_formatPrice:(NSString *)price;
- (NSString *)_float_formatPrice:(double)price;
- (NSString *)_formatVolume:(NSString *)volume;
- (void)_updatePropertyValue;
- (NSArray *)parseBestPricesWithoutFormat:(NSString *)rawString;
- (NSArray *)parseBestVolumesWithoutFormat:(NSString *)rawString;
@end