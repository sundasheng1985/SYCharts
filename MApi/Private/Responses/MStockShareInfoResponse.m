//
//  MStockShareInfoResponse.m
//  TSApi
//
//  Created by Mitake on 2015/3/22.
//  Copyright (c) 2015年 Mitake. All rights reserved.
//

#import "MStockShareInfoResponse.h"

@implementation MStockShareInfoResponse

- (id)initWithData:(NSData *)data request:(MRequest *)request timestamp:(NSString *)timestamp headers:(NSDictionary *)headers {
    self = [super initWithData:data request:request timestamp:timestamp headers:headers];
    if (self) {
        NSDictionary *JSONObject = nil;
        if ([self getJSONObject:&JSONObject withData:data parseClass:NSDictionary.class]) {
            MRESPONSE_TRY_PARSE_DATA_START
            NSMutableDictionary *dict = [JSONObject mutableCopy];
            if (JSONObject[@"TotalShareL"]) {
                dict[@"TotalShareSum"] = JSONObject[@"TotalShareL"];
            }
            self.record = dict;
            MRESPONSE_TRY_PARSE_DATA_END
        }
    }
    return self;
}

@end
