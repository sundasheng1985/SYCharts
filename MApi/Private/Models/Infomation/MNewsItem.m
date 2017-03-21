//
//  MNewsItem.m
//  TSApi
//
//  Created by Mitake on 2015/3/22.
//  Copyright (c) 2015年 Mitake. All rights reserved.
//

#import "MNewsItem.h"
#import "NSString+MApiAdditions.h"
/*
 JSON Format
 
 ID	ID
 INIPUBDATE	首次发布日期
 REPORTTITLE	标题
 MEDIANAME	媒体出处(Option)
 ABSTRACTFORMAT	内容格式
 */
@implementation MNewsItem

- (instancetype)initWithJSONObject:(NSDictionary *)JSONObject {
    if (self = [super initWithJSONObject:JSONObject]) {
        self.ID = JSONObject[@"ID"];
        self.datetime = [JSONObject[@"INIPUBDATE"] datetimeStringWithoutSecond];
        self.title = JSONObject[@"REPORTTITLE"];
        self.source = JSONObject[@"MEDIANAME"];
        self.format = JSONObject[@"ABSTRACTFORMAT"];
        
    }
    return self;
}


@end
