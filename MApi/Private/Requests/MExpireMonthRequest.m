//
//  MExpireMonthRequest.m
//  TSApi
//
//  Created by Mitake on 2015/3/22.
//  Copyright (c) 2015年 Mitake. All rights reserved.
//

#import "MExpireMonthRequest.h"

@implementation MExpireMonthRequest

- (NSString *)path {
    return @"optionexpire";
}

- (NSDictionary *)HTTPHeaderFields {
    NSMutableDictionary *headerFields = [self commonHTTPHeaderFields];
    headerFields[@"Symbol"] = self.stockID;
    return (NSDictionary *)headerFields;
}

@end
