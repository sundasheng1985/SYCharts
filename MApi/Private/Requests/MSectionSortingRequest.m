//
//  MSectionSortingRequest.m
//  MAPI
//
//  Created by FanChiangShihWei on 2016/7/22.
//  Copyright © 2016年 Mitake. All rights reserved.
//

#import "MSectionSortingRequest.h"

@implementation MSectionSortingRequest

- (NSString *)path {
    return @"bankuaisorting";
}

- (NSDictionary *)HTTPHeaderFields {
//    Header Param  页码,笔数,排序栏位,顺向逆向  0,12,jzf,0
//				排序栏位: 均涨幅 jzf、总成交额zcje、涨股比zgb、换手率hsl、权涨幅qzf
//				顺向逆向 0=> 由大到小, 1=>由小到大
    NSMutableDictionary *headerFields = [self commonHTTPHeaderFields];
    static NSString * const ssr_f_map[] = {
        [MSectionSortingFieldWeightedChange] = @"qzf",
        [MSectionSortingFieldAverageChange] = @"jzf",
        [MSectionSortingFieldAmount] = @"zcje",
        [MSectionSortingFieldAdvanceAndDeclineCount] = @"zdjs",
        [MSectionSortingFieldTurnoverRate] = @"hsl",
//        [MSectionSortingFieldStock] = @"lzg",
//        [MSectionSortingFieldStockChange] = @"ggzf",
//        [MSectionSortingFieldStockChangeRate] = @"ggzfb",
    };
    if (!self.str_field) {
        self.str_field = ssr_f_map[self.field];
    }
    NSMutableString *param = [NSMutableString string];
    [param appendFormat:@"%@,", @(self.pageIndex)];
    [param appendFormat:@"%@,", @(self.pageSize)];
    [param appendFormat:@"%@,", self.str_field];
    [param appendFormat:@"%@", self.ascending ? @"1":@"0"];
    headerFields[@"Param"] = param;
    if (self.code) {
        headerFields[@"Symbol"] = self.code;
    }
    return (NSDictionary *)headerFields;
}

@end













