//
//  MStockXRRequest.m
//  MAPI
//
//  Created by FanChiangShihWei on 2016/6/21.
//  Copyright © 2016年 Mitake. All rights reserved.
//

#import "MStockXRRequest.h"

@implementation MStockXRRequest

- (NSString *)path {
    return @"service/xrStock";
}

- (NSDictionary *)HTTPHeaderFields {
    NSMutableDictionary *headerFields = [self commonHTTPHeaderFields];
    headerFields[@"Symbol"] = self.code;
    headerFields[@"Param"] = [NSString stringWithFormat:@"%@_%@_%@",
                              [MApiHelper sharedHelper].corpID,
                              self.platform,
                              self.bundleID];
    return (NSDictionary *)headerFields;
}

@end
