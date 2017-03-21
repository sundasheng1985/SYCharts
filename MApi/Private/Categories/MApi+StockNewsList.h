//
//  MApi+StockNewsList.h
//  Pods
//
//  Created by 金融研發一部-蕭裕翰 on 12/2/15.
//
//

#import "MApi.h"
@interface MApi (StockNewsList)
+ (BOOL)isStockNewsListRequest:(id)request;
+ (BOOL)isStockNewsListResponse:(id)response;
+ (BOOL)shouldSendRequest:(id)request byCachedResponse:(id)cachedResponse;
+ (BOOL)processItemsOfCachedResponse:(id)cachedResponse withRequest:(id)request;
+ (void)processNewsListRequestSuccessOfResponse:(id)response andRequest:(id)request;
@end
