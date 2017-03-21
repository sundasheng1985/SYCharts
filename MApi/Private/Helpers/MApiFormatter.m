//
//  CTFormatter.m
//  TSApi
//
//  Created by Mitake on 2015/4/24.
//  Copyright (c) 2015年 Mitake. All rights reserved.
//

#import "MApiFormatter.h"

#import "MMarketInfo.h"

//double MApiFormatterFloorDouble(double number, uint16_t decimal) {
//    if (number==0)
//        return number;
//    bool b=number<0;
//    if (b)
//        number-= (1.0/pow(10,(decimal+1)));
//    else
//        number+= (1.0/pow(10,(decimal+1)));
//    number*=pow(10, decimal);
//    number=floor(fabs(number));
//    number/=pow(10, decimal);
//    return b?number*-1:number;
//}

static NSString *const kNilValueString = @"一";
@implementation MApiFormatter


+ (NSString *)mapi_formatPriceWithValue:(double)value marketInfo:(MMarketInfo *)info {
    NSString *format = [NSString stringWithFormat:@"%%.%@f", @(info.decimal)];
    return [NSString stringWithFormat:format, value + 0.00000001];
}


//五档与明细数据规则
+ (NSString *)mapi_formatTickItemsUnitWithValue:(double)value{
    if (value == 0) {
        return kNilValueString;
    }
    if (value >= 100000000000.) {
        return [self stingWithDouble: value / 100000000. numberOfDecimal:0 unit:@"亿"];
    }
    else if (value >= 10000000000.) {
        return [self stingWithDouble: value / 100000000. numberOfDecimal:1 unit:@"亿"];
    }
    else if (value >= 100000000.) {
        return [self stingWithDouble: value / 100000000. numberOfDecimal:2 unit:@"亿"];
    }
    else if (value >= 10000000.) {
        return [self stingWithDouble: value/ 10000. numberOfDecimal:0 unit:@"万"];
    }
    else if (value >= 1000000.) {
        return [self stingWithDouble: value/ 10000. numberOfDecimal:1 unit:@"万"];
    }
    else if (value >= 10000.) {
        return [self stingWithDouble: value/ 10000. numberOfDecimal:2 unit:@"万"];
    }
    else {
        return [self stingWithDouble: value numberOfDecimal:0 unit:nil];
    }
}

//中文格式化量的数值
+ (NSString *)mapi_formatChineseUnitWithValue:(double)value {
    if (value == 0) {
        return kNilValueString;
    }
    if (value >= 100000000000.) {
        return [self stingWithDouble: value / 100000000. numberOfDecimal:0 unit:@"亿"];
    }
    else if (value >= 10000000000.) {
        return [self stingWithDouble: value / 100000000. numberOfDecimal:1 unit:@"亿"];
    }
    else if (value >= 1000000000.) {
        return [self stingWithDouble: value / 100000000. numberOfDecimal:2 unit:@"亿"];
    }
    else if (value >= 100000000.) {
        return [self stingWithDouble: value / 10000. numberOfDecimal:0 unit:@"万"];
    }
    else if (value >= 10000000.) {
        return [self stingWithDouble: value / 10000. numberOfDecimal:0 unit:@"万"];
    }
    else if (value >= 1000000.) {
        return [self stingWithDouble: value / 10000. numberOfDecimal:0 unit:@"万"];
    }
    else if (value >= 100000.) {
        return [self stingWithDouble: value / 10000. numberOfDecimal:2 unit:@"万"];
    }
    else if (value >= 10000.) {
        return [self stingWithDouble: value / 10000. numberOfDecimal:2 unit:@"万"];
    }
    else if (value < 1.) {
        return [self stingWithDouble: value numberOfDecimal:2 unit:nil];
    }
    else {
        return [self stingWithDouble: value numberOfDecimal:0 unit:nil];
    }
}

//中文格式化量的数值
+ (NSString *)mapi_formatChineseUnitWithValue:(double)value maxValue:(double)maxValue {
    if (value == 0) {
        return kNilValueString;
    }

    if (maxValue >= 100000000000.) {
        return [self stingWithDouble: value / 100000000. numberOfDecimal:0 unit:@"亿"];
    }
    else if (maxValue >= 10000000000.) {
        return [self stingWithDouble: value / 100000000. numberOfDecimal:1 unit:@"亿"];
    }
    else if (maxValue >= 1000000000.) {
        return [self stingWithDouble: value / 100000000. numberOfDecimal:2 unit:@"亿"];
    }
    else if (maxValue >= 100000000.) {
        return [self stingWithDouble: value / 10000. numberOfDecimal:0 unit:@"万"];
    }
    else if (maxValue >= 10000000.) {
        return [self stingWithDouble: value / 10000. numberOfDecimal:0 unit:@"万"];
    }
    else if (maxValue >= 1000000.) {
        return [self stingWithDouble: value / 10000. numberOfDecimal:2 unit:@"万"];
    }
    else if (maxValue >= 100000.) {
        return [self stingWithDouble: value / 10000. numberOfDecimal:2 unit:@"万"];
    }
    else if (maxValue >= 10000.) {
        return [self stingWithDouble: value / 10000. numberOfDecimal:2 unit:@"万"];
    }
    else if (maxValue < 1.) {
        return [self stingWithDouble: value numberOfDecimal:2 unit:nil];
    }
    else {
        return [self stingWithDouble: value numberOfDecimal:0 unit:nil];
    }
}

