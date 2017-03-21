//
//  MFundValueResponse.m
//  MAPI
//
//  Created by 陈志春 on 16/10/17.
//  Copyright © 2016年 Mitake. All rights reserved.
//

#import "MFundValueResponse.h"

@implementation MFundValueResponse
- (id)initWithData:(NSData *)data request:(MRequest *)request timestamp:(NSString *)timestamp headers:(NSDictionary *)headers {
    self = [super initWithData:data request:request timestamp:timestamp headers:headers];
    if (self) {
        MRESPONSE_TRY_PARSE_DATA_START
        NSArray *JSONObject = nil;
        if ([self getJSONObject:&JSONObject withData:data parseClass:NSArray.class]) {
            self.items = JSONObject;
            
        }
        MRESPONSE_TRY_PARSE_DATA_END
    }
    return self;
}
@end
