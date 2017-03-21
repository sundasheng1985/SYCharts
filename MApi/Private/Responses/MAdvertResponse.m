//
//  MAdvertResponse.m
//  MAPI
//
//  Created by Mitake on 2015/6/12.
//  Copyright (c) 2015年 Mitake. All rights reserved.
//

#import "MAdvertResponse.h"

@implementation MAdvertResponse

- (id)initWithData:(NSData *)data request:(MRequest *)request timestamp:(NSString *)timestamp headers:(NSDictionary *)headers {
    self = [super initWithData:data  request:request timestamp:timestamp headers:headers];
    if (self) {
        NSDictionary *JSONDictionary = nil;
        if ([self getJSONObject:&JSONDictionary withData:data parseClass:NSDictionary.class]) {
             self.advertDictionary = JSONDictionary;
        }
    }
    return self;
}

@end
