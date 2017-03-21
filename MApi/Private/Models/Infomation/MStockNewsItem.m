//
//  MStockNewsItem.m
//  TSApi
//
//  Created by Mitake on 2015/3/22.
//  Copyright (c) 2015年 Mitake. All rights reserved.
//

#import "MStockNewsItem.h"
#import "NSString+MApiAdditions.h"
/*
 INIPUBDATE	日期
 ID	序号
 REPORTTITLE	标题
 REPORTLEVEL	报告级别
 MEDIANAME	来源
 */
@implementation MStockNewsItem

- (instancetype)initWithJSONObject:(NSDictionary *)JSONObject {
    if (self = [super initWithJSONObject:JSONObject]) {
        self.datetime = [JSONObject[@"INIPUBDATE"] datetimeStringWithoutSecond];
        self.ID = JSONObject[@"ID"];
        self.title = JSONObject[@"REPORTTITLE"];
        self.level = JSONObject[@"REPORTLEVEL"];
        self.source = JSONObject[@"MEDIANAME"];
        self.stockName = JSONObject[@"STOCKNAME"];
    }
    return self;
}

@end
