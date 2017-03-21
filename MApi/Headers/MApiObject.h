/////////////////////////////////////////////////////////
//                                                     //
// Copyright (c) 2016年 上证云平台. All rights reserved. //
//                                                     //
/////////////////////////////////////////////////////////


#ifndef __MAPI_OBJECT_PUBLIC_MACRO__
#define __MAPI_OBJECT_PUBLIC_MACRO__
#if __has_extension(objc_generics)
@class MTickItem, MTimeTickItem, MTimeTickDetailItem, MPriceVolumeItem, MStockItem, MOHLCItem,
MOptionItem, MSectionRankingItem, MSectionSortingItem,
MSearchResultItem, MBrokerSeatItem, MHKOddInfoItem, MStaticDataItem, MBoardInfoItem;
#define MAPI_OBJ_TICK_TYPE                 <MTickItem *>
#define MAPI_OBJ_TIME_TICK_TYPE            <MTimeTickItem *>
#define MAPI_OBJ_TIME_TICK_DETAIL_TYPE     <MTimeTickDetailItem *>
#define MAPI_OBJ_PRICE_VOLUME_TYPE    <MPriceVolumeItem *>
#define MAPI_OBJ_STOCK_TYPE           <MStockItem *>
#define MAPI_OBJ_OHLC_TYPE            <MOHLCItem *>
#define MAPI_OBJ_OPTION_TYPE          <MOptionItem *>
#define MAPI_OBJ_SECTION_RANKING_TYPE <MSectionRankingItem *>
#define MAPI_OBJ_SECTION_SORTING_TYPE <MSectionSortingItem *>
#define MAPI_OBJ_SEARCH_RESULT_TYPE   <MSearchResultItem *>
#define MAPI_OBJ_BROKER_SEAT_TYPE     <MBrokerSeatItem *>
#define MAPI_OBJ_ODD_INFO_TYPE     <MHKOddInfoItem *>
#define MAPI_OBJ_STATIC_DATA_TYPE     <MStaticDataItem *>
#define MAPI_OBJ_BOARD_INFO_TYPE     <MBoardInfoItem *>
#else
#define MAPI_OBJ_TICK_TYPE
#define MAPI_OBJ_TIME_TICK_TYPE
#define MAPI_OBJ_TIME_TICK_DETAIL_TYPE
#define MAPI_OBJ_PRICE_VOLUME_TYPE
#define MAPI_OBJ_STOCK_TYPE
#define MAPI_OBJ_OHLC_TYPE
#define MAPI_OBJ_OPTION_TYPE
#define MAPI_OBJ_SECTION_RANKING_TYPE
#define MAPI_OBJ_SECTION_SORTING_TYPE
#define MAPI_OBJ_SEARCH_RESULT_TYPE
#define MAPI_OBJ_BROKER_SEAT_TYPE
#define MAPI_OBJ_ODD_INFO_TYPE
#define MAPI_OBJ_STATIC_DATA_TYPE
#define MAPI_OBJ_BOARD_INFO_TYPE
#endif
#endif

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

typedef NS_ENUM(NSInteger, MApiNetworkStatus) {
    /**
     *  网络状态
     */
    MApiNotReachable = 0,
    MApiReachableViaWiFi = 2,
    MApiReachableViaWWAN = 1
};

typedef NS_ENUM(NSInteger, MApiSourceLevel) {
    /**
     *  资讯源级别
     */
    MApiSourceLevel1 = 1,
    MApiSourceLevel2 = 2,
};

typedef NS_ENUM(NSUInteger, MBSVolumeType){
    /**
     *  内外盘别
     */
    MBSVolumeTypeNone,
    MBSVolumeTypeBuy,
    MBSVolumeTypeSell
};

typedef NS_ENUM(NSUInteger, MChangeState){
    /**
     *  涨跌状态
     */
    MChangeStateFlat,
    MChangeStateRise,
    MChangeStateDrop
};

typedef NS_ENUM(NSUInteger, MChartType){
    /**
     *  走势类别
     */
    MChartTypeOneDay = 0,
    MChartTypeFiveDays = 1
};

typedef NS_ENUM(NSUInteger, MOHLCPeriod){
    /**
     *  K线周期
     */
    MOHLCPeriodDay = 0,
    MOHLCPeriodWeek = 1,
    MOHLCPeriodMonth = 2,
    MOHLCPeriodMin5 = 3,
    MOHLCPeriodMin15 = 4,
    MOHLCPeriodMin30 = 5,
    MOHLCPeriodMin60 = 6,
    MOHLCPeriodMin120 = 7
};

typedef NS_ENUM(NSInteger, MResponseStatus){
    /**
     *  回传代码
     */
    MResponseStatusSuccess        = 200,
    MResponseStatusSessionExpired = 401,
    MResponseStatusNotFound       = 404,
    MResponseStatusOverLimit      = 444,
    MResponseStatusServerError    = 500,
    MResponseStatusBadGateway     = 502,

    MResponseStatusTimeout            = -1001,
    MResponseStatusDataParseError     = -1003,
    MResponseStatusDataNil            = -1004,
    MResponseStatusParameterError     = -1005,
    MResponseStatusServerSiteNotFound = -1006,
    MResponseStatusNotReachabled      = -1009,
    MResponseStatusCertificationAuditError = -2001
    
};

typedef NS_ENUM(NSUInteger, MOptionType){
    /**
     *  期权类别
     */
    MOptionTypeUnknown,
    MOptionTypeCall,
    MOptionTypePut
};

typedef NS_ENUM(NSInteger, MStockStatus){
    /**
     *  交易状态
     */
    MStockStatusNormal   = 0,  // 正常交易
    MStockStatusPause    = 1,  // 暂停交易
    MStockStatusSuspend  = 2,  // 停牌
    MStockStatusUnmarket = 3   // 退市
};

