//
//  MDataRequest.m
//  MAPI
//
//  Created by IOS_HMX on 16/12/16.
//  Copyright © 2016年 Mitake. All rights reserved.
//

#import "MDataRequest.h"

@implementation MDataRequest

- (NSString *)APIVersion {
    return self.sourceType == 0 ? @"v1" : @"v2";
}

- (NSMutableDictionary *)commonHTTPHeaderFields {
    NSMutableDictionary *headerFields = [super commonHTTPHeaderFields];
    if (self.sourceType == MF10DataSourceCH) {
        headerFields[@"src"] = @"d";
    }else {
        headerFields[@"src"] = @"g";
    }
    return headerFields;
}

@end
