//
//  MChartRequest.m
//  TSApi
//
//  Created by Mitake on 2015/3/18.
//  Copyright (c) 2015年 Mitake. All rights reserved.
//

#import "MChartRequest.h"

@implementation MChartRequest

- (NSString *)path {
    const NSArray *funMaps = @[@"line", @"line5d"];
    NSString *path = nil;
    @try {
        path = funMaps[self.chartType];
    }
    @catch (NSException *exception) {
        [NSException raise:@"ChartTypeErrorException" format:@"chartType设置错误，请依照MChartType设置。"];
    }
    @finally {}
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
    NSString *marketType = [self.code pathExtension];
    NSString *tradeDate = [MApiHelper sharedHelper].marketTradeDates[marketType];
    
    MChartResponse *response = [self cachedObject];
    if (self.chartType == MChartTypeOneDay && response.OHLCItems.count > 0) {
        // 检查是否有比交易日期小的MOHLCItem，有的话就remove;
        NSMutableArray *OHLCItems = [response.OHLCItems mutableCopy];
        for (MOHLCItem *OHLCItem in response.OHLCItems) {
            NSString *dateTime = [OHLCItem.datetime substringToIndex:8];
            if (![dateTime isEqualToString:tradeDate]) {
                [OHLCItems removeObject:OHLCItem];
            }
        }
        response.OHLCItems = OHLCItems;
        [MApiCache cacheObject:response toPath:[self cachePath]];
    }
    if (response.OHLCItems.count > 0) {
        MOHLCItem *lastOHLCItem = [response.OHLCItems lastObject];
        headerFields[@"Param"] = lastOHLCItem.datetime;
    }
    
    return (NSDictionary *)headerFields;
}

- (BOOL)isValidate {
    return [self.code validateCode] &&
    (self.subtype != nil) &&
    (self.chartType <= MChartTypeFiveDays);
}

#pragma mark - MApiCaching

- (id)cachePath {
    NSString *relativePath = [self.path stringByAppendingPathComponent:self.APIVersion];
    return [relativePath stringByAppendingPathComponent:self.code];
}

- (id)cachedObject {
    return [MApiCache cachedObjectFromPath:[self cachePath]];
}


@end