typedef NS_ENUM(NSInteger, MStockStage) {
    /**
     *  交易阶段
     */
    MStockStageUnknown       = 99,
    MStockStageUnopen        = 0,  // 未开市
    MStockStageVirtual       = 1,  // 虚拟盘
    MStockStageAuction       = 2,  // 集合竞价
    MStockStageOpen          = 3,  // 连续竞价
    MStockStageTempSuspensed = 4,  // 临时停市
    MStockStageClosed        = 5,  // 已收盘
    MStockStageLunchBreak    = 6,  // 午间休市
    MStockStageOnTrading     = 7   // 交易中
};

typedef NS_ENUM(NSInteger, MOHLCPriceAdjustedMode) {
    MOHLCPriceAdjustedModeNone = 0,    // 不复权
    MOHLCPriceAdjustedModeForward = 1, // 前复权
    MOHLCPriceAdjustedModeBackward = 2 // 后复权
};

typedef NS_ENUM(NSInteger, MCategorySortingField) {
    MCategorySortingFieldID = 1,
    MCategorySortingFieldName = 2,
    MCategorySortingFieldPinyin = 4,
    MCategorySortingFieldLastPrice = 7,
    MCategorySortingFieldHighPrice = 8,
    MCategorySortingFieldLowPrice = 9,
    MCategorySortingFieldOpenPrice = 10,
    MCategorySortingFieldPreClosePrice = 11,
    MCategorySortingFieldChangeRate = 12,
    MCategorySortingFieldVolume = 13,
    MCategorySortingFieldTurnoverRate = 15,
    MCategorySortingFieldChange = 19,
    MCategorySortingFieldAmount = 20,
    MCategorySortingFieldVolumeRatio = 21,
    MCategorySortingFieldAmplitudeRate = 37
};

typedef NS_ENUM(NSInteger, MSectionSortingField) {
    MSectionSortingFieldWeightedChange = 0,
    MSectionSortingFieldAverageChange = 1,
    MSectionSortingFieldAmount = 2,
    MSectionSortingFieldAdvanceAndDeclineCount = 3,
    MSectionSortingFieldTurnoverRate = 4,
};


typedef NS_ENUM(NSUInteger, MHKOddSide) {
    /**
     *  港股碎股订单买卖方向
     */
    MHKOddSideNone,
    MHKOddSideBid,
    MHKOddSideOffer
};

typedef NS_OPTIONS(NSUInteger, MHKInfoStatus) {
    MHKInfoStatusNone = 0,
    MHKInfoStatusODD  = 1 << 0,
    MHKInfoStatusVCM  = 1 << 1,
    MHKInfoStatusCAS  = 1 << 2,
};

typedef NS_ENUM(NSInteger, MTimeTickAMSFlag) {
    /**
     *  港股碎股订单买卖方向
     */
    MTimeTickAMSFlagUnknown = -1,
    MTimeTickAMSFlagNone = 0,                       // AMS <space>
    MTimeTickAMSFlagLateTrade = 4,                  // AMS 'P'
    MTimeTickAMSFlagNonDirectOffExchangeTrade = 22, // AMS 'M'
    MTimeTickAMSFlagAutomatchInternalized = 100,    // AMS 'Y'
    MTimeTickAMSFlagDirectOffExchangeTrade = 101,   // AMS 'X'
    MTimeTickAMSFlagOddLotTrade = 102,              // AMS 'D'
    MTimeTickAMSFlagAuctionTrade = 103              // AMS 'U'
};


typedef NS_ENUM(NSInteger, MTimeTickRequestType) {
    MTimeTickRequestTypeRecent = -1, // 最新N笔数据
    MTimeTickRequestTypeNewer = 0,   // 比index更新的N笔数据
    MTimeTickRequestTypeOlder = 1    // 比index更旧的N笔数据
};

typedef NS_ENUM(NSInteger, MSnapQuoteRequestType) {
    MSnapQuoteRequestType1 = 0, // 1档 (默认)
    MSnapQuoteRequestType5,     // 5档
    MSnapQuoteRequestType10     // 10档
};

@class MStockItem;

#pragma mark - 基底类
@interface MApiModel : NSObject <NSSecureCoding, NSCopying>

@end

#pragma mark - 请求类

/*! @brief 请求类
 */
@interface MRequest : MApiModel
@property (nonatomic, copy, readonly) NSString *APIVersion;
/** 请求超时时间 */
@property (nonatomic) NSTimeInterval timeoutInterval;
/** 请求次数 */
@property (nonatomic, readonly) NSUInteger sendCount;
/** 取消请求 */
- (void)cancel;
@end

@interface MListRequest : MRequest
/** 页次 */
@property (nonatomic, assign) NSInteger pageIndex;
@end

/*! @brief 取得券商公告
 */
@interface MAnnouncementRequest : MRequest
@end

/*! @brief 行销宣传页请求类
 */
@interface MAdvertRequest : MRequest
/** 广告key(可为空，取回所有广告) */
@property (nonatomic, copy) NSString *advertKey;
@end
/*! @brief 取得主选单功能请求类
 */
@interface MGetMenuRequest : MRequest
@end

/**
 *  取得更版信息
 */
@interface MCheckVersionRequest : MRequest
@end

/*! @brief 使用者行为记录请求类
 */
@interface MEventRequest : MRequest
/** 功能代码 */
@property (nonatomic, copy) NSString *fid;
@end

/**
 *  取得各券商APP可使用的资讯源
 */
@interface MGetSourceRequest : MRequest
@end

/*! @brief 取得可使用的分类类别请求
 */
@interface MGetSourceClassRequest : MRequest
@end

/*! @brief 股票行情请求类
 */
@interface MQuoteRequest : MRequest
/** 
    股票代码(可多笔，用逗号隔开), 如果不同市场别则要分开发送请求
    如 request.code = @"600000.sh,600001.sh"
    request.code = @"399001.sz,300398.sz"
 */
@property (nonatomic, copy) NSString *code;

@end

/*! @brief 股票快照行情请求类
 */
