//
//  MCategoryQuoteListRequest.m
//  MAPI
//
//  Created by 梁晖 on 15/8/6.
//  Copyright (c) 2015年 Mitake. All rights reserved.
//

#import "MCategoryQuoteListRequest.h"

@implementation MCategoryQuoteListRequest

- (NSString *)APIVersion {
    return @"v2";
}

- (NSString *)path {
    return @"catequote";
}

- (NSDictionary *)HTTPHeaderFields {
    NSMutableDictionary *headerFields = [self commonHTTPHeaderFields];
    if (self.categoryID) {
        headerFields[@"Symbol"] = self.categoryID;
    }
    if (self.pageIndex >= 0) {
        headerFields[@"Param"] = [NSString stringWithFormat:@"%ld", (long)self.pageIndex];
    }
    return (NSDictionary *)headerFields;
}

@end
