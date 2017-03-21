//
//  MPriceVolumeRequest.m
//  MAPI
//
//  Created by FanChiangShihWei on 2016/6/30.
//  Copyright © 2016年 Mitake. All rights reserved.
//

#import "MPriceVolumeRequest.h"

@implementation MPriceVolumeRequest

- (NSString *)_market {
    return [self level2_marketString];
}

- (NSString *)path {
    return @"pv";
}

- (NSString *)APIVersion {
    return @"v2";
}

- (NSDictionary *)HTTPHeaderFields {
    NSMutableDictionary *headerFields = [self commonHTTPHeaderFields];
    headerFields[@"Symbol"] = self.code;
    return (NSDictionary *)headerFields;
}

@end
