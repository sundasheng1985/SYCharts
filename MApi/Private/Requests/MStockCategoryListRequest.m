//
//  MSearchCategoryRequest.m
//  MAPI
//
//  Created by FanChiangShihWei on 2016/4/14.
//  Copyright © 2016年 Mitake. All rights reserved.
//

#import "MStockCategoryListRequest.h"

@implementation MStockCategoryListRequest

- (NSString *)path {
    return @"service/catetype";
}

- (NSDictionary *)HTTPHeaderFields {
    NSMutableDictionary *headerFields = [self commonHTTPHeaderFields];
    return (NSDictionary *)headerFields;
}


@end