@interface MSnapQuoteRequest : MRequest
/** 股票代码(只可单笔查询), 如 600000.sh */
@property (nonatomic, copy) NSString *code;
/** 明细条数*/
@property (nonatomic, assign) NSInteger tickCount;
/** 
    请求类型, 分成一档行情、五档行情、十档行情
    
    如果设置 MSnapQuoteRequestType10 会有以下两种resp.stockItem字段差异
    1. request.code为港股时, resp.stockItem会有经济席位数据, @see MStockItem (MApiQuoteHK)
    2. request.code为沪深股时, resp.stockItem会有买卖队列数据, @see MStockItem (MApiQuoteSHSZ)
 */
@property (nonatomic, assign) MSnapQuoteRequestType type;
@end

/*! @brief 板块排行请求类
 */
@interface MSectionRankingRequest : MListRequest
/** 板块代码 */
@property (nonatomic, copy) NSString *code;
@end

/*! @brief 板块排行请求类
 */
@interface MSectionSortingRequest : MListRequest
/** 板块代码 */
@property (nonatomic, copy) NSString *code;
/** 笔数 */
@property (nonatomic, assign) NSInteger pageSize;
/** 排列顺序 */
@property (nonatomic, assign) BOOL ascending;
/** 排序栏位 */
@property (nonatomic, assign) MSectionSortingField field;
@property (nonatomic, copy) NSString *str_field;
@end


/*! @brief 分类涨幅排行请求类
 */
@interface MRiseRankingRequest : MListRequest
/** 分类代码 */
@property (nonatomic, copy) NSString *code;
/** 笔数 */
@property (nonatomic, assign) NSInteger pageSize;
@end

/*! @brief 分类跌幅排行请求类
 */
@interface MFallRankingRequest : MListRequest
/** 分类代码 */
@property (nonatomic, copy) NSString *code;
/** 笔数 */
@property (nonatomic, assign) NSInteger pageSize;
@end

/*! @brief 分类涨跌幅排行请求类
 */
@interface MCategorySortingRequest : MListRequest
/** 分类代码 */
@property (nonatomic, copy) NSString *code;
/** 笔数 */
@property (nonatomic, assign) NSInteger pageSize;
/** 排列顺序 */
@property (nonatomic, assign) BOOL ascending;
/** 排序栏位 */
@property (nonatomic, assign) MCategorySortingField field;
/** 是否包含停牌股 */
@property (nonatomic, assign) BOOL includeSuspension;
@end

/*! @brief 历史行情(K线数据)请求类
 */
@interface MOHLCRequest : MRequest
/** 股票代码 */
@property (nonatomic, copy) NSString *code;
/** 次类别 */
@property (nonatomic, copy) NSString *subtype;
/** K线周期 */
@property (nonatomic) MOHLCPeriod period;
/** 周期单位 */
@property (nonatomic) NSInteger unit;
/** 复权模式 默认不复权 */
@property (nonatomic, assign) MOHLCPriceAdjustedMode priceAdjustedMode;
@end

/*! @brief 当日走势数据请求类
 */
@interface MChartRequest : MRequest
/** 股票代码 */
@property (nonatomic, copy) NSString *code;
/** 次类别 */
@property (nonatomic, copy) NSString *subtype;
/** 走势类别 */
@property (nonatomic) MChartType chartType;
@end

/*! @brief 期权行情请求类
 *
 *  请求期权行情列表，若期权类别设置为MOptionTypeUnknown可查询认购及认沽的期权股票。
 */
@interface MOptionRequest : MListRequest
/** 标的证券代码 */
@property (nonatomic, copy) NSString *stockID;
/** 期权类别 */
@property (nonatomic) MOptionType optionType;
@end

/*! @brief 期权T型报价行情请求类
 *
 *  请求期权T型报价行情列表。
 */
@interface MOptionTRequest : MRequest
/** 标的证券代码 */
@property (nonatomic, copy) NSString *stockID;
/** 期权交割月 */
@property (nonatomic, copy) NSString *expireMonth;
@end

/*! @brief 标的证券列表请求类
 */
@interface MUnderlyingStockRequest : MRequest

@end

/*! @brief 交割月列表请求类
 */
@interface MExpireMonthRequest : MRequest
/** 标的证券代码 */
@property (nonatomic, copy) NSString *stockID;
@end



/*! @brief 板块分类即时行情列表请求类
 */
@interface MCategoryQuoteListRequest : MListRequest
/** 板块ID */
@property (nonatomic, copy) NSString *categoryID;
@end


/*! @brief 搜寻股票请求类
 */
@interface MSearchRequest : MRequest
/** 搜寻文字 */
@property (nonatomic, copy) NSString *keyword;
/** 市场别 */
@property (nonatomic, copy) NSString *market;
/** 市场别数组 */
@property (nonatomic, copy) NSArray *markets;
/** 子类别 */
@property (nonatomic, copy) NSString *subtype;
/** 子类别数组 */
@property (nonatomic, copy) NSArray *subtypes;
/** 
    是否为本地端搜索
    设置为yes时, 发送请求前需先调用MApi.downloadStockTableWithCompletionHandler: 方法先下载股票表
 */
@property (nonatomic, assign) BOOL searchLocal;
/** 搜寻结果数量限制 */
@property (nonatomic, assign) NSUInteger searchLimit;
@end

/*! @brief 经纪席位请求类(港股专用)
 */
@interface MBrokerSeatRequest : MRequest
/** 港股股票代码 */
@property (nonatomic, copy) NSString *code;
@end

/*! @brief 股票代码请求类
 */
@interface MStockTableRequest : MRequest

@end

/*! @brief 股票分类代码表请求类
 */
@interface MStockCategoryListRequest : MRequest

@end

/*! @brief 分时明细表请求类
 */
@interface MTimeTickRequest : MRequest
/** 股票代码 */
@property (nonatomic, copy) NSString *code;
/** 次类别 */
@property (nonatomic, copy) NSString *subtype;
/** 开始索引 */
@property (nonatomic, copy) NSString *index;
/** 笔数 */
@property (nonatomic, assign) NSUInteger pageSize;
/** 基于开始索引请求的类别 */
@property (nonatomic, assign) MTimeTickRequestType type;
@end

/*! @brief 分价量表请求类
 */
