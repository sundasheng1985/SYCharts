//
//  MQuoteRequest.m
//  TSApi
//
//  Created by Mitake on 2015/3/18.
//  Copyright (c) 2015年 Mitake. All rights reserved.
//

#import "MQuoteRequest.h"

@implementation MQuoteRequest
- (NSString *)APIVersion {
    return @"v2";
}

- (NSString *)path {
    return @"quote";
}

- (NSString *)_market {
    return [self level2_marketString];
}

- (NSDictionary *)HTTPHeaderFields {
    NSMutableDictionary *headerFields = [self commonHTTPHeaderFields];
    headerFields[@"Symbol"] = self.code;
    return (NSDictionary *)headerFields;
}

@end
