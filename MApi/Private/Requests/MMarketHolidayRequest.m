//
//  MMarketHolidayRequest.m
//  MAPI
//
//  Created by FanChiangShihWei on 2016/7/13.
//  Copyright © 2016年 Mitake. All rights reserved.
//

#import "MMarketHolidayRequest.h"

@implementation MMarketHolidayRequest

- (NSString *)path {
    return @"service/holiday";
}

- (NSDictionary *)HTTPHeaderFields {
    NSMutableDictionary *headerFields = [super commonHTTPHeaderFields];
    return (NSDictionary *)headerFields;
}

@end
