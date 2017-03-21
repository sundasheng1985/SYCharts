//
//  MStockItem.m
//  TSApi
//
//  Created by Mitake on 2015/3/18.
//  Copyright (c) 2015年 Mitake. All rights reserved.
//

#import "MStockItem.h"
#import "MApiDebug.h"
#import "MOrderQuantityResponse.h"


@implementation MStockItem (MApiQuoteTCP)

- (BOOL)update:(NSData *)data code:(NSString *)code {
    NSArray *arr = [data componentsSeparatedByByte:0x02];
    BOOL isUpdated = false;
    NSMutableArray *updateFields = [NSMutableArray array];
    for (NSData *row in arr) {
        NSString *str = [row convertToUTF8String];
        if (str.length == 0) {
            continue;
        }
        NSUInteger sepLoc = [str rangeOfString:@"="].location;
        if (sepLoc == NSNotFound) {
            continue;
        }
        
        NSString *keyString = [str substringToIndex:sepLoc];
        NSString *valueString = [str substringFromIndex:sepLoc+1];
        // 买入加权平均价 = abp
        if ([keyString isEqualToString:@"abp"]) {
            self.averageBuyPrice = [valueString transform_decodeString];
            [updateFields addObject:[NSString stringWithFormat:@"averageBuyPrice=%@", self.averageBuyPrice]];
            self.averageBuyPrice = [self _formatPrice:self.averageBuyPrice];
            continue;
        }
        // 买入总量 = tbq
        else if ([keyString isEqualToString:@"tbq"]) {
            self.totalBuyVolume = [valueString transform_decodeString];
            [updateFields addObject:[NSString stringWithFormat:@"totalBuyVolume=%@", self.totalBuyVolume]];
            self.totalBuyVolume = [self _formatVolume:self.totalBuyVolume];
            continue;
        }
        // 卖出加权平均价 = aop
        else if ([keyString isEqualToString:@"aop"]) {
            self.averageSellPrice = [valueString transform_decodeString];
            [updateFields addObject:[NSString stringWithFormat:@"averageSellPrice=%@", self.averageSellPrice]];
            self.averageSellPrice = [self _formatPrice:self.averageSellPrice];
            continue;
        }
        // 卖出总量 = toq
        else if ([keyString isEqualToString:@"toq"]) {
            self.totalSellVolume = [valueString transform_decodeString];
            [updateFields addObject:[NSString stringWithFormat:@"totalSellVolume=%@", self.totalSellVolume]];
            self.totalSellVolume = [self _formatVolume:self.totalSellVolume];
            continue;
        }
        // 卖出对列50档
        else if ([keyString isEqualToString:@"os"]) {
            if (self.isHongKong) {
//                self.brokerSeatSellItems = [valueString componentsSeparatedByString:@","];
//                [updateFields addObject:[NSString stringWithFormat:@"brokerSeatSellItems=%@", self.brokerSeatSellItems]];
            } else {
                NSArray *result = [MOrderQuantityResponse orderQuantitiesWithTCPPushString:valueString market:self.market subtype:self.subtype];
                self.orderQuantitySellItems = result;
                [updateFields addObject:[NSString stringWithFormat:@"orderQuantitySellItems=%@", result]];
            }
            continue;
        }
        // 买入对列50档
        else if ([keyString isEqualToString:@"bs"]) {
            if (self.isHongKong) {
//                self.brokerSeatBuyItems = [valueString componentsSeparatedByString:@","];
//                [updateFields addObject:[NSString stringWithFormat:@"brokerSeatBuyItems=%@", self.brokerSeatBuyItems]];
            } else {
                NSArray *result = [MOrderQuantityResponse orderQuantitiesWithTCPPushString:valueString market:self.market subtype:self.subtype];
                self.orderQuantityBuyItems = [[result reverseObjectEnumerator] allObjects];
                [updateFields addObject:[NSString stringWithFormat:@"orderQuantityBuyItems=%@", result]];
            }
            continue;
        }
        
        NSCharacterSet *numberSet = [NSCharacterSet decimalDigitCharacterSet];
        NSString * trimmedString = [keyString stringByTrimmingCharactersInSet:numberSet];
        if (!(trimmedString.length == 0) && (keyString.length > 0)) {
            continue;
        }
        NSInteger idx = [keyString integerValue];
        if (idx >= 0 && idx < self.stockItemFields.count) {
            
            NSDictionary *fieldInfo = self.stockItemFields[idx];
            id value = nil;
            id value2 = nil;
            NSString *propertyName = fieldInfo[@"key"];
            NSString *propertyName2 = fieldInfo[@"key2"];
            NSString *propertyType = fieldInfo[@"type"];
            
            if ([propertyType isEqualToString:@"prices"]) {
                value = [self parseBestPricesWithoutFormat:valueString];
            }
            else if ([propertyType isEqualToString:@"volumes"]) {
                NSArray *volumeComps = [self parseBestVolumesWithoutFormat:valueString];
                value = volumeComps[0];
                value2 = volumeComps[1];
            }
            else if ([fieldInfo[@"encrypt"] boolValue] && [valueString length] > 0) {
                value = [valueString transform_decodeString];
            }
            else {
                value = valueString;
            }
            
            if ([propertyType isEqualToString:@"integer"]) {
                [self setValue:@([value integerValue]) forKey:propertyName];
            } else if ([propertyType isEqualToString:@"string"]) {
                if ( ((NSString *)value).length > 0 &&
                     ![[self valueForKey:propertyName] isEqualToString:value] ){
                    [self setValue:value forKey:propertyName];
                } else {
//                    MAPI_LOG(@"%@---->value(%@) not set", propertyName, value);
                }
            } else {
                [self setValue:value forKey:propertyName];
                if (propertyName2) {
                    [self setValue:value2 forKey:propertyName2];
                }
            }
            [updateFields addObject:[NSString stringWithFormat:@"%@=%@", propertyName, value]];
            isUpdated = YES;
        }
    }
    if (isUpdated) {
//        MAPI_LOG(@"\nnew -(%@)-> %@", code, [updateFields componentsJoinedByString:@","]);
        [self _updatePropertyValue];
    }
    return isUpdated;
}

