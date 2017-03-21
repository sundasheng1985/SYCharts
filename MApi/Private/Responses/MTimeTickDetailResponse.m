//
//  MTimeTickDetailResponse.m
//  MAPI
//
//  Created by FanChiangShihWei on 2016/8/29.
//  Copyright © 2016年 Mitake. All rights reserved.
//

#import "MTimeTickDetailResponse.h"
#import "MApiObject.h"
#import "MTickItem.h"
#import "MTimeTickDetailRequest.h"

@implementation MTimeTickDetailResponse

- (id)initWithData:(NSData *)data request:(MRequest *)request timestamp:(NSString *)timestamp headers:(NSDictionary *)headers {
    self = [super initWithData:data request:request timestamp:timestamp headers:headers];
    if (self) {
        MRESPONSE_TRY_PARSE_DATA_START
        MTimeTickDetailRequest *req = (MTimeTickDetailRequest *)request;
        NSArray *array = [data componentsSeparatedByByte:0x04];
        if (array.count > 0) {
            NSMutableArray *arr = [NSMutableArray array];
            NSArray *rows = [array[0] componentsSeparatedByByte:0x03];
            for (NSData *tickRowData in rows) {
                MTickItem *tick = [[MTimeTickItem alloc] initWithData:tickRowData
                                                               market:req._market
                                                              subtype:req.subtype];
                [arr addObject:tick];
            }
            _tickItems = [arr copy];
        }
        if (array.count > 1) {
            NSMutableArray *arr = [NSMutableArray array];
            NSArray *rows = [array[1] componentsSeparatedByByte:0x03];
            for (NSData *tickRowData in rows) {
                MTickItem *tick = [[MTimeTickDetailItem alloc] initWithData:tickRowData
                                                                     market:req._market
                                                                    subtype:req.subtype];
                [arr addObject:tick];
            }
            _detailTickItems = [arr copy];
        }
        MRESPONSE_TRY_PARSE_DATA_END
    }
    return self;
}

@end
