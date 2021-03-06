//
//  MGetAppSourceResponse.m
//  MAPI
//
//  Created by Mitake on 2015/7/27.
//  Copyright (c) 2015年 Mitake. All rights reserved.
//

#import "MGetSourceClassResponse.h"

@implementation MGetSourceClassResponse

- (id)initWithData:(NSData *)data request:(MRequest *)request timestamp:(NSString *)timestamp headers:(NSDictionary *)headers {
    self = [super initWithData:data request:request timestamp:timestamp headers:headers];
    if (self) {
        NSDictionary *JSONValue = nil;
        if ([self getJSONObject:&JSONValue withData:data parseClass:NSDictionary.class]) {
            self.sourceClassInfos = JSONValue;
        }
    }
    return self;
}

@end