@end

@implementation MStockItem {
    NSString *tempStatus;
}

@synthesize pinyin = private_pinyin;
@synthesize averageValue = private_averageValue;

/// 原始數據, 不可重新命名
@synthesize lastPrice_        = original_lastPrice_;
@synthesize highPrice_        = original_highPrice_;
@synthesize lowPrice_         = original_lowPrice_;
@synthesize openPrice_        = original_openPrice_;
@synthesize preClosePrice_    = original_preClosePrice_;
@synthesize volume_           = original_volume_;
@synthesize limitUp_          = original_limitUp_;
@synthesize limitDown_        = original_limitDown_;
@synthesize buyPrice_         = original_buyPrice_;
@synthesize sellPrice_        = original_sellPrice_;
@synthesize buyVolume_        = original_buyVolume_;
@synthesize sellVolume_       = original_sellVolume_;
@synthesize netAsset_         = original_netAsset_;
@synthesize capitalization_   = original_capitalization_;
@synthesize circulatingShare_ = original_circulatingShare_;

@synthesize buyPrices_        = original_buyPrices_;
@synthesize buyVolumes_       = original_buyVolumes_;
@synthesize sellPrices_       = original_sellPrices_;
@synthesize sellVolumes_      = original_sellVolumes_;

- (NSArray *)stockItemFields {
    static NSArray *stockItemFields = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        stockItemFields = @[
        @{@"key": @"tempStatus", @"type": @"string", @"encrypt": @(NO)},        //0
        @{@"key": @"ID", @"type": @"string", @"encrypt": @(NO)},                //1
        @{@"key": @"name", @"type": @"string", @"encrypt": @(NO)},              //2
        @{@"key": @"datetime", @"type": @"string", @"encrypt": @(YES)},         //3
        @{@"key": @"pinyin", @"type": @"string", @"encrypt": @(NO)},            //4
        @{@"key": @"market", @"type": @"string", @"encrypt": @(NO)},            //5
        @{@"key": @"subtype", @"type": @"string", @"encrypt": @(NO)},           //6
        @{@"key": @"lastPrice_", @"type": @"string", @"encrypt": @(YES)},       //7
        @{@"key": @"highPrice_", @"type": @"string", @"encrypt": @(YES)},       //8
        @{@"key": @"lowPrice_", @"type": @"string", @"encrypt": @(YES)},        //9
        @{@"key": @"openPrice_", @"type": @"string", @"encrypt": @(YES)},       //10
        @{@"key": @"preClosePrice_", @"type": @"string", @"encrypt": @(YES)},   //11
        @{@"key": @"HKInfoStatus", @"type": @"integer", @"encrypt": @(YES)},    //12
        @{@"key": @"volume_", @"type": @"string", @"encrypt": @(YES)},          //13
        @{@"key": @"nowVolume", @"type": @"string", @"encrypt": @(YES)},        //14
        @{@"key": @"turnoverRate", @"type": @"string", @"encrypt": @(YES)},     //15
        @{@"key": @"limitUp_", @"type": @"string", @"encrypt": @(YES)},         //16
        @{@"key": @"limitDown_", @"type": @"string", @"encrypt": @(YES)},       //17
        @{@"key": @"averageValue", @"type": @"string", @"encrypt": @(YES)},     //18
        @{@"key": @"change", @"type": @"string", @"encrypt": @(YES)},           //19
        @{@"key": @"amount", @"type": @"string", @"encrypt": @(YES)},           //20
        @{@"key": @"volumeRatio", @"type": @"string", @"encrypt": @(NO)},       //21
        @{@"key": @"buyPrice_", @"type": @"string", @"encrypt": @(YES)},        //22
        @{@"key": @"sellPrice_", @"type": @"string", @"encrypt": @(YES)},       //23
        @{@"key": @"buyVolume_", @"type": @"string", @"encrypt": @(YES)},       //24
        @{@"key": @"sellVolume_", @"type": @"string", @"encrypt": @(YES)},      //25
        @{@"key": @"totalValue", @"type": @"string", @"encrypt": @(YES)},       //26
        @{@"key": @"flowValue", @"type": @"string", @"encrypt": @(YES)},        //27
        @{@"key": @"netAsset_", @"type": @"string", @"encrypt": @(NO)},         //28
        @{@"key": @"PE", @"type": @"string", @"encrypt": @(YES)},               //29
        @{@"key": @"ROE", @"type": @"string", @"encrypt": @(YES)},              //30
        @{@"key": @"capitalization_", @"type": @"string", @"encrypt": @(YES)},  //31
        @{@"key": @"circulatingShare_", @"type": @"string", @"encrypt": @(YES)},//32
        @{@"key": @"buyPrices_", @"type": @"prices", @"encrypt": @(YES)},       //33
        @{@"key": @"buyVolumes_", @"key2": @"buyCount", @"type": @"volumes", @"encrypt": @(YES)},   //34
        @{@"key": @"sellPrices_", @"type": @"prices", @"encrypt": @(YES)},      //35
        @{@"key": @"sellVolumes_", @"key2": @"sellCount", @"type": @"volumes", @"encrypt": @(YES)},  //36
        @{@"key": @"amplitudeRate", @"type": @"string", @"encrypt": @(YES)},    //37
        @{@"key": @"receipts", @"type": @"string", @"encrypt": @(NO)}           //38
        ];
        
    });
    
    return stockItemFields;
}

