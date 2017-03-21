//
//  MBlockTradeInfoResponse.m
//  TSApi
//
//  Created by Mitake on 2015/3/22.
//  Copyright (c) 2015年 Mitake. All rights reserved.
//

#import "MBlockTradeInfoResponse.h"

@implementation MBlockTradeInfoResponse

- (id)initWithData:(NSData *)data request:(MRequest *)request timestamp:(NSString *)timestamp headers:(NSDictionary *)headers {
    self = [super initWithData:data request:request timestamp:timestamp headers:headers];
    if (self) {
        NSArray *JSONValues = nil;
        if ([self getJSONObject:&JSONValues withData:data parseClass:NSArray.class]) {
            self.records = JSONValues;
        }
    }
    return self;
}

@end
