//
//  MStockCategoryListResponse.m
//  MAPI
//
//  Created by FanChiangShihWei on 2016/4/14.
//  Copyright © 2016年 Mitake. All rights reserved.
//

#import "MStockCategoryListResponse.h"

@implementation MStockCategoryListResponse

- (id)initWithData:(NSData *)data request:(MRequest *)request timestamp:(NSString *)timestamp headers:(NSDictionary *)headers {
    self = [super initWithData:data request:request timestamp:timestamp headers:headers];
    if (self) {
        NSArray *JSONValue = nil;
        if ([self getJSONObject:&JSONValue withData:data parseClass:NSArray.class]) {
            self.list = JSONValue;
        }
    }
    return self;
}

@end