@interface MPriceVolumeRequest : MRequest
/** 股票代码 */
@property (nonatomic, copy) NSString *code;
/** 次类别 */
@property (nonatomic, copy) NSString *subtype;
@end

/*! @brief 买卖队列请求类
 */
@interface MOrderQuantityRequest : MRequest
/** 股票代码 */
@property (nonatomic, copy) NSString *code;
/** 次类别 */
@property (nonatomic, copy) NSString *subtype;
@end


/*! @brief 港股其他资讯请求类
 */
@interface MHKQuoteInfoRequest : MRequest
/** 股票代码 */
@property (nonatomic, copy) NSString *code;
/** 次类别 */
@property (nonatomic, copy) NSString *subtype;
@end


/*! @brief 假日档请求类
 */
@interface MMarketHolidayRequest : MRequest

@end

/*! @brief 分时明细表请求类
 */
@interface MTimeTickDetailRequest : MListRequest
/** 股票代码 */
@property (nonatomic, copy) NSString *code;
/** 次类别 */
@property (nonatomic, copy) NSString *subtype;
/** 笔数 */
@property (nonatomic, assign) NSInteger pageSize;
@end


/*! @brief 个股静态数据
 *
 *  包含个股静态数据、个股所属板块信息、两市港股通标识、融资标识、融券标识
 */
@interface MStaticDataRequest : MRequest
/** 股票代码，多个股票用逗号隔开，如“600000.sh,000001.sz” */
@property (nonatomic, copy) NSString *code;
/**
 *  默认为 “bk,hki,su,bu”
 *  bk:个股所属板块信息
 *  hki:两市港股通标识
 *  su:融资标识
 *  bu:融券标识
 */
@property (nonatomic, copy) NSString *param;

@end

/*! @brief 两市港股通
 *
 *  包含每日初始额度 日中剩余额度和额度状态
 */
@interface MHKMarketInfoRequest : MRequest
@end

#pragma mark - 应答类类

/*! @brief 应答类类
 *
 *  MResponse为应答类数据的基类
 */
@interface MResponse : MApiModel
/** 回传代码 */
@property (nonatomic, assign) MResponseStatus status;
/** 回传信息 */
@property (nonatomic, readonly) NSString *message;
/** 更新时间 */
@property (nonatomic, copy) NSString *datetime;
/** 总页次 */
@property (nonatomic, assign) NSUInteger numberOfPages;
/** 请求对象 */
@property (nonatomic, weak) MRequest *request;
/**
 *  是否为缓存数据
 *
 *  YES:缓存数据, NO:真实数据(目前只有走势及k线数据支持缓存数据的回传)
 */
@property (nonatomic, assign) BOOL isCacheResponse;
@end

@interface MAnnouncementResponse : MResponse
@property (nonatomic, readonly, copy) NSString *announcementTitle;
@property (nonatomic, readonly, copy) NSString *announcementContent;
@property (nonatomic, readonly, copy) NSString *announcementDatetime;
@end

/**
 *  取得更版信息
 */
@interface MCheckVersionResponse : MResponse
@property (nonatomic, strong) NSDictionary *versionInfo;
@property (nonatomic, readonly, copy) NSString *versionStatus;
@property (nonatomic, readonly, copy) NSString *downloadURLString;
@property (nonatomic, readonly, copy) NSString *checkVersionDescription;
@property (nonatomic, readonly, copy) NSString *version;
@end


/*! @brief 使用者行为记录应答类
 */
@interface MEventResponse : MResponse

@end


/*! @brief 取得可使用的分类类别应答类
 */
@interface MGetSourceClassResponse : MResponse
@property (nonatomic, strong) NSDictionary *sourceClassInfos;
@end

/*! @brief 取得主选单功能应答类
 */
@interface MGetMenuResponse : MResponse
@property (nonatomic, strong) NSDictionary *menuDictionary;
@end

/**
 *  各券商APP可使用的资讯源类别
 */
@interface MGetSourceResponse : MResponse
/**资讯源类别资料 */
@property (nonatomic, strong) NSDictionary *sourceInfos;
@end

/*! @brief 股票行情应答类
 *
 *  透过MQuoteRequest取得之股票行情回传数据，包含单笔或多笔股票行情
 */
@interface MQuoteResponse : MResponse
/** 股票行情列表 */
@property (nonatomic, strong) NSArray MAPI_OBJ_STOCK_TYPE *stockItems;
@end

/*! @brief 行销宣传页应答类
 */
@interface MAdvertResponse : MResponse
/** 分类列表 */
@property (nonatomic, strong) NSDictionary *advertDictionary;;
@end

/*! @brief 股票快照行情应答类
 */
@interface MSnapQuoteResponse : MResponse
/** 股票快照行情 */
@property (nonatomic, strong) MStockItem *stockItem;
@property (nonatomic, strong) NSArray *orderQuantityBuyItems;
@property (nonatomic, strong) NSArray *orderQuantitySellItems;
@property (nonatomic, strong) NSArray *buyBrokerSeatItems;
@property (nonatomic, strong) NSArray *sellBrokerSeatItems;
@end

/*! @brief 板块排行应答类
 */
@interface MSectionRankingResponse : MResponse
/** 板块排行列表 */
@property (nonatomic, strong) NSArray MAPI_OBJ_SECTION_RANKING_TYPE *sectionRankingItems;
@end

/*! @brief 板块排行应答类
 */
@interface MSectionSortingResponse : MResponse
/** 板块排行列表 */
@property (nonatomic, strong) NSArray MAPI_OBJ_SECTION_SORTING_TYPE *sectionSortingItems;
@end

/*! @brief 分类涨幅排行应答类
 */
@interface MRiseRankingResponse : MResponse
/** 股票区块列表 */
@property (nonatomic, strong) NSArray MAPI_OBJ_STOCK_TYPE *stockItems;
@end

/*! @brief 分类跌幅排行应答类
 */
@interface MFallRankingResponse : MResponse
/** 股票区块列表 */
@property (nonatomic, strong) NSArray MAPI_OBJ_STOCK_TYPE *stockItems;
@end

