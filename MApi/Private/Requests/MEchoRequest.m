//
//  MEchoRequest.m
//  MAPI
//
//  Created by Mitake on 2015/6/26.
//  Copyright (c) 2015年 Mitake. All rights reserved.
//

#import "MEchoRequest.h"
#import "MApiHelper.h"

@implementation MEchoRequest

- (NSString *)path {
    return @"service/echo";
}

- (NSString *)_market {
    return @"auth";
}

- (NSDictionary *)HTTPHeaderFields {
    NSMutableDictionary *headerFields = [NSMutableDictionary dictionary];
    headerFields[@"Accept-Encoding"] = @"gzip";
    return (NSDictionary *)headerFields;
}

@end
