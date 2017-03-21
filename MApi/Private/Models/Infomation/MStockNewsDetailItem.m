//
//  MStockNewsDetailItem.m
//  TSApi
//
//  Created by Mitake on 2015/3/22.
//  Copyright (c) 2015年 Mitake. All rights reserved.
//

#import "MStockNewsDetailItem.h"
#import "NSString+MApiAdditions.h"
/*
 INIPUBDATE	日期
 ID	序号
 ABSTRACT	内文
 ABSTRACTFORMAT	格式
 MEDIANAME	来源
 */
@implementation MStockNewsDetailItem

- (instancetype)initWithJSONObject:(NSDictionary *)JSONObject {
    if (self = [super initWithJSONObject:JSONObject]) {
        self.datetime = [JSONObject[@"INIPUBDATE"] datetimeStringWithoutSecond];
        self.ID = JSONObject[@"ID"];
        self.content = JSONObject[@"ABSTRACT"];
        self.format = JSONObject[@"ABSTRACTFORMAT"];
        self.source = JSONObject[@"MEDIANAME"];
    }
    return self;
}

@end
