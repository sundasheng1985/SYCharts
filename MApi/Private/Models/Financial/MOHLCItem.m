//
//  MOHLCItem.m
//  TSApi
//
//  Created by Mitake on 2015/3/18.
//  Copyright (c) 2015年 Mitake. All rights reserved.
//

#import "MOHLCItem.h"

#pragma mark MOHLCItem

@interface MOHLCItem (MApiAdditions)
@property (nonatomic, readonly) double _openPrice;
@property (nonatomic, readonly) double _highPrice;
@property (nonatomic, readonly) double _lowPrice;
@property (nonatomic, readonly) double _closePrice;
@property (nonatomic, readonly) long long _tradeVolume;
@property (nonatomic, readonly) double _averagePrice;
@property (nonatomic, readonly) double _referencePrice;
@property (nonatomic, readonly) double _amount;
@end

@implementation MOHLCItem (MApiAdditions)

- (double)_openPrice {
    return [self.openPrice doubleValue];
}

- (double)_highPrice {
    return [self.highPrice doubleValue];
}

- (double)_lowPrice {
    return [self.lowPrice doubleValue];
}

- (double)_closePrice {
    return [self.closePrice doubleValue];
}

- (long long)_tradeVolume {
    return [self.tradeVolume doubleValue];
}

- (double)_averagePrice {
    return [self.averagePrice doubleValue];
}

- (double)_referencePrice {
    return [self.referencePrice doubleValue];
}

- (double)_amount {
    return [self.amount doubleValue];
}

@end


@implementation MOHLCItem

- (instancetype)initWithData:(NSData *)data market:(NSString *)market subtype:(NSString *)subtype {
    if (self = [super initWithData:data market:market subtype:subtype]) {
        NSArray *dataCols = [data componentsSeparatedByByte:0x02];
        NSString *date = [[dataCols[0] convertToUTF8String] transform_decodeString];
        NSInteger time = [[[dataCols[1] convertToUTF8String] transform_decodeString] integerValue];
        NSString *timeString = [NSString stringWithFormat:@"%06d", (int32_t)time];
        
        self.datetime = [date stringByAppendingString:timeString];
        self.openPrice = [[dataCols[2] convertToUTF8String] transform_decodeString];
        self.highPrice = [[dataCols[3] convertToUTF8String] transform_decodeString];
        self.lowPrice = [[dataCols[4] convertToUTF8String] transform_decodeString];
        self.closePrice = [[dataCols[5] convertToUTF8String] transform_decodeString];
        self.tradeVolume = [[dataCols[6] convertToUTF8String] transform_decodeString];
        self.referencePrice = [[dataCols[7] convertToUTF8String] transform_decodeString];
        self.amount = [[dataCols[8] convertToUTF8String] transform_decodeString];
        //格式化价格
        self.openPrice = [MApiHelper formatPrice:self._openPrice market:market subtype:subtype];
        self.highPrice = [MApiHelper formatPrice:self._highPrice market:market subtype:subtype];
        self.lowPrice = [MApiHelper formatPrice:self._lowPrice market:market subtype:subtype];
        self.closePrice = [MApiHelper formatPrice:self._closePrice market:market subtype:subtype];
        
        self.tradeVolume = ___mapi_object_fixes_20161216_hk_ignore_server_volume
            ([MApiHelper formatVolume:self.tradeVolume market:market subtype:subtype], market, subtype);
        
        self.referencePrice = [MApiHelper formatPrice:self._referencePrice market:market subtype:subtype];
    }
    return self;
}

- (instancetype)initWithChartData:(NSData *)data market:(NSString *)market subtype:(NSString *)subtype {
    if (self = [super initWithData:data market:market subtype:subtype]) {
        
        NSArray *dataCols = [data componentsSeparatedByByte:0x02];

        NSString *price = [[dataCols[0] convertToUTF8String] transform_decodeString];
        self.closePrice = [MApiHelper formatPrice:[price doubleValue] market:market subtype:subtype];
        
        NSString *volume = [[dataCols[1] convertToUTF8String] transform_decodeString];
        self.tradeVolume = ___mapi_object_fixes_20161216_hk_ignore_server_volume
            ([MApiHelper formatVolume:volume market:market subtype:subtype], market, subtype);
        
        self.datetime = [[dataCols[2] convertToUTF8String] transform_decodeString];
        
        if (dataCols.count >= 4) {
            NSString *averagePrice = [[dataCols[3] convertToUTF8String] transform_decodeString];
            self.averagePrice = [MApiHelper formatAveragePrice:[averagePrice doubleValue] market:market subtype:subtype];
        }

    }
    return self;
}


#pragma mark - getter & setter

- (void)setPreClosePrice:(NSString *)preClosePrice {
    self.referencePrice = preClosePrice;
}

- (NSString *)preClosePrice {
    return self.referencePrice;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:self.datetime forKey:@"datetime"];
    [aCoder encodeObject:self.openPrice forKey:@"openPrice"];
    [aCoder encodeObject:self.highPrice forKey:@"highPrice"];
    [aCoder encodeObject:self.closePrice forKey:@"closePrice"];
    [aCoder encodeObject:self.lowPrice forKey:@"lowPrice"];
    [aCoder encodeObject:self.tradeVolume forKey:@"tradeVolume"];
    [aCoder encodeObject:self.averagePrice forKey:@"averagePrice"];
    [aCoder encodeObject:self.preClosePrice forKey:@"preClosePrice"];
    [aCoder encodeObject:self.referencePrice forKey:@"referencePrice"];
    [aCoder encodeObject:self.amount forKey:@"amount"];
    [aCoder encodeObject:self.rgbar forKey:@"rgbar"];

}
- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super init];
    if (self) {
        self.datetime = [aDecoder decodeObjectForKey:@"datetime"];
        self.averagePrice = [aDecoder decodeObjectForKey:@"averagePrice"];
        self.openPrice = [aDecoder decodeObjectForKey:@"openPrice"];
        self.highPrice = [aDecoder decodeObjectForKey:@"highPrice"];
        self.closePrice = [aDecoder decodeObjectForKey:@"closePrice"];
        self.lowPrice = [aDecoder decodeObjectForKey:@"lowPrice"];
        self.tradeVolume = [aDecoder decodeObjectForKey:@"tradeVolume"];
        self.preClosePrice = [aDecoder decodeObjectForKey:@"preClosePrice"];
        self.referencePrice = [aDecoder decodeObjectForKey:@"referencePrice"];
        self.amount = [aDecoder decodeObjectForKey:@"amount"];
        self.rgbar = [aDecoder decodeObjectForKey:@"rgbar"];
    }
    return self;
}

@end
