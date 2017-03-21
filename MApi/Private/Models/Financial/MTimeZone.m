//
//  MTimeZone.m
//  MAPI
//
//  Created by mitake on 2015/5/28.
//  Copyright (c) 2015年 Mitake. All rights reserved.
//

#import "MTimeZone.h"

@implementation MTimeZone

- (instancetype)initWithJSONObject:(NSDictionary *)JSONObject {
    if (self = [super initWithJSONObject:JSONObject]) {
        self.openTime = JSONObject[@"open"];
        self.closeTime = JSONObject[@"close"];
    }
    return self;
}

@end
