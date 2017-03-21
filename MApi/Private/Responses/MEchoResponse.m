//
//  MEchoResponse.m
//  MAPI
//
//  Created by Mitake on 2015/6/26.
//  Copyright (c) 2015年 Mitake. All rights reserved.
//

#import "MEchoResponse.h"

@implementation MEchoResponse

- (id)initWithData:(NSData *)data request:(MRequest *)request timestamp:(NSString *)timestamp headers:(NSDictionary *)headers {
    self = [super initWithData:data request:request timestamp:timestamp headers:headers];
    if (self) {
        NSDictionary *JSONValue = nil;
        if (headers) {
            MRESPONSE_TRY_PARSE_DATA_START
            NSString *tradeDates = headers[@"ex"];
            NSArray *components = [tradeDates componentsSeparatedByString:@","];
            NSString *sh = ([components count] > 0) ? components[0] : @"";
            NSString *sz = ([components count] > 1) ? components[1] : @"";
            NSString *hk = ([components count] > 2) ? components[2] : @"";
            self.marketTradeDates = @{@"timestamp":headers[@"t"],
                                      @"hk":hk,
                                      @"sh":sh,
                                      @"sz":sz};
            MRESPONSE_TRY_PARSE_DATA_END
        }
        else if ([self getJSONObject:&JSONValue withData:data parseClass:NSDictionary.class]) {
            self.marketTradeDates = JSONValue;
        }
    }
    return self;
}

@end
