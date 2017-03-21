//
//  MCheckVersionRequest.m
//  Pods
//
//  Created by 金融研發一部-蕭裕翰 on 7/22/15.
//
//

#import "MCheckVersionRequest.h"

@implementation MCheckVersionRequest

- (NSString *)path {
    return @"service/chkVersion";
}

- (NSDictionary *)HTTPHeaderFields {
    NSMutableDictionary *headerFields = [self commonHTTPHeaderFields];
    headerFields[@"Param"] = [NSString stringWithFormat:@"%@_%@_%@",
                              [MApiHelper sharedHelper].corpID,
                              self.platform,
                              self.bundleID];
    return (NSDictionary *)headerFields;
}

@end
