//
//  MGetAppSourceRequest.m
//  MAPI
//
//  Created by Mitake on 2015/7/27.
//  Copyright (c) 2015年 Mitake. All rights reserved.
//

#import "MGetSourceClassRequest.h"


@implementation MGetSourceClassRequest

- (NSString *)path {
    return @"service/getAppSourceClass";
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
