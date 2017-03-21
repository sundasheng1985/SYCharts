//
//  MOptionTRequest.m
//  TSApi
//
//  Created by Mitake on 2015/5/21.
//  Copyright (c) 2015年 Mitake. All rights reserved.
//

#import "MOptionTRequest.h"

@implementation MOptionTRequest

- (NSString *)path {
    return @"optiontquote";
}

- (NSString *)APIVersion {
    return @"v2";
}

- (NSDictionary *)HTTPHeaderFields {
    NSMutableDictionary *headerFields = [self commonHTTPHeaderFields];
    NSString *symbol = [self.stockID stringByAppendingFormat:@"_%@",self.expireMonth];
    headerFields[@"Symbol"] = symbol;
    return (NSDictionary *)headerFields;
}

@end
