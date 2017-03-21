//
//  MStockReportRespone.m
//  TSApi
//
//  Created by Mitake on 2015/3/22.
//  Copyright (c) 2015年 Mitake. All rights reserved.
//

#import "MStockReportResponse.h"

@implementation MStockReportResponse

- (id)initWithData:(NSData *)data request:(MRequest *)request timestamp:(NSString *)timestamp headers:(NSDictionary *)headers {
    self = [super initWithData:data request:request timestamp:timestamp headers:headers];
    if (self) {
        NSDictionary *JSONObject = nil;
        if ([self getJSONObject:&JSONObject withData:data parseClass:NSDictionary.class]) {
            MRESPONSE_TRY_PARSE_DATA_START
            self.stockReportDetailItem = [MStockReportDetailItem itemWithJSONObject:JSONObject];
            MRESPONSE_TRY_PARSE_DATA_END
        }
    }
    return self;
}

@end
