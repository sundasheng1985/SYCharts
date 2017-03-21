//
//  MStockBulletinRequest.m
//  TSApi
//
//  Created by Mitake on 2015/3/22.
//  Copyright (c) 2015年 Mitake. All rights reserved.
//

#import "MStockBulletinRequest.h"

@implementation MStockBulletinRequest

- (NSString *)path {
    return @"stockbulletin";
}

- (NSString *)_market {
    return @"nf";
}

- (NSDictionary *)HTTPHeaderFields {
    NSMutableDictionary *headerFields = [self commonHTTPHeaderFields];
    headerFields[@"Symbol"] = self.stockBulletinID;
    return (NSDictionary *)headerFields;
}


#pragma mark - MApiCaching

- (id)cachePath {
    NSString *relativePath = [self.path stringByAppendingPathComponent:self.APIVersion];
    return [relativePath stringByAppendingPathComponent:self.stockBulletinID];
}

- (id)cachedObject {
    return [MApiCache cachedObjectFromPath:[self cachePath]];
}

@end
