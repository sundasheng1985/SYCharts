//
//  MExpireMonthResponse.m
//  TSApi
//
//  Created by Mitake on 2015/3/22.
//  Copyright (c) 2015年 Mitake. All rights reserved.
//

#import "MExpireMonthResponse.h"

@implementation MExpireMonthResponse

- (id)initWithData:(NSData *)data request:(MRequest *)request timestamp:(NSString *)timestamp headers:(NSDictionary *)headers {
    self = [super initWithData:data request:request timestamp:timestamp headers:headers];
    if (self) {
        MRESPONSE_TRY_PARSE_DATA_START
        NSMutableArray *expireMonths = [NSMutableArray array];
        NSArray *datas = [data componentsSeparatedByByte:0x02];
        for (NSData *data in datas) {
            NSString *month = [data convertToUTF8String];
            [expireMonths addObject:month];
        }
        self.expireMonths = expireMonths;
        MRESPONSE_TRY_PARSE_DATA_END
    }
    
    return self;
}

@end
