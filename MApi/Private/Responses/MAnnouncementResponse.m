//
//  MAnnouncementResponse.m
//  MAPI
//
//  Created by 金融研發一部-蕭裕翰 on 8/16/15.
//  Copyright (c) 2015 Mitake. All rights reserved.
//

#import "MAnnouncementResponse.h"

@interface MAnnouncementResponse()
@property (nonatomic, readwrite, copy) NSString *announcementTitle;
@property (nonatomic, readwrite, copy) NSString *announcementContent;
@property (nonatomic, readwrite, copy) NSString *announcementDatetime;
@end

@implementation MAnnouncementResponse

- (id)initWithData:(NSData *)data request:(MRequest *)request timestamp:(NSString *)timestamp headers:(NSDictionary *)headers {
    self = [super initWithData:data request:request timestamp:timestamp headers:headers];
    if (self) {
        NSDictionary *JSONDictionary = nil;
        if ([self getJSONObject:&JSONDictionary withData:data parseClass:NSDictionary.class]) {
            self.announcementTitle = JSONDictionary[@"title"];
            self.announcementContent = JSONDictionary[@"content"];
            self.announcementDatetime = JSONDictionary[@"datetime"];
        }
    }
    return self;
}

@end
