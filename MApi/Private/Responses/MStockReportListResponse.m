//
//  MStockReportListResponse.m
//  TSApi
//
//  Created by Mitake on 2015/3/22.
//  Copyright (c) 2015年 Mitake. All rights reserved.
//

#import "MStockReportListResponse.h"

@implementation MStockReportListResponse

- (id)initWithData:(NSData *)data request:(MRequest *)request timestamp:(NSString *)timestamp headers:(NSDictionary *)headers {
    self = [super initWithData:data request:request timestamp:timestamp headers:headers];
    if (self) {
        NSDictionary *JSONValues = nil;
        if ([self getJSONObject:&JSONValues withData:data parseClass:NSDictionary.class]) {
            MRESPONSE_TRY_PARSE_DATA_START
            NSMutableArray *items = [NSMutableArray array];
            for (NSDictionary *newsJSONValue in JSONValues[@"List"]) {
                id item = [MStockReportItem itemWithJSONObject:newsJSONValue];
                if (item) {
                    [items addObject:item];
                }
            }
            self.stockReportItems = items;
            self.overpage = [JSONValues[@"OverPage"] integerValue];
            MRESPONSE_TRY_PARSE_DATA_END
        }
    }
    return self;
}

@end
