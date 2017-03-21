//
//  MSectionRankingRequest.m
//  TSApi
//
//  Created by Mitake on 2015/4/10.
//  Copyright (c) 2015年 Mitake. All rights reserved.
//

#import "MSectionRankingRequest.h"

@implementation MSectionRankingRequest

- (NSString *)path {
    return @"bankuairanking";
}

- (NSDictionary *)HTTPHeaderFields {
    NSMutableDictionary *headerFields = [self commonHTTPHeaderFields];
    headerFields[@"Symbol"] = self.code;
    if (self.pageIndex >= 0) {
        headerFields[@"Param"] = [NSString stringWithFormat:@"%ld", (long)self.pageIndex];
    }
    return (NSDictionary *)headerFields;
}


@end
