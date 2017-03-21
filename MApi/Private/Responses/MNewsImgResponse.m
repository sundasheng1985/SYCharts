//
//  MNewsImgResponse.m
//  TSApi
//
//  Created by Mitake on 2015/4/13.
//  Copyright (c) 2015年 Mitake. All rights reserved.
//

#import "MNewsImgResponse.h"

@implementation MNewsImgResponse

- (id)initWithData:(NSData *)data request:(MRequest *)request timestamp:(NSString *)timestamp headers:(NSDictionary *)headers {
    self = [super initWithData:data request:request timestamp:timestamp headers:headers];
    if (self) {
        self.imageData = data;
    }
    return self;
}
@end
