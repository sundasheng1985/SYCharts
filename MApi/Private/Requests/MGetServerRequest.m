//
//  MGetServerRequest.m
//  MAPI
//
//  Created by FanChiangShihWei on 2016/11/16.
//  Copyright © 2016年 Mitake. All rights reserved.
//

#import "MGetServerRequest.h"

@implementation MGetServerRequest

- (NSString *)path {
    return @"service/getAppServerIP";
}

- (NSDictionary *)HTTPHeaderFields {
    NSMutableDictionary *headerFields = [self commonHTTPHeaderFields];
    headerFields[@"Param"] = [NSString stringWithFormat:@"%@_%@_%@",
                              [MApiHelper sharedHelper].corpID,
                              self.platform,
                              self.bundleID];
    return (NSDictionary *)headerFields;
}

@end
