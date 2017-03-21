//
//  MIPOCalendarResponse.m
//  MAPI
//
//  Created by FanChiangShihWei on 2016/7/13.
//  Copyright © 2016年 Mitake. All rights reserved.
//

#import "MIPOCalendarResponse.h"

@implementation MIPOCalendarResponse

- (id)initWithData:(NSData *)data request:(MRequest *)request timestamp:(NSString *)timestamp headers:(NSDictionary *)headers {
    self = [super initWithData:data request:request timestamp:timestamp headers:headers];
    if (self) {
        NSDictionary *JSONObject = nil;
        if ([self getJSONObject:&JSONObject withData:data parseClass:NSDictionary.class]) {
            MRESPONSE_TRY_PARSE_DATA_START
            self.info = JSONObject;
            MRESPONSE_TRY_PARSE_DATA_END
        }
    }
    return self;
}

@end