- (instancetype)initWithData:(NSData *)data {
    if (self = [super initWithData:data]) {
        
        NSArray *dataCols = [data componentsSeparatedByByte:0x02];

        for (int index = 0; index < [[self stockItemFields] count]; index++) {
            if (index < [dataCols count]) {
                NSDictionary *fieldInfo = [self stockItemFields][index];
                NSString *rawString = [dataCols[index] convertToUTF8String];
                id value = nil;
                id value2 = nil;
                NSString *propertyName = fieldInfo[@"key"];
                NSString *propertyName2 = fieldInfo[@"key2"];
                NSString *propertyType = fieldInfo[@"type"];
                
                if ([propertyType isEqualToString:@"prices"]) {
                    value = [self parseBestPricesWithoutFormat:rawString];
                }
                else if ([propertyType isEqualToString:@"volumes"]) {
                    NSArray *volumeComps = [self parseBestVolumesWithoutFormat:rawString];
                    value = volumeComps[0];
                    value2 = volumeComps[1];
                }
                else if ([[[self stockItemFields][index] objectForKey:@"encrypt"] boolValue] &&
                         [rawString length] > 0) {
                    value = [rawString transform_decodeString];
                }
                else {
                    value = rawString;
                }

                if ([propertyType isEqualToString:@"integer"]) {
                    [self setValue:@([value integerValue]) forKey:propertyName];
                } else {
                    [self setValue:value forKey:propertyName];
                    if (propertyName2) {
                        [self setValue:value2 forKey:propertyName2];
                    }
                }
            }
        }
        [self _updatePropertyValue];
        
    }
    return self;
}

