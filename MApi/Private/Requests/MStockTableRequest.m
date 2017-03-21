//
//  MStockTableRequest.m
//  TSApi
//
//  Created by Mitake on 2015/3/13.
//  Copyright (c) 2015年 Mitake. All rights reserved.
//

#import "MStockTableRequest.h"
#import "MApiHelper.h"

@implementation MStockTableRequest

- (NSString *)path {
    return @"search";
}

- (NSDictionary *)HTTPHeaderFields {
    NSMutableDictionary *headerFields = [super commonHTTPHeaderFields];
    return (NSDictionary *)headerFields;
}


@end
