//
//  MPriceVolumeItem.m
//  MAPI
//
//  Created by FanChiangShihWei on 2016/6/30.
//  Copyright © 2016年 Mitake. All rights reserved.
//

#import "MPriceVolumeItem.h"

@implementation MPriceVolumeItem

- (instancetype)initWithData:(NSData *)data market:(NSString *)market subtype:(NSString *)subtype {
    if (self = [super initWithData:data]) {
        NSArray *dataCols = [data componentsSeparatedByByte:0x02];
        if (dataCols.count < 2) {
            return nil;
        }
        self.price = [MApiHelper formatPrice:[[dataCols[0] convertToUTF8String] doubleValue] market:market subtype:subtype];
        self.volume = [MApiHelper formatVolume:[dataCols[1] convertToUTF8String] market:market subtype:subtype];
    }
    return self;
}


@end
