//
//  MResponse.m
//  TSApi
//
//  Created by Mitake on 2015/3/18.
//  Copyright (c) 2015年 Mitake. All rights reserved.
//

#import "MResponse.h"
#import <objc/runtime.h>

@implementation MResponse

- (id)initWithData:(NSData *)data request:(MRequest *)request timestamp:(NSString *)timestamp headers:(NSDictionary *)headers {
    self = [super init];
    if (self) {
        self.status = MResponseStatusSuccess;
    }
    return self;
}

- (BOOL)getJSONObject:(__autoreleasing id*)obj withData:(NSData *)JSONData parseClass:(Class)parseClass {
    /**
     * MEchoRequest無reponse body
     * MAnnouncementRequest后台没开启时返回HTTPStatusCode404当成正常处理时, 無reponse body
     * 所以要检查JSONData的长度, 有response body且JSONSerialization Error时才报错
     **/
    if (JSONData.length) {
        NSError *error = nil;
        id result = [NSJSONSerialization JSONObjectWithData:JSONData options:NSJSONReadingMutableLeaves error:&error];
        if (!error && [result isKindOfClass:parseClass]) {
            *obj = result;
        }
        else {
            
            /// START ----
            /// 处理F10 response parseClass是NSArray, 但没资料时却传空的NSDictionary的逻辑
            /// 注记: 此为F10 server问题, 手机端帮忙档这个错误
            if ([result isKindOfClass:[NSDictionary class]] && ((NSDictionary *)result).count == 0) {
                return YES;
            }
            if ([result isKindOfClass:[NSArray class]] && ((NSArray *)result).count == 0) {
                return YES;
            }
            /// END ----
            
            self.status = MResponseStatusDataParseError;
            return NO;
        }
    }
    return YES;
}


#pragma mark - getter

- (NSString *)message {
    switch (self.status) {
        // HTTP status
        case MResponseStatusSuccess: return @"请求成功";
        case MResponseStatusSessionExpired: return @"Session失效";
        case MResponseStatusNotFound: return @"请求失败";
        case MResponseStatusOverLimit: return @"股票代码数量超过限制";
        case MResponseStatusServerError: return @"业务异常";
        case MResponseStatusBadGateway: return @"网关错误";
        // -10xx
        case MResponseStatusTimeout: return @"请求超时";
        case MResponseStatusNotReachabled: return @"无法连结到主机";
        case MResponseStatusDataParseError: return @"应答信息处理失败";
        case MResponseStatusDataNil: return @"服务器无应答信息";
        case MResponseStatusParameterError: return @"参数错误";
        case MResponseStatusServerSiteNotFound: return @"未获取到站点信息";
        // -20xx
        case MResponseStatusCertificationAuditError: return @"认证审计错误";
    }
    if (self.status < -100000) {
        return @"NSURLError";
    }
    return @"未知错误";
}

@end
