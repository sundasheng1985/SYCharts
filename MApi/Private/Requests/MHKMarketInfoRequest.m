//
//  MHKMarketInfoRequest.m
//  MAPI
//
//  Created by IOS_HMX on 16/12/14.
//  Copyright © 2016年 Mitake. All rights reserved.
//

#import "MHKMarketInfoRequest.h"

@implementation MHKMarketInfoRequest
- (NSString *)path {
    return @"hkmarinfo";
}
- (NSDictionary *)HTTPHeaderFields {
    NSMutableDictionary *headerFields = [self commonHTTPHeaderFields];
    return (NSDictionary *)headerFields;
}
@end
