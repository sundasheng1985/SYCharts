//
//  MApiHelper.h
//  MobileSDK
//
//  Created by 李政修 on 2015/1/20.
//  Copyright (c) 2015年 Mitake. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_INLINE NSString *MApiResponseClassMap(NSString *className) {
    if (className == nil) return nil;
    
    static dispatch_once_t onceToken;
    static NSDictionary *map;
    dispatch_once(&onceToken, ^{
        map = @{
                @"MBondBuyBacksRequest": @"MBondBuyBacksResponse",
                @"MBondInterestPayRequest": @"MBondInterestPayResponse",
                @"MBondBasicInfoRequest": @"MBondBasicInfoResponse",
                @"MFundDividendRequest": @"MFundDividendResponse",
                @"MFundFinanceRequest": @"MFundFinanceResponse",
                @"MFundShareStructRequest": @"MFundShareStructResponse",
                @"MFundStockPortfolioRequest": @"MFundStockPortfolioResponse",
                @"MFundIndustryPortfolioRequest": @"MFundIndustryPortfolioResponse",
                @"MFundAssetAllocationRequest": @"MFundAssetAllocationResponse",
                @"MFundNetValueRequest": @"MFundNetValueResponse",
                @"MFundBasicInfoRequest": @"MFundBasicInfoResponse",
                @"MLatestIndexRequest": @"MLatestIndexResponse",
                @"MBigEventNotificationRequest": @"MBigEventNotificationResponse",
                @"MForecastYearRequest": @"MForecastYearResponse",
                @"MForecastRatingRequest": @"MForecastRatingResponse",
                @"MCompanyInfoRequest": @"MCompanyInfoResponse",
                @"MIPOInfoRequest": @"MIPOInfoResponse",
                @"MCoreBusinessRequest": @"MCoreBusinessResponse",
                @"MControlingShareHolderRequest": @"MControlingShareHolderResponse",
                @"MBonusFinanceRequest": @"MBonusFinanceResponse",
                @"MLeaderPersonInfoRequest": @"MLeaderPersonInfoResponse",
                @"MStockShareInfoRequest": @"MStockShareInfoResponse",
                @"MStockShareChangeInfoRequest": @"MStockShareChangeInfoResponse",
                @"MBlockTradeInfoRequest": @"MBlockTradeInfoResponse",
                @"MTradeDetailInfoRequest": @"MTradeDetailInfoResponse",
                @"MShareHolderHistoryInfoRequest": @"MShareHolderHistoryInfoResponse",
                @"MTopLiquidShareHolderRequest": @"MTopLiquidShareHolderResponse",
                @"MTopShareHolderRequest": @"MTopShareHolderResponse",
                @"MFundShareHolderInfoRequest": @"MFundShareHolderInfoResponse",
                @"MFinancialInfoRequest": @"MFinancialInfoResponse",
                @"MFinancialSummaryRequest": @"MFinancialSummaryResponse",
                @"MNewsListRequest": @"MNewsListResponse",
                @"MNewsRequest": @"MNewsResponse",
                @"MNewsImgRequest": @"MNewsImgResponse",
                @"MStockBulletinListRequest": @"MStockBulletinListResponse",
                @"MStockBulletinRequest": @"MStockBulletinResponse",
                @"MStockNewsListRequest": @"MStockNewsListResponse",
                @"MStockNewsRequest": @"MStockNewsResponse",
                @"MStockReportListRequest": @"MStockReportListResponse",
                @"MStockReportRequest": @"MStockReportResponse",
                @"MPortfolioNewsListRequest": @"MPortfolioNewsListResponse",
                @"MAuthRequest": @"MAuthResponse",
                @"MMarketInfoRequest": @"MMarketInfoResponse",
                @"MCheckVersionRequest": @"MCheckVersionResponse",
                @"MEventRequest": @"MEventResponse",
                @"MEchoRequest": @"MEchoResponse",
                @"MGetSourceClassRequest" : @"MGetSourceClassResponse",
                @"MGetMenuRequest" : @"MGetMenuResponse",
                @"MAdvertRequest": @"MAdvertResponse",
                @"MQuoteRequest": @"MQuoteResponse",
                @"MSnapQuoteRequest": @"MSnapQuoteResponse",
                @"MRiseRankingRequest": @"MRiseRankingResponse",
                @"MFallRankingRequest": @"MFallRankingResponse",
                @"MSectionRankingRequest": @"MSectionRankingResponse",
                @"MChartRequest": @"MChartResponse",
                @"MOHLCRequest": @"MOHLCResponse",
                @"MOptionRequest": @"MOptionResponse",
                @"MOptionTRequest": @"MOptionResponse",
                @"MExpireMonthRequest": @"MExpireMonthResponse",
                @"MUnderlyingStockRequest": @"MUnderlyingStockResponse",
                @"MCategoryQuoteListRequest": @"MCategoryQuoteListResponse",
                @"MBrokerSeatRequest": @"MBrokerSeatResponse",
                @"MStockTableRequest": @"MSearchResponse",
                @"MSearchRequest": @"MSearchResponse",
                @"MGetSourceRequest": @"MGetSourceResponse",
                @"MAnnouncementRequest": @"MAnnouncementResponse",
                @"MStockCategoryListRequest": @"MStockCategoryListResponse",
                @"MCategorySortingRequest": @"MCategorySortingResponse",
                @"MStockXRRequest": @"MStockXRResponse",
                @"MTimeTickRequest": @"MTimeTickResponse",
                @"MPriceVolumeRequest": @"MPriceVolumeResponse",
                @"MOrderQuantityRequest": @"MOrderQuantityResponse",
                @"MCrashReportRequest": @"MResponse",
                @"MHKQuoteInfoRequest": @"MHKQuoteInfoResponse",
                @"MIPODateRequest": @"MIPODateResponse",
                @"MIPOCalendarRequest": @"MIPOCalendarResponse",
                @"MIPOShareDetailRequest": @"MIPOShareDetailResponse",
                @"MMarketHolidayRequest": @"MMarketHolidayResponse",
                @"MSectionSortingRequest": @"MSectionSortingResponse",
                @"MTimeTickDetailRequest": @"MTimeTickDetailResponse",
                @"MFundValueRequest":@"MFundValueResponse",
                @"MPingRequest":@"MPingResponse",
                @"MGetServerRequest":@"MGetServerResponse",
                @"MStaticDataRequest":@"MStaticDataResponse",
                @"MHKMarketInfoRequest":@"MHKMarketInfoResponse",
                };
    });
    return map[className];
}


