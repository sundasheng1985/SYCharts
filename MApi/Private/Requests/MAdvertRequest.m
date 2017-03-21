//
//  MAdvertRequest.m
//  MAPI
//
//  Created by Mitake on 2015/6/12.
//  Copyright (c) 2015年 Mitake. All rights reserved.
//

#import "MAdvertRequest.h"

@implementation MAdvertRequest

- (NSString *)path {
    return @"service/marketing";
}

- (NSDictionary *)HTTPHeaderFields {
    NSMutableDictionary *headerFields = [self commonHTTPHeaderFields];
    if (self.advertKey) {
        headerFields[@"Param"] = [NSString stringWithFormat:@"%@_%@",
                                  [MApiHelper sharedHelper].corpID,
                                  self.advertKey];
        headerFields[@"Param"] = self.advertKey;
    } else {
        headerFields[@"Param"] = [MApiHelper sharedHelper].corpID;
    }

    return (NSDictionary *)headerFields;
}

@end
