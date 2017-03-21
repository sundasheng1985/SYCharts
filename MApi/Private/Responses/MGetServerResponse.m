//
//  MGetServerResponse.m
//  MAPI
//
//  Created by FanChiangShihWei on 2016/11/16.
//  Copyright © 2016年 Mitake. All rights reserved.
//

#import "MGetServerResponse.h"

@implementation MGetServerResponse

- (id)initWithData:(NSData *)data request:(MRequest *)request timestamp:(NSString *)timestamp headers:(NSDictionary *)headers {
    self = [super initWithData:data request:request timestamp:timestamp headers:headers];
    if (self) {
        MRESPONSE_TRY_PARSE_DATA_START
        NSDictionary *JSONObject = nil;
        if ([self getJSONObject:&JSONObject withData:data parseClass:NSDictionary.class]) {
            self.servers = JSONObject[@"quote"];
            self.fileVersion = headers[@"t"];
        }
        MRESPONSE_TRY_PARSE_DATA_END
    }
    return self;
}

@end
