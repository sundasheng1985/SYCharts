//
//  MIPOShareDetailRequest.m
//  MAPI
//
//  Created by FanChiangShihWei on 2016/7/13.
//  Copyright © 2016年 Mitake. All rights reserved.
//

#import "MIPOShareDetailRequest.h"

@implementation MIPOShareDetailRequest

- (NSString *)path {
    return @"shareipodetail";
}

- (NSString *)_market {
    return @"nf";
}

- (NSDictionary *)HTTPHeaderFields {
    NSMutableDictionary *headerFields = [self commonHTTPHeaderFields];
    if (self.code) {
        headerFields[@"Symbol"] = self.code;
    }
    return (NSDictionary *)headerFields;
}
@end
