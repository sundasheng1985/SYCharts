//
//  MBondInterestPayResponse.m
//  MAPI
//
//  Created by IOS_HMX on 16/12/16.
//  Copyright © 2016年 Mitake. All rights reserved.
//

#import "MBondInterestPayResponse.h"

@implementation MBondInterestPayResponse

- (id)initWithData:(NSData *)data request:(MRequest *)request timestamp:(NSString *)timestamp headers:(NSDictionary *)headers {
    self = [super initWithData:data request:request timestamp:timestamp headers:headers];
    if (self) {
        NSDictionary *JSONValues = nil;
        if ([self getJSONObject:&JSONValues withData:data parseClass:NSDictionary.class]) {
            self.record = JSONValues;
        }
    }
    return self;
}

@end
