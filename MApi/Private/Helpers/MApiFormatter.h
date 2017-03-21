//
//  CTFormatter.h
//  TSApi
//
//  Created by Mitake on 2015/4/24.
//  Copyright (c) 2015年 Mitake. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MMarketInfo;


NS_INLINE NSString *MApiFormatterStringForValue(NSString *value) {
    return value.length > 0 ? value : @"一";
}

@interface MApiFormatter : NSFormatter
+ (NSString *)mapi_formatPriceWithValue:(double)value marketInfo:(MMarketInfo *)info;
+ (NSString *)mapi_formatTickItemsUnitWithValue:(double)value;
+ (NSString *)mapi_formatChineseUnitWithValue:(double)value;
+ (NSString *)mapi_formatChineseUnitWithValue:(double)value maxValue:(double)maxValue;
+ (NSString *)mapi_formatChineseAmountWithValue:(double)value;
+ (NSString *)mapi_formatChineseAmountWithValue:(double)value maxValue:(double)maxValue;
@end
