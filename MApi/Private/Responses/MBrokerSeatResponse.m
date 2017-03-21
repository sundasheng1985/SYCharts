//
//  MBrokerSeatResponse.m
//  TSApi
//
//  Created by 李政修 on 2015/4/17.
//  Copyright (c) 2015年 Mitake. All rights reserved.
//

#import "MBrokerSeatResponse.h"

@implementation MBrokerSeatResponse


- (id)initWithData:(NSData *)data request:(MRequest *)request timestamp:(NSString *)timestamp headers:(NSDictionary *)headers {
    self = [super initWithData:data request:request timestamp:timestamp headers:headers];
    if (self) {
        MRESPONSE_TRY_PARSE_DATA_START
        NSArray *buyItems = nil;
        NSArray *sellItems = nil;
        [MBrokerSeatResponse parseData:data buy:&buyItems sell:&sellItems];
        self.buyBrokerSeatItems = buyItems;
        self.sellBrokerSeatItems = sellItems;
        
        MRESPONSE_TRY_PARSE_DATA_END
    }
    return self;
}

+ (void)parseData:(NSData *)data buy:(NSArray **)buyItems sell:(NSArray **)sellItems{
    NSArray *sectionDatas = [data componentsSeparatedByByte:0x04];
    if (sectionDatas.count >= 1) {
        *buyItems = [self brokerSeatItemsWithData:sectionDatas[0]];
    }
    if (sectionDatas.count >= 2) {
        *sellItems = [self brokerSeatItemsWithData:sectionDatas[1]];
    }
}

+ (NSArray *)brokerSeatItemsWithData:(NSData *)data {
    NSMutableArray *brokerSeatItems = [NSMutableArray array];
    NSArray *rowDatas = [data componentsSeparatedByByte:0x03];
    
    for (NSData *rowData in rowDatas) {
        MBrokerSeatItem *brokerSeatItem = [[MBrokerSeatItem alloc] initWithData:rowData];
        if (brokerSeatItem) {
            [brokerSeatItems addObject:brokerSeatItem];
        }
    }
    for (NSInteger index = brokerSeatItems.count; index < 40; index++) {
        MBrokerSeatItem *brokerSeatItem = [MBrokerSeatItem new];
        [brokerSeatItems addObject:brokerSeatItem];
    }
    return brokerSeatItems;
}

@end
