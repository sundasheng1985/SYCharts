//
//  MStockReportDetailItem.m
//  TSApi
//
//  Created by Mitake on 2015/3/22.
//  Copyright (c) 2015年 Mitake. All rights reserved.
//

#import "MStockReportDetailItem.h"
#import "NSString+MApiAdditions.h"
/*
 PUBDATE	日期
 ID	序号
 ABSTRACT	内文
 ABSTRACTFORMAT	格式
 ComName	来源
 */
@implementation MStockReportDetailItem

- (instancetype)initWithJSONObject:(NSDictionary *)JSONObject {
    if (self = [super initWithJSONObject:JSONObject]) {
        self.datetime = [JSONObject[@"PUBDATE"] datetimeStringWithoutSecond];
        self.ID = JSONObject[@"ID"];
        self.content = JSONObject[@"ABSTRACT"];
        self.format = JSONObject[@"ABSTRACTFORMAT"];
        self.source = JSONObject[@"COMNAME"];
    }
    return self;
}

@end