- (BOOL)isEqualToStockItem:(MStockItem *)stockItem {
    return [self.ID isEqualToString:stockItem.ID];
}


#pragma mark - Private methods

//// 为了同步安卓算法 offer是啥问安卓
- (NSInteger)android_offer {
    if (self.isIndex) {
        return 100000;
    }
    return 1000;
}

- (NSString *)_formatPrice:(NSString *)price {
    return [self _float_formatPrice:price.doubleValue];
}

- (NSString *)_float_formatPrice:(double)price {
    return [MApiHelper formatPrice:price market:self.market subtype:self.subtype];
}

- (NSString *)_formatVolume:(NSString *)volume {
    return [MApiHelper formatVolume:volume market:self.market subtype:self.subtype];
}

- (void)_updatePropertyValue {
    
    self.code = [self.ID stringByDeletingPathExtension];
    
    /// CAL START
    if (original_lastPrice_.longLongValue > 0 && original_preClosePrice_.longLongValue > 0) {
        if (original_lastPrice_.longLongValue > original_preClosePrice_.longLongValue) {
            self.changeState = MChangeStateRise;
        }
        else if (original_lastPrice_.longLongValue < original_preClosePrice_.longLongValue) {
            self.changeState = MChangeStateDrop;
        }
        else {
            self.changeState = MChangeStateFlat;
        }
    }
    
    if (original_lastPrice_.longLongValue > 0 && original_preClosePrice_.longLongValue > 0) {
        //计算涨跌
        double oriChange = fabs((double)(original_lastPrice_.longLongValue - original_preClosePrice_.longLongValue));
        self.change = [self _float_formatPrice:oriChange];
        
        //计算涨跌幅
        double changeRate = oriChange / original_preClosePrice_.doubleValue * 100.;
        self.changeRate = [NSString mapi_stringWithValue:changeRate decimal:2];
    } else {
        self.change = nil;
        self.changeRate = nil;
    }
    
    
    //计算换手率: 总手/流通股数(%)
    if (original_volume_.longLongValue > 0 && original_circulatingShare_.longLongValue > 0) {
        double turnoverRate = (double)original_volume_.longLongValue / (double)original_circulatingShare_.longLongValue * 100.;
        self.turnoverRate = [NSString mapi_stringWithValue:turnoverRate decimal:2];
    }
    else {
        self.turnoverRate = nil;
    }
    
    //计算振幅
    if((original_highPrice_.longLongValue - original_lowPrice_.longLongValue) != 0 && original_preClosePrice_.longLongValue > 0) {
        double amplitudeRate = (double)(llabs(original_highPrice_.longLongValue - original_lowPrice_.longLongValue)) / original_preClosePrice_.doubleValue * 100.;
        self.amplitudeRate = [NSString mapi_stringWithValue:amplitudeRate decimal:2];
    }
    else {
        self.amplitudeRate = nil;
    }
    
    /////////////////////////////////////////
    //计算市盈: 现价/折算成全年的每股收益
    if (original_lastPrice_.longLongValue != 0 && _receipts.doubleValue != 0) {
        double PE = original_lastPrice_.longLongValue / _receipts.doubleValue / [self android_offer];
        self.PE = [NSString mapi_stringWithValue:PE decimal:2];
    }
    else {
        self.PE = nil;
    }
    
    //计算市净率: 现价/每股净资产
    if (original_lastPrice_.longLongValue != 0 && original_netAsset_.doubleValue != 0) {
        double ROE = original_lastPrice_.longLongValue / original_netAsset_.doubleValue / [self android_offer];
        self.ROE = [NSString mapi_stringWithValue:ROE decimal:2];
    }
    else {
        self.ROE = nil;
    }
    
    //计算总市值: 总股本*现价
    if (original_lastPrice_.longLongValue != 0 && original_capitalization_.longLongValue != 0) {
        double totalValue = original_lastPrice_.longLongValue * original_capitalization_.longLongValue / [self android_offer];
        self.totalValue = [NSString mapi_stringWithValue:totalValue decimal:0];
    }
    else {
        self.totalValue = nil;
    }
    
    //计算流值: 流通股本*现价
    if (original_lastPrice_.longLongValue != 0 && original_circulatingShare_.longLongValue != 0) {
        double flowValue = original_lastPrice_.longLongValue * original_circulatingShare_.longLongValue / [self android_offer];
        self.flowValue = [NSString mapi_stringWithValue:flowValue decimal:0];
    }
    else {
        self.flowValue = nil;
    }
    
    /// CAL END
    

    //處理股票狀態
    if ([tempStatus length] >= 2) {
        self.status = [[tempStatus substringWithRange:NSMakeRange(0, 1)] integerValue];
        self.stage = [[tempStatus substringWithRange:NSMakeRange(1, 1)] integerValue];
    }
    
    /// format
    // 涨停价
    self.limitUp = [self _formatPrice:original_limitUp_];
    // 跌停价
    self.limitDown = [self _formatPrice:original_limitDown_];
    // 昨收价
    self.preClosePrice = [self _formatPrice:original_preClosePrice_];
    // 最新价
    self.lastPrice = [self _formatPrice:original_lastPrice_];
    // 开盘价
    self.openPrice = [self _formatPrice:original_openPrice_];
    // 最高价
    self.highPrice = [self _formatPrice:original_highPrice_];
    // 最低价
    self.lowPrice = [self _formatPrice:original_lowPrice_];
    // 买价
    self.buyPrice = [self _formatPrice:original_buyPrice_];
    // 卖价
    self.sellPrice = [self _formatPrice:original_sellPrice_];
    // 总量
    self.volume = ___mapi_object_fixes_20161216_hk_ignore_server_volume
    ([self _formatVolume:original_volume_], self.market, self.subtype);
    
    // 每股净资产
    if (original_netAsset_.doubleValue != 0) {
        self.netAsset = [NSString mapi_stringWithValue:original_netAsset_.doubleValue decimal:2];
    } else {
        self.netAsset = nil;
    }
    // 总股本
    if (original_capitalization_.longLongValue != 0) {
        self.capitalization = [NSString stringWithFormat:@"%lld", original_capitalization_.longLongValue];
    } else {
        self.capitalization = nil;
    }
    // 流通股本
    if (original_circulatingShare_.longLongValue != 0) {
        self.circulatingShare = [NSString stringWithFormat:@"%lld", original_circulatingShare_.longLongValue];
    } else {
        self.circulatingShare = nil;
    }
    // 外盘量
    self.buyVolume = [self _formatVolume:original_buyVolume_];
    // 内盘量
    self.sellVolume = [self _formatVolume:original_sellVolume_];
    
    double topBuyVolumeSum = 0;
    double topSellVolumeSum = 0;
    
    // 五档format
    NSMutableArray *mutableBuyVolumes = [NSMutableArray array];
    for (NSString *buyVolume in original_buyVolumes_) {
        topBuyVolumeSum += buyVolume.doubleValue;
        [mutableBuyVolumes addObject:[self _formatVolume:buyVolume]];
    }
    self.buyVolumes = [mutableBuyVolumes copy];
    
    NSMutableArray *mutableSellVolumes = [NSMutableArray array];
    for (NSString *sellVolume in original_sellVolumes_) {
        topSellVolumeSum += sellVolume.doubleValue;
        [mutableSellVolumes addObject:[self _formatVolume:sellVolume]];
    }
    self.sellVolumes = [mutableSellVolumes copy];
    
    NSMutableArray *mutableBuyPrices = [NSMutableArray array];
    for (NSString *buyPrice in original_buyPrices_) {
        NSString *price = [self _formatPrice:buyPrice];
        if (price) {
            [mutableBuyPrices addObject:price];
        }
    }
    self.buyPrices = [mutableBuyPrices copy];
    
    NSMutableArray *mutableSellPrices = [NSMutableArray array];
    for (NSString *sellPrice in original_sellPrices_) {
        NSString *price = [self _formatPrice:sellPrice];
        if (price) {
            [mutableSellPrices addObject:price];
        }
    }
    self.sellPrices = [mutableSellPrices copy];
    
    
    // 委比计算
    if (topBuyVolumeSum > 0 || topSellVolumeSum > 0) {
        // 委比的计算公式为：委比=(委买手数－委卖手数)/(委买手数+委卖手数)×100%
        double orderRatio = ((topBuyVolumeSum - topSellVolumeSum) / (topBuyVolumeSum + topSellVolumeSum)) * 100.0;
        self.orderRatio = [NSString mapi_stringWithValue:orderRatio decimal:2];
    } else {
        self.orderRatio = nil;
    }

}

