//
//  MIPOCalendarRequest.m
//  MAPI
//
//  Created by FanChiangShihWei on 2016/7/13.
//  Copyright © 2016年 Mitake. All rights reserved.
//

#import "MIPOCalendarRequest.h"

@implementation MIPOCalendarRequest

- (NSString *)path {
    return @"newsharescal";
}

- (NSString *)_market {
    return @"nf";
}

- (NSDictionary *)HTTPHeaderFields {
    NSMutableDictionary *headerFields = [self commonHTTPHeaderFields];
    if (self.date) {
        headerFields[@"Symbol"] = self.date;
    }
    return (NSDictionary *)headerFields;
}


@end
