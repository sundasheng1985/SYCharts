//
//  MFundShareHolderInfoResponse.m
//  TSApi
//
//  Created by Mitake on 2015/3/22.
//  Copyright (c) 2015年 Mitake. All rights reserved.
//

#import "MFundShareHolderInfoResponse.h"

@implementation MFundShareHolderInfoResponse

- (id)initWithData:(NSData *)data request:(MRequest *)request timestamp:(NSString *)timestamp headers:(NSDictionary *)headers {
    self = [super initWithData:data request:request timestamp:timestamp headers:headers];
    if (self) {
        NSDictionary *JSONObject = nil;
        if ([self getJSONObject:&JSONObject withData:data parseClass:NSDictionary.class]) {
            _count = [JSONObject[@"COUNT"] integerValue];
            _endDate = JSONObject[@"ENDDATE"];
            self.records = JSONObject[@"list"];
        }
    }
    return self;
}

@end
