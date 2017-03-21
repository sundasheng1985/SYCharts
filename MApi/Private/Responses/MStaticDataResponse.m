//
//  MStaticDataResponse.m
//  MAPI
//
//  Created by IOS_HMX on 16/12/14.
//  Copyright © 2016年 Mitake. All rights reserved.
//

#import "MStaticDataResponse.h"
#import "MStaticDataItem.h"

@implementation MStaticDataResponse
-(id)initWithData:(NSData *)data request:(MRequest *)request timestamp:(NSString *)timestamp headers:(NSDictionary *)headers
{
    self = [super initWithData:data request:request timestamp:timestamp headers:headers];
    if (self) {
        MRESPONSE_TRY_PARSE_DATA_START
        NSMutableArray *array = [NSMutableArray array];
        NSArray *datas = [data componentsSeparatedByByte:0x03];
        [datas enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            MStaticDataItem *item = [[MStaticDataItem alloc]initWithData:obj requestInfo:((MStaticDataRequest *)request).param];
            [array addObject:item];
        }];
        self.dataItems = array;
        MRESPONSE_TRY_PARSE_DATA_END
       
    }
    return self;
}
@end
