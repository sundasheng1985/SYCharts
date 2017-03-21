//
//  MTimeTickRequest.m
//  MAPI
//
//  Created by FanChiangShihWei on 2016/6/30.
//  Copyright © 2016年 Mitake. All rights reserved.
//

#import "MTimeTickRequest.h"

@implementation MTimeTickRequest

- (instancetype)init
{
    self = [super init];
    if (self) {
        _pageSize = 20;
    }
    return self;
}

- (NSString *)path {
    return @"tick";
}

- (NSString *)APIVersion {
    return @"v2";
}

- (NSString *)_market {
    return [self level2_marketString];
}

- (NSDictionary *)HTTPHeaderFields {
    NSMutableDictionary *headerFields = [self commonHTTPHeaderFields];
    headerFields[@"Symbol"] = self.code;
    
    headerFields[@"Param"] = [NSString stringWithFormat:@"%@,%zd,%zd",
                              self.index?:@"0", self.pageSize, self.type];
    return (NSDictionary *)headerFields;
}

@end
