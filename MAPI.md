
<h1 id="top">移动行情客户端接口说明</h1>
================

* [概述](#概述)
	* [目的](#目的)
	* [形式说明](#形式说明)
	* [资源类别列表](#资源类别列表)
		* [辅助类别列表](#辅助类别列表)
		* [请求类别列表](#请求类别列表)
		* [应答类别列表](#应答类别列表)
		* [数据结构列表](#数据结构列表)
		* [错误代码列表](#错误代码列表)
		* [通知代码列表](#通知代码列表)
* [使用说明](#使用说明) 
	* [应用程序接口](#MApi)
		* [说明](#InitExplain)
		* [调用样例](#InitSample)
	* [取得全市场股票代码表](#MApi_downloadStockTableWithCompletionHandler)
		* [说明](#MApi_downloadStockTableWithCompletionHandlerExplain)
		* [调用样例](#MApi_downloadStockTableWithCompletionHandlerSample)
	* [股票报价订阅接口](#MApi_subscribeQuoteCode)
		* [说明](#MApi_subscribeQuoteCodeExplain)
		* [调用样例](#MApi_subscribeQuoteCodeSample)
	* [其他类方法](#MApi_ClassMethods)
		* [说明](#MApi_ClassMethodsExplain)
	* [版本检查](#MCheckVersion)
		* [说明](#MCheckVersionExplain)
		* [请求类(MCheckVersionRequest)](#MCheckVersionRequest)
		* [应答类(MCheckVersionResponse)](#MCheckVersionResponse)
		* [调用样例](#MCheckVersionSample)	
	* [获取资讯源类别](#MGetSource)
		* [说明](#MGetSourceExplain)
		* [请求类(MGetSourceRequest)](#MGetSourceRequest)
		* [应答类(MGetSourceResponse)](#MGetSourceResponse)
		* [调用样例](#MGetSourceSample	)
	* [获取行情分类](#MGetSourceClass)
		* [说明](#MGetSourceClassExplain)
		* [请求类(MGetSourceClassRequest)](#MGetSourceClassRequest)
		* [应答类(MGetSourceClassResponse)](#MGetSourceClassResponse)
		* [调用样例](#MGetSourceClassSample	)
	* [获取主选单分类](#MGetMenu)
		* [说明](#MGetMenuExplain)
		* [请求类(MGetMenuRequest)](#MGetMenuRequest)
		* [应答类(MGetMenuResponse)](#MGetMenuResponse)
		* [调用样例](#MGetMenuSample	)
	* [获取广告资讯](#MAdvert)
		* [说明](MAdvertExplain)
		* [请求类(MAdvertRequest)](#MAdvertRequest)
		* [应答类(MAdvertResponse)](#MAdvertResponse)
		* [调用样例](#MAdvertSample	)
	* [获取公告](#MAnnouncement)
		* [说明](MAnnouncementExplain)
		* [请求类(MAnnouncementRequest)](#MAnnouncementRequest)
		* [应答类(MAnnouncementResponse)](#MAnnouncementResponse)
		* [调用样例](#MAnnouncementSample	)
	* [证券行情列表](#Quote)
		* [说明](#QuoteExplain)
		* [请求类(MQuoteRequest)](#MQuoteRequest)
		* [应答类(MQuoteResponse)](#MQuoteResponse)
		* [调用样例](#QuoteSample)	
	* [行情快照](#QuoteSnap)
		* [说明](#QuoteSnapExplain)
		* [请求类(MSnapQuoteRequest)](#MSnapQuoteRequest)
		* [应答类(MSnapQuoteResponse)](#MSnapQuoteResponse)
		* [调用样例](#QuoteSnapSample)			
  	* [板块排行](#MSectionSorting)
	  * [说明](#MSectionSortingExplain)
	  * [请求类(MSectionSortingRequest)](#MSectionSortingRequest)
	  * [应答类(MSectionSortingResponse)](#MSectionSortingResponse)
	  * [调用样例](#MSectionSortingSample)
	* [指数分类即时行情列表](#MCategoryQuoteList)
	  * [说明](#MCategoryQuoteListExplain)
	  * [请求类(MCategoryQuoteListRequest)](#MCategoryQuoteListRequest)
	  * [应答类(MCategoryQuoteListResponse)](#MCategoryQuoteListResponse)
	  * [调用样例](#MCategoryQuoteListSample)
  * [分类排行](#MCategorySorting)
    * [说明](#MCategorySortingExplain)
	* [请求类(MCategorySortingRequest)](#MCategorySortingRequest)
	* [应答类(MCategorySortingResponse)](#MCategorySortingResponse)
	* [调用样例](#MCategorySortingSample)

   * [走势数据](#Chart)
		* [说明](#ChartExplain)
		* [请求类(MChartRequest)](#MChartRequest)
		* [应答类(MChartResponse)](#MChartResponse)
		* [调用样例](#ChartSample)
	* [K线数据](#OHLC)
		* [说明](#OHLCExplain)
		* [请求类(MOHLCRequest)](#MOHLCRequest)
		* [应答类(MOHLCResponse)](#MOHLCResponse)
		* [调用样例](#OHLCSample)
	* [经纪席位](#MBrokerSeat)
		* [说明](#MBrokerSeatExplain)
		* [请求类(MBrokerSeatRequest)](#MBrokerRequest)
		* [应答类(MBrokerSeatResponse)](#MBrokerResponse)
		* [调用样例](#MBrokerSample)
	* [股票查询](#Search)
		* [说明](#SearchExplain)
		* [请求类(MSearchRequest)](#MSearchRequest)
		* [应答类(MSearchResponse)](#MSearchResponse)
		* [调用样例](#SearchSample)
	* [期权-标的行情](#UnderlyingStock)
		* [说明](#UnderlyingStockExplain)
		* [请求类(MUnderlyingStockRequest)](#MUnderlyingStockRequest)
		* [应答类(MUnderlyingStockResponse)](#MUnderlyingStockResponse)
		* [调用样例](#UnderlyingStockSample)
	* [期权-交割月列表](#ExpireMonth)
		* [说明](#ExpireMonthExplain)
		* [请求类(MExpireMonthRequest)](#MExpireMonthRequest)
		* [应答类(MExpireMonthResponse)](#MExpireMonthResponse)
		* [调用样例](#ExpireMonthSample)
	* [期权-商品行情](#Option)
		* [说明](#OptionExplain)
		* [请求类(MOptionRequest)](#MOptionRequest)
		* [应答类(MOptionResponse)](#MOptionResponse)
		* [调用样例](#OptionSample)
	* [期权T型报价行情](#OptionT)
		* [说明](#TOptionExplain)
		* [请求类(MOptionTRequest)](#MOptionTRequest)
		* [应答类(MOptionResponse)](#MOptionResponse)
		* [调用样例](#TOptionSample)
	* [用户行为统计](#MEvent)
		* [说明](#MEventExplain)
		* [请求类(MEventRequest)](#MEventRequest)
		* [调用样例](#TOptionSample)
	* [股票分类代码表](#StockCategoryList)
		* [说明](#StockCategoryListExplain)
		* [请求类(MStockCategoryListRequest)](#MStockCategoryListRequest)
		* [应答类(MStockCategoryListResponse)](#MStockCategoryListResponse)
		* [调用样例](#StockCategoryListSample)
	* [分时明细表](#MTimeTick)
		* [说明](#MTimeTickExplain)
		* [请求类(MTimeTickRequest)](#MTimeTickRequest)
		* [应答类(MTimeTickResponse)](#MTimeTickResponse)
		* [调用样例](#MTimeTickSample)
	* [分价量表](#MPriceVolume)
		* [说明](#MPriceVolumeExplain)
		* [请求类(MPriceVolumeRequest)](#MPriceVolumeRequest)
		* [应答类(MPriceVolumeResponse)](#MPriceVolumeResponse)
		* [调用样例](#MPriceVolumeSample)
	* [买卖队列](#MOrderQuantity)
		* [说明](#MOrderQuantityExplain)
		* [请求类(MOrderQuantityRequest)](#MOrderQuantityRequest)
		* [应答类(MOrderQuantityResponse)](#MOrderQuantityResponse)
		* [调用样例](#MOrderQuantitySample)
	* [港股其他信息](#MHKQuoteInfo)
		* [说明](#MHKQuoteInfoExplain)
		* [请求类(MHKQuoteInfoRequest)](#MHKQuoteInfoRequest)
		* [应答类(MHKQuoteInfoResponse)](#MHKQuoteInfoResponse)
		* [调用样例](#MHKQuoteInfoSample)
	* [假日黑名单](#MMarketHoliday)
		* [说明](#MMarketHolidayExplain)
		* [请求类(MMarketHolidayRequest)](#MMarketHolidayRequest)
		* [应答类(MMarketHolidayResponse)](#MMarketHolidayResponse)
		* [调用样例](#MMarketHolidaySample)
	
	* [逐笔明细](#MTimeTickDetail)
		* [说明](#MTimeTickDetailExplain)
		* [请求类(MTimeTickDetailRequest)](#MTimeTickDetailRequest)
		* [应答类(MTimeTickDetailResponse)](#MTimeTickDetailResponse)
		* [调用样例](#MTimeTickDetailSample)  
	
	* [个股静态数据](#MStaticData)
		* [说明](#MStaticDataExplain)
		* [请求类(MStaticDataRequest)](#MStaticDataRequest)
		* [应答类(MStaticDataResponse)](#MStaticDataResponse)
		* [调用样例](#MStaticDataSample)
	
	* [两市港股通数据](#MHKMarketInfo)
		* [说明](#MHKMarketInfoExplain)
		* [请求类(MHKMarketInfoRequest)](#MHKMarketInfoRequest)
		* [应答类(MHKMarketInfoResponse)](#MHKMarketInfoResponse)
		* [调用样例](#MHKMarketInfoSample)

* [数据结构](#数据结构)
	* [股票行情(MStockItem)](#MStockItem)
	* [K线数据(MOHLCItem)](#MOHLCItem)
	* [分笔成交(MTickItem)](#MTickItem)
	* [分时成交(MTimeTickItem)](#MTimeTickItem)
	* [分时成交明细(MTimeTickDetailItem)](#MTimeTickDetailItem)
	* [分价量表(MPriceVolumeItem)](#MPriceVolumeItem)
	* [个股静态数据(MStaticDataItem)](#MStaticDataItem)
	* [版块信息(MBoardInfoItem)](#MBoardInfoItem)
	* [交易单明细(MOrderQuantityItem)](#MOrderQuantityItem)
	* [搜寻结果(MSearchResultItem)](#MSearchResultItem)
	* [板块分类(MCategoryItem)](#MCategoryItem)
	* [板块排行(MSectionRankingItem)](#MSectionRankingItem)
	* [经纪席位(MBrokerSeatItem)](#MBrokerSeatItem)
	* [期权-商品行情(MOptionItem)](#MOptionItem)
	* [港股碎股(MHKOddInfoItem)](#MHKOddInfoItem)

* 其他
	* [K线周期(MOHLCPeriod)](#MOHLCPeriod)
	* [K线复权(MOHLCPriceAdjustedMode)](#MOHLCPriceAdjustedMode)
	* [内外盘类别(MBSVolumeType)](#MBSVolumeType)
	* [走势类别(MChartType)](#MChartType)
	* [涨跌状态(MChangeState)](#MChangeState)
	* [期权类别(MOptionType)](#MOptionType)
	* [交易狀態代碼表(MStockStatus)](#MStockStatus)
	* [交易阶段代碼表(MStockStage)](#MStockStage)
	* [港股状态(MHKInfoStatus)](#MHKInfoStatus)
	* [港股交易明细旗标(MTimeTickAMSFlag)](#MTimeTickAMSFlag)
	* [排序代码栏位(MCategorySortingField)](#MCategorySortingField)
	* [港股碎股订单买卖方向(MHKOddSide)](#MHKOddSide)
	* [详细报价请求类别(MSnapQuoteRequestType)](#MSnapQuoteRequestType)
	* [分类代码(MCategoryID)](#MCategoryID)
	* [板块排行代码(MSectionRankingID)](#MSectionRankingID)
	* [分时明细请求类别(MTimeTickRequestType)](#MTimeTickRequestType)
	

* * *

<h2 id="概述">概述</h2>

<h3 id="目的">目的</h3>

* 本文档面向的读者是项目开发人员，其中详细描述了iOS系统之请求应答类别名与上下行参数的属性名称及型态。
* 如何通过行情客户端接口发送请求，进而获得行情数据，请至网页下载最新的[API Documentation](http://example.net/)或下载[Demo](http://example.net/)程式码。
* 接口实现了通讯、数据结构与缓存机制，故开发UI人员可以大量减少处理数据的代码与时间。

<h3 id="形式说明">形式说明</h3>

* 接口中的类名、属性名及方法名皆以驼峰式命名法，类名首字母皆为大写，属性及方法名首字母皆为小写。
* 由于iOS不支持命名空间，故类名皆冠上M来避免与工程上的其他类重复。

<h3 id="资源类别列表">资源类别列表</h3>

<h4 id="辅助类别列表">辅助类别列表</h4>

| 说明           | 类名 |        备注        |
|----------------|:----:|:------------------:|
| 应用程序接口类 | [MApi](#MApi) | 初始化、发送请求用 |

<h4 id="请求类别列表">请求类别列表</h4>

| 说明             | 类名                    | 备注 |
|------------------|-------------------------|------|
| 版本检查 | [MCheckVersionRequest](#MCheckVersionRequest)    |      |
| 获取资讯源类别 | [MGetSourceRequest](#MGetSourceRequest)    |      |
| 获取行情分类 | [MGetSourceClassRequest](#MGetSourceClassRequest)|
| 获取主选单分类 | [MGetMenuRequest](#MGetMenuRequest)    | |
| 获取广告资讯     | [MAdvertRequest](#MAdvertRequest)  |
| 获取公告     | [MAnnouncementRequest](#MAnnouncementRequest)  |
| 证券行情列表     | [MQuoteRequest](#MQuoteRequest) |      |
| 行情快照     | [MSnapQuoteRequest](#MSnapQuoteRequest) |      |
| 板块排行     | [MSectionSortingRequest](#MSectionSortingRequest) |      |
| 板块类别个股即時行情 | [MCategoryQuoteListRequest](#MCategoryQuoteListRequest) ||
| 分类排行     | [MCategorySortingRequest](#MCategorySortingRequest) |      |
| 走势数据         | [MChartRequest](#MChartRequest) |      |
| K线数据          | [MOHLCRequest](#MOHLCRequest) |      |
| 经纪席位         | [MBrokerSeatRequest](#MBrokerSeatRequest) |      |
| 股票查询         | [MSearchRequest](#MSearchRequest) |      |
| 期权-标的行情     | [MUnderlyingStockRequest](#MUnderlyingStockRequest) |      |
| 期权-交割月       | [MExpireMonthRequest](#MExpireMonthRequest) |      |
| 期权-商品行情         | [MOptionRequest](#MOptionRequest) |      |
| 期权-T型报价      | [MOptionTRequest](#MOptionTRequest) |      |
| 用户行为统计     | [MEventRequest](#MEventRequest) |      |
| 股票分类代码表     | [MStockCategoryListRequest](#MStockCategoryListRequest) |      |
| 个股静态数据     | [MStaticDataRequest](#MStaticDataRequest) |      |
| 两市港股通数据     | [MHKMarketInfoRequest](#MHKMarketInfoRequest) |      |

[top](#top)

<h4 id="应答类别列表">应答类别列表</h4>

| 说明             | 类名                     | 备注 |
|------------------|--------------------------|------|
| 版本检查 | [MCheckVersionResponse](#MCheckVersionResponse)   |      |
| 获取资讯源类别 | [MGetSourceResponse](#MGetSourceResponse)    |  |
| 获取行情分类 | [MGetSourceClassResponse](#MGetSourceClassResponse)|
| 获取主选单分类 | [MGetMenuResponse](#MGetMenuResponse)    | |
| 获取广告资讯     | [MAdvertResponse](#MAdvertResponse)  |
| 获取公告     | [MAnnouncementResponse](#MAnnouncementResponse)  |
| 证券行情列表     | [MQuoteResponse](#MQuoteResponse)           |      |
| 行情快照     | [MSnapQuoteResponse](#MSnapQuoteResponse)       |      |
| 板块排行     | [MSectionSortingResponse](#MSectionSortingResponse) |      |
| 板块类别个股即時行情 | [MCategoryQuoteListResponse](#MCategoryQuoteListResponse) ||
| 分类排行     | [MCategorySortingResponse](#MCategorySortingResponse) |      |
| 走势数据         | [MChartResponse](#MChartResponse)           |      |
| K线数据          | [MOHLCResponse](#MOHLCResponse)            |      |
| 经纪席位         | [MBrokerSeatResponse](#MBrokerSeatResponse)      |      |
| 股票查询         | [MSearchResponse](#MSearchResponse)          |      |
| 板块分类         | [MCategoryListResponse](#MCategoryListResponse)    |      |
| 期权-标的行情     | [MUnderlyingStockResponse](#MUnderlyingStockResponse) |      |
| 期权-交割月       | [MExpireMonthResponse](#MExpireMonthResponse)     |      |
| 期权-商品行情         | [MOptionResponse](#MOptionResponse)          |      |
| 期权-T型报价      | [MOptionResponse](#MOptionResponse)         |      |
| 股票分类代码表     | [MStockCategoryListResponse](#MStockCategoryListResponse) |      |
| 个股静态数据     | [MStaticDataResponse](#MStaticDataResponse) |      |
| 两市港股通数据     | [MHKMarketInfoResponse](#MHKMarketInfoResponse) |      |

[top](#top)

<h4 id="数据结构列表">数据结构列表</h4>

| 说明             | 类名                 | 备注 |
|------------------|----------------------|------|
| 股票模型         | [MStockItem](#MStockItem)           |      |
| 分笔成交模型     | [MTickItem](#MTickItem)            |      |
| 历史数据结构     | [MOHLCItem](#MOHLCItem)            |      |
| 搜寻结果模型     | [MSearchResultItem](#MSearchResultItem)    |      |
| 板块分类模型     | [MCategoryItem](#MCategoryItem)        |      |
| 板块排行模型     | [MSectionRankingItem](#MSectionRankingItem)  |      |
| 期权-商品行情模型     | [MOptionItem](#MOptionItem)          |      |

[top](#top)

<h4 id="错误代码列表">错误代码列表</h4>

| 说明             | 列举名                 | 备注 |
|------------------|----------------------|------|
| 请求成功        | MResponseStatusSuccess | 200 |
| session失效    | MResponseStatusSessionExpired | 401 |
| 请求失败        | MResponseStatusNoData | 404 |
| 股票代码数量超过限制        | MResponseStatusOverLimit | 444 |
| 业务异常        | MResponseStatusServerError | 500 |
| 网关错误        | MResponseStatusBadGateway | 502 |
| 请求逾时        | MResponseStatusTimeout | -1001 |
| 无法连结到主机   | MResponseStatusNotReachabled | -1002 |
| 应答信息处理失败  | MResponseStatusDataParseError | -1003 |
| 服务器无应答信息  | MResponseStatusDataNil | -1004 |
| 参数错误        | MResponseStatusParameterError | -1005 |
| 认证审计错误     | MResponseStatusCertificationAuditError | -2001 |

[top](#top)

<h4 id="通知代码列表">通知代码列表</h4>

| 说明             | 通知名称                 | 通知信息 |
|------------------|----------------------|------|
| 行情源切换通知  | MApiSourceLevelChangedNotification |[行情源切换通知信息](#行情源切换通知信息) |

<h4 id="行情源切换通知信息">行情源切换通知信息</h4>

| 键值      | 说明         | 型态         | 备注  |
|-------------|-----------|--------------|------|
| MApiSourceLevelChangedToKey | 行情源切换通知：切换方向 | MApiSourceLevel | 当值为1（MApiSourceLevel1）时表示切换到MApiSourceLevel1 |
| MApiSourceLevelChangedMarketKey | 行情源切换通知：市场别 | NSString | 如：sh|


[top](#top)


<h2 id="使用说明">使用说明</h2>

<h3 id="MApi">应用程序接口</h3>

<h4 id="InitExplain">说明</h4>

* 初始化方法说明:

	`+ (void)registerAPP:(NSString *)appkey completionHandler:(void (^)(NSError *error))handler;`
	
		* MApi的成员函数，与服务器注册接口的使用许可。
		* appkey: 许可键值。
		* error: 注册失败错误对象。
		
	`+ (void)registerAPP:(NSString *)appkey sourceLevel:(MApiSourceLevel)sourceLevel completionHandler:(void (^)(NSError *error))handler;`

		* MApi的成员函数，与服务器注册接口的使用许可。
		* sourceLevel: 行情源类别。
			1. MApiSourceLevel1 (默认)
			2. MApiSourceLevel2
		* appkey: 许可键值。
		* error: 注册失败错误对象。

	`+ (void)registerAPP:(NSString *)appkey withOptions:(NSDictionary *)options completionHandler:(void (^)(NSError *error))handler;`

		* MApi的成员函数，与服务器注册接口的使用许可。
		* options: 配置参数，如：@{MApiRegisterOptionGetServerPoolingTimeKey:@60};
		* appkey: 许可键值。
		* error: 注册失败错误对象。
	备注：更多配置见 [注册配置键值表](#RegisterOptionsKey)

* 发送方法说明:
		
	`+ (void)sendRequest:(MRequest *)request completionHandler:(MApiCompletionHandler)handler;`
	
		* 发送请求至行情服务器。
		* request: 具体的发送对象。
		* handler: 回调函式(返回回应内容对象)。

* 取消请求方法:
		
	`+ (void)cancelAllRequests`
	
		* 取消所有请求。
		
	`+ (void)cancelRequest:(MRequest *)request;`
	
		* 取消某个请求。

	`+ (void)cancelRequest_ptr:(MRequest *)request;`
	
		* 取消某个请求。

* 清除缓存方法:
		
	`+ (void)clearCache`
	
		* 支持部分行情缓存，调用此方法可清除所有缓存数据，释放内存及硬盘空间。

* 获取缓存大小方法:
		
	`+ (unsigned long long)num_CacheSize;`
	
		*  此库支持部分行情缓存，调用此方法可获取当前缓存使用量。
 		*  返回单位:Byte。

* 获取网络状态方法:
		
	`+ (MApiNetworkStatus)networkStatus;`
	
		*  调用此方法可获取当前装置的网路状态。
 		*  返回值
			*  MApiNotReachable,
    			*  MApiReachableViaWiFi,
    			*  MApiReachableViaWWAN

* 获取市场资讯方法:
		
	`+ (MMarketInfo *)marketInfoWithMarket:(NSString *)market subtype:(NSString *)subtype;`
	
		*  若欲查询股票的市场资讯(包含小数位数、开收盘时间等信息)，可调用此方法。
 		*  market:市场别 可见 MStockItem类的market。
		*  subtype:次类别 可见 MStockItem类的subtype。

* 获取市场交易日:
		
	`+ (NSDictionary *)fetchMarketLastestTradeDays;`
	
		*  取得各个市场最新交易日期数组。

* 获取全市场股票代码表:
		
	`+ (MStockTableRequest *)downloadStockTableWithCompletionHandler:(void (^)(NSError *error))handler;`
	
		*  下载全市场股票代码列表到本地
		*  说明：此处不会返回股票代码列表，可以发送MStockTableRequest请求获取股票代码列表。

* 获取当前版本信息:
		
	`+ (NSString *)version;`
	
* 获取注册的行情源:
		
	`+ (MApiSourceLevel)sourceLevel;`
	

* 获取当前某市场行情源类别:
		
	`+ (MApiSourceLevel)sourceLevelWithMarket:(NSString *)market;`
	
		*  market:sh 或 sz 或 hk

* 订阅股票:
		
	`+ (void)subscribeQuoteCode:(NSString *)code didReceiveUpdate:(MApiTcpReceiveBlock)didReceiveUpdate;`
	
* 取消订阅股票:
		
	`+ (void)unsubscribeQuoteCode:(NSString *)code;`

		*  取消某只股票的订阅
	
	`+ (void)unsubscribeAllQuoteCode;`

		*  取消所有股票的订阅

* 更新服务器列表:
		
	`+ (void)checkServerList;`

		*  若要更新当前服务器列表，可调用此方法

<h4 id="InitSample">调用样例</h4>	

	- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
		//初始化接口
    	[MApi registerAPP:@"anAppKey"completionHandler:^(NSError *error) {
			if(!error) {
            	[self initialCompleted];
        	} else {
            	[Utility alertMessage:[error localizedDescription]];
        	}
    	}];
		returnYES;
	}
	
[top](#top)	
	
<h3 id="MApi_downloadStockTableWithCompletionHandler">取得全市场股票代码表</h3>

<h4 id="MApi_downloadStockTableWithCompletionHandlerExplain">说明</h4>

* 下载代码表方法说明:

	`+ (void)downloadStockTableWithCompletionHandler:(void (^)(NSError *error))handler;`
	
		* MApi的成员函数，向服务器请求股票代码表，即可使用本地搜索功能。
		* error: 获取失败错误对象。

<h4 id="MApi_downloadStockTableWithCompletionHandlerSample">调用样例</h4>	

    [MApi downloadStockTableWithCompletionHandler:^(NSError *error) {
		if (!error) {
			// 进入搜索页
		}
    }];
	
[top](#top)


<h3 id="MApi_subscribeQuoteCode">股票报价订阅接口</h3>

<h4 id="MApi_subscribeQuoteCodeExplain">说明</h4>

* 订阅方法说明:

	`+ (void)subscribeQuoteCode:(NSString *)code didReceiveUpdate:(MApiTcpReceiveBlock)didReceiveUpdate;`
	
		* MApi的成员函数，向服务器建立TCP长连接请求股票行情，即可接收服务端PUSH之行情报价。
		* code: 股票代码，用逗号（,）分隔。
		* didReceiveUpdate: 接收信息的回调函式。

* 解订阅方法说明:

	`+ (void)unsubscribeQuoteCode:(NSString *)code;`
	
		* MApi的成员函数，向服务器取消订阅行情报价。
		* code: 股票代码，用逗号（,）分隔。
		
	`+ (void)unsubscribeAllQuoteCode;`
	
		* MApi的成员函数，向服务器取消订阅行情报价。

<h4 id="MApi_subscribeQuoteCodeSample">调用样例</h4>	
     
	/// 订阅股票
    [MApi subscribeQuoteCode:@"000001.sh,600000.sh" didReceiveUpdate:^(NSString *code, MApiTcpUpdateBlock update) {    
        for (MStockItem *item in self.items) {
            if ([item.ID isEqualToString:code]) {
                update(item);
                break;
            }
        }
        [self reloadData];
    }];
	
	/// 取消订阅
	[MApi unsubscribeAllQuoteCode];
	
[top](#top)

	
<h3 id="MApi_ClassMethods">其他类方法</h3>

<h4 id="MApi_ClassMethodsExplain">说明</h4>

* 获取某市场别行情源类别说明:

	`+ (MApiSourceLevel)sourceLevelWithMarket:(NSString *)market;`
	
		* MApi的成员函数，若要知道某市场别当前使用的行情源，可以调用此方法。
		* market: 市场别，如：sh或sz或hk。

* 更新服务器列表说明:

	`+ (void)checkServerList;`
	
		* MApi的成员函数，若要更新当前服务器列表，可调用此方法。
		
	
[top](#top)

	
<h3 id="MCheckVersion">版本检查</h3>

<h4 id="MCheckVersionExplain">说明</h4>

* 从服务器取得最新版本资讯,其中包含最新版本号与最新版本下载位址等

<h4 id="MCheckVersionRequest">请求类：MCheckVersionRequest</h4>

* 属性说明:

	無
	
	
<h4 id="MCheckVersionResponse">应答类：MCheckVersionResponse</h4>

* 属性说明

	| 属性名      | 说明         | 型态         | 备注 |
	|-------------|--------------|--------------|------|
	| versionInfo | 最新版本资讯 | NSDictionary |      |
	| versionStatus | 检核状态 | NSString |   0:提示更新 1:强制更新 2:强制退出   |
	| downloadURLString | 下载网址 | NSString |      |
	| checkVersionDescription | 更新叙述 | NSString |      |
	| version | 最新版本号 | NSString |      |				

<h4 id="MCheckVersionSample">调用样例</h4>	
	//请求版本资讯
	MCheckVersionRequest *request = [[MCheckVersionRequest alloc] init];

	//发送请求
	[MApi sendRequest:request completionHandler:^(MResponse *resp) {
		if (resp.status == ResponseStatusSuccess) {
			MCheckVersionResponse *response = (MCheckVersionResponse *)resp;
			self.versionInfo = response.versionInfo;
			if (![self isNewestVersion:response.versionInfo[@"ver"]]) {
			[self updata];
			
		} else {
			//应答错误，显示错误信息
			[Utility alertMessage:resp.message];
		}
	}];

[top](#top)

<h3 id="MGetSource">获取资讯源类别</h3>

<h4 id="MGetSourceExplain">说明</h4>

* 获取资讯源类别, 举例:hkl2:港股Level2, hk:港股Level1, sh:上証...等资讯源类别

<h4 id="MGetSourceRequest">请求类：MGetSourceRequest</h4>

* 属性说明:

	無
	
	
<h4 id="MGetSourceResponse">应答类：MGetSourceResponse</h4>

* 属性说明

	| 属性名      | 说明         | 型态         | 备注 |
	|-------------|--------------|--------------|------|
	| sourceInfos | 资讯源类别 | NSDictionary   |{ "src":[{ "type":" hk" }, { "type":"hkl2" }, { "type":"sh" }]} 


<h4 id="MGetSourceSample">调用样例</h4>	
	//获取资讯源类别
	MGetSourceRequest *request = [[MGetSourceRequest alloc] init];

	//发送请求
	[MApi sendRequest:request completionHandler:^(MResponse *resp) {
		if (resp.status == ResponseStatusSuccess) {
			//应答无误，处理数据更新画面
			MGetSourceResponse *response = (MGetSourceResponse *)resp;
			self.sourceInfos = response.sourceInfos;
			[self reloadData];
			
		} else {
			//应答错误，显示错误信息
			[Utility alertMessage:resp.message];
		}
	}];

[top](#top)

<h3 id="MGetSourceClass">获取行情分类</h3>

<h4 id="MGetSourceClassExplain">说明</h4>

* 取得各市场行情的分类列表:如沪深市场又区分沪深A股、上证A股等,港股分港股通、AH股等

<h4 id="MGetSourceClassRequest">请求类：MGetSourceClassRequest</h4>

* 属性说明:

	無
	
	
<h4 id="MGetSourceClassResponse">应答类：MGetSourceClassResponse</h4>

* 属性说明

	| 属性名      | 说明         | 型态         | 备注 |
	|-------------|--------------|--------------|------|
	| sourceClassInfos | 各市场分类类别 | NSDictionary |      |

	   	{ 
		"class": [ 
	 		{
            "n": "沪深市场",
            "m": [
                {
                    "t": "cateranking",
                    "s": "SHSZ1001",
                    "n": "沪深A股"
                },
                {
                    "t": "cateranking",
                    "s": "SH1001",
                    "n": "上证A股"
                },
                {
                    "t": "cateranking",
                    "s": "SZ1001",
                    "n": "深证A股"
                },
                {
                    "t": "cateranking",
                    "s": "SZ1004",
                    "n": "创业板"
                },
                {
                    "t": "cateranking",
                    "s": "SHSZ1400",
                    "n": "大盘指数"
                },
                {
                    "t": "cateranking",
                    "s": "SH1400",
                    "n": "上海指数"
                },
                {
                    "t": "cateranking",
                    "s": "SZ1400",
                    "n": "深圳指数"
                },
                {
                    "t": "cateranking",
                    "s": "SH1002",
                    "n": "上证B股"
                },
                {
                    "t": "cateranking",
                    "s": "SZ1002",
                    "n": "深证B股"
                },
                {
                    "t": "cateranking",
                    "s": "SH1100",
                    "n": "上证基金"
                },
                {
                    "t": "cateranking",
                    "s": "SZ1100",
                    "n": "深证基金"
                },
                {
                    "t": "cateranking",
                    "s": "SH1300",
                    "n": "上证债券"
                },
                {
                    "t": "cateranking",
                    "s": "SZ1300",
                    "n": "深证债券"
                }
            ]
        },
        {
            "n": "板块",
            "m": [
                {
                    "t": "bankuairanking",
                    "s": "Trade",
                    "n": "行业板块"
                },
                {
                    "t": "bankuairanking",
                    "s": "Notion",
                    "n": "概念板块"
                },
                {
                    "t": "bankuairanking",
                    "s": "Area",
                    "n": "地域板块"
                }
            ]
        },
        {
            "n": "沪港通",
            "m": [
                {
                    "t": "cateranking",
                    "s": "SHTone",
                    "n": "沪股通"
                },
                {
                    "t": "cateranking",
                    "s": "HKTone",
                    "n": "港股通"
                },
                {
                    "t": "cateranking",
                    "s": "HKAH",
                    "n": "AH股"
                }
            ]
        },
        {
            "n": "期权",
            "m": [
                {
                    "t": "cateranking",
                    "s": "SH3002",
                    "n": "上证期权"
                }
            ]
        },
        {
            "n": "港股",
            "m": [
                {
                    "t": "cateranking",
                    "s": "HKTone",
                    "n": "港股通"
                },
                {
                    "t": "cateranking",
                    "s": "HKAH",
                    "n": "AH股"
                },
                {
                    "t": "cateranking",
                    "s": "HKRed",
                    "n": "红筹股"
                },
                {
                    "t": "cateranking",
                    "s": "HKBlue",
                    "n": "蓝筹股"
                },
                {
                    "t": "cateranking",
                    "s": "HK1000",
                    "n": "主版"
                },
                {
                    "t": "cateranking",
                    "s": "HK1004",
                    "n": "创业板"
                },
                {
                    "t": "cateranking",
                    "s": "HKNationCom",
                    "n": "国企股"
                }]
        	}]
		}

<h4 id="MGetSourceClassSample">调用样例</h4>	
	//获取行情分类
	MGetSourceClassRequest *request = [[MGetSourceClassRequest alloc] init];

	//发送请求
	[MApi sendRequest:request completionHandler:^(MResponse *resp) {
		if (resp.status == ResponseStatusSuccess) {
			//应答无误，处理数据更新画面
			MGetSourceClassResponse *response = (MGetSourceClassResponse *)resp;
			self.sourceClassInfos = response.sourceClassInfos;
			[self reloadData];
			
		} else {
			//应答错误，显示错误信息
			[Utility alertMessage:resp.message];
		}
	}];
[top](#top)
<h3 id="MGetMenu">获取主选单分类</h3>

<h4 id="MGetMenuExplain">说明</h4>

* 取得主选单的功能列表

<h4 id="MGetMenuRequest">请求类：MGetMenuRequest</h4>

* 属性说明:

	無
	
	
<h4 id="MGetMenuResponse">应答类：MGetMenuResponse</h4>

* 属性说明

	| 属性名      | 说明         | 型态         | 备注 |
	|-------------|--------------|--------------|------|
	| menuDictionary | 主选单功能列表 | NSDictionary |   { "menu":[{ "id":" 1", "name":"财经新闻" }, { "id":" 2", "name":"自选股" }, { "id":"3", "name":"大盘指数" }] }   |

<h4 id="MGetMenuSample">调用样例</h4>	
	//请求主选单功能列表
	MGetMenuRequest *request = [[MGetMenuRequest alloc] init];

	//发送请求
	[MApi sendRequest:request completionHandler:^(MResponse *resp) {
		if (resp.status == ResponseStatusSuccess) {
			//应答无误，处理数据更新画面
			MGetMenuResponse *response = (MGetMenuResponse *)resp;
			self.menuDictionary = response.menuDictionary;

			[self reloadData];
			
		} else {
			//应答错误，显示错误信息
			[Utility alertMessage:resp.message];
		}
	}];

[top](#top)

<h3 id="MAdvert">获取广告资讯</h3>

<h4 id="MAdvertExplain">说明</h4>

* 从服务器取得广告轮拨资讯和重点资讯列表

<h4 id="MAdvertRequest">请求类：MAdvertRequest</h4>

* 属性说明:

	| 属性名  | 说明 | 型态 | 备注 |
	|--------|------|------|------|
	|advertKey |广告Key|NSString| 可为空取回所有广告资讯列表|
	
<h4 id="MAdvertResponse">应答类：MAdvertResponse</h4>

* 属性说明

	| 属性名      | 说明         | 型态         | 备注 |
	|-------------|--------------|--------------|------|
	| advertDictionary | 分类列表 | NSDictionary |      |
	
        {  marketing : 
		 	( 
		 		{ items : 
		 			({ 
						click : "http://114.80.155.142:22018/upload/html/20150916101910796/index.html";
				        image : "http://114.80.155.142:22018/upload/image/2015040803.png";
             			title : "\U4e91\U5e73\U53f0\U5168\U9762\U516c\U7248\U6d4b\U8bd5";
		                type : image;
                	},
                	{
                    	click : "http://114.80.155.142:22018/upload/html/20150916101910796/index.html";
                    	image : "http://114.80.155.142:22018/upload/image/2015040801.png";
                    	title : "\U4e91\U5e73\U53f0\U5168\U9762\U516c\U7248\U6d4b\U8bd5";
                    	type : image;
                	});
            	  loc : 01;
        		},
                { items :             
                	({
                    	click : "http://114.80.155.142:22018/upload/html/20150916101941687/index.html";
                    	image : "http://114.80.155.142:22018/upload/image/2015042600.png";
                    	title : "\U79fb\U52a8\U8bc1\U5238\U6807\U51c6\U7248\U4ecb\U7ecd";
                    	type : list;
                	},
                   {
                    	click : "http://114.80.155.142:22018/upload/html/20150916102015548/index.html";
                    	image : "http://114.80.155.142:22018/upload/image/2015042600.png";
                    	title : "\U79fb\U52a8\U8bc1\U5238\U63a5\U53e3\U7248\U4ecb\U7ecd";
                    	type : list;
                	});
            	loc : 02;
         		}
        	);
       	}

<h4 id="MAdvertSample">调用样例</h4>	
	//请求广告资讯
	MAdvertRequest *request = [[MAdvertRequest alloc] init];

	//发送请求
	[MApi sendRequest:request completionHandler:^(MResponse *resp) {
		if (resp.status == ResponseStatusSuccess) {
			//应答无误，处理数据更新画面
			MAdvertResponse *response = (MAdvertResponse *)resp;
			self.advertDictionary = response.advertDictionary;
			[self reloadData];
			
		} else {
			//应答错误，显示错误信息
			[Utility alertMessage:resp.message];
		}
	}];

[top](#top)

<h3 id="MAnnouncement">获取公告</h3>

<h4 id="MAdvertExplain">说明</h4>

* 从服务器获取公告

<h4 id="MAnnouncementRequest">请求类：MAnnouncementRequest</h4>

* 属性说明:

	無
	
<h4 id="MAnnouncementResponse">应答类：MAnnouncementResponse</h4>

* 属性说明

	| 属性名      | 说明         | 型态         | 备注 |
	|-------------|--------------|--------------|------|
	| announcementTitle | 公告标题 | NSString |      |
	| announcementContent | 公告內容 | NSString |      | 
	| announcementDatetime | 公告时间 | NSString |      | 		

<h4 id="MAnnouncementSample">调用样例</h4>	
	MAnnouncementRequest *request = [[MAnnouncementRequest alloc] init];

	//发送请求
	[MApi sendRequest:request completionHandler:^(MResponse *resp) {
		if (resp.status == ResponseStatusSuccess) {
			//应答无误，处理数据更新画面
                MAnnouncementResponse *announcementResponse = (MAnnouncementResponse *)resp;
                if (announcementResponse.announcementTitle && announcementResponse.announcementContent) {
                    [[[UIAlertView alloc] initWithTitle:announcementResponse.announcementTitle message:announcementResponse.announcementContent delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil] show];
                }
			
		} else {
			//应答错误，显示错误信息
			[Utility alertMessage:resp.message];
		}
	}];

[top](#top)

<h3 id="Quote">证券行情列表</h3>

<h4 id="QuoteExplain">说明</h4>

* 通过设置股票代码可获取该股票的行情数据，股票代码支持多笔，若异查询多行股票行情，可用逗号隔开，例如:600000.sh,600600.sh。

<h4 id="MQuoteRequest">请求类：MQuoteRequest</h4>

* 属性说明:

	| 属性名 | 说明     | 型态     | 备注 |
	|--------|----------|----------|------|
	| code   | 股票代码 | NSString |      |
	
<h4 id="MQuoteResponse">应答类：MQuoteResponse</h4>

* 属性说明

	| 属性名     | 说明     | 型态    | 备注                             	|
	|------------|----------|---------|----------------------------------|
	| stockItems | 股票列表 | NSArray | 股票列表中的对象请参考[MStockItem](#MStockItem)|

<h4 id="QuoteSample">调用样例</h4>	
	//请求股票行情
	MQuoteRequest *request = [[MQuoteRequest alloc] init];
	request.code = symbols; //填入股票代码

	//发送请求
	[MApi sendRequest:requestcompletionHandler:^(MResponse *resp) {
		if (resp.status == ResponseStatusSuccess) {
			//应答无误，处理数据更新画面
			MQuoteResponse *response = (MQuoteResponse *)resp;
			self.stockItems = response.stockItems;
			[self reloadData];
		} else {
			//应答错误，显示错误信息
			[Utility alertMessage:resp.message];
		}
	}];

[top](#top)

<h3 id="QuoteSnap">行情快照</h3>

<h4 id="QuoteSnapExplain">说明</h4>

* 可获得股票(包含指数、期权)全部行情字段、五档、最新十笔交易明细。
* 若送出的股票代码为期权商品，应答类的stockItem对象的形态为MOptionItem。
* 若送出的股票代码为指数商品，应答类的stockItem对象会包含涨停、跌停及平盘家数。

<h4 id="MSnapQuoteRequest">请求类：MSnapQuoteRequest</h4>

* 属性说明:

	| 属性名 | 说明                   | 型态     | 备注 |
	|--------|------------------------|----------|------|
	| code   | 股票代码(只可单笔查询) | NSString |      |
	| tickCount   | 明细条数 | NSInteger |      |
	| type   | 请求类别 | [MSnapQuoteRequestType](#MSnapQuoteRequestType) |      |

	
<h4 id="MSnapQuoteResponse">应答类：MSnapQuoteResponse</h4>

* 属性说明

	| 属性名    | 说明         | 型态       | 备注 |
	|-----------|--------------|------------|------|
	| stockItem | 快照行情  | [MStockItem](#MStockItem) | 根据市场别不同，期权商品为[MOptionItem](#MOptionItem) |
	| orderQuantityBuyItems | 买卖队列买盘 | NSArray |  |
	| orderQuantitySellItems | 买卖队列卖盘 | NSArray |  |
	| buyBrokerSeatItems | 经济席位买盘 | NSArray |  |
	| sellBrokerSeatItems | 经济席位买盘 | NSArray |  |

<h4 id="MSnapQuoteSample">调用样例</h4>

	 //请求快照行情
    MSnapQuoteRequest *request = [[MSnapQuoteRequest alloc] init];
    request.code = self.stockItem.ID; //填入股票代码
    request.type = MSnapQuoteRequestType1;
    request.tickCount = 50;
    //发送请求
    [MApi sendRequest:request completionHandler:^(MResponse *resp) {
        if(resp.status == MResponseStatusSuccess) {
            //应答无误，处理数据更新画面
            MSnapQuoteResponse *response = (MSnapQuoteResponse *)resp;
            self.stockItem = response.stockItem;
            [self reloadData];
        } else {
            //应答错误，显示错误信息            
            [Utility alertMessage:resp.message];
        }
    }];

[top](#top)    
    
<h3 id="MSectionSorting">板块排行</h3>

<h4 id="MSectionSortingExplain">说明</h4>

* 可获得板块排行列表。

<h4 id="MSectionSortingRequest">请求类：MSectionSortingRequest</h4>

* 属性说明:

	| 属性名    | 说明     | 型态     | 备注 |
	|-----------|----------|----------|------|
	| code      | 板块代码 | NSString | 板块代码请参考[MSectionRankingID](#MSectionRankingID) |
	| pageIndex | 页码     | NSString |      |
	| pageSize | 资料笔数     | NSInteger |      |
	| ascending | 是否为升序     | BOOL |      |
	| field | 排序栏位     | MSectionSortingField |  排序栏位请参考[MSectionSortingField](#MSectionSortingField)  |

	
<h4 id="MSectionSortingResponse">应答类：MSectionSortingResponse</h4>

* 属性说明

	| 属性名              | 说明         | 型态    | 备注 |
	|---------------------|--------------|---------|------|
	| sectionSortingItems | 板块排行列表 | NSArray |  板块排行列表中的对象请参考[MSectionSortingItem](#MSectionSortingItem)    |

<h4 id="MSectionSortingSample">调用样例</h4>

	 //请求板块排行
    MSectionSortingRequest *request = [[MSectionSortingRequest alloc] init];
    request.code = @"Trade"; //填入板块代码
    request.pageIndex = 0;
    request.pageSize = 20;

    //发送请求
    [MApi sendRequest:request completionHandler:^(MResponse *resp) {
        if(resp.status == MResponseStatusSuccess) {
            //应答无误，处理数据更新画面
            MSectionSortingResponse *response = (MSectionSortingResponse *)resp;
            self.sectionSortingItems = response.sectionSortingItems;
            [self reloadData];
        } else {
            //应答错误，显示错误信息
            [Utility alertMessage:resp.message];
        }
        [self removeRequest:request];
    }];

[top](#top)    

    
<h3 id="MCategoryQuoteList">版块类股票行情</h3>

<h4 id="MCategoryQuoteListExplain">说明</h4>

* 可获得板块类别个股即時行情。

<h4 id="MCategoryQuoteListRequest">请求类：MCategoryQuoteListRequest</h4>

* 属性说明:

	| 属性名    | 说明     | 型态     | 备注 |
	|-----------|----------|----------|------|
	| categoryID  | 分类代码 | NSString | 分类代码请参考[MCategoryID](#MCategoryID) |
	| pageIndex  | 页次 | NSInteger |      |

	
<h4 id="MCategoryQuoteListResponse">应答类：MCategoryQuoteListResponse</h4>

* 属性说明

	| 属性名              | 说明         | 型态    | 备注 |
	|---------------------|--------------|---------|------|
	| categoryQuoteItems | 分类即时列表 | NSArray |   版块类股票行情中的对象请参考[MStockItem](#MStockItem)   |

<h4 id="MCategoryQuoteListSample">调用样例</h4>

	 //请求板块类别个股即時列表
    MCategoryQuoteListRequest *request = [[MCategoryQuoteListRequest alloc] init];
    request.categoryID = @"SHSZ1001";  
    request.pageIndex = self.pageIndex;

    //发送请求
    [MApi sendRequest:request completionHandler:^(MResponse *resp) {
        if(resp.status == MResponseStatusSuccess) {
            //应答无误，处理数据更新画面
            MCatequoteResponse *response = (MCatequoteResponse *)resp;
            self.stockItem = response.stockItem;
            [self reloadData];
        } else {
            //应答错误，显示错误信息
            [Utility alertMessage:resp.message];
        }
        [self removeRequest:request];
    }];

[top](#top)
  
<h3 id="MCategorySorting">分类排行</h3>

<h4 id="MCategorySortingExplain">说明</h4>

* 可获得分类排行列表。

<h4 id="MCategorySortingRequest">请求类：MCategorySortingRequest</h4>

* 属性说明:

	| 属性名    | 说明     | 型态     | 备注 |
	|-----------|----------|----------|------|
	| code      | 分类代码 | NSString | 分类代码请参考[MCategoryID](#MCategoryID) |
	| pageIndex | 页码     | NSInteger |      |
	| pageSize | 资料笔数     | NSInteger |      |
	| ascending | 是否为升序     | BOOL |      |
	| field | 排序栏位     | MCategorySortingField |  排序栏位请参考[MCategorySortingField](#MCategorySortingField)  |
	| includeSuspension | 是否包含停牌股     | BOOL |      |
	
<h4 id="MCategorySortingResponse">应答类：MCategorySortingResponse</h4>

* 属性说明

	| 属性名     | 说明         | 型态    | 备注 |
	|------------|--------------|---------|------|
	| stockItems | 股票区块列表 | NSArray |  分类跌幅排中的对象请参考[MStockItem](#MStockItem)    |

<h4 id="MCategorySortingSample">调用样例</h4>

	 //请求排行数据
     MCategorySortingRequest *request =[[MCategorySortingRequest alloc] init];
     request.code = @"allstocks"; //查询全部股票
     request.pageIndex = 0; //第一页
     request.ascending = YES;
     request.field = MCategorySortingFieldChangeRate; // 涨跌幅排序
     
     //请求分类排行数据
     [MApi sendRequest:request completionHandler:^(MResponse *resp) {
         if(resp.status == MResponseStatusSuccess) {
             //应答无误，处理数据更新画面
             if ([resp respondsToSelector:@selector(stockItems)]) {
                 self.items = [resp valueForKeyPath:@"stockItems"];
             }
             else if ([resp respondsToSelector:@selector(sectionRankingItems)]) {
                 self.items = [resp valueForKeyPath:@"sectionRankingItems"];
             }
             [self reloadData];
         } else {
             //应答错误，显示错误信息
             [Utility alertMessage:resp.message];
         }
     }];
  
[top](#top) 
  
  
<h3 id="Chart">走势数据</h3>

<h4 id="ChartExplain">说明</h4>

* 可获得当日及五日走势数据。

<h4 id="MChartRequest">请求类：MChartRequest</h4>

* 属性说明:

	| 属性名    | 说明     | 型态       | 备注 |
	|-----------|----------|------------|------|
	| code      | 股票代码 | NSString   |      |
	| subtype   | 次类别   | NSString   |      |
	| chartType | 走势类别 | [MChartType](#MChartType) |      |
	
<h4 id="MChartResponse">应答类：MChartResponse</h4>

* 属性说明

	| 属性名     | 说明                                           | 型态    | 备注                            |
	|------------|------------------------------------------------	|---------|---------------------------------|
	| OHLCItems  | 走势数据列表                                   | NSArray | 走势数据列表中的对象：[MOHLCItem](#MOHLCItem) |
	| tradeDates | 交易日，若五日则有五个交易日、若分时则显示当日 | NSArray |                                 |

<h4 id="ChartSample">调用样例</h4>

	//请求当日走势
	MChartRequest *request = [[MChartRequestalloc] init];
    request.code = self.stockItem.ID; //填入股票代码
    request.chartType = MChartTypeOneDay;

	//发送请求
    [MApi sendRequest:requestcompletionHandler:^(MResponse *resp) {
		if (resp.status == ResponseStatusSuccess) {
			//应答无误，处理数据更新画面
			MChartResponse *response = (MChartResponse *)resp;
			self.OHLCItems = response.OHLCItems;
            [self reloadData];
        } else {
			//应答错误，显示错误信息
            [Utility alertMessage:resp.message];
        }
    }];
	
[top](#top)	
	
<h3 id="OHLC">K线数据</h3>

<h4 id="OHLCExplain">说明</h4>

* 可通过设置__K线周期(period)来获取不同周期的日K或分K历史行情
<h4 id="MOHLCRequest">请求类：MOHLCRequest</h4>

* 属性说明:

	| 属性名  | 说明     | 型态        | 备注 |
	|---------|----------|-------------|------|
	| code    | 股票代码 | NSString    |      |
	| period  | K线周期  | [MOHLCPeriod](#MOHLCPeriod) |    |    
	| priceAdjustedMode  | 复权模式  | [MOHLCPriceAdjustedMode](#MOHLCPriceAdjustedMode) |  |
	
<h4 id="MOHLCResponse">应答类：MOHLCResponse</h4>

* 属性说明

	| 属性名    | 说明        | 型态    | 备注                           	|
	|-----------|-------------|---------|--------------------------------|
	| OHLCItems | K线数据列表 | NSArray | K线数据列表中的对象：[MOHLCItem](#MOHLCItem) |
	
<h4 id="OHLCSample">调用样例</h4>    
	//请求K线数据
	MOHLCRequest *request = [[MOHLCRequest alloc] init];
    request.code = self.stockItem.ID; //填入股票代码
    request.period = MOHLCPeriodDay; //日K线
 

	//发送请求
    [MApi sendRequest:requestcompletionHandler:^(MResponse *resp) {
		if (resp.status == ResponseStatusSuccess) {
			//应答无误，处理数据更新画面
			MOHLCResponse *response = (MOHLCResponse *)resp;
			self.OHLCItems = response.OHLCItems;
            [self reloadData];
        } else {
			//应答错误，显示错误信息
            [Utility alertMessage:resp.message];
        }
    }];	

[top](#top)

<h3 id="MBrokerSeat">经纪席位</h3>

<h4 id="MBrokerSeatExplain">说明</h4>

* 可获得经纪席位买卖(港股专用)。

<h4 id="MBrokerSeatRequest">请求类：MBrokerSeatRequest</h4>

* 属性说明:

	| 属性名 | 说明         | 型态     | 备注 |
	|--------|--------------|----------|------|
	| code   | 港股股票代码 | NSString |      |
	
<h4 id="MBrokerSeatResponse">应答类(MBrokerSeatResponse)</h4>

* 属性说明

	| 属性名              | 说明         | 型态    | 备注 |
	|---------------------|--------------|---------|------|
	| buyBrokerSeatItems  | 经纪席位(买) | NSArray |  经纪席位(买)中的对象：[MBrokerSeatItem](#MBrokerSeatItem)    |
	| sellBrokerSeatItems | 经纪席位(卖) | NSArray |  经纪席位(卖中的对象：[MBrokerSeatItem](#MBrokerSeatItem)    |
	
<h4 id="MBrokerSample">经纪席位请求样例</h4>
	//请求经纪席位买
	MBrokerSeatRequest *request = [[MBrokerSeatRequest alloc] init];
    request.code = self.stockItem.ID;
    
    [MApi sendRequest:request completionHandler:^(MResponse *resp) {
        if (resp.status == MResponseStatusSuccess) {
            MBrokerSeatResponse *response = (MBrokerSeatResponse *)resp;
            self.buyBrokerSeatItems = response.buyBrokerSeatItems;
            self.sellBrokerSeatItems = response.sellBrokerSeatItems;
            [self reloadData];
        } else {
			//应答错误，显示错误信息
            [Utility alertMessage:resp.message];
        }
     };

[top](#top)
     
<h3 id="Search">股票查询</h3>

<h4 id="SearchExplain">说明</h4>

* 通过设置__搜寻字串(keyword)__可获得相关股票列表，搜寻字串可以是代码、股名或拼音字串。

<h4 id="MSearchRequest">请求类(MSearchRequest)</h4>

* 属性说明:

	| 属性名  | 说明     | 型态     | 备注 |
	|---------|----------|----------|------|
	| keyword | 搜寻字串 | NSString |      |
	| market | 市场别 | NSString | 市场别：SH, SZ, HK     |
	| markets | 多市场别 | NSArray | 市场别：SH, SZ, HK     |
	| subtype | 子类别 | NSString | 请参考 [搜索子分类代码表](#MSearchSubtype)    |
	| subtypes | 多子类别 | NSArray | 请参考 [搜索子分类代码表](#MSearchSubtype)    |
	| searchLocal | 是否为本地端搜索 | BOOL | 如为YES，请先调用[取得全市场股票代码表](#MApi_downloadStockTableWithCompletionHandler)接口 |
	| searchLimit | 搜寻结果数量限制 | NSUInteger |      |
	
	
<h4 id="MSearchResponse">应答类(MSearchResponse)</h4>

* 属性说明

	| 属性名  | 说明         | 型态    | 备注                                    	|
	|---------|--------------|---------|-----------------------------------------|
	| results | 搜寻结果列表 | NSArray | 搜寻结果列表中的对象：[MSearchResultItem](#MSearchResultItem) |
	
<h4 id="SearchSample">调用样例</h4>
	//股票查询
	MSearchRequest *request = [[MSearchRequest alloc] init];
	request.market = @"sh";
	request.subtype = @"1001"
    request.keyword = self.keywordTextField.text; //设定关键字

	//发送请求
    [MApi sendRequest:requestcompletionHandler:^(MResponse *resp) {
		if (resp.status == ResponseStatusSuccess) {
			//应答无误，处理数据更新画面
			MSearchResponse *response = (MSearchResponse *)resp;
			self.results = response.results;
            [self reloadData];
        } else {
			//应答错误，显示错误信息
            [Utility alertMessage:resp.message];
        }
    }];

[top](#top)
	
<h3 id="UnderlyingStock">期权-标的行情</h3>

<h4 id="UnderlyingStockExplain">说明</h4>
* 可获得期权-标的行情列表。	
<h4 id="MUnderlyingStockRequest">请求类(MUnderlyingStockRequest)</h4>

* 属性说明:无
	
<h4 id="MUnderlyingStockResponse">应答类(MUnderlyingStockResponse)</h4>

* 属性说明

	| 属性名     | 说明             | 型态    | 备注                                           	|
	|------------|------------------|---------|------------------------------------------------|
	| stockItems | 期权-标的行情列表 | NSArray | 期权-标的行情列表中的对象：[MStockItem](#MStockItem) |
	
[top](#top)	
	
<h3 id="UnderlyingStockSample">调用样例</h3>

    //请求期权标的证劵
    MUnderlyingStockRequest *request =[[MUnderlyingStockRequest alloc] init];
    
    [MApi sendRequest:request completionHandler:^(MResponse *resp) {
        if(resp.status == MResponseStatusSuccess) {
            //应答无误，处理数据更新画面
            MUnderlyingStockResponse *response = (MUnderlyingStockResponse *)resp;
            self.items = response.stockItems;
            [self reloadData];
        } else {
            //应答错误，显示错误信息
            [Utility alertMessage:resp.message];
        }
    }];

[top](#top)
	
<h3 id="ExpireMonth">期权-交割月列表</h3>

<h4 id="ExpireMonthExplain">说明</h4>
* 可获得期权-标的行情交割月列表。
	
<h4 id="MExpireMonthRequest">请求类(MExpireMonthRequest)</h4>

* 属性说明:

	| 属性名  | 说明         | 型态     | 备注 |
	|---------|--------------|----------|------|
	| stockID | 标的证券代码 | NSString |      |
	
<h4 id="MExpireMonthResponse">应答类(MExpireMonthResponse)</h4>

* 属性说明

	| 属性名       | 说明           | 型态    | 备注                             	|
	|--------------|----------------|---------|----------------------------------|
	| expireMonths | 期权-交割月列表 | NSArray | 期权-交割月列表中的对象：NSString |
	
<h4 id="ExpireMonthSample">调用样例</h4>

	MExpireMonthRequest *request = [[MExpireMonthRequest alloc] init];
    request.stockID = self.stockID;
    [MApi sendRequest:request completionHandler:^(MResponse *resp) {
        if(resp.status == MResponseStatusSuccess) {
            //应答无误，处理数据更新画面
            MExpireMonthResponse *response = (MExpireMonthResponse *)resp;
            self.expireMonths = response.expireMonths;
        } else {
            //应答错误，显示错误信息
            [Utility alertMessage:resp.message];
        }
    }];

[top](#top)
	
<h3 id="Option">期权-商品行情</h3>

<h4 id="OptionExplain">说明</h4>

* 可通过设置期权型态(optionType)来获取认购行情、认沽行情或全部行情。
* 若要获得600600期权认购报价列表行期，可设置stockID=600600, optionType=MOptionTypeCALL。
 
	
<h4 id="MOptionRequest">请求类(MOptionRequest)</h4>

* 属性说明:

	| 属性名     | 说明         | 型态        | 备注 |
	|------------|--------------|-------------|------|
	| stockID    | 标的证券代码 | NSString    |      |
	| pageIndex  | 页码         | NSInteger   |      |
	| optionType | 期权类别     | [MOptionType](#MOptionType) |      |
	
<h4 id="MOptionResponse">应答类(MOptionResponse)</h4>

* 属性说明

	| 属性名      | 说明         | 型态    | 备注                              	|
	|-------------|--------------|---------|-----------------------------------|
	| optionItems | 期权-商品行情 | NSArray |期权-商品行情中的对象：[MOptionItem](#MOptionItem) |
	
<h4 id="OptionSample">调用样例</h4>

   	MOptionRequest *request =[[MOptionRequest alloc] init];
    request.stockID = self.code;
    request.optionType = self.optionType;
    //请求期权数据
    [MApi sendRequest:request completionHandler:^(MResponse *resp) {
            if(resp.status == MResponseStatusSuccess) {
                //应答无误，处理数据更新画面
                if ([resp respondsToSelector:@selector(optionItems)]) {
                    self.items = [resp valueForKeyPath:@"optionItems"];
                }
                [self reloadData];
            } else {
                //应答错误，显示错误信息
                [Utility alertMessage:resp.message];
            };
        }];
    }

[top](#top)

<h3 id="OptionT">期权T型报价行情</h3>

<h4 id="TOptionExplain">说明</h4>

* 可通过设置标的证券代码(stockID)、期权-交割月(expireMonth)来获取期权T型报价行情。
 
<h4 id="MOptionTRequest">请求类(MOptionTRequest)</h4>

* 属性说明:

	| 属性名      | 说明         | 型态     | 备注 |
	|-------------|--------------|----------|------|
	| stockID     | 标的证券代码 | NSString |      |
	| expireMonth | 期权-交割月   | NSString |      |
	
<h4 id="MOptionTResponse">应答类(MOptionResponse)</h4>

* 属性说明:
[MOptionResponse](#MOptionResponse)
 
	
<h4 id="TOptionSample">调用样例</h4>

    MOptionTRequest *request = [[MOptionTRequest alloc] init];
    request.stockID = self.stockID;
    request.expireMonth = expireMonth ;
    
    //发送请求
    [MApi sendRequest:request completionHandler:^(MResponse *resp) {
        if(resp.status == MResponseStatusSuccess) {
            //应答无误，处理数据更新画面
            MOptionResponse *response = (MOptionResponse *)resp;
            self.optionItems = response.optionItems;
            self.optionItems = [self array:self.optionItems sortOptionByKey:@"exePrice"];
            for(MOptionItem *item in _optionItems) {
                if (item.putType) {
                    [self.putItems addObject:item];
                } else {
                    [self.callItems addObject:item];
                }
            }
            [self.optionsView reloadData];
        } else {
            //应答错误，显示错误信息
            [Utility alertMessage:resp.message];
        }
    }];
    
[top](#top)    
    
<h3 id="MEvent">用户行为统计</h3>

<h4 id="MEventExplain">说明</h4>

* 可透过操作代码记录使用者行为。
 
<h4 id="MEventRequest">请求类(MEventRequest)</h4>

* 属性说明:

	| 属性名      | 说明         | 型态     | 备注 |
	|-------------|--------------|----------|------|
	| fid     | 操作代码 | NSString |      |
 
	
<h4 id="MEventSample">调用样例</h4>

    MEventRequest *request = [[MEventRequest alloc] init];
    request.fid = self.fid;
    
    //发送请求
    [MApi sendRequest:request completionHandler:^(MResponse *resp) {}];
    
[top](#top)

<h3 id="StockCategoryList">股票分类代码表</h3>

<h4 id="StockCategoryListExplain">说明</h4>

* 可获取股票分类代码列表。
 
<h4 id="MStockCategoryListRequest">请求类(MStockCategoryListRequest)</h4>

* 属性说明:无
	
<h4 id="MStockCategoryListResponse">应答类(MStockCategoryListResponse)</h4>

* 属性说明:

	| 属性名      | 说明         | 型态     | 备注 |
	|-------------|--------------|----------|------|
	| list     | 股票代码表 | NSArray |      |
 
	
<h4 id="StockCategoryListSample">调用样例</h4>

    MStockCategoryListRequest *request = [[MStockCategoryListRequest alloc] init];
    
    //发送请求
    [MApi sendRequest:request completionHandler:^(MResponse *resp) {
        if(resp.status == MResponseStatusSuccess) {
            //应答无误，处理数据更新画面
            MStockCategoryListResponse *response = (MStockCategoryListResponse *)resp;
            self.stockCategoryList = response.list;
        } else {
            //应答错误，显示错误信息
            [Utility alertMessage:resp.message];
        }
    }];
    
[top](#top)    


<h3 id="MTimeTick">分时明细表</h3>

<h4 id="MTimeTickExplain">说明</h4>

* 通过设置股票代码及笔数可获取特定笔数的分时明细。
 
<h4 id="MTimeTickRequest">请求类(MTimeTickRequest)</h4>

* 属性说明:

	| 属性名      | 说明         | 型态     | 备注 |
	|-------------|--------------|----------|------|
	| code     | 股票代码 | NSString |      |
	| subtype | 次类别   | NSString |      |
	| index | 开始索引   | NSUInteger |      |
	| pageSize | 笔数   | NSUInteger |      |
	| type | 基于开始索引请求的类别   | [MTimeTickRequestType](#MTimeTickRequestType) |      |

<h4 id="MTimeTickResponse">应答类(MTimeTickResponse)</h4>

* 属性说明:
 
	| 属性名      | 说明         | 型态     | 备注 |
	|-------------|--------------|----------|------|
	| items     | 明细数组 | NSArray |   列表中的对象类[MTickItem](#MTickItem)   |
	| startIndex | 开始索引值 | NSString |    | 
	| endIndex   | 结束索引值 | NSString |    |
	
<h4 id="MTimeTickSample">调用样例</h4>

    MTimeTickRequest *request = [[MTimeTickRequest alloc] init];
    request.code = @"600000.sh";
    request.subtype = @"1001";
    
    //发送请求
    [MApi sendRequest:request completionHandler:^(MResponse *resp) {
        if(resp.status == MResponseStatusSuccess) {
            //应答无误，处理数据更新画面
            MTimeTickResponse *response = (MTimeTickResponse *)resp;
            self.tickItems = response.items;
            [self.list reloadData];
        } else {
            //应答错误，显示错误信息
            [Utility alertMessage:resp.message];
        }
    }];
    
[top](#top)    

<h3 id="MPriceVolume">分价量表</h3>

<h4 id="MPriceVolumeExplain">说明</h4>

* 通过设置股票代码可获取分价量表。
 
<h4 id="MPriceVolumeRequest">请求类(MPriceVolumeRequest)</h4>

* 属性说明:

	| 属性名      | 说明         | 型态     | 备注 |
	|-------------|--------------|----------|------|
	| code     | 股票代码 | NSString |      |
	| subtype | 次类别   | NSString |      |

<h4 id="MPriceVolumeResponse">应答类(MPriceVolumeResponse)</h4>

* 属性说明:
 
	| 属性名      | 说明         | 型态     | 备注 |
	|-------------|--------------|----------|------|
	| items     | 价量数组 | NSArray |   列表中的对象类[MPriceVolumeItem](#MPriceVolumeItem)   |
 
	
<h4 id="MPriceVolumeSample">调用样例</h4>

    MPriceVolumeRequest *request = [[MPriceVolumeRequest alloc] init];
    request.code = @"600000.sh";
    request.subtype = @"1001";
    
    //发送请求
    [MApi sendRequest:request completionHandler:^(MResponse *resp) {
        if(resp.status == MResponseStatusSuccess) {
            //应答无误，处理数据更新画面
            MPriceVolumeResponse *response = (MPriceVolumeResponse *)resp;
            self.tickItems = response.items;
            [self.list reloadData];
        } else {
            //应答错误，显示错误信息
            [Utility alertMessage:resp.message];
        }
    }];
    
[top](#top)    

<h3 id="MOrderQuantity">买卖队列</h3>

<h4 id="MOrderQuantityExplain">说明</h4>

* 通过设置股票代码可获取买卖队列。
 
<h4 id="MOrderQuantityRequest">请求类(MOrderQuantityRequest)</h4>

* 属性说明:

	| 属性名      | 说明         | 型态     | 备注 |
	|-------------|--------------|----------|------|
	| code     | 股票代码 | NSString |      |
	| subtype | 次类别   | NSString |      |

<h4 id="MOrderQuantityResponse">应答类(MOrderQuantityResponse)</h4>

* 属性说明:
 
	| 属性名      | 说明         | 型态     | 备注 |
	|-------------|--------------|----------|------|
	| buyItems     | 委买数组 | NSArray | 为买1~买10的[MOrderQuantityItem](#MOrderQuantityItem)数组对象 |
 	| sellItems     | 委卖数组 | NSArray | 为卖1~卖10的[MOrderQuantityItem](#MOrderQuantityItem)数组对象 |
	
<h4 id="MOrderQuantitySample">调用样例</h4>

    MOrderQuantityRequest *request = [[MOrderQuantityRequest alloc] init];
    request.code = @"600000.sh";
    request.subtype = @"1001";
    
    //发送请求
    [MApi sendRequest:request completionHandler:^(MResponse *resp) {
        if(resp.status == MResponseStatusSuccess) {
            //应答无误，处理数据更新画面
            MOrderQuantityResponse *response = (MOrderQuantityResponse *)resp;
            self.tickItems = response.items;
            [self.list reloadData];
        } else {
            //应答错误，显示错误信息
            [Utility alertMessage:resp.message];
        }
    }];
    
[top](#top)    


<h3 id="MHKQuoteInfo">港股其他信息</h3>

<h4 id="MHKQuoteInfoExplain">说明</h4>

* 通过设置股票代码可获取港股其他信息，包含港股碎股订单消息、港股市场波动调节、港股收市集合竞价。
 
<h4 id="MHKQuoteInfoRequest">请求类(MHKQuoteInfoRequest)</h4>

* 属性说明:

	| 属性名      | 说明         | 型态     | 备注 |
	|-------------|--------------|----------|------|
	| code     | 股票代码 | NSString |      |
	| subtype | 次类别   | NSString |      |

<h4 id="MHKQuoteInfoResponse">应答类(MHKQuoteInfoResponse)</h4>

* 属性说明:
 
	| 属性名      | 说明         | 型态     | 备注 |
	|-------------|--------------|----------|------|
	| oddInfoItems     | 碎股订单数组 | NSArray | [MHKOddInfo](#MHKOddInfoItem)|
 	| vcmDatetime     | VCM 时间 | NSString |  |
	| vcmStartTime     | 市场调节机制起始时间 | NSString |  |
	| vcmEndTime     | 市场调节机制结束时间 | NSString |  |
	| vcmRefPrice     | 市场调节机制参考价 | NSString |  |
	| vcmLowerPrice     | 市场调节下限价 | NSString |  |
	| vcmUpperPrice     | 市场调节上限价 | NSString |  |
	| casDatetime     | CAS 时间 | NSString |  |
	| casOrdImbDirection     | CAS 未能配对买卖盘的方向 | NSString |  |
	| casOrdImbQty     | CAS 未能配对买卖盘的数量 | NSString |  |
	| casRefPrice     | CAS 的参考价格 | NSString |  |
	| casLowerPrice     | CAS 下限价 | NSString |  |
	| casUpperPrice     | CAS 下限价 | NSString |  |
	
	 	
<h4 id="MHKQuoteInfoSample">调用样例</h4>

    MHKQuoteInfoRequest *request = [[MHKQuoteInfoRequest alloc] init];
    request.code = @"00005.hk";
    request.subtype = @"1001";
    
    //发送请求
    [MApi sendRequest:request completionHandler:^(MResponse *resp) {
        if(resp.status == MResponseStatusSuccess) {
            //应答无误，处理数据更新画面
            MHKQuoteInfoResponse *response = (MHKQuoteInfoResponse *)resp;

        } else {
            //应答错误，显示错误信息
            [Utility alertMessage:resp.message];
        }
    }];
    
[top](#top)    


<h3 id="MMarketHoliday">假日黑名单</h3>

<h4 id="MMarketHolidayExplain">说明</h4>

* 取得假日黑名单。
 
<h4 id="MMarketHolidayRequest">请求类(MMarketHolidayRequest)</h4>

* 属性说明:
	无

<h4 id="MMarketHolidayResponse">应答类(MMarketHolidayResponse)</h4>

* 属性说明:
 
	| 属性名      | 说明         | 型态     | 备注 |
	|-------------|--------------|----------|------|
	| JSONObject     |  | NSDictionary | |	
	 	
<h4 id="MHKQuoteInfoSample">调用样例</h4>

    MMarketHolidayRequest *request = [[MMarketHolidayRequest alloc] init];
    
    //发送请求
    [MApi sendRequest:request completionHandler:^(MResponse *resp) {
        if(resp.status == MResponseStatusSuccess) {
            //应答无误，处理数据更新画面
            MMarketHolidayResponse *response = (MMarketHolidayResponse *)resp;

        } else {
            //应答错误，显示错误信息
            [Utility alertMessage:resp.message];
        }
    }];
    
[top](#top)    


<h3 id="MTimeTickDetail">逐笔明细表</h3>

<h4 id="MTimeTickDetailExplain">说明</h4>

* 通过设置股票代码及笔数可获取特定笔数的分时明细。
 
<h4 id="MTimeTickDetailRequest">请求类(MTimeTickDetailRequest)</h4>

* 属性说明:

	| 属性名      | 说明         | 型态     | 备注 |
	|-------------|--------------|----------|------|
	| code     | 股票代码 | NSString |      |
	| subtype | 次类别   | NSString |      |
	| pageIndex | 页次   | NSInteger |      |
	| pageSize | 笔数   | NSInteger |      |

<h4 id="MTimeTickDetailResponse">应答类(MTimeTickDetailResponse)</h4>

* 属性说明:
 
	| 属性名      | 说明         | 型态     | 备注 |
	|-------------|--------------|----------|------|
	| tickItems     | 分时数组 | NSArray |   列表中的对象类[MTimeTickItem](#MTimeTickItem)   |
	| detailTickItems     | 明细数组 | NSArray |   列表中的对象类[MTimeTickDetailItem](#MTimeTickDetailItem)   | 
	
<h4 id="MTimeTickDetailSample">调用样例</h4>

    MTimeTickDetailRequest *request = [[MTimeTickDetailRequest alloc] init];
    request.code = @"600000.sh";
    request.subtype = @"1001";
    request.pageIndex = 0;
    request.pageSize = 10;
    
    //发送请求
    [MApi sendRequest:request completionHandler:^(MResponse *resp) {
        if(resp.status == MResponseStatusSuccess) {
            //应答无误，处理数据更新画面
            MTimeTickDetailResponse *response = (MTimeTickDetailResponse *)resp;
            self.tickItems = response.tickItems;
            self.detailTickItems = response.detailTickItems;
            [self.list reloadData];
        } else {
            //应答错误，显示错误信息
            [Utility alertMessage:resp.message];
        }
    }];
    
[top](#top)    


<h3 id="MStaticData">个股静态数据</h3>

<h4 id="MStaticDataExplain">说明</h4>

* 通过设置股票代码可以获取个股所属板块信息、两市港股通标识、融资标识、融券标识
 
<h4 id="MStaticDataRequest">请求类(MStaticDataRequest)</h4>

* 属性说明:

	| 属性名      | 说明         | 型态     | 备注 |
	|-------------|--------------|----------|------|
	| code     | 股票代码 | NSString |   多个股票用逗号隔开，如："000001.sh,600000.sh"   |
	| param |  获取信息参数  | NSString |   默认为全部,即"bk,hki,su,bu",也可以指定为以上4种的任一一种或多种的组合，如"bk,bki"   |
	
<h4 id="MStaticDataResponse">应答类(MStaticDataResponse)</h4>

* 属性说明:
 
	| 属性名      | 说明         | 型态     | 备注 |
	|-------------|--------------|----------|------|
	| dataItems     | 静态数据数组 | NSArray |   列表中的对象类[MStaticDataItem](#MStaticDataItem),顺序为传入股票的顺序   |
	 
	
<h4 id="MStaticDataSample">调用样例</h4>

    MStaticDataRequest *r = [[MStaticDataRequest alloc] init];
    r.code = @"600000.sh,000001.sz";
    r.param = @"bk";
    
    //发送请求
    [MApi sendRequest:r completionHandler:^(MResponse *resp) {
    	if(resp.status == MResponseStatusSuccess) {
            //应答无误，处理数据更新画面
           MStaticDataResponse* response = (MStaticDataResponse *)resp;
        
        } else {
            
        }
    }];
    
[top](#top) 


<h3 id="MHKMarketInfo">两市港股通数据</h3>

<h4 id="MHKMarketInfoExplain">说明</h4>

* 获取两市港股通 每日初始额度 日中剩余额度和额度状态

<h4 id="MHKMarketInfoRequest">请求类(MHKMarketInfoRequest)</h4>

* 属性说明:

	无参数
	
<h4 id="MHKMarketInfoResponse">应答类(MHKMarketInfoResponse)</h4>

* 属性说明:
 
	| 属性名      | 说明         | 型态     | 备注 |
	|-------------|--------------|----------|------|
	| SHInitialQuota     | 沪初始额度 |	NSString |      |
	| SHRemainQuota     | 沪日中剩余额度 |	NSString |      |
	| SHStatus     | 沪港通额度状态 |	NSInteger |   1:不可用,2:可用,0或者null:源没有   |
	| SZInitialQuota     | 深初始额度 |	NSString |      |
	| SZRemainQuota     | 深日中剩余额度 |	NSString |      |
	| SZStatus     | 深港通额度状态 |	NSInteger |   1:不可用,2:可用,0或者null:源没有   |
	 
	
<h4 id="MHKMarketInfoSample">调用样例</h4>

    MHKMarketInfoRequest *r = [[MHKMarketInfoRequest alloc] init];
    
    //发送请求
    [MApi sendRequest:r completionHandler:^(MResponse *resp) {
    	if(resp.status == MResponseStatusSuccess) {
            //应答无误，处理数据
           MHKMarketInfoResponse* response = (MHKMarketInfoResponse *)resp;
        
        } else {
            
        }
    }];
    
[top](#top)


<h2 id="数据结构">数据结构</h2>

<h3 id="MStockItem">股票行情(MStockItem)</h3>


| 属性名           | 说明              | 型态         | 备注                                                                                  |
|------------------|-------------------|--------------|---------------------------------------------------------------------------------------|
| status           | 股票状态          | NSInteger    | 正常交易=0, 暂停交易=1, 停牌=2, 退市=3                                                |
| stage            | 交易階段          | NSInteger    | 未开市=0, 集合竞价=1, 未知状态=2,连续竞价=3,临时停市=4,已收盘=5,午间休市＝6 ,交易中=7 |
| ID               | 股票代码          | NSString     | 含市場代號的股票代碼                                                                  |
| name             | 股票名            | NSString     |                                                                                       |
| datetime         | 交易时间          | NSString     |                                                                                       |
| market           | 市场别            | NSString     |                                                                                       |
| subtype          | 次类别            | NSString     |                                                                                       |
| lastPrice        | 最新价            | NSString     |                                                                                       |
| highPrice        | 最高价            | NSString     |                                                                                       |
| lowPrice         | 最低价            | NSString     |                                                                                       |
| openPrice        | 今开价            | NSString     |                                                                                       |
| preClosePrice    | 昨收价            | NSString     |                                                                                       |
| changeRate       | 涨跌比率          | NSString     |                                                                                       |
| volume           | 总量              | NSString     |                                                                                       |
| nowVolume        | 当前成交量        | NSString     |                                                                                       |
| turnoverRate     | 换手率            | NSString     |                                                                                       |
| limitUp          | 涨停价            | NSString     |                                                                                       |
| limitDown        | 跌停价            | NSString     |                                                                                       |
| change           | 涨跌              | NSString     |                                                                                       |
| amount           | 成交金额          | NSString     |                                                                                       |
| buyPrice         | 买一价            | NSString     |                                                                                       |
| sellPrice        | 卖一价            | NSString     |                                                                                       |
| buyVolume        | 外盘量            | NSString     |                                                                                       |
| sellVolume       | 内盘量            | NSString     |                                                                                       |
| totalValue       | 总值              | NSString     |                                                                                       |
| flowValue        | 流值              | NSString     |                                                                                       |
| netAsset         | 净资产            | NSString     |                                                                                       |
| PE               | PE(市盈)          | NSString     |                                                                                       |
| ROE              | ROE(净资产收益率) | NSString     |                                                                                       |
| captitalization  | 总股本            | NSString     |                                                                                       |
| circulatingShare | 流通股            | NSString     |                                                                                       |
| buyPrices        | 一、五、十档委买价          | NSArray      |                                                                                       |
| sellPrices       | 一、五、十档委卖价          | NSArray      |                                                                                       |
| buyVolumes       | 一、五、十档委买量          | NSArray      |                                                                                       |
| sellVolumes      | 一、五、十档委卖量          | NSArray      |                                                                                       |
| buyCount       | 一、五、十档委买笔数          | NSArray      |                                                                                       |
| sellCount      | 一、五、十档委卖笔数          | NSArray      |                                                                                       |
| orderRatio      | 委比          | NSString      |                                                                                       |
| volumeRatio      | 量比          | NSString      |                                                                                       |
| amplitudeRate    | 振幅比率          | NSString     |                                                                                       |
| receipts         | 收益              | NSString     |                                                                                       |
| tickItems        | 最新十笔明细列表  | NSArray      | 列表中的对象类[MTickItem](#MTickItem)                                                               |
| code             | 股票代码          | NSString     | 不含市场代号                                                                          |
| changeState      | 涨跌状态          | [MChangeState](#MChangeState) |                                                                                       |
| advanceCount  | 上涨家数      | NSString     | 指数类,     [MSnapQuoteRequest](#MSnapQuoteRequest) only                                                                            |
| declineCount  | 下跌家数      | NSString     | 指数类,     [MSnapQuoteRequest](#MSnapQuoteRequest) only                                                                            |
| equalCount    | 平盘家数      | NSString     | 指数类,     [MSnapQuoteRequest](#MSnapQuoteRequest) only                                                                            |
| HKInfoStatus    | 港股信息状态  | [MHKInfoStatus](#MHKInfoStatus)   | 港股                                                                                |
| totalBuyVolume    | 总买量  |  NSString  |    [MSnapQuoteRequest](#MSnapQuoteRequest) only                                                                             |
| totalSellVolume    | 总卖量  |  NSString  |    [MSnapQuoteRequest](#MSnapQuoteRequest) only                                                                             |
| averageBuyPrice    | 均买价  |  NSString  |    [MSnapQuoteRequest](#MSnapQuoteRequest) only                                                                             |
| averageSellPrice    | 均卖价  |  NSString  |   [MSnapQuoteRequest](#MSnapQuoteRequest) only                                                                              |
| subtype2    | 副类别2  |  NSString  |                                                                                 |

<h5 id="MStockItemL2">股票行情L2(MStockItem)</h5>
需使用[MSnapQuoteRequest](#MSnapQuoteRequest)并设置`type`为[MSnapQuoteRequestType10](#MSnapQuoteRequestType)。

| 属性名           | 说明              | 型态         | 备注                                                                                  |
|------------------|-------------------|--------------|---------------------------------------------------------------------------------------|
| orderQuantityBuyItems           | 50笔队列(买)          | NSArray    | 为买1~买10的[MOrderQuantityItem](#MOrderQuantityItem)数组对象 |
| orderQuantitySellItems           | 50笔队列(卖)          | NSArray    | 为卖1~卖10的[MOrderQuantityItem](#MOrderQuantityItem)数组对象 |
| brokerSeatBuyItems           | 经济席位(买)          | NSArray    | 港股 |
| brokerSeatSellItems           | 经济席位(卖)        | NSArray    | 港股 |


[top](#top)


<h3 id="MTickItem">分笔成交(MTickItem)</h3>
| 属性名      | 说明     | 型态          | 备注 |
|-------------|----------|---------------|------|
| time    | 交易时间 | NSString      |      |
| tradePrice  | 交易价格 | NSString      |      |
| tradeVolume | 交易量   | NSString      |      |
| type        | 内外盘   | [MBSVolumeType](#MBSVolumeType) |      |
| AMSFlag    | 港股旗标   | [MTimeTickAMSFlag](#MTimeTickAMSFlag) |      |

<h3 id="MTimeTickItem">分时成交(MTimeTickItem)</h3>
继承: [MTickItem](#MTickItem)

| 属性名      | 说明     | 型态          | 备注 |
|-------------|----------|---------------|------|
| sectionRange    | 索引范围 | NSString      |      |

<h3 id="MTimeTickDetailItem">分时成交明细(MTimeTickDetailItem)</h3>
继承: [MTickItem](#MTickItem)

| 属性名      | 说明     | 型态          | 备注 |
|-------------|----------|---------------|------|
| index    | 索引 | NSString      |      |


[top](#top)

<h3 id="MPriceVolumeItem">分价量表(MPriceVolumeItem)</h3>

| 属性名      | 说明     | 型态          | 备注 |
|-------------|----------|---------------|------|
| price    | 价格 | NSString      |      |
| volume  | 量 | NSString      |      |

[top](#top)

<h3 id="MStaticDataItem">静态数据(MStaticDataItem)</h3>

| 属性名      | 说明     | 型态          | 备注 |
|-------------|----------|---------------|------|
| boardInfoItems    | 版块信息 | NSArray      |  列表中的对象类[MBoardInfoItem](#MBoardInfoItem)    |
| HFlag  | 沪港通标识 | BOOL      |   1为沪港通标识 默认为0   |
| SFlag  | 深港通标识 | BOOL      |   1为深港通标识 默认为0   |
| financeFlag  | 融资标识 | BOOL      |   1为融资标识 0源未下 ,默认为0   |
| securityFlag  | 融券标识 | BOOL      |  1为融券标识 0源未下 ,默认为0    |

[top](#top)

<h3 id="MBoardInfoItem">版块信息(MBoardInfoItem)</h3>

| 属性名      | 说明     | 型态          | 备注 |
|-------------|----------|---------------|------|
| name  | 版块名称 | NSString      |      |
| ID  | 版块ID | NSString      |      |

[top](#top)

<h3 id="MOrderQuantityItem">交易单明细(MOrderQuantityItem)</h3>

| 属性名      | 说明     | 型态          | 备注 |
|-------------|----------|---------------|------|
| volume  | 量 | NSString      |      |

[top](#top)


<h3 id="MOHLCItem">K线数据(MOHLCItem)</h3>

| 属性名       | 说明     | 型态     | 备注 |
|--------------|----------|----------|------|
| datetime     | 交易时间 | NSString |      |
| openPrice    | 开盘价   | NSString |      |
| highPrice    | 最高价   | NSString |      |
| lowPrice     | 最低价   | NSString |      |
| closePrice   | 收盘价   | NSString |      |
| tradeVolume  | 交易量   | NSString |      |
| referencePrice | 参考价   | NSString |      |
| averagePrice | 均价     | NSString |      |
| amount       | 金额     | NSString |      |
| rgbar       | 大盘红绿柱     | NSString |      |


[top](#top)

<h3 id="MSearchResultItem">搜寻结果(MSearchResultItem)</h3>

| 属性名  | 说明                 | 型态     | 备注 |
|---------|----------------------|----------|------|
| stockID | 股票代码             | NSString |      |
| name    | 股票名称             | NSString |      |
| market  | 市场别               | NSString |      |
| pinyin  | 拼音                 | NSString |      |
| subtype | 次类别               | NSString |      |
| code    | 股票代码(不含市场别) | NSString |      |

[top](#top)

<h3 id="MCategoryItem">板块分类(MCategoryItem)</h3>

| 属性名 | 说明     | 型态     | 备注 |
|--------|----------|----------|------|
| code   | 分类代码 | NSString |      |
| name   | 分类名   | NSString |      |

[top](#top)

<h3 id="MSectionRankingItem">板块排行(MSectionRankingItem)</h3>

| 属性名          | 说明           | 型态     | 备注 |
|-----------------|----------------|----------|------|
| name            | 板块名称       | NSString |      |
| ID              | 板块代号       | NSString |      |
| changeRate      | 板块涨幅比     | NSString |      |
| change          | 板块涨幅       | NSString |      |
| stockName       | 领涨名称       | NSString |      |
| stockID         | 领涨代号       | NSString |      |
| stockChangeRate | 领涨个股涨幅比 | NSString |      |
| stockChange     | 领涨个股涨幅   | NSString |      |

[top](#top)


<h3 id="MSectionSortingItem">板块排行(MSectionSortingItem)</h3>

| 属性名          | 说明           | 型态     | 备注 |
|-----------------|----------------|----------|------|
| ID              | 板块代号       | NSString |      |
| name            | 板块名称       | NSString |      |
| weightedChange  | 权涨幅        | NSString |      |
| averageChange   | 均涨幅        | NSString |      |
| amount          | 总成交额      | NSString |      |
| changeRate      | 板块涨幅比     | NSString |      |
| turnoverRate    | 换手率       | NSString |      |
| stockID         | 领涨代号       | NSString |      |
| stockName       | 领涨名称       | NSString |      |
| stockChange     | 领涨个股涨幅   | NSString |      |
| stockChangeRate | 领涨个股涨幅比 | NSString |      |


[top](#top)


<h3 id="MBrokerSeatItem">经纪席位(MBrokerSeatItem)</h3>

| 属性名   | 说明     | 型态     | 备注 |
|----------|----------|----------|------|
| value    | 量       | NSString |      |
| name     | 名称     | NSString |      |
| fullName | 完整名称 | NSString |      |

[top](#top)

<h3 id="MOptionItem">期权行情(MOptionItem)</h3>

| 属性名       | 说明         | 型态        | 备注 |
|--------------|--------------|-------------|------|
| contractID   | 合约代码     | NSString    |      |
| stockID      | 标的证券代码 | NSString    |      |
| stockSymbol  | 标的证券简称 | NSString    |      |
| stockType    | 标的证券类型 | NSString    |      |
| callOrPut    | 认购认沽     | NSString    |      |
| unit         | 合约单位     | NSString    |      |
| exePrice     | 期权行权价格 | NSString    |      |
| startDate    | 首个交易日   | NSString    |      |
| endDate      | 最后交易日   | NSString    |      |
| exeDate      | 期权行权日   | NSString    |      |
| deliDate     | 期权交割日   | NSString    |      |
| expDate      | 期权到期日   | NSString    |      |
| version      | 合约版号     | NSString    |      |
| presetPrice  | 前结算价     | NSString    |      |
| stockClose   | 标的证券昨收 | NSString    |      |
| stockLast    | 标的证券价格 | NSString    |      |
| isLimit      | 有无涨跌限制 | BOOL        |      |
| remainDate   | 剩余天数     | NSString    |      |
| openInterest | 持仓量       | NSString    |      |
| optionType   | 期权类别     | [MOptionType](#MOptionType) |      |

[top](#top)


<h3 id="MHKOddInfoItem">港股碎股(MHKOddInfoItem)</h3>

| 属性名       | 说明         | 型态        | 备注 |
|--------------|--------------|-------------|------|
| orderId   | 订单编号     | NSString    |      |
| orderQty      | 订单数量 | NSString    |      |
| price  | 价格 | NSString    |      |
| brokerId  | 经纪人编号 | NSString    |      |
| side  | 买卖方向 | [MHKOddSide](#MHKOddSide)    |      |
| datetime  | 时间 | NSString    |      |

[top](#top)

<h2 id="Others">其他</h2>

<h3 id="MOHLCPeriod">K线周期(MOHLCPeriod)</h3>

| 名称              | 说明 | 备注 |
|-------------------|------|------|
| MOHLCPeriodMinute | 分K  |      |
| MOHLCPeriodMonth  | 月K  |      |
| MOHLCPeriodWeek   | 周K  |      |
| MOHLCPeriodDay    | 日K  |      |

[top](#top)

<h3 id="MOHLCPriceAdjustedMode">K线复权(MOHLCPriceAdjustedMode)</h3>

| 名称                 | 说明     | 备注 |
|----------------------|----------|------|
| MOHLCPriceAdjustedModeNone     | 除权  |      |
| MOHLCPriceAdjustedModeForward  | 前复权 |      |
| MOHLCPriceAdjustedModeBackward | 后复权 |      |

[top](#top)

<h3 id="MBSVolumeType">内外盘类别(MBSVolumeType)</h3>

| 名称              | 说明 | 备注 |
|-------------------|------|------|
| MBSVolumeTypeBuy  | 内盘 |      |
| MBSVolumeTypeSell | 外盘 |      |

[top](#top)

<h3 id="MChartType">走势类别(MChartType)</h3>

| 名称               | 说明     | 备注 |
|--------------------|----------|------|
| MChartTypeOneDay   | 当日走势 |      |
| MChartTypeFiveDays | 五日走势 |      |

[top](#top)
<h3 id="MChangeState">涨跌状态(MChangeState)</h3>

| 名称             | 说明 | 备注 |
|------------------|------|------|
| MChangeStateFlat | 平盘 |      |
| MChangeStateRise | 上涨 |      |
| MChangeStateFall | 下跌 |      |

[top](#top)

<h3 id="MOptionType">期权类别(MOptionType)</h3>

| 名称            | 说明 | 备注 |
|-----------------|------|------|
| MOptionTypeAll  | 全部 |      |
| MOptionTypeCall | 认购 |      |
| MOptionTypePut  | 认沽 |      |

[top](#top)

<h3 id="MStockStatus">交易狀態表(MStockStatus)</h3>

| 名称                 | 说明     | 备注 |
|----------------------|----------|------|
| MStockStatusNormal   | 正常交易 |      |
| MStockStatusPause    | 暂停交易 |      |
| MStockStatusSuspend  | 停牌     |      |
| MStockStatusUnmarket | 退市     |      |

[top](#top)

<h3 id="MStockStage">交易阶段表(MStockStage)</h3>

| 名称                     | 说明     | 备注 |
|--------------------------|----------|------|
| MStockStageAuction       | 集合竞价 |      |
| MStockStageUnknown       | 未知状态 |      |
| MStockStageOpen          | 连续竞价 |      |
| MStockStageTempSuspensed | 临时停市 |   弃用,之后api也会删掉   |
| MStockStageClosed        | 已收盘   |      |
| MStockStageLunchBreak    | 午间休市 |      |
| MStockStageOnTrading     | 交易中   |   弃用,之后api也会删掉   |

[top](#top)



<h3 id="MHKInfoStatus">港股状态(MHKInfoStatus)</h3>

| 名称                     | 说明     | 备注 |
|--------------------------|----------|------|
| MHKInfoStatusNone       |  |      |
| MHKInfoStatusODD        |  |     |
| MHKInfoStatusVCM         |  |      |
| MHKInfoStatusCAS        |  |      |

[top](#top)


<h3 id="MTimeTickAMSFlag">港股交易明细旗标(MTimeTickAMSFlag)</h3>

| 名称                     | 说明     | 备注 |
|--------------------------|----------|------|
| MTimeTickAMSFlagUnknown       |  |      |
| MTimeTickAMSFlagNone        |  |     |
| MTimeTickAMSFlagLateTrade         |  |      |
| MTimeTickAMSFlagNonDirectOffExchangeTrade        |  |      |
| MTimeTickAMSFlagAutomatchInternalized        |  |      |
| MTimeTickAMSFlagDirectOffExchangeTrade        |  |      |
| MTimeTickAMSFlagOddLotTrade        |  |      |
| MTimeTickAMSFlagAuctionTrade        |  |      |

[top](#top)


<h3 id="MCategorySortingField">排序代码栏位(MCategorySortingField)</h3>

| 名称                     | 说明     | 备注 |
|--------------------------|----------|------|
| MCategorySortingFieldID    | 代码   |      |
| MCategorySortingFieldName    | 名称   |      |
| MCategorySortingFieldPinyin    | 拼音  |      |
| MCategorySortingFieldLastPrice    | 最新价   |      |
| MCategorySortingFieldHighPrice    | 最高价   |      |
| MCategorySortingFieldLowPrice    | 最低价   |      |
| MCategorySortingFieldOpenPrice    | 开盘价   |      |
| MCategorySortingFieldPreClosePrice    | 昨收价   |      |
| MCategorySortingFieldChangeRate    | 涨幅    |      |
| MCategorySortingFieldVolume    | 总量    |      |
| MCategorySortingFieldTurnoverRate    | 换手率   |      |
| MCategorySortingFieldChange    | 涨跌   |      |
| MCategorySortingFieldAmount    | 成交金额   |      |
| MCategorySortingFieldVolumeRatio    | 量比   |      |
| MCategorySortingFieldAmplitudeRate    | 振幅比率  |      |

[top](#top)


<h3 id="MSectionSortingField">版块排序代码栏位(MSectionSortingField)</h3>

| 名称                     | 说明     | 备注 |
|--------------------------|----------|------|
| MSectionSortingFieldWeightedChange    | 权涨幅   |      |
| MSectionSortingFieldAverageChange    | 均涨幅   |      |
| MSectionSortingFieldAmount    | 总成交额  |      |
| MSectionSortingFieldChangeRate    | 涨幅比  |      |
| MSectionSortingFieldTurnoverRate    | 换手率  |      |

[top](#top)


<h3 id="MHKOddSide">港股碎股订单买卖方向(MHKOddSide)</h3>

| 名称              | 说明 | 备注 |
|-------------------|------|------|
| MHKOddSideNone |   |      |
| MHKOddSideBid  | 买  |      |
| MHKOddSideOffer   | 卖  |      |

[top](#top)
<h3 id="MSnapQuoteRequestType">详细报价请求类别(MSnapQuoteRequestType)</h3>

| 名称              | 说明 | 备注 |
|-------------------|------|------|
| MSnapQuoteRequestType1 | 1档  |      |
| MSnapQuoteRequestType5  | 5档  |      |
| MSnapQuoteRequestType10   | 10档  |      |

[top](#top)

<h3 id="MCategoryID">分类代码</h3>

| 名称                     | 说明     | 备注 |
|--------------------------|----------|------|
| SH1001    | 上证A股   |      |
| SH1002    | 上证B股   |      |
| SH1100    | 上证基金  |      |
| SH1300    | 上证债券  |      |
| SH1400    | 上海指数   |      |
| SHSZ1001  | 沪深A股   |      |
| SHSZ1400  | 大盘指数   |      |
| SZ1001    | 深证A股   |      |
| SZ1002    | 深证B股   |      |
| SZ1003    | 中小板    |      |
| SZ1004    | 创业板    |      |
| SZ1100    | 深证基金   |      |
| SZ1300    | 深证债券   |      |
| SZ1400    | 深证指数   |      |
| HKAH      | AH股	    |      |
| HKUA2301  | 港股通（沪）    |      |
| SZHK      | 港股通（深）    |      |
| SH3002    | 上证期权   |      |
| HK1000    | 主板 (港股)   |      |
| HK1004    | 创业板 (港股)   |      |
| HK1100    | 基金 (港股)   |      |
| HK1300    | 债券 (港股)   |      |
| HK1400    | 香港指数   |      |
| HKRed    | 红筹股    |      |
| HKStartup    | 创业板    |      |
| SH1110    | LOF基金   |      |
| SH1120    | ETF基金   |      |
| SH1130    | 分类基金   |      |
| SH1131    | 分级A   |      |
| SH1132    | 分级B   |      |
| 指数代码（如000001.sh）    | 成分股   |      |
| Risk      | 风险提示(港澳)   |      |
| Delist    | 退市调整(港澳) |      |
| SHS       | 上证风险警示（交易所接口哦） |      |
| SZS	    | 深证风险警示（交易所接口哦） |      |
| SHP	    | 上证退市整理（交易所接口哦） |      |
| SZZ       | 深证退市整理（交易所接口哦） |      |
| SHSZS     | 沪深风险警示（交易所接口哦） |      |
| SHSZP     | 沪深退市整理（交易所接口哦） |      |

| 名称                     | 说明     | 备注 |
|--------------------------|----------|------|
| allstocks    | 全部股票    |      |
| SHSZTurnoverRate    | 换手率排行    |      |
| SHSZAmp    | 振幅排行    |      |
| SHSZTurnover    | 成交额排行    |      |
| SHSZVolumeRatio    | 量比排行    |      |


[top](#top)


<h3 id="MSectionRankingID">板块排行代码</h3>

| 名称                     | 说明     | 备注 |
|--------------------------|----------|------|
| Notion    | 概念板块   |      |
| Area    | 地区板块   |      |
| Trade    | 行业板块  |      |

[top](#top)


<h3 id="MSearchSubtype">搜索子分类代码</h3>

| 名称                     | 说明     | 可用市场别 |
|--------------------------|----------|------|
| 1001    | A股   |   全部   |
| 1002    | B股   |    SH, SZ, HK  |
| 1004    | 创业版  |   SZ, HK   |
| 1400    | 大盘指数  |   全部   |
| 1100    | 基金   |   全部   |
| 1300  | 债券   |   全部   |
| 3002  | 上证期权   |   SH   |
|  1500 | 涡轮   |   HK   |
|  1501 | 主版   |   HK   |
|  1502 | 创业   |   HK   |
|  1503 | 衍生   |   HK   |
|  1110 | LOF上市型开放式基金   |   SH, SZ   |
|  1120 | ETF交易型开放式指数基金   |   SH, SZ   |
|  1140 | CEF封闭式基金   |   SH, SZ   |

[top](#top)


<h3 id="MTimeTickRequestType">分时明细请求类别(MTimeTickRequestType)</h3>

| 名称                     | 说明     | 备注 |
|--------------------------|----------|------|
| MTimeTickRequestTypeRecent    | 最新N笔数据   |      |
| MTimeTickRequestTypeNewer    | 比索引值更新的N笔数据   |      |
| MTimeTickRequestTypeOlder    | 比索引值更旧的N笔数据  |      |

[top](#top)

<h4 id="RegisterOptionsKey">注册配置键值表</h4>

| 键值             | 说明                 | 备注 |
|------------------|----------------------|------|
| MApiRegisterOptionGetServerPoolingTimeKey        | 定时检查server时间间隔 | 单位：秒 |


[top](#top)

