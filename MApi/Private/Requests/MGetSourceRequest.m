//
//  MGetAppSourceRequest.m
//  Pods
//
//  Created by 金融研發一部-蕭裕翰 on 7/27/15.
//
//

#import "MGetSourceRequest.h"

@implementation MGetSourceRequest
- (NSString *)path {
    return @"service/getAppSource";
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
