//
//  MApi+StockNewsList.m
//  Pods
//
//  Created by 金融研發一部-蕭裕翰 on 12/2/15.
//
//

#import "MApi+StockNewsList.h"
#import "MApiCache.h"
#import "MApi_Reachability.h"

#define kRequestClassStrings @[@"MStockNewsListRequest", \
                        @"MStockBulletinListRequest", \
                        @"MStockReportListRequest", \
                        @"MNewsListRequest"]

#define kResponseClassStrings @[@"MStockNewsListResponse", \
                        @"MStockBulletinListResponse", \
                        @"MStockReportListResponse", \
                        @"MNewsListResponse"]

#pragma mark - Response categories
@interface MResponse(StockNewsList)
- (void)resetListItems:(NSArray *)items;
- (NSArray *)getListItems;
@end
@implementation MResponse(StockNewsList)
- (void)resetListItems:(NSArray *)items {
    return;
}
- (NSArray *)getListItems {
    return @[];
}
@end

@implementation MStockNewsListResponse(StockNewsList)
- (void)resetListItems:(NSArray *)items {
    @synchronized (self) {
        self.stockNewsItems = items;
    }
}

- (NSArray *)getListItems {
    @synchronized (self) {
        return self.stockNewsItems;
    }
}
@end

@implementation MStockBulletinListResponse(StockNewsList)
- (void)resetListItems:(NSArray *)items {
    @synchronized (self) {
        self.stockBulletinItems = items;
    }
}

- (NSArray *)getListItems {
    @synchronized (self) {
        return self.stockBulletinItems;
    }
}
@end

@implementation MStockReportListResponse(StockNewsList)
- (void)resetListItems:(NSArray *)items {
    @synchronized (self) {
        self.stockReportItems = items;
    }
}

- (NSArray *)getListItems {
    @synchronized (self) {
        return self.stockReportItems;
    }
}
@end

@implementation MNewsListResponse(StockNewsList)
- (void)resetListItems:(NSArray *)items {
    @synchronized (self) {
        self.newsItems = items;
    }
}

- (NSArray *)getListItems {
    @synchronized (self) {
        return self.newsItems;
    }
}
@end

#pragma mark - Request categories

@interface MRequest(StockNewsList)
- (BOOL)shouldSendRequestByCachedResponse:(id)cachedResponse;
- (NSArray *)getNextPageItemsByCachedResponse:(id)cachedResponse;
@end

@implementation MRequest(StockNewsList)

- (BOOL)shouldSendRequestByCachedResponse:(id)cachedResponse {
    BOOL shouldSendRequest = YES;
    if ([MApi isStockNewsListRequest:self]) {
        NSInteger pageIndex = [[self valueForKey:@"pageIndex"] integerValue];
        NSInteger cachedItemCount = [cachedResponse getListItems].count;
        shouldSendRequest = ((pageIndex * 10) > cachedItemCount) && ((cachedItemCount % 10) == 0);
//        shouldSendRequest = isRefreshOrCountOfResponseStockNewsItemsBiggerThanNextPage([[self valueForKey:@"pageIndex"] integerValue], [response getListItems]);
//        MApi_Reachability *reach = [MApi_Reachability reachabilityForInternetConnection];
//        if ([reach currentReachabilityStatus] == NotReachable) {
//            shouldSendRequest = NO;
//        }
    }
    return shouldSendRequest;
}
- (NSArray *)getNextPageItemsByCachedResponse:(id)cachedResponse {
    NSMutableArray *nextPageItems = [@[] mutableCopy];
    if ([MApi isStockNewsListResponse:cachedResponse]) {
        NSInteger pageIndex = [[self valueForKey:@"pageIndex"] integerValue];
        NSInteger startIndex = pageIndex*10;
        NSArray *cachedItems = [cachedResponse getListItems];
        for (NSInteger i = startIndex; i<startIndex+10; i++) {
            if (i < cachedItems.count) {
                [nextPageItems addObject:cachedItems[i]];
            } else {
                break;
            }
        }
        /* 这段code实在太厉害了
        NSInteger endIndex = (pageIndex ? pageIndex+1 : 1) * 10;
        NSMutableArray *mutableArray = [@[] mutableCopy];
        for (NSInteger startIndex = pageIndex ? (pageIndex+1) * 10 - 10 : 0; startIndex < endIndex; startIndex++) {
            if (startIndex < [[response getListItems] count]) {
                [mutableArray addObject:[response getListItems][startIndex]];
            }
            else {
                break;
            }
        }
        nextPageItems = [mutableArray copy];
         */
    }
    return [nextPageItems copy];
}
@end

#pragma mark - MApi category
@implementation MApi (StockNewsList)
+ (BOOL)isStockNewsListRequest:(id)request {
    return [kRequestClassStrings containsObject:NSStringFromClass([request class])];
}

+ (BOOL)isStockNewsListResponse:(id)response {
    return [kResponseClassStrings containsObject:NSStringFromClass([response class])];
}

+ (BOOL)shouldSendRequest:(id)request byCachedResponse:(id)cachedResponse {
    return [request shouldSendRequestByCachedResponse:cachedResponse];
}

+ (BOOL)processItemsOfCachedResponse:(id)cachedResponse withRequest:(id)request {
    NSArray *tempArray = @[];
    NSInteger pageIndex = [[request valueForKey:@"pageIndex"] integerValue];
    MApi_Reachability *reachBility = [MApi_Reachability reachabilityForInternetConnection];
    if (pageIndex > 0 ||
        ([reachBility currentReachabilityStatus] == MApi_RC_NotReachable && pageIndex == 0)) {
        tempArray = [request getNextPageItemsByCachedResponse:cachedResponse];
    }

    if (tempArray.count >= 10) {
        [cachedResponse resetListItems:tempArray];
        return YES;
    }

    return NO;
}

+ (void)processNewsListRequestSuccessOfResponse:(id)response andRequest:(id)request {
    id cachedObject = [request cachedObject];
    NSString *cachePath = [(id<MApiCaching>)request cachePath];
    if (cachedObject) {
        //Refresh
        if ([request pageIndex] == 0) {
            //If overpage then store brand new cache.
            if ([response overpage]) {
                [MApiCache cacheObject:response toPath:cachePath];
            }
            else {
                NSMutableArray *readyCacheItems = [[response getListItems] mutableCopy];
                [readyCacheItems addObjectsFromArray:[cachedObject getListItems]];
                NSInteger limitCachedCount = 50;
                if (readyCacheItems.count > limitCachedCount) {
                    [readyCacheItems removeObjectsInRange:NSMakeRange(limitCachedCount,
                                                                      (readyCacheItems.count - limitCachedCount))];
                }
                [cachedObject resetListItems:readyCacheItems];
                [MApiCache cacheObject:cachedObject toPath:cachePath];
                
                //取前十笔
                NSMutableArray *topTenItems = [NSMutableArray array];
                for (id obj in readyCacheItems) {
                    [topTenItems addObject:obj];
                    if (topTenItems.count >= 10) {
                        break;
                    }
                }
                [response resetListItems:[topTenItems copy]];
            }
        }
        //Get more
        else {
            //Append data to cache.
            NSMutableArray *mutableArray = [[cachedObject getListItems] mutableCopy];
            [mutableArray addObjectsFromArray:[response getListItems]];
            [cachedObject resetListItems:[mutableArray copy]];
            [MApiCache cacheObject:cachedObject toPath:cachePath];
            NSArray *array = [request getNextPageItemsByCachedResponse:cachedObject];
            [response resetListItems:array];
        }
    }
    else {
        [MApiCache cacheObject:response toPath:cachePath];
    }
}
@end
