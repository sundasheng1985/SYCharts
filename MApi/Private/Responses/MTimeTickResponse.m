//
//  MTimeTickResponse.m
//  MAPI
//
//  Created by FanChiangShihWei on 2016/6/30.
//  Copyright © 2016年 Mitake. All rights reserved.
//

#import "MTimeTickResponse.h"
#import "MTimeTickRequest.h"

@implementation MTimeTickResponse

- (id)initWithData:(NSData *)data request:(MRequest *)request timestamp:(NSString *)timestamp headers:(NSDictionary *)headers {
    self = [super initWithData:data request:request timestamp:timestamp headers:headers];
    if (self) {
        MRESPONSE_TRY_PARSE_DATA_START
        NSMutableArray *tickItems = [NSMutableArray array];
        NSArray *datas = [data componentsSeparatedByByte:0x03];
        MTimeTickRequest *r = (MTimeTickRequest *)request;
        
        NSString *market = [r.code pathExtension];

        for (NSData *data in datas) {
            MTickItem *tick = [[MTickItem alloc] initWithData:data market:market subtype:r.subtype];
            if (tick) {
                [tickItems addObject:tick];
            }
        }
        self.items = tickItems;
        NSArray *params = [headers[@"Params"] componentsSeparatedByString:@","];
        self.startIndex = params[0];
        self.endIndex = params[1];
        MRESPONSE_TRY_PARSE_DATA_END
    }
    return self;
}

@end
