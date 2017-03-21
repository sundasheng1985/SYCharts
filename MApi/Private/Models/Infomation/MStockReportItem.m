//
//  MStockReportItem.m
//  TSApi
//
//  Created by Mitake on 2015/3/22.
//  Copyright (c) 2015年 Mitake. All rights reserved.
//

#import "MStockReportItem.h"
#import "NSString+MApiAdditions.h"
/*
 PUBDATE	日期
 ID	序号
 ReportTitle	标题
 REPORTLEVEL	报告级别
 ComName	来源
 */
@implementation MStockReportItem

- (instancetype)initWithJSONObject:(NSDictionary *)JSONObject {
    if (self = [super initWithJSONObject:JSONObject]) {
        self.datetime = [JSONObject[@"PUBDATE"] datetimeStringWithoutSecond];
        self.ID = JSONObject[@"ID"];
        self.title = JSONObject[@"REPORTTITLE"];
        self.level = JSONObject[@"REPORTLEVEL"];
        self.source = JSONObject[@"COMNAME"];
        self.stockName = JSONObject[@"STOCKNAME"];
    }
    return self;
}

@end