#define MAPI_AUTH_SERVERS [MApiHelper sharedHelper].authServers
#define MAPI_QUOTE_SERVERS [MApiHelper sharedHelper].quoteServers
#define MAPI_ACCESS_TOKEN [MApiHelper sharedHelper].token
#define MAPI_MARKET_INFOS [MApiHelper sharedHelper].marketInfos

extern NSString * const MApiHttpMethodGET;
extern NSString * const MApiHttpMethodPOST;


@class MMarketInfo;

@interface MApiHelper : NSObject

@property (nonatomic, copy) NSArray *authServers;
@property (nonatomic, copy) NSDictionary *quoteServers;

@property (nonatomic, assign) UInt8 currentServerIndex;
/** */
@property (nonatomic, copy) NSString *corpID;
/** */
@property (nonatomic, copy) NSString *productID;
/** */
@property (nonatomic, copy) NSString *productVersion;
/** */
@property (nonatomic, copy) NSString *clientIP;
/** */
@property (nonatomic, copy) NSString *phoneNumber;

@property (nonatomic, copy) NSString *token;

@property (nonatomic, copy) NSString *appKey;

/** */
@property (nonatomic, readonly) NSString *currentReachabilityStatusString;
/** */
@property (nonatomic, readonly) NSString *platform;
/** */
@property (nonatomic, readonly) NSString *operationSystem;
/** */
@property (nonatomic, readonly) NSString *operationSystemVersion;

@property (nonatomic, copy) NSDictionary *marketInfos;
/** 各市场交易日期(hk=20160115, sh=20160115, ...), 包含一个timestamp */
@property (nonatomic, strong) NSDictionary *marketTradeDates;


@property (nonatomic, copy) NSString *unitTest_bundleID;
@property (nonatomic, copy) NSString *unitTest_version;

@property (nonatomic, strong) NSDictionary *registerOptions;
/** 單一實體 */
+ (instancetype)sharedHelper;
- (BOOL)isTokenEmpty;
+ (NSString *)archiveType;
+ (NSString *)formatPrice:(double)price market:(NSString *)market subtype:(NSString *)subtype;
+ (NSString *)formatAveragePrice:(double)price market:(NSString *)market subtype:(NSString *)subtype;
+ (NSString *)formatVolume:(NSString *)volume market:(NSString *)market subtype:(NSString *)subtype;
+ (NSDictionary *)tradingInfomationWithMarket:(NSString *)market subtype:(NSString *)subtype;
+ (MMarketInfo *)marketInfoWithMarket:(NSString *)market subtype:(NSString *)subtype;
+ (void)saveAuthIPs:(NSArray *)IPs;

- (void)archiveToken:(NSString *)token;
- (void)archiveQuoteServers:(NSDictionary *)quoteServers;
- (void)archiveMarketInfos:(NSDictionary *)marketInfos;

- (void)restoreAuthInfo;
- (void)clearAuthInfo;
@end
