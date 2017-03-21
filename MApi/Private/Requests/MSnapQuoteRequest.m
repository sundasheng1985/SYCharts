//
//  MSnapQuoteRequest.m
//  TSApi
//
//  Created by Mitake on 2015/4/21.
//  Copyright (c) 2015年 Mitake. All rights reserved.
//

#import "MSnapQuoteRequest.h"

@implementation MSnapQuoteRequest
- (NSString *)APIVersion {
    return @"v2";
}

- (NSString *)path {
    if (self.type == MSnapQuoteRequestType5) {
        return @"quotentrd5";
    } else if (self.type == MSnapQuoteRequestType10) {
        return @"quotentrd10";
    }
    return @"quotentrd1";
}

- (NSString *)_market {
    return [self level2_marketString];
}

- (NSDictionary *)HTTPHeaderFields {
    NSMutableDictionary *headerFields = [self commonHTTPHeaderFields];
    NSMutableString *symbol = [NSMutableString stringWithFormat:@"%@", self.code];
    if (self.tickCount > 0) {
        [symbol appendFormat:@",%@", @(self.tickCount)];
    }
    headerFields[@"Symbol"] = symbol;
    return (NSDictionary *)headerFields;
}


@end