- (NSArray *)parseBestPricesWithoutFormat:(NSString *)rawString {
    __autoreleasing NSMutableArray *prices = [NSMutableArray array];
    
    NSArray *lines = [rawString componentsSeparatedByString:@","];
    for(NSString __strong *line in lines) {
        if([line length] > 0) {
            line = [line transform_decodeString];
            [prices addObject:line];
        }
    }
    return prices;
}

- (NSArray *)parseBestVolumesWithoutFormat:(NSString *)rawString {
    __autoreleasing NSMutableArray *volumes = [NSMutableArray array];
    __autoreleasing NSMutableArray *counts = [NSMutableArray array];
    NSArray *lines = [rawString componentsSeparatedByString:@","];
    for(NSString *line in lines) {
        NSArray *array = [line componentsSeparatedByString:@"|"];
        if([array count] > 0) {
            NSString *volume = array[0];
            if ([volume length] > 0) {
                volume = [volume transform_decodeString];
                [volumes addObject:volume];
            }
        }
        if (array.count > 1) {
            NSString *count = array[1];
            if (count.length > 0) {
                count = [count transform_decodeString];
                [counts addObject:count];
            }
        }
    }
    return @[volumes, counts];
}

- (BOOL)isIndex {
    return [self.subtype isEqualToString:@"1400"];
}

