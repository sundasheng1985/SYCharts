//
//  MOHLCRequest.m
//  TSApi
//
//  Created by Mitake on 2015/3/18.
//  Copyright (c) 2015年 Mitake. All rights reserved.
//

#import "MOHLCRequest.h"

@implementation MOHLCRequest

- (NSString *)path {
    const NSArray *funMaps = @[@"dayk", @"weekk", @"monthk", @"m5", @"m15", @"m30", @"m60", @"m120"];
    return funMaps[self.period];
    NSString *path = nil;
    @try {
        path = funMaps[self.period];
    }
    @catch (NSException *exception) {
        [NSException raise:@"OHLCPeriodErrorException" format:@"period设置错误，请依照MOHLCPeriod设置。"];
    }
    @finally {
        path = @"";
    }
    return path;
}

- (NSString *)APIVersion {
    return @"v2";
}

- (BOOL)isContinueAfterGetCache {
    return YES;
}

- (NSDictionary *)HTTPHeaderFields {
    NSMutableDictionary *headerFields = [self commonHTTPHeaderFields];
    headerFields[@"Symbol"] = self.code;
    
    MOHLCResponse *response = [self cachedObject];
    if ([response.OHLCItems count] > 0) {
        MOHLCItem *lastOHLCItem = [response.OHLCItems lastObject];
        headerFields[@"Param"] = lastOHLCItem.datetime;
    }
    return (NSDictionary *)headerFields;
}

- (BOOL)isValidate {
    return [self.code validateCode] &&
    (self.subtype != nil) &&
    (self.period <= MOHLCPeriodMin120) &&
    (self.priceAdjustedMode <= MOHLCPriceAdjustedModeBackward);
}

#pragma mark - MApiCaching

- (id)cachePath {
    NSString *relativePath = [self.path stringByAppendingPathComponent:self.APIVersion];
    if (self.priceAdjustedMode == MOHLCPriceAdjustedModeNone) {
        return [relativePath stringByAppendingPathComponent:self.code];
    }
    NSString *lastComp = [NSString stringWithFormat:@"%@_%@",@(self.priceAdjustedMode), self.code];
    return [relativePath stringByAppendingPathComponent:lastComp];
}

- (id)cachedObject {
    return [MApiCache cachedObjectFromPath:[self cachePath]];
}

@end
