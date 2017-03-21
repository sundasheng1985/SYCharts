//
//  MSearchRequest.m
//  TSApi
//
//  Created by Mitake on 2015/3/22.
//  Copyright (c) 2015年 Mitake. All rights reserved.
//

#import "MSearchRequest.h"

@implementation MSearchRequest

- (NSString *)path {
    return @"search";
}

- (NSDictionary *)HTTPHeaderFields {
    NSMutableDictionary *headerFields = [self commonHTTPHeaderFields];
    if (self.keyword) {
        NSString *keyWord = [self.keyword stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        headerFields[@"Param"] = keyWord;
    } else {
        headerFields[@"Param"] = @"";
    }
    NSMutableString *symbol = [NSMutableString string];
    if (self.market.length > 0) {
        [symbol appendString:[self.market uppercaseString]];
    }
    if (self.subtype.length > 0) {
        [symbol appendString:self.subtype];
        headerFields[@"Symbol"] = symbol;
    }
    return (NSDictionary *)headerFields;
}


@end
