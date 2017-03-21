//
//  MSectionSortingItem.m
//  MAPI
//
//  Created by FanChiangShihWei on 2016/7/22.
//  Copyright © 2016年 Mitake. All rights reserved.
//

#import "MSectionSortingItem.h"
#import "MApiHelper.h"

@implementation MSectionSortingItem

//新增 zdjs 涨跌家数
//移除 szjs 上涨家数, xdjs 下跌家数, zgb 涨股比
//
//字段说明：
//s 版块代号
//n 版块名称
//qzf 权涨幅
//jzf 均涨幅
//zcje 总成交额
//hsl 换手率
//lzg 领涨股
//ggzf 个股涨幅
//ggzfb 个股涨幅比
//zdjs 涨跌家数

- (instancetype)initWithJSONObject:(NSDictionary *)JSONObject {
    self = [super initWithJSONObject:JSONObject];
    if (self) {
#define __ss_toString(arg) [NSString stringWithFormat:@"%@", arg];
#define __ss_parseDoubleFixed_2(arg) [NSString stringWithFormat:@"%.2f", [arg doubleValue] + 0.000001];
        self.ID = JSONObject[@"s"];
        self.name = JSONObject[@"n"];
        self.weightedChange = __ss_parseDoubleFixed_2(JSONObject[@"qzf"]);
        self.averageChange = __ss_parseDoubleFixed_2(JSONObject[@"jzf"]);
        self.amount = __ss_toString(JSONObject[@"zcje"]);
        self.turnoverRate = __ss_parseDoubleFixed_2(JSONObject[@"hsl"]);
        self.stockID = JSONObject[@"lzg"];
        self.stockName = JSONObject[@"lzgn"];
        NSDecimalNumber *ggzf = [NSDecimalNumber decimalNumberWithDecimal:[JSONObject[@"ggzf"] decimalValue]];
        NSDecimalNumberHandler *hander = [[NSDecimalNumberHandler alloc] initWithRoundingMode:NSRoundPlain
                                                                                        scale:8
                                                                             raiseOnExactness:NO
                                                                              raiseOnOverflow:NO
                                                                             raiseOnUnderflow:NO
                                                                          raiseOnDivideByZero:NO];
        self.stockChange = [[ggzf decimalNumberByRoundingAccordingToBehavior:hander] stringValue];
        self.stockChangeRate = __ss_parseDoubleFixed_2(JSONObject[@"ggzfb"]);
        self.advanceAndDeclineCount = __ss_toString(JSONObject[@"zdjs"]);
        self.stockLastPrice = [MApiHelper formatPrice:[JSONObject[@"lzgj"] doubleValue]
                                               market:JSONObject[@"lzgex"]
                                              subtype:JSONObject[@"lzgsb"]];
#undef __ss_toString
#undef __ss_parseDoubleFixed_2
    }
    return self;
}

@end
