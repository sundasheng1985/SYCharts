//
//  MUnderlyingStockRequest.m
//  TSApi
//
//  Created by Mitake on 2015/3/18.
//  Copyright (c) 2015年 Mitake. All rights reserved.
//

#import "MUnderlyingStockRequest.h"

@implementation MUnderlyingStockRequest

- (NSString *)path {
    return @"optionlist";
}

- (NSString *)APIVersion {
    return @"v2";
}

- (NSDictionary *)HTTPHeaderFields {
    NSMutableDictionary *headerFields = [self commonHTTPHeaderFields];
    return (NSDictionary *)headerFields;
}


@end
