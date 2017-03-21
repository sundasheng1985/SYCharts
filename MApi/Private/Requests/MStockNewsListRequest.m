//
//  MStockNewsListRequest.m
//  TSApi
//
//  Created by Mitake on 2015/3/22.
//  Copyright (c) 2015年 Mitake. All rights reserved.
//

#import "MStockNewsListRequest.h"
#import <objc/runtime.h>

@implementation MStockNewsListRequest
- (NSString *)APIVersion {
    return self.sourceType == 0 ? @"v1" : @"v2";
}

- (NSString *)path {
    return @"stocknewslist";
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
    MStockNewsListResponse *cacheObject = [self cachedObject];
    MStockNewsItem *firstNewsItem = [cacheObject.stockNewsItems firstObject];
    return firstNewsItem.ID;
}

- (NSString *)getLastNewsIDByPageIndex:(NSInteger)pageIndex {
    MStockNewsListResponse *cacheObject = [self cachedObject];
    NSString *lastNewsID;
    if (cacheObject.stockNewsItems.count <= (NSUInteger)self.pageIndex * 10) {
        lastNewsID = ((MStockNewsItem *)[cacheObject.stockNewsItems lastObject]).ID;
    }
    else {
        lastNewsID = ((MStockNewsItem *)cacheObject.stockNewsItems[(self.pageIndex * 10)]).ID;
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
