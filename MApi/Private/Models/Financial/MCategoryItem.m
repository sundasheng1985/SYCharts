//
//  MCategoryItem.m
//  TSApi
//
//  Created by Mitake on 2015/3/18.
//  Copyright (c) 2015年 Mitake. All rights reserved.
//

#import "MCategoryItem.h"

#pragma mark MCategoryItem

@implementation MCategoryItem

- (instancetype)initWithData:(NSData *)data {
    if (self = [super initWithData:data]) {
        NSArray *dataCols = [data componentsSeparatedByByte:0x02];
        if (dataCols.count < 2) {
            return nil;
        }
        self.code = [dataCols[0] convertToUTF8String];
        self.name = [dataCols[1] convertToUTF8String];
    }
    return self;
}

@end
