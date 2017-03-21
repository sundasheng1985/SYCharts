//
//  MPingResponse.m
//  MAPI
//
//  Created by FanChiangShihWei on 2016/11/10.
//  Copyright © 2016年 Mitake. All rights reserved.
//

#import "MPingResponse.h"
#import "MPingRequest.h"

@implementation MPingResponse

- (id)initWithData:(NSData *)data request:(MRequest *)request timestamp:(NSString *)timestamp headers:(NSDictionary *)headers {
    self = [super initWithData:data request:request timestamp:timestamp headers:headers];
    if (self) {
        MPingRequest *req = (MPingRequest *)request;
        self.responseTime = [[NSDate date] timeIntervalSinceDate:req.startDate];
    }
    return self;
}

@end
