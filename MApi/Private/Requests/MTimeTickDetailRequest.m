//
//  MTimeTickDetailRequest.m
//  MAPI
//
//  Created by FanChiangShihWei on 2016/8/29.
//  Copyright © 2016年 Mitake. All rights reserved.
//

#import "MTimeTickDetailRequest.h"

@implementation MTimeTickDetailRequest

- (NSString *)path {
    return @"tickdetail_l2";
}

- (NSString *)APIVersion {
    return @"v2";
}

- (NSString *)_market {
    return [self level2_marketString];
}

- (NSDictionary *)HTTPHeaderFields {
    ///v2/tickdetail_l2  -H 'Symbol: 600000.sh' -H 'Param:3,50'

    NSMutableDictionary *headerFields = [self commonHTTPHeaderFields];
    
    NSMutableString *param = [NSMutableString string];
    [param appendFormat:@"%@,", @(self.pageIndex)];
    [param appendFormat:@"%@", @(self.pageSize)];
    headerFields[@"Param"] = param;
    if (self.code) {
        headerFields[@"Symbol"] = self.code;
    }
    return (NSDictionary *)headerFields;
}

@end
