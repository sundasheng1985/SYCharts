//
//  MBigEventNotificationRequest.m
//  TSApi
//
//  Created by Mitake on 2015/3/28.
//  Copyright (c) 2015年 Mitake. All rights reserved.
//

#import "MBigEventNotificationRequest.h"

@implementation MBigEventNotificationRequest

- (NSString *)path {
    return @"importantnotice";
}

- (NSString *)_market {
    return @"nf";
}

- (NSDictionary *)HTTPHeaderFields {
    NSMutableDictionary *headerFields = [self commonHTTPHeaderFields];
    headerFields[@"Symbol"] = self.code;
    return (NSDictionary *)headerFields;
}


@end
