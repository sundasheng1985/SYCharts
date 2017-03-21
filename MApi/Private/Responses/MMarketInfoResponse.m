//
//  MMarketInfoResponse.m
//  MAPI
//
//  Created by mitake on 2015/5/28.
//  Copyright (c) 2015年 Mitake. All rights reserved.
//

#import "MMarketInfoResponse.h"

@implementation MMarketInfoResponse

- (id)initWithData:(NSData *)data request:(MRequest *)request timestamp:(NSString *)timestamp headers:(NSDictionary *)headers {
    self = [super initWithData:data request:request timestamp:timestamp headers:headers];
    if (self) {
        NSDictionary *JSONValue = nil;
        if ([self getJSONObject:&JSONValue withData:data parseClass:NSDictionary.class]) {
            self.marketInfos = JSONValue;
        }
    }
    return self;
}

@end
