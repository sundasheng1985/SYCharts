//
//  MHKQuoteInfoResponse.m
//  MAPI
//
//  Created by FanChiangShihWei on 2016/7/14.
//  Copyright © 2016年 Mitake. All rights reserved.
//

#import "MHKQuoteInfoResponse.h"

@implementation MHKQuoteInfoResponse

- (id)initWithData:(NSData *)data request:(MRequest *)request timestamp:(NSString *)timestamp headers:(NSDictionary *)headers {
    self = [super initWithData:data request:request timestamp:timestamp headers:headers];
    if (self) {
        MRESPONSE_TRY_PARSE_DATA_START
        NSArray *datas = [data componentsSeparatedByByte:0x02];
        NSInteger idx = 0;
        MHKQuoteInfoRequest *req = ((MHKQuoteInfoRequest *)request);
        NSString *market = req.code.pathExtension;
        
#define formatPrice(str) [MApiHelper formatPrice:[str doubleValue] market:market subtype:req.subtype];
#define formatTime(str) [NSString stringWithFormat:@"%06zd", [str integerValue]]

        for (NSData *data in datas) {
            
            id JSONValue = nil;
            if (idx == 0) {
                if ([self getJSONObject:&JSONValue withData:data parseClass:NSArray.class]) {
                    NSMutableArray *array = [NSMutableArray arrayWithCapacity:[JSONValue count]];
                    for (NSDictionary *dict in JSONValue) {
                        MHKOddInfoItem *info = [[MHKOddInfoItem alloc] initWithJSONObject:dict];
                        info.price = formatPrice(info.price);
                        if (info.datetime) {
                            info.datetime = formatTime(info.datetime);
                        }
                        [array addObject:info];
                    }
                    self.oddInfoItems = [array copy];
                }
            }
            else if (idx == 1) {
                if ([self getJSONObject:&JSONValue withData:data parseClass:NSDictionary.class]) {
                    if (JSONValue[@"t"]) {
                        self.vcmDatetime = formatTime([JSONValue[@"t"] transform_decodeString]);
                    }
                    if (JSONValue[@"st"]) {
                        self.vcmStartTime = formatTime([JSONValue[@"st"] transform_decodeString]);
                    }
                    if (JSONValue[@"et"]) {
                        self.vcmEndTime = formatTime([JSONValue[@"et"] transform_decodeString]);
                    }
                    self.vcmRefPrice = formatPrice([JSONValue[@"r"] transform_decodeString]);
                    self.vcmLowerPrice = formatPrice([JSONValue[@"l"] transform_decodeString]);
                    self.vcmUpperPrice = formatPrice([JSONValue[@"h"] transform_decodeString]);
                }
            }
            else {
                if ([self getJSONObject:&JSONValue withData:data parseClass:NSDictionary.class]) {
                    if (JSONValue[@"t"]) {
                        self.casDatetime = formatTime([JSONValue[@"t"] transform_decodeString]);
                    }
                    self.casOrdImbDirection = [JSONValue[@"d"] transform_decodeString];
                    self.casOrdImbQty = [JSONValue[@"q"] transform_decodeString];
                    self.casRefPrice = formatPrice([JSONValue[@"p"] transform_decodeString]);
                    self.casLowerPrice = formatPrice([JSONValue[@"l"] transform_decodeString]);
                    self.casUpperPrice = formatPrice([JSONValue[@"h"] transform_decodeString]);
                }
            }            
            idx++;
        }
#undef formatPrice
#undef formatTime

        MRESPONSE_TRY_PARSE_DATA_END
    }
    return self;
}

@end
