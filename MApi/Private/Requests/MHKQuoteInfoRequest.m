//
//  MHKQuoteInfoRequest.m
//  MAPI
//
//  Created by FanChiangShihWei on 2016/7/14.
//  Copyright © 2016年 Mitake. All rights reserved.
//

#import "MHKQuoteInfoRequest.h"

@implementation MHKQuoteInfoRequest


- (NSString *)path {
    return @"hk_stockinfo";
}

- (NSString *)_market {
    return @"hk";
}

- (NSDictionary *)HTTPHeaderFields {
    NSMutableDictionary *headerFields = [self commonHTTPHeaderFields];
    if (self.code) {
        headerFields[@"Symbol"] = self.code;
    }
    return (NSDictionary *)headerFields;
}

@end
