//
//  MRiseRankingRequest.m
//  TSApi
//
//  Created by Mitake on 2015/3/23.
//  Copyright (c) 2015年 Mitake. All rights reserved.
//

#import "MRiseRankingRequest.h"

@implementation MRiseRankingRequest
- (NSString *)APIVersion {
    return @"v2";
}

- (NSString *)path {
    return @"cateranking";
}

- (NSDictionary *)HTTPHeaderFields {
    NSMutableDictionary *headerFields = [self commonHTTPHeaderFields];
    headerFields[@"Symbol"] = self.code;
    if (self.pageIndex >= 0) {
        NSMutableString *param = [NSMutableString stringWithFormat:@"%@", @(self.pageIndex)];
        if (self.pageSize > 0) {
            [param appendFormat:@",%@", @(self.pageSize)];
        }
        headerFields[@"Param"] = param;
    }
    return (NSDictionary *)headerFields;
}


@end
