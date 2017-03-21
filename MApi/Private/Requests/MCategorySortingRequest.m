//
//  MCategorySortingRequest.m
//  MAPI
//
//  Created by FanChiangShihWei on 2016/5/23.
//  Copyright © 2016年 Mitake. All rights reserved.
//

#import "MCategorySortingRequest.h"

/*
 // symbol: 版块分类代码 (SH1001) 沪市A股..etc
 // param: 页码,笔数,排序栏位,顺向逆向,停牌是否排序  (0,12,1,0,1)
 // 顺向逆向 0=> 由大到小, 1=>由小到大
 /// POKI 文档有误  测试结果为 0=> 由小到大, 1=>由大到小
 
 
 排序栏位，因应标准版(???)需求，多一些复杂的排序功能，因此此API，你开心用哪个栏位排序就用哪一个，但是其中 //18 均价, 19 涨跌, 33 五档买价, 34 五档买量, 35	五档卖价, 36 五档卖量, 26 总值, 29 PE(市盈),30 ROE(净资产收益率) 这几个栏位并不会进行排序。
 */

@implementation MCategorySortingRequest

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.includeSuspension = YES;
    }
    return self;
}

#pragma mark - override methods

- (NSString *)APIVersion {
    return @"v2";
}

- (NSString *)path {
    return @"catesorting";
}

- (NSDictionary *)HTTPHeaderFields {
    NSMutableDictionary *headerFields = [self commonHTTPHeaderFields];
    headerFields[@"Symbol"] = self.code;
    if (self.pageIndex >= 0) {
        NSMutableString *param = [NSMutableString stringWithFormat:@"%@", @(self.pageIndex)];
        if (self.pageSize > 0) {
            [param appendFormat:@",%@", @(self.pageSize)];
        } else {
            [param appendString:@",0"];
        }
        [param appendFormat:@",%@", @(self.field)];
        [param appendFormat:@",%@", self.ascending ? @"0" : @"1"];
        [param appendFormat:@",%@", self.includeSuspension ? @"1" : @"0"];
        headerFields[@"Param"] = param;
    }
    return (NSDictionary *)headerFields;
}

@end
