//
//  MFundValueRequest.m
//  MAPI
//
//  Created by 陈志春 on 16/10/17.
//  Copyright © 2016年 Mitake. All rights reserved.
//

#import "MFundValueRequest.h"

@implementation MFundValueRequest
- (NSString *)path {
    return @"fndnavindex";
}


- (NSString *)_market {
    return @"nf";
}

- (NSDictionary *)HTTPHeaderFields {    
    NSMutableDictionary *headerFields = [self commonHTTPHeaderFields];
    if (self.code) {
        headerFields[@"Symbol"] = self.code;
    }
    if (self.type) {
        headerFields[@"type"] = self.type;
    }
    return (NSDictionary *)headerFields;
}
@end
