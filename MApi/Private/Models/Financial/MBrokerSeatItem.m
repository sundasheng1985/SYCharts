//
//  MBrokerSeatItem.m
//  TSApi
//
//  Created by 李政修 on 2015/4/17.
//  Copyright (c) 2015年 Mitake. All rights reserved.
//

#import "MBrokerSeatItem.h"

@implementation MBrokerSeatItem

- (instancetype)initWithData:(NSData *)data {
    if (self = [super initWithData:data]) {
        NSArray *dataCols = [data componentsSeparatedByByte:0x02];
        if (dataCols.count >= 1) {
            self.value = [dataCols[0] convertToUTF8String];
        }
        if (dataCols.count >= 3) {
            self.name = [dataCols[1] convertToUTF8String];
            self.fullName = [dataCols[2] convertToUTF8String];
        }
    }
    return self;
}


@end
