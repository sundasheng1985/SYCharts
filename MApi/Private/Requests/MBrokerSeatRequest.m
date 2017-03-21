//
//  MBrokerSeatRequest.m
//  TSApi
//
//  Created by 李政修 on 2015/4/17.
//  Copyright (c) 2015年 Mitake. All rights reserved.
//

#import "MBrokerSeatRequest.h"

@implementation MBrokerSeatRequest

- (NSString *)path {
    return @"hk_brokerinfo";
}

- (NSString *)_market {
    return @"hk";
}

- (NSDictionary *)HTTPHeaderFields {
    NSMutableDictionary *headerFields = [self commonHTTPHeaderFields];
    headerFields[@"Symbol"] = self.code;
    return (NSDictionary *)headerFields;
}

- (BOOL)isValidate {
    return [self.code validateCode];
}

@end
