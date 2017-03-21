//
//  MHKMarketInfoResponse.m
//  MAPI
//
//  Created by IOS_HMX on 16/12/14.
//  Copyright © 2016年 Mitake. All rights reserved.
//

#import "MHKMarketInfoResponse.h"

@implementation MHKMarketInfoResponse
-(id)initWithData:(NSData *)data request:(MRequest *)request timestamp:(NSString *)timestamp headers:(NSDictionary *)headers
{
    self = [super initWithData:data request:request timestamp:timestamp headers:headers];
    if (self) {
        NSArray *dataItems = [data componentsSeparatedByByte:0x02];
        [dataItems enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (idx == 0) {
                self.SHInitialQuota = [[[NSString alloc] initWithData:obj encoding:NSUTF8StringEncoding] transform_decodeString];
            }
            if (idx == 1) {
                self.SHRemainQuota = [[[NSString alloc] initWithData:obj encoding:NSUTF8StringEncoding] transform_decodeString];
            }
            if (idx == 2) {
                self.SHStatus = [[[NSString alloc] initWithData:obj encoding:NSUTF8StringEncoding]integerValue];
            }
            if (idx == 3) {
                self.SZInitialQuota = [[[NSString alloc] initWithData:obj encoding:NSUTF8StringEncoding] transform_decodeString];
            }
            if (idx == 4) {
                self.SZRemainQuota = [[[NSString alloc] initWithData:obj encoding:NSUTF8StringEncoding] transform_decodeString];
            }
            if (idx == 5) {
                self.SZStatus = [[[NSString alloc] initWithData:obj encoding:NSUTF8StringEncoding] integerValue];
            }
        }];
    }
    return self;
}
@end
