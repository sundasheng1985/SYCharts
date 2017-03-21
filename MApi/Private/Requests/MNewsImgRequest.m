//
//  MNewsImgRequest.m
//  TSApi
//
//  Created by Mitake on 2015/4/13.
//  Copyright (c) 2015年 Mitake. All rights reserved.
//

#import "MNewsImgRequest.h"

@implementation MNewsImgRequest

- (NSString *)path {
    return @"fininfoimage";
}

- (NSString *)_market {
    return @"nf";
}

- (NSDictionary *)HTTPHeaderFields {
    NSMutableDictionary *headerFields = [self commonHTTPHeaderFields];
    headerFields[@"Symbol"] = self.newsID;
    return (NSDictionary *)headerFields;
}

#pragma mark - NSCaching

- (id)cachePath {
    NSString *relativePath = [self.path stringByAppendingPathComponent:self.APIVersion];
    return [relativePath stringByAppendingPathComponent:self.newsID];
}

- (id)cachedObject {
    return [MApiCache cachedObjectFromPath:[self cachePath]];
}
@end
