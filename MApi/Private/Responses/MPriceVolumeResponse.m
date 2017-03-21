//
//  MPriceVolumeResponse.m
//  MAPI
//
//  Created by FanChiangShihWei on 2016/6/30.
//  Copyright © 2016年 Mitake. All rights reserved.
//

#import "MPriceVolumeResponse.h"
#import "MPriceVolumeRequest.h"

@implementation MPriceVolumeResponse

- (id)initWithData:(NSData *)data request:(MRequest *)request timestamp:(NSString *)timestamp headers:(NSDictionary *)headers {
    self = [super initWithData:data request:request timestamp:timestamp headers:headers];
    if (self) {
        MRESPONSE_TRY_PARSE_DATA_START
        NSMutableArray *pvItems = [NSMutableArray array];
        NSArray *datas = [data componentsSeparatedByByte:0x03];
        
        MPriceVolumeRequest *r = (MPriceVolumeRequest *)request;
        NSString *market = [r.code pathExtension];
        
        for (NSData *data in datas) {
            MPriceVolumeItem *pv = [[MPriceVolumeItem alloc] initWithData:data market:market subtype:r.subtype];
            if (pv) {
                [pvItems addObject:pv];
            }
        }
        self.items = pvItems;
        MRESPONSE_TRY_PARSE_DATA_END
    }
    return self;
}

@end