/*! @brief 分类跌跌幅排行应答类
 */
@interface MCategorySortingResponse : MResponse
/** 股票区块列表 */
@property (nonatomic, strong) NSArray MAPI_OBJ_STOCK_TYPE *stockItems;
@end

/*! @brief 走势数据应答类
 */
@interface MChartResponse : MResponse
/** 走势数据数组 */
@property (nonatomic, strong) NSArray MAPI_OBJ_OHLC_TYPE *OHLCItems;
/** 交易日，若五日则有五个交易日、若分时则显示当日 */
@property (nonatomic, strong) NSArray *tradeDates;
@end

/*! @brief 历史行情应答类
 */
@interface MOHLCResponse : MResponse
/** K线数据数组 */
@property (nonatomic, strong) NSArray MAPI_OBJ_OHLC_TYPE *OHLCItems;
/** 补足当前一笔资料 */
- (NSArray *)OHLCItemsByPeriodType:(MOHLCPeriod)period andSnapshotStockItem:(MStockItem *)stockItem;
@end

/*! @brief 期权行情应答类
 */
@interface MOptionResponse : MResponse
/** 期权行情列表 */
@property (nonatomic, strong) NSArray MAPI_OBJ_OPTION_TYPE *optionItems;
@end

/*! @brief 交割月应答类
 */
@interface MExpireMonthResponse : MResponse
/** 交割月列表 */
@property (nonatomic, strong) NSArray *expireMonths;
@end

/*! @brief 标的证券应答类
 */
@interface MUnderlyingStockResponse : MResponse
/** 标的证券列表 */
@property (nonatomic, strong) NSArray MAPI_OBJ_STOCK_TYPE *stockItems;
@end


/*! @brief 板块分类即时行情应答类
 */
@interface MCategoryQuoteListResponse : MResponse
/** 分类即时列表 */
@property (nonatomic, strong) NSArray MAPI_OBJ_STOCK_TYPE *categoryQuoteItems;
@end

/*! @brief 搜索股票应答类
 */
@interface MSearchResponse : MResponse
/** 搜寻结果列表 */
@property (nonatomic, strong) NSArray MAPI_OBJ_SEARCH_RESULT_TYPE *resultItems;
@end

/*! @brief 经纪席位应答类
 */
@interface MBrokerSeatResponse : MResponse
/** 经纪席位(买) */
@property (nonatomic, strong) NSArray MAPI_OBJ_BROKER_SEAT_TYPE *buyBrokerSeatItems;
/** 经纪席位(卖) */
@property (nonatomic, strong) NSArray MAPI_OBJ_BROKER_SEAT_TYPE *sellBrokerSeatItems;
@end

/*! @brief 股票分类代码表应答类
 */
@interface MStockCategoryListResponse : MResponse
/** 代码表数组 */
@property (nonatomic, strong) NSArray *list;
@end

/*! @brief 分时明细应答类
 */
@interface MTimeTickResponse : MResponse
/** 明细数组 */
@property (nonatomic, strong) NSArray MAPI_OBJ_TICK_TYPE *items;
@property (nonatomic, copy) NSString *startIndex;
@property (nonatomic, copy) NSString *endIndex;
@end

/*! @brief 分价量表应答类
 */
@interface MPriceVolumeResponse : MResponse
/** 代码表数组 */
@property (nonatomic, strong) NSArray MAPI_OBJ_PRICE_VOLUME_TYPE *items;
@end

/*! @brief 买卖队列应答类
 */
@interface MOrderQuantityResponse : MResponse
/** 买卖队列(买) */
@property (nonatomic, strong) NSArray *buyItems;
/** 买卖队列(买) */
@property (nonatomic, strong) NSArray *sellItems;
@end


/*! @brief 港股其他资讯应答类
 */
@interface MHKQuoteInfoResponse : MResponse
/** 碎股订单信息数组 */
@property (nonatomic, strong) NSArray MAPI_OBJ_ODD_INFO_TYPE *oddInfoItems;
/** 市场调节机制 时间 */
@property (nonatomic, copy) NSString *vcmDatetime;
/** 市场调节机制起始时间 143025 表示 14:30:25 */
@property (nonatomic, copy) NSString *vcmStartTime;
/** 市场调节机制结束时间 143025 表示 14:30:25 */
@property (nonatomic, copy) NSString *vcmEndTime;
/** 市场调节机制参考价 */
@property (nonatomic, copy) NSString *vcmRefPrice;
/** 市场调节下限价 */
@property (nonatomic, copy) NSString *vcmLowerPrice;
/** 市场调节上限价 */
@property (nonatomic, copy) NSString *vcmUpperPrice;
/** CAS 时间 */
@property (nonatomic, copy) NSString *casDatetime;
/** CAS 未能配对买卖盘的方向 N = 买卖盘量相等, B = 买盘比卖盘多, S = 卖盘比买盘多, <空格> = 不适用 */
@property (nonatomic, copy) NSString *casOrdImbDirection;
/** CAS 未能配对买卖盘的数量 */
@property (nonatomic, copy) NSString *casOrdImbQty;
/** CAS 的参考价格 */
@property (nonatomic, copy) NSString *casRefPrice;
/** CAS 下限价 */
@property (nonatomic, copy) NSString *casLowerPrice;
/** CAS 下限价 */
@property (nonatomic, copy) NSString *casUpperPrice;
@end


/*! @brief 假日档应答类
 */
@interface MMarketHolidayResponse : MResponse
/** 假日数组 */
@property (nonatomic, strong) NSDictionary *JSONObject;
@end

/*! @brief 分时明细表详情应答类
 */
@interface MTimeTickDetailResponse : MResponse
@property (nonatomic, strong) NSArray MAPI_OBJ_TIME_TICK_TYPE *tickItems;
@property (nonatomic, strong) NSArray MAPI_OBJ_TIME_TICK_DETAIL_TYPE *detailTickItems;
@end

/*! @brief 个股静态数据应答类
 */
