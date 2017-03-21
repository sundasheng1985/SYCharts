//
//  MNewsListRequest.m
//  TSApi
//
//  Created by Mitake on 2015/3/22.
//  Copyright (c) 2015年 Mitake. All rights reserved.
//

#import "MNewsListRequest.h"

NSString *const MNewsTypeImportant = @"0000";
NSString *const MNewsTypeRoll = @"";
NSString *const MNewsTypeFinance = @"13";
NSString *const MNewsTypeIndustry = @"14";
NSString *const MNewsTypeStock = @"15";
NSString *const MNewsTypeFuture = @"11";
NSString *const MNewsTypeForeignExchange = @"10";
NSString *const MNewsTypeFund = @"16";
NSString *const MNewsTypeBond = @"17";
NSString *const MNewsTypeGold = @"12";
NSString *const MNewsTypeOthers = @"99";

@implementation MNewsListRequest

- (NSString *)APIVersion {
    return self.sourceType == 0 ? @"v1" : @"v2";
}

- (NSString *)path {
    return @"fininfolist";
}

- (NSString *)_market {
    return @"nf";
}

- (NSDictionary *)HTTPHeaderFields {
    NSMutableDictionary *headerFields = [self commonHTTPHeaderFields];
    if ([self.newsType length] != 0) {
        headerFields[@"Symbol"] = self.newsType;
    }
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
    MNewsListResponse *cacheObject = [self cachedObject];
    MNewsItem *firstNewsItem = [cacheObject.newsItems firstObject];
    return firstNewsItem.ID;
}

- (NSString *)getLastNewsIDByPageIndex:(NSInteger)pageIndex {
    MNewsListResponse *cacheObject = [self cachedObject];
    NSString *lastNewsID;
    if (cacheObject.newsItems.count <= (NSUInteger)self.pageIndex * 10) {
        lastNewsID = ((MNewsItem *)[cacheObject.newsItems lastObject]).ID;
    }
    else {
        lastNewsID = ((MNewsItem *)cacheObject.newsItems[(self.pageIndex * 10)]).ID;
    }
    return lastNewsID;
}

#pragma mark - MApiCaching

- (id)cachePath {
    NSString *relativePath = [self.path stringByAppendingPathComponent:self.APIVersion];
    return [relativePath stringByAppendingPathComponent:self.newsType];
}

- (id)cachedObject {
    return [MApiCache cachedObjectFromPath:[self cachePath]];
}
@end
