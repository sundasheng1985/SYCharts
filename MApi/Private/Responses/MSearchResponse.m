//
//  MSearchResponse.m
//  TSApi
//
//  Created by Mitake on 2015/3/18.
//  Copyright (c) 2015年 Mitake. All rights reserved.
//

#import "MSearchResponse.h"
#import "MSearchRequest.h"

@implementation MSearchResponse

- (id)initWithData:(NSData *)data request:(MRequest *)request timestamp:(NSString *)timestamp headers:(NSDictionary *)headers {
    self = [super initWithData:data request:request timestamp:timestamp headers:headers];
    if (self) {
        MRESPONSE_TRY_PARSE_DATA_START
        NSMutableArray *resultItems = [NSMutableArray array];
        NSArray *dataRows = [data componentsSeparatedByByte:0x03];
        BOOL isKindOfMSearchRequest = [request isKindOfClass:[MSearchRequest class]];
        for (NSData *dataRow in dataRows) {
            MSearchResultItem *resultItem = [[MSearchResultItem alloc] initWithData:dataRow];
            if (resultItem) {
                [resultItems addObject:resultItem];
            }
            if (isKindOfMSearchRequest) {
                if (((MSearchRequest *)request).searchLimit > 0 &&
                    resultItems.count == ((MSearchRequest *)request).searchLimit) {
                    break;
                }
            }
        }
        self.resultItems = resultItems;
        MRESPONSE_TRY_PARSE_DATA_END
    }
    return self;
}

@end
