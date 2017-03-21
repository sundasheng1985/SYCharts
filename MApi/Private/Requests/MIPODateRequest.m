//
//  MIPODateRequest.m
//  MAPI
//
//  Created by FanChiangShihWei on 2016/7/13.
//  Copyright © 2016年 Mitake. All rights reserved.
//

#import "MIPODateRequest.h"

@implementation MIPODateRequest

- (NSString *)path {
    return @"tradingday";
}

- (NSString *)_market {
    return @"nf";
}

- (NSDictionary *)HTTPHeaderFields {
    NSMutableDictionary *headerFields = [self commonHTTPHeaderFields];
    return (NSDictionary *)headerFields;
}
@end
