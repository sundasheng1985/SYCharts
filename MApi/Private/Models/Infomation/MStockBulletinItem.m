//
//  MStockBulletinItem.m
//  TSApi
//
//  Created by Mitake on 2015/3/22.
//  Copyright (c) 2015年 Mitake. All rights reserved.
//

#import "MStockBulletinItem.h"
#import "NSString+MApiAdditions.h"
/*
 PUBDATE	日期
 ID	序号
 TITLE	标题
 */
@implementation MStockBulletinItem

- (instancetype)initWithJSONObject:(NSDictionary *)JSONObject {
    if (self = [super initWithJSONObject:JSONObject]) {
        self.datetime = [JSONObject[@"PUBDATE"] datetimeStringWithoutSecond];
        self.ID = JSONObject[@"ID"];
        self.title = JSONObject[@"TITLE"];
        self.stockName =JSONObject[@"STOCKNAME"];
    }
    return self;
}

@end
