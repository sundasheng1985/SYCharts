//
//  MSectionSortingResponse.m
//  MAPI
//
//  Created by FanChiangShihWei on 2016/7/22.
//  Copyright © 2016年 Mitake. All rights reserved.
//

#import "MSectionSortingResponse.h"

@implementation MSectionSortingResponse
- (id)initWithData:(NSData *)data request:(MRequest *)request timestamp:(NSString *)timestamp headers:(NSDictionary *)headers {
    self = [super initWithData:data request:request timestamp:timestamp headers:headers];
    if (self) {
        NSArray *JSONObject = nil;
        if ([self getJSONObject:&JSONObject withData:data parseClass:NSArray.class]) {
            NSMutableArray *items = [NSMutableArray array];
            for (NSDictionary *obj in JSONObject) {
                [items addObject:[[MSectionSortingItem alloc] initWithJSONObject:obj]];
            }
            self.sectionSortingItems = [items copy];
        }
    }
    return self;
}
@end
