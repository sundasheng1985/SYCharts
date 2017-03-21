//
//  MPingRequest.m
//  MAPI
//
//  Created by FanChiangShihWei on 2016/11/10.
//  Copyright © 2016年 Mitake. All rights reserved.
//

#import "MPingRequest.h"

@implementation MPingRequest

- (NSString *)path {
    return @"service/ping";
}

- (NSString *)_market {
    return @"test";
}

@end
