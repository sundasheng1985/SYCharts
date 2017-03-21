//
//  MFundBasicInfoRequest.m
//  MAPI
//
//  Created by IOS_HMX on 16/12/16.
//  Copyright © 2016年 Mitake. All rights reserved.
//

#import "MFundBasicInfoRequest.h"

@implementation MFundBasicInfoRequest

- (NSString *)path {
    return @"fndbasicinfo";
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
