//
//  MEventResponse.m
//  MAPI
//
//  Created by Mitake on 2015/6/13.
//  Copyright (c) 2015年 Mitake. All rights reserved.
//

#import "MEventResponse.h"

@implementation MEventResponse

- (id)initWithData:(NSData *)data request:(MRequest *)request timestamp:(NSString *)timestamp headers:(NSDictionary *)headers {
    self = [super initWithData:data request:request timestamp:timestamp headers:headers];
    if (self) {
    
    }
    return self;
}

@end
