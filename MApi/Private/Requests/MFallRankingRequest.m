//
//  MFallRankingRequest.m
//  TSApi
//
//  Created by Mitake on 2015/4/25.
//  Copyright (c) 2015年 Mitake. All rights reserved.
//

#import "MFallRankingRequest.h"

@implementation MFallRankingRequest

- (NSString *)path {
    return @"revcateranking";
}

- (NSString *)APIVersion {
    return @"v2";
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
