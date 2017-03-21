//
//  MNewsDetailItem.m
//  TSApi
//
//  Created by Mitake on 2015/3/22.
//  Copyright (c) 2015年 Mitake. All rights reserved.
//

#import "MNewsDetailItem.h"
#import "NSString+MApiAdditions.h"
/*
 ABSTRACT	Abstract
 INIPUBDATE	首次发布日期
 MEDIANAME	媒体出处(Option)
 ABSTRACTFORMAT	内容格式
 */
@implementation MNewsDetailItem

- (instancetype)initWithJSONObject:(NSDictionary *)JSONObject {
    if (self = [super initWithJSONObject:JSONObject]) {
        self.content = JSONObject[@"ABSTRACT"];
        self.datetime = [JSONObject[@"INIPUBDATE"] datetimeStringWithoutSecond];
        self.source = JSONObject[@"MEDIANAME"];
        self.format = JSONObject[@"ABSTRACTFORMAT"];
    }
    return self;
}

@end
