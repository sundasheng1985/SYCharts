//
//  MFundShareHolderInfoRequest.m
//  TSApi
//
//  Created by Mitake on 2015/3/22.
//  Copyright (c) 2015年 Mitake. All rights reserved.
//

#import "MFundShareHolderInfoRequest.h"

@implementation MFundShareHolderInfoRequest

- (NSString *)path {
    return @"fundshareholding";
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
