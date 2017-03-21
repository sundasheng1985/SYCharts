//
//  MHKOddInfoItem.m
//  MAPI
//
//  Created by FanChiangShihWei on 2016/7/18.
//  Copyright © 2016年 Mitake. All rights reserved.
//

#import "MHKOddInfoItem.h"

@implementation MHKOddInfoItem

- (instancetype)initWithJSONObject:(NSDictionary *)JSONObject {
    self = [super initWithJSONObject:JSONObject];
    if (self) {
        _orderId = [[JSONObject[@"i"] transform_decodeString] copy];
        _datetime = [[JSONObject[@"t"] transform_decodeString] copy];
        _orderQty = [[JSONObject[@"q"] transform_decodeString] copy];
        _price = [[JSONObject[@"p"] transform_decodeString] copy];
        _brokerId = [[JSONObject[@"b"] transform_decodeString] copy];
        if (JSONObject[@"s"]) {
            _side = ([[JSONObject[@"s"] transform_decodeString] integerValue] == 0) ? MHKOddSideBid : MHKOddSideOffer;
        } else {
            _side = MHKOddSideNone;
        }
    }
    return self;
}

@end