//中文格式化金额的数值
+ (NSString *)mapi_formatChineseAmountWithValue:(double)value {
    if (value == 0) {
        return kNilValueString;
    }
    if (value >= 100000000000.) {
        return [self stingWithDouble: value / 100000000. numberOfDecimal:0 unit:@"亿"];
    }
    else if (value >= 10000000000.) {
        return [self stingWithDouble: value / 100000000. numberOfDecimal:1 unit:@"亿"];
    }
    else if (value >= 1000000000.) {
        return [self stingWithDouble: value / 100000000. numberOfDecimal:2 unit:@"亿"];
    }
    else if (value >= 100000000.) {
        return [self stingWithDouble: value / 100000000. numberOfDecimal:2 unit:@"亿"];
    }
    else if (value >= 10000000.) {
        return [self stingWithDouble: value / 10000. numberOfDecimal:0 unit:@"万"];
    }
    else if (value >= 1000000.) {
        return [self stingWithDouble: value / 10000. numberOfDecimal:1 unit:@"万"];
    }
    else if (value >= 100000.) {
        return [self stingWithDouble: value / 10000. numberOfDecimal:2 unit:@"万"];
    }
    else if (value >= 10000.) {
        return [self stingWithDouble: value / 10000. numberOfDecimal:3 unit:@"万"];
    }
    else {
        return [self stingWithDouble: value numberOfDecimal:0 unit:nil];
    }
}

//中文格式化金额的数值
+ (NSString *)mapi_formatChineseAmountWithValue:(double)value maxValue:(double)maxValue {
    if (value == 0) {
        return kNilValueString;
    }
    if (maxValue >= 100000000000.) {
        return [self stingWithDouble: value / 100000000. numberOfDecimal:0 unit:@"亿"];
    }
    else if (maxValue >= 10000000000.) {
        return [self stingWithDouble: value / 100000000. numberOfDecimal:1 unit:@"亿"];
    }
    else if (maxValue >= 1000000000.) {
        return [self stingWithDouble: value / 100000000. numberOfDecimal:2 unit:@"亿"];
    }
    else if (maxValue >= 100000000.) {
        return [self stingWithDouble: value / 100000000. numberOfDecimal:2 unit:@"亿"];
    }
    else if (maxValue >= 10000000.) {
        return [self stingWithDouble: value / 10000. numberOfDecimal:0 unit:@"万"];
    }
    else if (maxValue >= 1000000.) {
        return [self stingWithDouble: value / 10000. numberOfDecimal:1 unit:@"万"];
    }
    else if (maxValue >= 100000.) {
        return [self stingWithDouble: value / 10000. numberOfDecimal:2 unit:@"万"];
    }
    else if (maxValue >= 10000.) {
        return [self stingWithDouble: value / 10000. numberOfDecimal:3 unit:@"万"];
    }
    else {
        return [self stingWithDouble: value numberOfDecimal:0 unit:nil];
    }
}


//數據處理
+ (NSString *)stingWithDouble:(double)caculateValue numberOfDecimal:(NSInteger)number unit:(NSString *)unit {
    if (!unit) {
        unit = @"";
    }
    NSString *format = [NSString stringWithFormat:@"%%.%df", (int32_t)number];
    NSString * formatVol = [NSString stringWithFormat:format, caculateValue + 0.00000001];
    NSString *result = [NSString stringWithFormat:@"%@%@",formatVol,unit];
//    NSString *stringValue = [NSString stringWithFormat:@"%.%@f",caculateValue];
//    NSArray *stringArray = [stringValue componentsSeparatedByString:@"."];
//    //+1 因为小数点 
//    NSInteger index = number > 0 ? ([stringArray[0] length]  + 1 + number) : [stringArray[0] length] ;
//
//    NSString *result = [NSString stringWithFormat:@"%@%@",[stringValue substringToIndex:index],unit];
    
    return result;
}

@end
