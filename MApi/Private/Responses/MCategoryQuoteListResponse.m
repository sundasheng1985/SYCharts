//
//  MCategoryQuoteListResponse.m
//  MAPI
//
//  Created by 梁晖 on 15/8/6.
//  Copyright (c) 2015年 Mitake. All rights reserved.
//

#import "MCategoryQuoteListResponse.h"

@implementation MCategoryQuoteListResponse
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
        self.categoryQuoteItems = stockItems;
        MRESPONSE_TRY_PARSE_DATA_END
    }
    return self;
}

@end
