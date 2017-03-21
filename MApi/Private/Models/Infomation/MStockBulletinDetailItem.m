//
//  MStockBulletinDetailItem.m
//  TSApi
//
//  Created by Mitake on 2015/3/22.
//  Copyright (c) 2015年 Mitake. All rights reserved.
//

#import "MStockBulletinDetailItem.h"
#import "NSString+MApiAdditions.h"
/*
 PUBDATE	日期
 ID	序号
 Content	内文
 CONTENTFORMAT	格式
 */
@implementation MStockBulletinDetailItem

- (instancetype)initWithJSONObject:(NSDictionary *)JSONObject {
    if (self = [super initWithJSONObject:JSONObject]) {
        self.datetime = [JSONObject[@"PUBDATE"] datetimeStringWithoutSecond];
        self.ID = JSONObject[@"ID"];
        self.content = JSONObject[@"CONTENT"];
        self.format = JSONObject[@"CONTENTFORMAT"];
    }
    return self;
}


@end
