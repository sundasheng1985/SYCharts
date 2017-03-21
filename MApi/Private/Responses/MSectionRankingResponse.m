//
//  MSectionRankingResponse.m
//  TSApi
//
//  Created by Mitake on 2015/4/10.
//  Copyright (c) 2015年 Mitake. All rights reserved.
//

#import "MSectionRankingResponse.h"

@implementation MSectionRankingResponse

- (id)initWithData:(NSData *)data request:(MRequest *)request timestamp:(NSString *)timestamp headers:(NSDictionary *)headers {
    self = [super initWithData:data request:request timestamp:timestamp headers:headers];
    if (self) {
        MRESPONSE_TRY_PARSE_DATA_START
        NSMutableArray *sectionRankingItems = [NSMutableArray array];
        NSArray *datas = [data componentsSeparatedByByte:0x03];
        
        for (NSData *data in datas) {
            MSectionRankingItem *sectionRankingItem = [[MSectionRankingItem alloc] initWithData:data];
            if (sectionRankingItem) {
                [sectionRankingItems addObject:sectionRankingItem];
            }
        }
        self.sectionRankingItems = sectionRankingItems;
        MRESPONSE_TRY_PARSE_DATA_END
    }
    return self;
}

@end
