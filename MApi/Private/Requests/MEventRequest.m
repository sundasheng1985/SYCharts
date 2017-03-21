//
//  MEventRequest.m
//  MAPI
//
//  Created by Mitake on 2015/6/13.
//  Copyright (c) 2015年 Mitake. All rights reserved.
//

#import "MEventRequest.h"

@implementation MEventRequest

- (NSString *)path {
    return @"service/event";
}

- (NSDictionary *)HTTPHeaderFields {
    NSMutableDictionary *headerFields = [self commonHTTPHeaderFields];
    headerFields[@"Symbol"] = self.fid;
    headerFields[@"Param"] = [NSString stringWithFormat:@"%@_%@_%@",
                              [MApiHelper sharedHelper].corpID,
                              self.platform,
                              self.bundleID];
    return (NSDictionary *)headerFields;
}

@end
