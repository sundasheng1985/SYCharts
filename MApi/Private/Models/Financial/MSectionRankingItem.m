//
//  MSectionRankingItem.m
//  TSApi
//
//  Created by Mitake on 2015/4/10.
//  Copyright (c) 2015年 Mitake. All rights reserved.
//

#import "MSectionRankingItem.h"

@implementation MSectionRankingItem

- (instancetype)initWithData:(NSData *)data {
    if (self = [super initWithData:data]) {
        NSArray *dataCols = [data componentsSeparatedByByte:0x02];
        if (dataCols.count < 8) {
            return nil;
        }
        self.name = [dataCols[0] convertToUTF8String];
        self.ID = [dataCols[1] convertToUTF8String];
        self.changeRate = [dataCols[2] convertToUTF8String];
        self.change = [dataCols[3] convertToUTF8String];
        self.stockName = [dataCols[4] convertToUTF8String];
        self.stockID = [dataCols[5] convertToUTF8String];
        self.stockChangeRate = [dataCols[6] convertToUTF8String];
        self.stockChange = [dataCols[7] convertToUTF8String];
    }
    return self;
}

@end
