//
//  MOptionRequest.m
//  TSApi
//
//  Created by Mitake on 2015/3/22.
//  Copyright (c) 2015年 Mitake. All rights reserved.
//

#import "MOptionRequest.h"

@implementation MOptionRequest

- (NSString *)path {
    return @"optionquote";
}

- (NSString *)APIVersion {
    return @"v2";
}

- (NSDictionary *)HTTPHeaderFields {
    NSMutableDictionary *headerFields = [self commonHTTPHeaderFields];
    headerFields[@"Symbol"] = [NSString stringWithFormat:@"%@%@",self.stockID,[self optionTypeString]];
    headerFields[@"Param"] = [NSString stringWithFormat:@"%lu" ,(long)self.pageIndex];
    return (NSDictionary *)headerFields;
}


- (NSString *)optionTypeString {
    NSString *optionTypeString;
    if (self.optionType == MOptionTypeCall) {
        optionTypeString = @"_CALL";
    } else if (self.optionType == MOptionTypePut) {
        optionTypeString = @"_PUT";
    } else {
        optionTypeString = @"";
    }
    return optionTypeString;
}

@end