@interface MStaticDataResponse : MResponse
@property (nonatomic , strong) NSArray MAPI_OBJ_STATIC_DATA_TYPE *dataItems;
@end

/*! @brief 两市港股通
 *
 *  包含每日初始额度 日中剩余额度和额度状态
 */
@interface MHKMarketInfoResponse : MResponse
/**沪初始额度*/
@property (nonatomic , copy) NSString *SHInitialQuota;
/**沪日中剩余额度*/
@property (nonatomic , copy) NSString *SHRemainQuota;
/**沪港通额度状态:1:不可用,2:可用,0或者null:源没有*/
@property (nonatomic , assign) NSInteger SHStatus;
/**深初始额度*/
@property (nonatomic , copy) NSString *SZInitialQuota;
/**深日中剩余额度*/
@property (nonatomic , copy) NSString *SZRemainQuota;
/**深港通额度状态:1:不可用,2:可用,0或者null:源没有*/
@property (nonatomic , assign) NSInteger SZStatus;
@end

#pragma mark - 数据模型

/*! @brief 数据模型基类
 */
@interface MBaseItem : MApiModel
@end

@interface MSearchBaseItem : NSManagedObject <NSCopying, NSCoding>
@end

/*! @brief 交易时间模型类
 */
@interface MTimeZone : MBaseItem
/** 开盘时间(HHmm) */
@property (nonatomic, copy) NSString *openTime;
/** 收盘时间(HHmm) */
@property (nonatomic, copy) NSString *closeTime;
@end

/*! @brief 市场资讯模型类
 */
@interface MMarketInfo : MBaseItem
/** 交易单位 */
@property (nonatomic, assign) NSInteger tradeUnit;
/** 小数位数 */
@property (nonatomic, assign) UInt8 decimal;
/** 交易时间列表 */
@property (nonatomic, strong) NSArray *timezones;
@end

/*! @brief 历史行情
 *
 *  包含时间、开、高、低、收、量等历史行情数据。可用来绘制走势或历史k线图。
 */
@interface MOHLCItem : MBaseItem
/** 时间 */
@property (nonatomic, copy) NSString *datetime;
/** 开盘价 */
@property (nonatomic, copy) NSString *openPrice;
/** 最高价 */
@property (nonatomic, copy) NSString *highPrice;
/** 最低价 */
@property (nonatomic, copy) NSString *lowPrice;
/** 收盘价 */
@property (nonatomic, copy) NSString *closePrice;
/** 交易量 */
@property (nonatomic, copy) NSString *tradeVolume;
/** 均价 */
@property (nonatomic, copy) NSString *averagePrice;
/** 昨收价 */
@property (nonatomic, copy) NSString *preClosePrice __attribute__((deprecated("请改用referencePrice")));
/** 参考价 */
@property (nonatomic, copy) NSString *referencePrice;
/** 成交金额 */
@property (nonatomic, copy) NSString *amount;
/** 大盘红绿柱 */
@property (nonatomic, copy) NSString *rgbar;
@end

/*! @brief 股票行情
 *
 *  股票行情类别，包含各种行情、五档等数据
 */
@interface MStockItem : MBaseItem

/** @brief 股票状态
 *
 * 参考 MStockStatus
 */
@property (nonatomic, assign) MStockStatus status;
/** @brief 交易階段
 *
 * 参照 MStockStage
 */
@property (nonatomic, assign) MStockStage stage;
/** @brief 股票代码
 *
 * 含市場代號的股票代碼
 */
@property (nonatomic, copy) NSString *ID;
/** 股票名 */
@property (nonatomic, copy) NSString *name;
/** 交易时间 */
@property (nonatomic, copy) NSString *datetime;
/** 市场别 */
@property (nonatomic, copy) NSString *market;
/** 次类别 */
@property (nonatomic, copy) NSString *subtype;
/** 最新价 */
@property (nonatomic, copy) NSString *lastPrice;
/** 最高价 */
@property (nonatomic, copy) NSString *highPrice;
/** 最低价 */
@property (nonatomic, copy) NSString *lowPrice;
/** 今开价 */
@property (nonatomic, copy) NSString *openPrice;
/** 昨收价 */
@property (nonatomic, copy) NSString *preClosePrice;
/** 涨跌比率 */
@property (nonatomic, copy) NSString *changeRate;
/** 总量 */
@property (nonatomic, copy) NSString *volume;
/** 当前成交量 */
@property (nonatomic, copy) NSString *nowVolume;
/** 换手率 */
@property (nonatomic, copy) NSString *turnoverRate;
/** 涨停价 */
@property (nonatomic, copy) NSString *limitUp;
/** 跌停价 */
@property (nonatomic, copy) NSString *limitDown;
/** 涨跌 */
@property (nonatomic, copy) NSString *change;
/** 成交金额 */
@property (nonatomic, copy) NSString *amount;
/** 买一价 */
@property (nonatomic, copy) NSString *buyPrice;
/** 卖一价 */
@property (nonatomic, copy) NSString *sellPrice;
/** 外盘量 */
@property (nonatomic, copy) NSString *buyVolume;
/** 内盘量 */
@property (nonatomic, copy) NSString *sellVolume;
/** 总值 */
@property (nonatomic, copy) NSString *totalValue;
/** 流值 */
@property (nonatomic, copy) NSString *flowValue;
/** 净资产 */
@property (nonatomic, copy) NSString *netAsset;
/** PE(市盈) */
@property (nonatomic, copy) NSString *PE;
/** ROE(净资产收益率) */
@property (nonatomic, copy) NSString *ROE;
/** 总股本 */
@property (nonatomic, copy) NSString *capitalization;
/** 流通股 */
@property (nonatomic, copy) NSString *circulatingShare;
/** 一、五、十档委买价, 买10 -> 买1 */
@property (nonatomic, strong) NSArray *buyPrices;
/** 一、五、十档委买量, 买10 -> 买1 */
@property (nonatomic, strong) NSArray *buyVolumes;
/** 一、五、十档委买笔数, 买10 -> 买1 */
@property (nonatomic, strong) NSArray *buyCount;
/** 一、五、十档委卖价, 卖1 -> 卖10 */
@property (nonatomic, strong) NSArray *sellPrices;
/** 一、五、十档委卖量, 卖1 -> 卖10*/
@property (nonatomic, strong) NSArray *sellVolumes;
/** 一、五、十档委卖笔数, 卖1 -> 卖10*/
@property (nonatomic, strong) NSArray *sellCount;
/** 委比 */
@property (nonatomic, copy) NSString *orderRatio;
/** 量比 */
@property (nonatomic, copy) NSString *volumeRatio;
/** 振幅比率 */
@property (nonatomic, copy) NSString *amplitudeRate;
/** 收益 */
@property (nonatomic, copy) NSString *receipts;
/** 最新十笔明细 */
@property (nonatomic, strong) NSArray *tickItems;
/** 股票代码(不含市场) */
@property (nonatomic, copy) NSString *code;
/** 涨跌状态 */
@property (nonatomic, assign) MChangeState changeState;
/** 上涨家数(指数类专用) */
@property (nonatomic, copy) NSString *advanceCount;
/** 下跌家数(指数类专用) */
@property (nonatomic, copy) NSString *declineCount;
/** 平盘家数(指数类专用) */
@property (nonatomic, copy) NSString *equalCount;
/** 是否为指数股票 */
@property (nonatomic, readonly, getter=isIndex) BOOL index;
/** 是否为香港股票 */
@property (nonatomic, readonly, getter=isHongKong) BOOL hongKong;
/** 是否为债券股票 */
@property (nonatomic, readonly, getter=isBond) BOOL bond;
/** 是否为基金股票 */
@property (nonatomic, readonly, getter=isFund) BOOL fund;
/** 是否为权证股票 */
@property (nonatomic, readonly, getter=isWrnt) BOOL wrnt;
/** 是否为期权股票 */
@property (nonatomic, readonly, getter=isOption) BOOL option;
/** 港股信息状态 */
@property (nonatomic, assign) MHKInfoStatus HKInfoStatus;

