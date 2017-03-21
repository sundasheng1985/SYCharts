//
//  MForecastRatingResponse.m
//  TSApi
//
//  Created by Mitake on 2015/3/28.
//  Copyright (c) 2015年 Mitake. All rights reserved.
//

#import "MForecastRatingResponse.h"

@implementation MForecastRatingResponse

- (id)initWithData:(NSData *)data request:(MRequest *)request timestamp:(NSString *)timestamp headers:(NSDictionary *)headers {
    self = [super initWithData:data request:request timestamp:timestamp headers:headers];
    if (self) {
        NSDictionary *JSONObject = nil;
        if ([self getJSONObject:&JSONObject withData:data parseClass:NSDictionary.class]) {
            self.ratingFlag = JSONObject[@"RATINGFLAG"];
            self.ratingDescription = JSONObject[@"RATINGDEC"];
            self.dateTitle = JSONObject[@"DATETITLE"];
            self.records = JSONObject[@"list"];
        }
    }
    return self;
}

@end
