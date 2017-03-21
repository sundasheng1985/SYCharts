//
//  MForecastRatingRequest.m
//  TSApi
//
//  Created by Mitake on 2015/3/28.
//  Copyright (c) 2015年 Mitake. All rights reserved.
//

#import "MForecastRatingRequest.h"

@implementation MForecastRatingRequest

- (NSString *)path {
    return @"forecastrating";
}

- (NSString *)_market {
    return @"nf";
}

- (NSDictionary *)HTTPHeaderFields {
    NSMutableDictionary *headerFields = [self commonHTTPHeaderFields];
    headerFields[@"Symbol"] = self.code;
    return (NSDictionary *)headerFields;
}


@end