/** 总买量 */
@property (nonatomic, copy) NSString *totalBuyVolume;
/** 总卖量 */
@property (nonatomic, copy) NSString *totalSellVolume;
/** 均买价 */
@property (nonatomic, copy) NSString *averageBuyPrice;
/** 均卖价 */
@property (nonatomic, copy) NSString *averageSellPrice;
/** 副类别2 */
@property (nonatomic, copy) NSString *subtype2;
/**
 *  @brief 股票比较
 *
 *  @param stockItem 欲比较的股票
 *
 *  @return 比较结果
 */
- (BOOL)isEqualToStockItem:(MStockItem *)stockItem;
@end

@interface MStockItem (MApiTopBuyFixes)
/** 一、五、十档委买价, 买1 -> 买10 */
@property (nonatomic, readonly) NSArray *buyPricesReverse;
/** 一、五、十档委买量, 买1 -> 买10 */
@property (nonatomic, readonly) NSArray *buyVolumesReverse;
/** 一、五、十档委买笔数, 买1 -> 买10 */
@property (nonatomic, readonly) NSArray *buyCountReverse;
@end

@interface MStockItem (MApiQuoteSHSZ)
@property (nonatomic, readonly) NSArray *orderQuantityBuyItems;
@property (nonatomic, readonly) NSArray *orderQuantitySellItems;
@end

@interface MStockItem (MApiQuoteHK)
@property (nonatomic, readonly) NSArray *brokerSeatBuyItems;
@property (nonatomic, readonly) NSArray *brokerSeatSellItems;
@end

/*! @brief 期权行情
 */
@interface MOptionItem : MStockItem
/** 合约代码 */
@property (nonatomic, copy) NSString *contractID;
/** 标的证券代码 */
@property (nonatomic, copy) NSString *stockID;
/** 标的证券简称 */
@property (nonatomic, copy) NSString *stockSymble;
/** 标的证券类型 */
@property (nonatomic, copy) NSString *stockType;
/** 合约单位 */
@property (nonatomic, copy) NSString *unit;
/** 执行价格 */
@property (nonatomic, copy) NSString *exePrice;
/** 首交易日 */
@property (nonatomic, copy) NSString *startDate;
/** 最后交易日 */
@property (nonatomic, copy) NSString *endDate;
/** 行权日 */
@property (nonatomic, copy) NSString *exeDate;
/** 交割日 */
@property (nonatomic, copy) NSString *deliDate;
/** 到期日 */
@property (nonatomic, copy) NSString *expDate;
/** 合约版号 */
@property (nonatomic, copy) NSString *version;
/** 前结算价 */
@property (nonatomic, copy) NSString *presetPrice;
/** 标的证券昨收 */
@property (nonatomic, copy) NSString *stockClose;
/** 标的证券价格 */
@property (nonatomic, copy) NSString *stockLast;
/** 有无涨跌限制 */
@property (nonatomic, assign) BOOL isLimit;
/** 剩余天数 */
@property (nonatomic, copy) NSString *remainDate;
/** 持仓量 */
@property (nonatomic, copy) NSString *openInterest;
/** 期权类别(Call or Put) */
@property (nonatomic, readonly) MOptionType optionType;
@end

/*! @brief 板块排行
 */
@interface MSectionRankingItem : MBaseItem
/** 板块名称 */
@property (nonatomic, copy) NSString *name;
/** 板块代号 */
@property (nonatomic, copy) NSString *ID;
/** 板块涨幅比 */
@property (nonatomic, copy) NSString *changeRate;
/** 板块涨幅 */
@property (nonatomic, copy) NSString *change;
/** 领涨名称 */
@property (nonatomic, copy) NSString *stockName;
/** 领涨代号 */
@property (nonatomic, copy) NSString *stockID;
/** 领涨个股涨幅比 */
@property (nonatomic, copy) NSString *stockChangeRate;
/** 领涨个股涨幅 */
@property (nonatomic, copy) NSString *stockChange;
@end

