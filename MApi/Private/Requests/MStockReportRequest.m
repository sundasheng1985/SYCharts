//
//  MStockReportRequest.m
//  TSApi
//
//  Created by Mitake on 2015/3/22.
//  Copyright (c) 2015年 Mitake. All rights reserved.
//

#import "MStockReportRequest.h"

@implementation MStockReportRequest

- (NSString *)path {
    return @"stockreport";
}

- (NSString *)_market {
    return @"nf";
}

- (NSDictionary *)HTTPHeaderFields {
    NSMutableDictionary *headerFields = [self commonHTTPHeaderFields];
    headerFields[@"Symbol"] = self.stockReportID;
    return (NSDictionary *)headerFields;
}


#pragma mark - MApiCaching
- (id)cachePath {
    NSString *relativePath = [self.path stringByAppendingPathComponent:self.APIVersion];
    return [relativePath stringByAppendingPathComponent:self.stockReportID];
}

- (id)cachedObject {
    return [MApiCache cachedObjectFromPath:[self cachePath]];
}


@end
