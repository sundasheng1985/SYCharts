//
//  MStockReportListRequest.m
//  TSApi
//
//  Created by Mitake on 2015/3/22.
//  Copyright (c) 2015年 Mitake. All rights reserved.
//

#import "MStockReportListRequest.h"

@implementation MStockReportListRequest
- (NSString *)APIVersion {
    return self.sourceType == 0 ? @"v1" : @"v2";
}

- (NSString *)path {
    return @"stockreportlist";
}

- (NSString *)_market {
    return @"nf";
}

- (NSDictionary *)HTTPHeaderFields {
    NSMutableDictionary *headerFields = [self commonHTTPHeaderFields];
    headerFields[@"Symbol"] = self.code;
    if (self.sourceType == MF10DataSourceCH) {
        headerFields[@"src"] = @"d";
    }else {
        headerFields[@"src"] = @"g";
    }
    NSString *param;
    id cachedObject = [self cachedObject];
    if (self.pageIndex == 0) {
        if (!cachedObject) {
            param = @"-1";
        }
        else {
            param = [NSString stringWithFormat:@"-1, %@", [self getFirstNewsID]];
        }
        
    }
    else {
        param = [self getLastNewsIDByPageIndex:self.pageIndex];
    }
    headerFields[@"Param"] = param;
    return (NSDictionary *)headerFields;
}

- (NSString *)getFirstNewsID {
    MStockReportListResponse *cacheObject = [self cachedObject];
    MStockReportItem *firstNewsItem = [cacheObject.stockReportItems firstObject];
    return firstNewsItem.ID;
}

- (NSString *)getLastNewsIDByPageIndex:(NSInteger)pageIndex {
    MStockReportListResponse *cacheObject = [self cachedObject];
    NSString *lastNewsID;
    if (cacheObject.stockReportItems.count <= (NSUInteger)self.pageIndex * 10) {
        lastNewsID = ((MStockReportItem *)[cacheObject.stockReportItems lastObject]).ID;
    }
    else {
        lastNewsID = ((MStockReportItem *)cacheObject.stockReportItems[(self.pageIndex * 10)]).ID;
    }
    return lastNewsID;
}

#pragma mark - MApiCaching

- (id)cachePath {
    NSString *relativePath = [self.path stringByAppendingPathComponent:self.APIVersion];
    return [relativePath stringByAppendingPathComponent:self.code];
}

- (id)cachedObject {
    return [MApiCache cachedObjectFromPath:[self cachePath]];
}

@end
