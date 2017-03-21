//
//  MBondBuyBacksRequest.m
//  MAPI
//
//  Created by IOS_HMX on 16/12/19.
//  Copyright © 2016年 Mitake. All rights reserved.
//

#import "MBondBuyBacksRequest.h"

@implementation MBondBuyBacksRequest

- (NSString *)path {
    return @"bndbuybacks";
}

- (NSString *)_market {
    return @"nf";
}

- (NSDictionary *)HTTPHeaderFields {
    NSMutableDictionary *headerFields = [self commonHTTPHeaderFields];
    headerFields[@"Symbol"] = self.code;
    return (NSDictionary *)headerFields;
}

@end
