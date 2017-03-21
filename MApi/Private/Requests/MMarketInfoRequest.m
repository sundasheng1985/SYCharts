//
//  MMarketInfoRequest.m
//  MAPI
//
//  Created by mitake on 2015/5/28.
//  Copyright (c) 2015年 Mitake. All rights reserved.
//

#import "MMarketInfoRequest.h"
#import "MApiHelper.h"

@implementation MMarketInfoRequest

- (NSString *)path {
    return @"service/marketinfo";
}

- (NSDictionary *)HTTPHeaderFields {
    NSMutableDictionary *headerFields = [self commonHTTPHeaderFields];
    return (NSDictionary *)headerFields;
}


@end
