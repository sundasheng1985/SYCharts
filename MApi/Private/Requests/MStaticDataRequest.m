//
//  MStaticDataRequest.m
//  MAPI
//
//  Created by IOS_HMX on 16/12/14.
//  Copyright © 2016年 Mitake. All rights reserved.
//

#import "MStaticDataRequest.h"

@implementation MStaticDataRequest
- (NSString *)path {
    return @"stockinfo";
}


- (NSDictionary *)HTTPHeaderFields {
    NSMutableDictionary *headerFields = [self commonHTTPHeaderFields];
    headerFields[@"Symbol"] = self.code;
    if (self.param && self.param.length>0) {
        headerFields[@"Param"] = self.param;
    }else {
        self.param = @"bk,hki,su,bu";
        headerFields[@"Param"] = self.param;
    }
        
    return (NSDictionary *)headerFields;
}
@end
