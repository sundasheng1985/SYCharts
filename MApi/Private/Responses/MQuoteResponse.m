//
//  MQuoteResponse.m
//  TSApi
//
//  Created by Mitake on 2015/3/18.
//  Copyright (c) 2015年 Mitake. All rights reserved.
//

#import "MQuoteResponse.h"

@implementation MQuoteResponse

- (id)initWithData:(NSData *)data request:(MRequest *)request timestamp:(NSString *)timestamp headers:(NSDictionary *)headers {
    self = [super initWithData:data request:request timestamp:timestamp headers:headers];
    if (self) {
        MRESPONSE_TRY_PARSE_DATA_START
        NSMutableArray *stockItems = [NSMutableArray array];
        NSArray *datas = [data componentsSeparatedByByte:0x03];
        
        for (NSData *data in datas) {
            MStockItem *stockItem = [[MStockItem alloc] initWithData:data];
            if (stockItem) {
                [stockItems addObject:stockItem];
            }
        }
        self.stockItems = stockItems;
        MRESPONSE_TRY_PARSE_DATA_END
    }
    return self;
}

@end
