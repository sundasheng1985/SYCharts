//
//  MOrderQuantityRequest.m
//  MAPI
//
//  Created by FanChiangShihWei on 2016/6/30.
//  Copyright © 2016年 Mitake. All rights reserved.
//

#import "MOrderQuantityRequest.h"

@implementation MOrderQuantityRequest

- (NSString *)path {
    return @"orderQty";
}

- (NSString *)_market {
    return [self level2_marketString];
}

- (NSDictionary *)HTTPHeaderFields {
    NSMutableDictionary *headerFields = [self commonHTTPHeaderFields];
    headerFields[@"Symbol"] = self.code;
    return (NSDictionary *)headerFields;
}

@end
