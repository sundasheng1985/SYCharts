//
//  MOptionResponse.m
//  TSApi
//
//  Created by Mitake on 2015/3/22.
//  Copyright (c) 2015年 Mitake. All rights reserved.
//

#import "MOptionResponse.h"

@implementation MOptionResponse
- (id)initWithData:(NSData *)data request:(MRequest *)request timestamp:(NSString *)timestamp headers:(NSDictionary *)headers {
    self = [super initWithData:data request:request timestamp:timestamp headers:headers];
    if (self) {
        MRESPONSE_TRY_PARSE_DATA_START
        NSMutableArray *stockItems = [NSMutableArray array];
        NSArray *datas = [data componentsSeparatedByByte:0x03];
        for (NSData *data in datas) {
            MOptionItem *optionItem = [[MOptionItem alloc] initWithData:data];
            
            if (optionItem.isOption) {
                if (optionItem) {
                    [stockItems addObject:optionItem];
                }
            }
        }
        self.optionItems = stockItems;
        MRESPONSE_TRY_PARSE_DATA_END
    }
    return self;
}

@end