@interface MSectionRankingItem (MStockItem)
+ (MStockItem *)stockItemBySectionRankingItem:(MSectionRankingItem *)sectionRankingItem;
+ (NSArray *)stockItemsBySectionRankingItems:(NSArray *)sectionRankingItems;
@end

/*! @brief 板块排行
 */
@interface MSectionSortingItem : MBaseItem
/** 板块代号 */
@property (nonatomic, copy) NSString *ID;
/** 板块名称 */
@property (nonatomic, copy) NSString *name;
/** 权涨幅 */
@property (nonatomic, copy) NSString *weightedChange;
/** 均涨幅 */
@property (nonatomic, copy) NSString *averageChange;
/** 总成交额 */
@property (nonatomic, copy) NSString *amount;
/** 涨跌家数 */
@property (nonatomic, copy) NSString *advanceAndDeclineCount;
/** 换手率 */
@property (nonatomic, copy) NSString *turnoverRate;
/** 领涨个股代码 */
@property (nonatomic, copy) NSString *stockID;
/** 领涨个股名 */
@property (nonatomic, copy) NSString *stockName;
/** 领涨个股涨幅 */
@property (nonatomic, copy) NSString *stockChange;
/** 领涨个股涨幅比 */
@property (nonatomic, copy) NSString *stockChangeRate;
/** 领涨个股最新价 */
@property (nonatomic, copy) NSString *stockLastPrice;
@end


/*! @brief 搜寻商品结果类
 */
@interface MSearchResultItem : MSearchBaseItem
/** 股票代码 */
@property (nonatomic, copy) NSString *stockID;
/** 股票名称 */
@property (nonatomic, copy) NSString *name;
/** 市场别 */
@property (nonatomic, copy) NSString *market;
/** 拼音 */
@property (nonatomic, copy) NSString *pinyin;
/** 次类别 */
@property (nonatomic, copy) NSString *subtype;
/** 股票代码(不含市场别) */
@property (nonatomic, copy) NSString *code;
@end

/*! @brief 分时成交
 *
 *  包含时、价、量、内外盘等分时数据，可用于显示分时明细画面。
 */
@interface MTickItem : MBaseItem
/** 时间 HHmmssff */
@property (nonatomic, readonly) NSString *time;
/** 时间 */
@property (nonatomic, copy) NSString *datetime __attribute__((deprecated("使用time4")));
/** 买进价 */
@property (nonatomic, copy) NSString *buyPrice;
/** 卖出价 */
@property (nonatomic, copy) NSString *sellPrice;
/** 最新价 */
@property (nonatomic, copy) NSString *tradePrice;
/** 量 */
@property (nonatomic, copy) NSString *tradeVolume;
/** 内外盘 */
@property (nonatomic, assign) MBSVolumeType type;
/** 港股AMS */
@property (nonatomic, assign) MTimeTickAMSFlag AMSFlag;

@end

@interface MTimeTickItem : MTickItem
/** 范围 */
@property (nonatomic, copy) NSString *sectionRange;
@end

@interface MTimeTickDetailItem : MTickItem
/** 索引 */
@property (nonatomic, copy) NSString *index;
@end

@interface MTickItem (Convenience)
/** 时间 HH:mm */
@property (nonatomic, readonly) NSString *time4;
/** 时间 HH:mm:ss */
@property (nonatomic, readonly) NSString *time6;
/** 时间 HH:mm:ss:ff */
@property (nonatomic, readonly) NSString *time8;
@end

/*! @brief 板块分类
 */
@interface MCategoryItem : MBaseItem
/** 分类代码 */
@property (nonatomic, copy) NSString *code;
/** 分类名 */
@property (nonatomic, copy) NSString *name;
@end

/*! @brief 经纪席位
 */
@interface MBrokerSeatItem : MBaseItem
/** 量 */
@property (nonatomic, copy) NSString *value;
/** 名称 */
@property (nonatomic, copy) NSString *name;
/** 完整名称 */
@property (nonatomic, copy) NSString *fullName;
@end


/*! @brief 分时成交
 *
 *  包含价、量数据，可用于显示分价量表画面。
 */
@interface MPriceVolumeItem : MBaseItem
/** 价 */
@property (nonatomic, copy) NSString *price;
/** 量 */
@property (nonatomic, copy) NSString *volume;
@end


/*! @brief 交易单明细
 *
 *  包含量数据，可用于显示买卖队列
 */
@interface MOrderQuantityItem : MBaseItem
/** 量 */
@property (nonatomic, copy) NSString *volume;
@end


/*! @brief 港股碎股资讯
 *
 *  包含订单编号、经纪人编号等信息
 */
@interface MHKOddInfoItem : MBaseItem
/** 订单编号 */
@property (nonatomic, copy) NSString *orderId;
/** 订单数量 */
@property (nonatomic, copy) NSString *orderQty;
/** 价格 */
@property (nonatomic, copy) NSString *price;
/** 经纪人编号 */
@property (nonatomic, copy) NSString *brokerId;
/** 买卖方向 */
@property (nonatomic, assign) MHKOddSide side;
/** 时间 */
@property (nonatomic, copy) NSString *datetime;
@end

/*! @brief 个股静态数据
 *
 *  包含个股所属板块信息、两市港股通标识、融资标识、融券标识
 */
@interface MStaticDataItem : MBaseItem
/** 所属板块信息 */
@property (nonatomic, strong) NSArray MAPI_OBJ_BOARD_INFO_TYPE *boardInfoItems;
/** 1为沪港通标识 默认为0*/
@property (nonatomic, assign) BOOL HFlag;
/** 1为深港通标识 默认为0*/
@property (nonatomic, assign) BOOL SFlag;
/** 1为融资标识 0源未下 ,默认为0*/
@property (nonatomic, assign) BOOL financeFlag;
/** 1为融券标识 0源未下 ,默认为0*/
@property (nonatomic, assign) BOOL securityFlag;
@end

/*! @brief 版块信息
 */
@interface MBoardInfoItem : MBaseItem
/** 版块名称 */
@property (nonatomic, copy) NSString *name;
/** 版块ID */
@property (nonatomic, copy) NSString *ID;
@end