- (BOOL)isBond {
    return [self.subtype isEqualToString:@"1300"];
}

- (BOOL)isFund {
    return [self.subtype isEqualToString:@"1100"] ||
    [self.subtype isEqualToString:@"1110"] ||
    [self.subtype isEqualToString:@"1120"] ||
    [self.subtype isEqualToString:@"1140"] ||
    [self.subtype isEqualToString:@"1131"] ||
    [self.subtype isEqualToString:@"1132"];
}

- (BOOL)isWrnt {
    return [self.subtype isEqualToString:@"1500"];
}

- (BOOL)isOption {
    return [self.subtype isEqualToString:@"3002"];
}

- (BOOL)isHongKong {
    return [self.market isEqualToString:@"hk"];
}

@end

@implementation MStockItem (MApiTopBuyFixes)

- (NSArray *)buyPricesReverse {
    return [[[self.buyPrice mutableCopy] reverseObjectEnumerator] allObjects];
}

- (NSArray *)buyVolumesReverse {
    return [[[self.buyVolumes mutableCopy] reverseObjectEnumerator] allObjects];
}

- (NSArray *)buyCountReverse {
    return [[[self.buyCount mutableCopy] reverseObjectEnumerator] allObjects];
}

@end

@implementation MStockItem (MApiQuoteSHSZ)


@end

@implementation MStockItem (MApiQuoteHK)


@end

