//
//  MAnnouncementRequest.m
//  MAPI
//
//  Created by 金融研發一部-蕭裕翰 on 8/16/15.
//  Copyright (c) 2015 Mitake. All rights reserved.
//

#import "MAnnouncementRequest.h"

@implementation MAnnouncementRequest

- (NSString *)path {
    return @"service/announcement";
}

- (NSDictionary *)HTTPHeaderFields {
    NSMutableDictionary *headerFields = [self commonHTTPHeaderFields];
    headerFields[@"Param"] = [NSString stringWithFormat:@"%@_%@_%@",
                              [MApiHelper sharedHelper].corpID,
                              self.platform,
                              self.bundleID];
    return (NSDictionary *)headerFields;
}

- (NSString *)description {
    NSMutableString *description = [NSMutableString stringWithString:[super description]];
    return description;
}

@end
