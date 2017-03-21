//
//  MOptionItem.m
//  TSApi
//
//  Created by Mitake on 2015/3/18.
//  Copyright (c) 2015年 Mitake. All rights reserved.
//

#import "MOptionItem.h"

@interface MOptionItem ()
/** 当日结算价 */
@property (nonatomic, copy) NSString *setPrice;
@end

@implementation MOptionItem
- (NSArray *)optionItemFields {
    static NSArray *stockItemFields = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        stockItemFields = @[
                            @{@"key": @"tempStatus", @"index": @"39", @"encrypt": @(NO)},    //39
                            @{@"key": @"stockID", @"index": @"40", @"encrypt": @(NO)},       //40
                            @{@"key": @"stockSymble", @"index": @"41", @"encrypt": @(NO)},   //41
                            @{@"key": @"stockType", @"index": @"42", @"encrypt": @(NO)},    //42
                            @{@"key": @"unit", @"index": @"43", @"encrypt": @(YES)},          //43
                            @{@"key": @"exePrice", @"index": @"44", @"encrypt": @(YES)},      //44
                            @{@"key": @"startDate", @"index": @"45", @"encrypt": @(YES)},     //45
                            @{@"key": @"endDate", @"index": @"46", @"encrypt": @(YES)},      //46
                            @{@"key": @"exeDate", @"index": @"47", @"encrypt": @(YES)},      //47
                            @{@"key": @"deliDate", @"index": @"48", @"encrypt": @(YES)},     //48
                            @{@"key": @"expDate", @"index": @"49", @"encrypt": @(YES)},      //49
                            @{@"key": @"version", @"index": @"50", @"encrypt": @(YES)},      //50
                            @{@"key": @"presetPrice", @"index": @"51", @"encrypt": @(YES)},  //51
                            @{@"key": @"setPrice", @"index": @"52", @"encrypt": @(YES)},     //52
                            @{@"key": @"stockClose", @"index": @"53", @"encrypt": @(YES)},   //53
                            @{@"key": @"stockLast", @"index": @"54", @"encrypt": @(YES)},    //54
                            @{@"key": @"isLimit", @"index": @"55", @"encrypt": @(YES)},      //55
                            @{@"key": @"openInterest", @"index": @"61", @"encrypt": @(NO)}  //61
                            ];
        
    });
    
    return stockItemFields;
}

- (BOOL)shouldUnwrapByIndex:(NSInteger)index {
    __block BOOL shouldWrap = NO;
    [[self optionItemFields] enumerateObjectsUsingBlock:^(NSDictionary *dictionary, NSUInteger idx, BOOL *stop) {
        if (index == [dictionary[@"index"] integerValue]) {
            shouldWrap = [dictionary[@"encrypt"] boolValue];
        }
    }];
    return shouldWrap;
}

- (instancetype)initWithData:(NSData *)data {
    if (self = [super initWithData:data]) {
        if (self.isOption) {
        NSArray *dataCols = [data componentsSeparatedByByte:0x02];
            for (NSInteger index = 39; index < [dataCols count]; index++) {
                NSString *value = [dataCols[index] convertToUTF8String];
                switch (index) {
                    case 39:
                        self.contractID = [self shouldUnwrapByIndex:index] ? [value transform_decodeString] : value;
                        break;
                    case 40:
                        self.stockID = [self shouldUnwrapByIndex:index] ? [value transform_decodeString] : value;
                        break;
                    case 41:
                        self.stockSymble = [self shouldUnwrapByIndex:index] ? [value transform_decodeString] : value;
                        break;
                    case 42:
                        self.stockType = [self shouldUnwrapByIndex:index] ? [value transform_decodeString] : value;
                        break;
                    case 43:
                        self.unit = [self shouldUnwrapByIndex:index] ? [value transform_decodeString] : value;;
                        break;
                    case 44:
                        self.exePrice = [self shouldUnwrapByIndex:index] ? [value transform_decodeString] : value;
                        break;
                    case 45:
                        self.startDate = [self shouldUnwrapByIndex:index] ? [value transform_decodeString] : value;
                        break;
                    case 46:
                        self.endDate = [self shouldUnwrapByIndex:index] ? [value transform_decodeString] : value;
                        break;
                    case 47:
                        self.exeDate = [self shouldUnwrapByIndex:index] ? [value transform_decodeString] : value;
                        break;
                    case 48:
                        self.deliDate = [self shouldUnwrapByIndex:index] ? [value transform_decodeString] : value;
                        break;
                    case 49:
                        self.expDate = [self shouldUnwrapByIndex:index] ? [value transform_decodeString] : value;
                        break;
                    case 50:
                        self.version = [self shouldUnwrapByIndex:index] ? [value transform_decodeString] : value;
                        break;
                    case 51:
                        self.presetPrice = [self shouldUnwrapByIndex:index] ? [value transform_decodeString] : value;
                        break;
                    case 52:
                        self.setPrice = [self shouldUnwrapByIndex:index] ? [value transform_decodeString] : value;
                        break;
                    case 53:
                        self.stockClose = [self shouldUnwrapByIndex:index] ? [value transform_decodeString] : value;
                        break;
                    case 54:
                        self.stockLast = [self shouldUnwrapByIndex:index] ? [value transform_decodeString] : value;
                        break;
                    case 55:
                        self.isLimit = [value boolValue];
                        break;
                    case 61:
                        self.openInterest = [self shouldUnwrapByIndex:index] ? [value transform_decodeString] : value;;
                    default:
                        break;
                }
            }
        }
        //标的证券的市场
        NSString *stockMarket = [self.stockID pathExtension];
        
        //格式化执行价格
        self.exePrice = [MApiHelper formatPrice:[self.exePrice doubleValue] market:self.market subtype:self.subtype];
        
        //格式化前结算价
        self.presetPrice = [MApiHelper formatPrice:[self.presetPrice doubleValue] market:self.market subtype:self.subtype];
        
        //格式化当日结算价
        self.setPrice = [MApiHelper formatPrice:[self.setPrice doubleValue] market:self.market subtype:self.subtype];
        
        //格式化标的证券昨收
        self.stockClose = [MApiHelper formatPrice:[self.stockClose doubleValue] market:stockMarket subtype:self.stockType];
        
        //格式化标的证券价格
        self.stockLast = [MApiHelper formatPrice:[self.stockLast doubleValue] market:stockMarket subtype:self.stockType];
        
        //计算剩馀天数
        self.remainDate = [self cacluateRemainingDay:self.endDate];
    }
    return self;
}

//计算剩馀天数
- (NSString *)cacluateRemainingDay:(NSString *)endDay {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyMMdd"];
    ;
    
    NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"Asia/Shanghai"];
    [dateFormatter setTimeZone:timeZone];
    
    NSDate *newsDateFormatted = [dateFormatter dateFromString:endDay];
    
    NSDate* current_date = [NSDate date];
    
    NSTimeInterval time = [newsDateFormatted timeIntervalSinceDate:current_date];//间隔的秒数
    int days = time/(3600*24) + 1;
    
    return [NSString stringWithFormat:@"%d", days];
}


- (MOptionType)optionType {
    NSString *putType = @"P";
    BOOL result = [putType isEqualToString:[self string:self.contractID BySeparatedString:putType]];
    return result ? MOptionTypePut : MOptionTypeCall;
}

- (NSString *)string:(NSString *)string BySeparatedString:(NSString *)seperatedString {
    NSRange range = [string rangeOfString:seperatedString];
    if (range.length == [seperatedString length]) {
        return [string substringWithRange:range];
    }
    
    return @"C";
}

@end
