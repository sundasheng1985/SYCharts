//
//  MMarketInfo.m
//  MAPI
//
//  Created by mitake on 2015/5/28.
//  Copyright (c) 2015年 Mitake. All rights reserved.
//

#import "MMarketInfo.h"

@implementation MMarketInfo
@synthesize power = private_power;

- (instancetype)initWithJSONObject:(NSDictionary *)JSONObject {
    if (self = [super initWithJSONObject:JSONObject]) {
        self.tradeUnit = [JSONObject[@"unit"] integerValue];
        self.decimal = [JSONObject[@"float"] integerValue];
        self.power = [JSONObject[@"power"] integerValue];
        NSMutableArray *timezones = [NSMutableArray array];
        for (id timezone in JSONObject[@"timezone"]) {
            MTimeZone *tz = [[MTimeZone alloc] initWithJSONObject:timezone];
            [timezones addObject:tz];
        }
        self.timezones = timezones;
    }
    return self;
}

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)coder {
    [super encodeWithCoder:coder];
    [coder encodeInt:self.power forKey:@"MMarketInfo.power"];
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    if (self = [super initWithCoder:coder]) {
        self.power = [coder decodeIntForKey:@"MMarketInfo.power"];
    }
    return self;
}

#pragma mark - NSCopying

- (instancetype)copyWithZone:(NSZone *)zone {
    MMarketInfo *copy = [super copyWithZone:zone];
    copy.power = self.power;
    return copy;
}

@end

