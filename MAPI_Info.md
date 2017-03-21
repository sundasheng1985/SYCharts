<h1 id="top">移动行情客户端接口说明</h1>
===========

* [概述](#概述)
	* [目的](#目的)
	* [形式说明](#形式说明)
	* [资源类别列表](#资源类别列表)
		* [请求类别列表](#请求类别列表)
		* [应答类别列表](#应答类别列表)
		* [数据结构列表](#数据结构列表)
		* [错误代码列表](#错误代码列表)

* [使用说明](#使用说明) 
	* [应用程序接口](#MApi)
		* [说明](#InitExplain)
		* [调用样例](#InitSample)
	* [最新指标](#LatestIndex)
		* [说明](#LatestIndexExplain)
		* [请求类(MLatestIndexRequest)](#MLatestIndexRequest)
		* [应答类(MLatestIndexResponse)](#MLatestIndexResponse)
		* [调用样例](#LatestIndexSample)
	* [大事提醒](#BigEventNotification)
		* [说明](#BigEventNotificationExplain)
		* [请求类(MBigEventNotificationRequest)](#MBigEventNotificationRequest)
		* [应答类(MBigEventNotificationResponse)](#MBigEventNotificationResponse)
		* [调用样例](#BigEventNotificationSample)
	* [分红配送](#BonusFinance)
		* [说明](#BonusFinanceExplain)
		* [请求类(MBonusFinanceRequest)](#MBonusFinanceRequest)
		* [应答类(MBonusFinanceResponse)](#MBonusFinanceResponse)
		* [调用样例](#BonusFinanceSample)
	* [融资融券](#TradeDetailInfo)
		* [说明](#TradeDetailInfoExplain)
		* [请求类(MTradeDetailInfoRequest)](#MTradeDetailInfoRequest)
		* [应答类(MTradeDetailInfoResponse)](#MTradeDetailInfoResponse)
		* [调用样例](#TradeDetailInfoSample)
	* [机构预测](#ForecastYear)
		* [说明](#ForecastYearExplain)
		* [请求类(MForecastYearRequest)](#MForecastYearRequest)
		* [应答类(MForecastYearResponse)](#MForecastYearResponse)
		* [调用样例](#ForecastYearSample)
	* [机构评等](#ForecastRating)
		* [说明](#ForecastRatingExplain)
		* [请求类(MForecastRatingRequest)](#MForecastRatingRequest)
		* [应答类(MForecastRatingResponse)](#MForecastRatingResponse)
		* [调用样例](#ForecastYearSample)
	* [大宗交易](#BlockTradeInfo)
		* [说明](#BlockTradeInfoExplain)
		* [请求类(MBlockTradeInfoRequest)](#MBlockTradeInfoRequest)
		* [应答类(MBlockTradeInfoResponse)](#MBlockTradeInfoResponse)
		* [调用样例](#BlockTradeInfoSample)
	* [基本情况](#CompanyInfo)
		* [说明](#CompanyInfoExplain)
		* [请求类(MCompanyInfoRequest)](#MCompanyInfoRequest)
		* [应答类(MCompanyInfoResponse)](#MCompanyInfoResponse)
		* [调用样例](#CompanyInfoSample)
	* [主要业务](#CoreBusiness)
		* [说明](#CoreBusinessExplain)
		* [请求类(MCoreBusinessRequest)](#MCoreBusinessRequest)
		* [应答类(MCoreBusinessResponse)](#MCoreBusinessResponse)
		* [调用样例](#CoreBusinessSample)
	* [管理层](#LeaderPersonInfo)
		* [说明](#LeaderPersonInfoExplain)
		* [请求类(MLeaderPersonInfoRequest)](#MLeaderPersonInfoRequest)
		* [应答类(MLeaderPersonInfoResponse)](#MLeaderPersonInfoResponse)
		* [调用样例](#LeaderPersonInfoSample)
	* [发行上市](#IPOInfo)
		* [说明](#IPOInfoExplain)
		* [请求类(MIPOInfoRequest)](#MIPOInfoRequest)
		* [应答类(MIPOInfoResponse)](#MIPOInfoResponse)
		* [调用样例](#IPOInfoSample)
	* [财报指标](#FinancialSummary)
		* [说明](#FinancialSummaryExplain)
		* [请求类(MFinancialSummaryRequest)](#MFinancialSummaryRequest)
		* [应答类(MFinancialSummaryResponse)](#MFinancialSummaryResponse)
		* [调用样例](#FinancialSummarySample)
	* [财务报表](#FinancialInfo)
		* [说明](#FinancialInfoExplain)
		* [请求类(MFinancialInfoRequest)](#MFinancialInfoRequest)
		* [应答类(MFinancialInfoResponse)](#MFinancialInfoResponse)
		* [调用样例](#FinancialInfoSample)
	* [股本结构](#StockShareInfo)
		* [说明](#CategoryListExplain)
		* [请求类(MStockShareInfoRequest)](#MStockShareInfoRequest)
		* [应答类(MStockShareInfoResponse)](#MStockShareInfoResponse)
		* [调用样例](#StockShareInfoSample)
	* [股本变动](#StockShareChangeInfo)
		* [说明](#StockShareChangeInfoExplain)
		* [请求类(MStockShareChangeInfoRequest)](#MStockShareChangeInfoRequest)
		* [应答类(MStockShareChangeInfoResponse)](#MStockShareChangeInfoResponse)
		* [调用样例](#StockShareChangeInfoSample)
	* [股东变动](#ShareHolderHistoryInfo)
		* [说明](#ShareHolderHistoryInfoExplain)
		* [请求类(MShareHolderHistoryInfoRequest)](#MShareHolderHistoryInfoRequest)
		* [应答类(MShareHolderHistoryInfoResponse)](#MShareHolderHistoryInfoResponse)
		* [调用样例](#ShareHolderHistoryInfoSample)
	* [最新十大流通股股东](#TopLiquidShareHolder)
		* [说明](#TopLiquidShareHolderExplain)
		* [请求类(MTopLiquidShareHolderRequest)](#MTopLiquidShareHolderRequest)
		* [应答类(MTopLiquidShareHolderResponse)](#MTopLiquidShareHolderResponse)
		* [调用样例](#TopLiquidShareHolderSample)
	* [十大机构股东](#TopShareHolder)
		* [说明](#TopShareHolderExplain)
		* [请求类(MTopShareHolderRequest)](#MTopShareHolderRequest)
		* [应答类(MTopShareHolderResponse)](#MTopShareHolderResponse)
		* [调用样例](#TopShareHolderSample)
	* [最新基金持股](#FundShareHolder)
		* [说明](#FundShareHolderExplain)
		* [请求类(MFundShareHolderInfoRequest)](#MFundShareHolderInfoRequest)
		* [应答类(MFundShareHolderInfoResponse)](#MFundShareHolderInfoResponse)
		* [调用样例](#FundShareHolderSample)
	* [控股股东](#ControlingShareHolder)
		* [说明](#ControlingShareHolderExplain)
		* [请求类(MControlingShareHolderRequest)](#MControlingShareHolderRequest)
		* [应答类(MControlingShareHolderResponse)](#MControlingShareHolderResponse)
		* [调用样例](#ControlingShareHolderSample)
	* [财经资讯列表](#NewsList)
		* [说明](#NewsListExplain)
		* [请求类(MNewsListRequest)](#MNewsListRequest)
		* [应答类(MNewsListResponse)](#MNewsListResponse)
		* [调用样例](#NewsListSample)
	* [财经资讯明细](#News)
		* [说明](#NewsExplain)
		* [请求类(MNewsRequest)](#MNewsRequest)
		* [应答类(MNewsResponse)](#MNewsResponse)
		* [调用样例](#NewsSample)
	* [个股公告列表](#StockBulletinList)
		* [说明](#StockBulletinListExplain)
		* [请求类(MStockBulletinListRequest)](#MStockBulletinListRequest)
		* [应答类(MStockBulletinListResponse)](#MStockBulletinListResponse)
		* [调用样例](#StockBulletinListSample)
	* [个股公告明细](#StockBulletin)
		* [说明](#StockBulletinExplain)
		* [请求类(MStockBulletinRequest)](#MStockBulletinRequest)
		* [应答类(MStockBulletinResponse)](#MStockBulletinResponse)
		* [调用样例](#StockBulletinSample)
	* [个股新闻列表](#StockNewsList)
		* [说明](#StockNewsListExplain)
		* [请求类(MStockNewsListRequest)](#MStockNewsListRequest)
		* [应答类(MStockNewsListResponse)](#MStockNewsListResponse)
		* [调用样例](#StockNewsListSample)
	* [个股新闻明细](#StockNews)
		* [说明](#StockNewsExplain)
		* [请求类(MStockNewsRequest)](#MStockNewsRequest)
		* [应答类(MStockNewsResponse)](#MStockNewsResponse)
		* [调用样例](#StockNewsSample)
	* [个股研报列表](#StockReportList)
		* [说明](#StockReportListExplain)
		* [请求类(MStockReportListRequest)](#MStockReportListRequest)
		* [应答类(MStockReportListResponse)](#MStockReportListResponse)
		* [调用样例](#StockReportListSample)
	* [个股研报明细](#StockReport)
		* [说明](#StockReportExplain)
		* [请求类(MStockReportRequest)](#MStockReportRequest)
		* [应答类(MStockReportResponse)](#MStockReportResponse)
		* [调用样例](#StockReportSample)
	* [新股上市日期信息](#MIPODate)
		* [说明](#MIPODateExplain)
		* [请求类(MIPODateRequest)](#MIPODateRequest)
		* [应答类(MIPODateResponse)](#MIPODateResponse)
		* [调用样例](#MIPODateSample)
	* [新股列表](#MIPOCalendar)
		* [说明](#MIPOCalendarExplain)
		* [请求类(MIPOCalendarRequest)](#MIPOCalendarRequest)
		* [应答类(MIPOCalendarResponse)](#MIPOCalendarResponse)
		* [调用样例](#MIPOCalendarSample)
	* [新股详情](#MIPOShareDetail)
		* [说明](#MIPOShareDetailExplain)
		* [请求类(MIPOShareDetailRequest)](#MIPOShareDetailRequest)
		* [应答类(MIPOShareDetailResponse)](#MIPOShareDetailResponse)
		* [调用样例](#MIPOShareDetailSample)
	* [基金净值](#MFundValue)
		* [说明](#MFundValueExplain)
		* [请求类(MFundValueRequest)](#MFundValueRequest)
		* [应答类(MFundValueResponse)](#MFundValueResponse)
		* [调用样例](#MFundValueSample)
	* [基金概况](#MFundBasicInfo)
		* [说明](#MFundBasicInfoExplain)
		* [请求类(MFundBasicInfoRequest)](#MFundBasicInfoRequest)
		* [应答类(MFundBasicInfoResponse)](#MFundBasicInfoResponse)
		* [调用样例](#MFundBasicInfoSample)
	* [基金净值(5天)](#MFundNetValue)
		* [说明](#MFundNetValueExplain)
		* [请求类(MFundNetValueRequest)](#MFundNetValueRequest)
		* [应答类(MFundNetValueResponse)](#MFundNetValueResponse)
		* [调用样例](#MFundNetValueSample)
	* [资产配置](#MFundAssetAllocation)
		* [说明](#MFundAssetAllocationExplain)
		* [请求类(MFundAssetAllocationRequest)](#MFundAssetAllocationRequest)
		* [应答类(MFundAssetAllocationResponse)](#MFundAssetAllocationResponse)
		* [调用样例](#MFundAssetAllocationSample)
	* [行业组合](#MFundIndustryPortfolio)
		* [说明](#MFundIndustryPortfolioExplain)
		* [请求类(MFundIndustryPortfolioRequest)](#MFundIndustryPortfolioRequest)
		* [应答类(MFundIndustryPortfolioResponse)](#MFundIndustryPortfolioResponse)
		* [调用样例](#MFundIndustryPortfolioSample)
	* [股票组合](#MFundStockPortfolio)
		* [说明](#MFundStockPortfolioExplain)
		* [请求类(MFundStockPortfolioRequest)](#MFundStockPortfolioRequest)
		* [应答类(MFundStockPortfolioResponse)](#MFundStockPortfolioResponse)
		* [调用样例](#MFundStockPortfolioSample)
	* [份额结构](#MFundShareStruct)
		* [说明](#MFundShareStructExplain)
		* [请求类(MFundShareStructRequest)](#MFundShareStructRequest)
		* [应答类(MFundShareStructResponse)](#MFundShareStructResponse)
		* [调用样例](#MFundShareStructSample)
	* [基金财务](#MFundFinance)
		* [说明](#MFundFinanceExplain)
		* [请求类(MFundFinanceRequest)](#MFundFinanceRequest)
		* [应答类(MFundFinanceResponse)](#MFundFinanceResponse)
		* [调用样例](#MFundFinanceSample)
	* [基金分红](#MFundDividend)
		* [说明](#MFundDividendExplain)
		* [请求类(MFundDividendRequest)](#MFundDividendRequest)
		* [应答类(MFundDividendResponse)](#MFundDividendResponse)
		* [调用样例](#MFundDividendSample)
	* [债券概况](#MBondBasicInfo)
		* [说明](#MBondBasicInfoExplain)
		* [请求类(MBondBasicInfoRequest)](#MBondBasicInfoRequest)
		* [应答类(MBondBasicInfoResponse)](#MBondBasicInfoResponse)
		* [调用样例](#MBondBasicInfoSample)
	* [付息情况](#MBondInterestPay)
		* [说明](#MBondInterestPayExplain)
		* [请求类(MBondInterestPayRequest)](#MBondInterestPayRequest)
		* [应答类(MBondInterestPayResponse)](#MBondInterestPayResponse)
		* [调用样例](#MBondInterestPaySample)
	* [债券回购](#MBondBuyBacks)
		* [说明](#MBondBuyBacksExplain)
		* [请求类(MBondBuyBacksRequest)](#MBondBuyBacksRequest)
		* [应答类(MBondBuyBacksResponse)](#MBondBuyBacksResponse)
		* [调用样例](#MBondBuyBacksSample)

* [数据结构](#数据结构)
	* [个股摘要](#个股摘要)
		* [最新指标](#MLatestIndex)
		* [大事提醒](#MBigEventNotification)
		* [分红配送](#MBonusFinanceInfo)
		* [融资融券](#MTradeDetailInfo)
		* [大宗交易](#MBlockTradeInfo)
	* [个股简况](#个股简况)
		* [基本情况](#MCompanyInfo)
		* [主要业务](#MCoreBusiness)
		* [管理层](#MLeaderPersonInfo)
		* [发行上市](#MIPOInfo)
	* [财务分析](#财务分析)
		* [财报指标](#MFinancialSummary)
		* [财务报表](#MFinancialInfo)
	* [个股股东](#个股股东)	
		* [控股股东](#MControlingShareHolder)
		* [股本结构](#MStockShareInfo)
		* [股本变动](#MStockShareChangeInfo)
		* [股东变动](#MShareHolderHistoryInfo)
		* [股东](#MShareHolderInfo)
		* [基金持股](#MFundShareHolderInfo)
  * [个股资讯](#个股资讯)
    * [个股公告(MStockBulletinItem)](#MStockBulletinItem)
    * [个股公告内文(MStockBulletinDetailItem)](#MStockBulletinDetailItem)
    * [个股新闻(MStockNewsItem)](#MStockNewsItem)
    * [个股新闻内文(MStockNewsDetailItem)](#MStockNewsDetailItem)
    * [个股研报(MStockReportItem)](#MStockReportItem)
    * [个股研报内文(MStockReportDetailItem)](#MStockReportDetailItem)
  * [新闻资讯](#新闻资讯)
    * [财经资讯列表](#MFininfolist)
    * [财经资讯明细](#MFininfodetail) 
    
* 其他
	* [新闻列表请求类别(MNewsType)](#MNewsType)
	* [f10数据来源类型(MF10DataSourceType)](#MF10DataSourceType)

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

| 说明           | 类名 | 备注               |
|----------------|------|--------------------|
| 应用程序接口类 | [MApi](#MApi) | 初始化、发送请求用 |

<h4 id="请求类别列表">请求类别列表</h4>

| 说明               | 类名                           | 备注 |
|--------------------|--------------------------------|------|
| 最新指标           | [MLatestIndexRequest](#MLatestIndexRequest)            |      |
| 大事提醒           | [MBigEventNotificationRequest](#MBigEventNotificationRequest)   |      |
| 分红配送           | [MBonusFinanceRequest](#MBonusFinanceRequest)           |      |
| 融资融券           | [MTradeDetailInfoRequest](#MTradeDetailInfoRequest)        |      |
| 机构预测           | [MForecastYearRequest](#MForecastYearRequest)           |      |
| 机构评等           | [MForecastRatingRequest](#MForecastRatingRequest)         |      |
| 大宗交易           | [MBlockTradeInfoRequest](#MBlockTradeInfoRequest)         |      |
| 基本情况           | [MCompanyInfoRequest](#MCompanyInfoRequest)            |      |
| 主要业务           | [MCoreBusinessRequest](#MCoreBusinessRequest)           |      |
| 管理层             | [MLeaderPersonInfoRequest](#MLeaderPersonInfoRequest)       |      |
| 发行上市           | [MIPOInfoRequest](#MIPOInfoRequest)                |      |
| 财报指标           | [MFinancialSummaryRequest](#MFinancialSummaryRequest)       |      |
| 财务报表           | [MFinancialInfoRequest](#MFinancialInfoRequest)          |      |
| 控股股东           | [MControlingShareHolderRequest](#MControlingShareHolderRequest)  |      |
| 股本结构           | [MStockShareInfoRequest](#MStockShareInfoRequest)         |      |
| 股本变动           | [MStockShareChangeInfoRequest](#MStockShareChangeInfoRequest)   |      |
| 股东变动           | [MShareHolderHistoryInfoRequest](#MShareHolderHistoryInfoRequest) |      |
| 最新十大流通股股东 | [MTopLiquidShareHolderRequest](#MTopLiquidShareHolderRequest)   |      |
| 十大机构股东     | [MTopShareHolderRequest](#MTopShareHolderRequest)         |      |
| 最新基金持股       | [MFundShareHolderInfoRequest](#MFundShareHolderInfoRequest)    |      |
| 财经资讯列表       | [MNewsListRequest](#MNewsListRequest)               |      |
| 财经资讯明细       | [MNewsRequest](#MNewsRequest)                   |      |
| 个股公告列表       | [MStockBulletinListRequest](#MStockBulletinListRequest)      |      |
| 个股公告明细       | [MStockBulletinRequest](#MStockBulletinRequest)          |      |
| 个股研报列表       | [MStockReportListRequest](#MStockReportListRequest)        |      |
| 个股研报明细       | [MStockReportRequest](#MStockReportRequest)            |      |
| 基金概况       | [MFundBasicInfoRequest](#MFundBasicInfoRequest)            |      |
| 基金净值       | [MFundNetValueRequest](#MFundNetValueRequest)            |      |
| 资产配置       | [MFundAssetAllocationRequest](#MFundAssetAllocationRequest)            |      |
| 行业组合       | [MFundIndustryPortfolioRequest](#MFundIndustryPortfolioRequest)            |      |
| 股票组合       | [MFundStockPortfolioRequest](#MFundStockPortfolioRequest)            |      |
| 份额结构       | [MFundShareStructRequest](#MFundShareStructRequest)            |      |
| 基金财务       | [MFundFinanceRequest](#MFundFinanceRequest)            |      |
| 基金分红       | [MFundDividendRequest](#MFundDividendRequest)            |      |
| 债券概况       | [MBondBasicInfoRequest](#MBondBasicInfoRequest)            |      |
| 付息情况       | [MBondInterestPayRequest](#MBondInterestPayRequest)            |      |
| 债券回购       | [MBondBuyBacksRequest](#MBondBuyBacksRequest)            |      |

[top](#top)

<h4 id="应答类别列表">应答类别列表</h4>

| 说明               | 类名                            | 备注 |
|--------------------|---------------------------------|------|
| 最新指标           | [MLatestIndexRequest](#MLatestIndexRequest)             |      |
| 大事提醒           | [MBigEventNotificationRequest](#MBigEventNotificationRequest)    |      |
| 分红配送           | [MBonusFinanceResponse](#MBonusFinanceResponse)           |      |
| 融资融券           | [MTradeDetailInfoResponse](#MTradeDetailInfoResponse)        |      |
| 机构预测           | [MForecastYearResponse](#MForecastYearResponse)           |      |
| 机构评等           | [MForecastRatingResponse](#MForecastRatingResponse)         |      |
| 大宗交易           | [MBlockTradeInfoResponse](#MBlockTradeInfoResponse)         |      |
| 基本情况           | [MCompanyInfoResponse](#MCompanyInfoResponse)            |      |
| 主要业务           | [MCoreBusinessResponse](#MCoreBusinessResponse)           |      |
| 管理层             | [MLeaderPersonInfoResponse](#MLeaderPersonInfoResponse)       |      |
| 发行上市           | [MIPOInfoResponse](#MIPOInfoResponse)                |      |
| 财报指标           | [MFinancialSummaryResponse](#MFinancialSummaryResponse)       |      |
| 财务报表           | [MFinancialInfoResponse](#MFinancialInfoResponse)          |      |
| 控股股东           | [MControlingShareHolderResponse](#MControlingShareHolderResponse)  |      |
| 股本结构           | [MStockShareInfoResponse](#MStockShareInfoResponse)         |      |
| 股本变动           | [MStockShareChangeInfoResponse](#MStockShareChangeInfoResponse)   |      |
| 股东变动           | [MShareHolderHistoryInfoResponse](#MShareHolderHistoryInfoResponse) |      |
| 最新十大流通股股东 | [MTopLiquidShareHolderResponse](#MTopLiquidShareHolderResponse)   |      |
| 十大机构股东     | [MTopShareHolderResponse](#MTopShareHolderResponse)         |      |
| 最新基金持股       | [MFundShareHolderInfoResponse](#MFundShareHolderInfoResponse)    |      |
| 财经资讯列表       | [MNewsListResponse](#MNewsListResponse)               |      |
| 财经资讯明细       | [MNewsResponse](#MNewsResponse)                   |      |
| 个股公告列表       | [MStockBulletinListResponse](#MStockBulletinListResponse)      |      |
| 个股公告明细       | [MStockBulletinResponse](#MStockBulletinResponse)          |      |
| 个股研报列表       | [MStockReportListResponse](#MStockReportListResponse)        |      |
| 个股研报明细       | [MStockReportResponse](#MStockReportResponse)            |      |
| 基金概况       | [MFundBasicInfoResponse](#MFundBasicInfoResponse)            |      |
| 基金净值       | [MFundNetValueResponse](#MFundNetValueResponse)            |      |
| 资产配置       | [MFundAssetAllocationResponse](#MFundAssetAllocationResponse)            |      |
| 行业组合       | [MFundIndustryPortfolioResponse](#MFundIndustryPortfolioResponse)            |      |
| 股票组合       | [MFundStockPortfolioResponse](#MFundStockPortfolioResponse)            |      |
| 份额结构       | [MFundShareStructResponse](#MFundShareStructResponse)            |      |
| 基金财务       | [MFundFinanceResponse](#MFundFinanceResponse)            |      |
| 基金分红       | [MFundDividendResponse](#MFundDividendResponse)            |      |
| 债券概况       | [MBondBasicInfoResponse](#MBondBasicInfoResponse)            |      |
| 付息情况       | [MBondInterestPayResponse](#MBondInterestPayResponse)            |      |
| 债券回购       | [MBondBuyBacksResponse](#MBondBuyBacksResponse)            |      |

[top](#top)

<h4 id="数据结构列表">数据结构列表</h4>

| 说明         | 类名                     | 备注 |
|--------------|--------------------------|------|
| 最新指标     | [MLatestIndex](#MLatestIndex)             |      |
| 大事提醒     | [MBigEventNotification](#MBigEventNotification)    |      |
| 分红配送     | [MBonusFinanceInfo](#MBonusFinanceInfo)        |      |
| 融资融券     | [MTradeDetailInfo](#MTradeDetailInfo)         |      |
| 机构预测     | [MForecastYear](#MForecastYear)            |      |
| 机构评等     | [MForecastRating](#MForecastRating)          |      |
| 大宗交易     | [MBlockTradeInfo](#MBlockTradeInfo)          |      |
| 基本情况     | [MCompanyInfo](#MCompanyInfo)             |      |
| 主要业务     | [MCoreBusiness](#MCoreBusiness)            |      |
| 管理层       | [MLeaderPersonInfo](#MLeaderPersonInfo)        |      |
| 发行上市     | [MIPOInfo](#MIPOInfo)                 |      |
| 财报指标     | [MFinancialSummary](#MFinancialSummary)        |      |
| 财务报表     | [MFinancialInfo](#MFinancialInfo)           |      |
| 控股股东     | [MControlingShareHolder](#MControlingShareHolder)   |      |
| 股本结构     | [MStockShareInfo](#MStockShareInfo)          |      |
| 股本变动     | [MStockShareChangeInfo](#MStockShareChangeInfo)    |      |
| 股东变动     | [MShareHolderHistoryInfo](#MShareHolderHistoryInfo)  |      |
| 股东         | [MShareHolderInfo](#MShareHolderInfo)         |      |
| 基金持股     | [MFundShareHolderInfo](#MFundShareHolderInfo)     |      |
| 财经资讯     | [MNewsItem](#MNewsItem)                |      |
| 财经资讯明细 | [MNewsDetailItem](#MNewsDetailItem)          |      |
| 个股公告     | [MStockBulletinItem](#MStockBulletinItem)       |      |
| 个股公告内文 | [MStockBulletinDetailItem](#MStockBulletinDetailItem) |      |
| 个股新闻     | [MStockNewsItem](#MStockNewsItem)           |      |
| 个股新闻内文 | [MStockNewsDetailItem](#MStockNewsDetailItem)     |      |
| 个股研报     | [MStockReportItem](#MStockReportItem)         |      |
| 个股研报内文 | [MStockReportDetailItem](#MStockReportDetailItem)   |      |

[top](#top)

<h4 id="错误代码列表">错误代码列表</h4>

| 说明             | 列举名                 | 备注 |
|------------------|----------------------|------|
| 请求成功        | MResponseStatusSuccess | 200 |
| session失效    | MResponseStatusSessionExpired | 401 |
| 请求失败        | MResponseStatusNoData | 404 |
| 业务异常        | MResponseStatusServerError | 500 |
| 网关错误        | MResponseStatusParameterError | 502 |
| 请求逾时        | MResponseStatusTimeout | -1001 |
| 无法连结到主机   | MResponseStatusNotReachabled | -1002 |
| 应答信息处理失败  | MResponseStatusDataParseError | -1003 |
| 服务器无应答信息  | MResponseStatusDataNil | -1004 |

[top](#top)

<h2 id="使用说明">使用说明</h2>

<h3 id="MApi">应用程序接口</h3>

<h4 id="InitExplain">说明</h4>

* 初始化方法说明:

	`+ (void)registerAPP:(NSString *)appkey completionHandler:(void (^)(NSError *error))handler;`
	
		* MApi的成员函数，与服务器注册接口的使用许可。
		* appkey: 许可键值。
		* error: 注册失败错误对象。
		* return: 成功返回YES，失败返回NO。

* 发送方法说明:
		
	`+ (BOOL)sendRequest:(MRequest *)request completionHandler:(MApiCompletionHandler)handler;`
	
		* 发送请求至行情服务器。
		* request: 具体的发送对象。
		* handler: 回调函式(返回回应内容对象)。
		* return: 成功返回YES，失败返回NO。

<h4 id="InitSample">调用样例</h4>	

	- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
		//初始化接口
    	[MApi registerAPP:@"anAppKey"completionHandler:^(NSError *error) {
			if(error) {
            	[self initialCompleted];
        	} else {
            	[Utility alertMessage:[error localizedDescription]];
        	}
    	}];
		returnYES;
	}

[top](#top)

<h3 id="LatestIndex">最新指标</h3>

<h4 id="LatestIndexExplain">说明</h4>

* 查询个股最新指标

<h4 id="MLatestIndexRequest">请求类：MLatestIndexRequest</h4>

* 属性说明:

| 属性名 | 说明     | 型态     | 备注 |
|--------|----------|----------|------|
| code   | 股票代码 | NSString |      |
| sourceType | 来源 | [MF10DataSourceType](#MF10DataSourceType) |   默认为MF10DataSourceGA   |
	
<h4 id="MLatestIndexResponse">应答类：MLatestIndexResponse</h4>

* 属性说明

| 属性名 | 说明     | 型态         | 备注           |
|--------|----------|--------------|----------------|
| record | 最新指标 | NSDictionary | [最新指标键值表](#MLatestIndex) |

<h4 id="LatestIndexSample">调用样例</h4>

    //请求个股最新指标
    MLatestIndexRequest *request = [[MLatestIndexRequest alloc] init];
    request.code = self.stockItem.ID; //填入股票代码
    
    //发送请求
    [MApi sendRequest:request completionHandler:^(MResponse *resp) {
        if(resp.status == MResponseStatusSuccess) {
            //应答无误，处理数据更新画面
            MLatestIndexResponse *response = (MLatestIndexResponse *)resp;
            self.record = response.record;
            [self reloadData];
        } else {
            //应答错误，显示错误信息
            [Utility alertMessage:resp.message];
        }
    }];
    
[top](#top)    
    
<h3 id="BigEventNotification">大事提醒</h3>

<h4 id="BigEventNotificationExplain">说明</h4>

* 查询个股大事提醒

<h4 id="MBigEventNotificationRequest">请求类：MBigEventNotificationRequest</h4>

* 属性说明:

| 属性名 | 说明     | 型态     | 备注 |
|--------|----------|----------|------|
| code   | 股票代码 | NSString |      |
| sourceType | 来源 | [MF10DataSourceType](#MF10DataSourceType) |   默认为MF10DataSourceGA   |

	
<h4 id="MBigEventNotificationResponse">应答类：MBigEventNotificationResponse</h4>

* 属性说明

| 属性名 | 说明     | 型态         | 备注           |
|--------|----------|--------------|----------------|
| record | 大事提醒 | NSDictionary | [大事提醒键值表](#MBigEventNotification) |

<h4 id="BigEventNotificationSample">调用样例</h4>

    //请求个股大事提醒
    MBigEventNotificationRequest *request = [[MBigEventNotificationRequest alloc] init];
    request.code = self.stockItem.ID; //填入股票代码

    //发送请求
    [MApi sendRequest:request completionHandler:^(MResponse *resp) {
        if(resp.status == MResponseStatusSuccess) {
            //应答无误，处理数据更新画面
            MBigEventNotificationResponse *response = (MBigEventNotificationResponse *)resp;
            self.record = response.record;
            [self reloadData];
        } else {
            //应答错误，显示错误信息
            [Utility alertMessage:resp.message];
        }
    }];

[top](#top)

<h3 id="BonusFinance">分红配送</h3>

<h4 id="BonusFinanceExplain">说明</h4>

* 查询个股分红配送资讯

<h4 id="MBonusFinanceRequest">请求类：MBonusFinanceRequest</h4>

* 属性说明:

| 属性名 | 说明     | 型态     | 备注 |
|--------|----------|----------|------|
| code   | 股票代码 | NSString |      |
| sourceType | 来源 | [MF10DataSourceType](#MF10DataSourceType) |   默认为MF10DataSourceGA   |
	
<h4 id="MBonusFinanceResponse">应答类：MBonusFinanceResponse</h4>

* 属性说明

| 属性名  | 说明         | 型态    | 备注           |
|---------|--------------|---------|----------------|
| records | 分红配送列表 | NSArray | [分红配送键值表](#MBonusFinanceInfo) |

<h4 id="BonusFinanceSample">调用样例</h4>

    //请求个股分红配送资讯
    MBonusFinanceRequest *request = [[MBonusFinanceRequest alloc] init];
    request.code = self.stockItem.ID; //填入股票代码
    
    //发送请求
    [MApi sendRequest:request completionHandler:^(MResponse *resp) {
        if(resp.status == MResponseStatusSuccess) {
            //应答无误，处理数据更新画面
            MBonusFinanceResponse *response = (MBonusFinanceResponse *)resp;
            self.records = response.records;
            [self reloadData];
        } else {
            //应答错误，显示错误信息
            [Utility alertMessage:resp.message];
        }
    }];

[top](#top)

<h3 id="TradeDetailInfo">融资融券</h3>

<h4 id="TradeDetailInfoExplain">说明</h4>

* 查询个股融资融券资讯

<h4 id="MTradeDetailInfoRequest">请求类：MTradeDetailInfoRequest</h4>

* 属性说明:

| 属性名 | 说明     | 型态     | 备注 |
|--------|----------|----------|------|
| code   | 股票代码 | NSString |      |
| sourceType | 来源 | [MF10DataSourceType](#MF10DataSourceType) |   默认为MF10DataSourceGA   |

	
<h4 id="MTradeDetailInfoResponse">应答类：MTradeDetailInfoResponse</h4>

* 属性说明

| 属性名 | 说明     | 型态         | 备注           |
|--------|----------|--------------|----------------|
| record | 融资融券 | NSDictionary | [融资融券键值表](#MTradeDetailInfo) |

<h4 id="TradeDetailInfoSample">调用样例</h4>	

    //请求个股融资融券资讯
    MTradeDetailInfoRequest *request = [[MTradeDetailInfoRequest alloc] init];
    request.code = self.stockItem.ID; //填入股票代码
    
    //发送请求
    [MApi sendRequest:request completionHandler:^(MResponse *resp) {
        if(resp.status == MResponseStatusSuccess) {
            //应答无误，处理数据更新画面
            MTradeDetailInfoResponse *response = (MTradeDetailInfoResponse *)resp;
            self.record = response.record;
            [self reloadData];
        } else {
            //应答错误，显示错误信息
            [Utility alertMessage:resp.message];
        }
    }];
    
[top](#top)    
    
<h3 id="ForecastYear">机构预测</h3>

<h4 id="ForecastYearExplain">说明</h4>

* 查询个股机构预测资讯

<h4 id="MForecastYearRequest">请求类：MForecastYearRequest</h4>

* 属性说明:

| 属性名 | 说明     | 型态     | 备注 |
|--------|----------|----------|------|
| code   | 股票代码 | NSString |      |
| sourceType | 来源 | [MF10DataSourceType](#MF10DataSourceType) |   默认为MF10DataSourceGA   |

	
<h4 id="MForecastYearResponse">应答类：MForecastYearResponse</h4>

* 属性说明

| 属性名 | 说明     | 型态         | 备注           |
|--------|----------|--------------|----------------|
| record | 机构预测 | NSDictionary | [机构预测键值表](#MForecastYear) |

<h4 id="ForecastYearSample">调用样例</h4>	

    //请求个股机构预测资讯
    MForecastYearRequest *request = [[MForecastYearRequest alloc] init];
    request.code = self.stockItem.ID; //填入股票代码
    
    //发送请求
    [MApi sendRequest:request completionHandler:^(MResponse *resp) {
        if(resp.status == MResponseStatusSuccess) {
            //应答无误，处理数据更新画面
            MForecastYearResponse *response = (MForecastYearResponse *)resp;
            self.record = response.record;
            [self reloadData];
        } else {
            //应答错误，显示错误信息
            [Utility alertMessage:resp.message];
        }
    }];
    
[top](#top)    
    
<h3 id="ForecastRating">机构评等</h3>

<h4 id="ForecastRatingExplain">说明</h4>

* 查询个股机构评等资讯

<h4 id="MForecastRatingRequest">请求类：MForecastRatingRequest</h4>

* 属性说明:

| 属性名 | 说明     | 型态     | 备注 |
|--------|----------|----------|------|
| code   | 股票代码 | NSString |      |
| sourceType | 来源 | [MF10DataSourceType](#MF10DataSourceType) |   默认为MF10DataSourceGA   |

	
<h4 id="MForecastRatingResponse">应答类：MForecastRatingResponse</h4>

* 属性说明

| 属性名 | 说明     | 型态         | 备注           |
|--------|----------|--------------|----------------|
| record | 机构评等 | NSDictionary | [机构评等键值表](#MForecastRating) |

<h4 id="ForecastRatingSample">调用样例</h4>	

    //请求个股机构评等资讯
    MForecastRatingRequest *request = [[MForecastRatingRequest alloc] init];
    request.code = self.stockItem.ID; //填入股票代码
    
    //发送请求
    [MApi sendRequest:request completionHandler:^(MResponse *resp) {
        if(resp.status == MResponseStatusSuccess) {
            //应答无误，处理数据更新画面
            MForecastRatingResponse *response = (MForecastRatingResponse *)resp;
            self.record = response.record;
            [self reloadData];
        } else {
            //应答错误，显示错误信息
            [Utility alertMessage:resp.message];
        }
    }];
    
[top](#top)    
    
<h3 id="BlockTradeInfo">大宗交易</h3>

<h4 id="BlockTradeInfoExplain">说明</h4>

* 查询个股大宗交易资讯

<h4 id="MBlockTradeInfoRequest">请求类：MBlockTradeInfoRequest</h4>

* 属性说明:

| 属性名 | 说明     | 型态     | 备注 |
|--------|----------|----------|------|
| code   | 股票代码 | NSString |      |
| sourceType | 来源 | [MF10DataSourceType](#MF10DataSourceType) |   默认为MF10DataSourceGA   |

	
<h4 id="MBlockTradeInfoResponse">应答类：MBlockTradeInfoResponse</h4>

* 属性说明

| 属性名  | 说明         | 型态    | 备注           |
|---------|--------------|---------|----------------|
| records | 大宗交易列表 | NSArray | [大宗交易键值表](#MBlockTradeInfo) |

<h4 id="BlockTradeInfoSample">调用样例</h4>	

    //请求个股大宗交易资讯
    MBlockTradeInfoRequest *request = [[MBlockTradeInfoRequest alloc] init];
    request.code = self.stockItem.ID; //填入股票代码
    
    //发送请求
    [MApi sendRequest:request completionHandler:^(MResponse *resp) {
        if(resp.status == MResponseStatusSuccess) {
            //应答无误，处理数据更新画面
            MBlockTradeInfoResponse *response = (MBlockTradeInfoResponse *)resp;
            self.records = response.records;
            [self reloadData];
        } else {
            //应答错误，显示错误信息
            [Utility alertMessage:resp.message];
        }
    }];
    
[top](#top)    
    
<h3 id="CompanyInfo">基本情况</h3>

<h4 id="CompanyInfoExplain">说明</h4>

* 查询个股基本情况

<h4 id="MCompanyInfoRequest">请求类：MCompanyInfoRequest</h4>

* 属性说明:

| 属性名 | 说明     | 型态     | 备注 |
|--------|----------|----------|------|
| code   | 股票代码 | NSString |      |
| sourceType | 来源 | [MF10DataSourceType](#MF10DataSourceType) |   默认为MF10DataSourceGA   |
	
<h4 id="MCompanyInfoResponse">应答类：MCompanyInfoResponse</h4>

* 属性说明

| 属性名 | 说明         | 型态         | 备注           |
|--------|--------------|--------------|----------------|
| record | 基本情况列表 | NSDictionary | [基本情况键值表](#MCompanyInfo) |

<h4 id="CompanyInfoSample">调用样例</h4>

    //请求个股基本情况
    MCompanyInfoRequest *request = [[MCompanyInfoRequest alloc] init];
    request.code = self.stockItem.ID; //填入股票代码
    
    //发送请求
    [MApi sendRequest:request completionHandler:^(MResponse *resp) {
        if(resp.status == MResponseStatusSuccess) {
            //应答无误，处理数据更新画面
            MCompanyInfoResponse *response = (MCompanyInfoResponse *)resp;
            self.record = response.record;
            [self reloadData];
        } else {
            //应答错误，显示错误信息
            [Utility alertMessage:resp.message];
        }
    }];
    
[top](#top)    
    
<h3 id="CoreBusiness">主要业务</h3>

<h4 id="CoreBusinessExplain">说明</h4>

* 查询个股主要业务

<h4 id="MCoreBusinessRequest">请求类：MCoreBusinessRequest</h4>

* 属性说明:

| 属性名 | 说明     | 型态     | 备注 |
|--------|----------|----------|------|
| code   | 股票代码 | NSString |      |
| sourceType | 来源 | [MF10DataSourceType](#MF10DataSourceType) |   默认为MF10DataSourceGA   |

	
<h4 id="MCoreBusinessResponse">应答类：MCoreBusinessResponse</h4>

* 属性说明

| 属性名  | 说明         | 型态    | 备注           |
|---------|--------------|---------|----------------|
| records | 主要业务列表 | NSArray | [主要业务键值表](#MCoreBusiness) |

<h4 id="CoreBusinessSample">调用样例</h4>

    //请求个股主要业务
    MCoreBusinessRequest *request = [[MCoreBusinessRequest alloc] init];
    request.code = self.stockItem.ID; //填入股票代码
    
    //发送请求
    [MApi sendRequest:request completionHandler:^(MResponse *resp) {
        if(resp.status == MResponseStatusSuccess) {
            //应答无误，处理数据更新画面
            MCoreBusinessResponse *response = (MCoreBusinessResponse *)resp;
            self.records = response.records;
            [self reloadData];
        } else {
            //应答错误，显示错误信息
            [Utility alertMessage:resp.message];
        }
    }];

[top](#top)

<h3 id="LeaderPersonInfo">管理层</h3>

<h4 id="LeaderPersonInfoExplain">说明</h4>

* 查询个股管理层资讯

<h4 id="MLeaderPersonInfoRequest">请求类：MLeaderPersonInfoRequest</h4>

* 属性说明:

| 属性名 | 说明     | 型态     | 备注 |
|--------|----------|----------|------|
| code   | 股票代码 | NSString |      |
| sourceType | 来源 | [MF10DataSourceType](#MF10DataSourceType) |   默认为MF10DataSourceGA   |
	
<h4 id="MLeaderPersonInfoResponse">应答类：MLeaderPersonInfoResponse</h4>

* 属性说明

| 属性名  | 说明       | 型态    | 备注         |
|---------|------------|---------|--------------|
| records | 管理层列表 | NSArray | [管理层键值表](#MLeaderPersonInfo) |

<h4 id="LeaderPersonInfoSample">调用样例</h4>		

    //请求个股管理层资讯
    MLeaderPersonInfoRequest *request = [[MLeaderPersonInfoRequest alloc] init];
    request.code = self.stockItem.ID; //填入股票代码
    
    //发送请求
    [MApi sendRequest:request completionHandler:^(MResponse *resp) {
        if(resp.status == MResponseStatusSuccess) {
            //应答无误，处理数据更新画面
            MLeaderPersonInfoResponse *response = (MLeaderPersonInfoResponse *)resp;
            self.records = response.records;
            [self reloadData];
        } else {
            //应答错误，显示错误信息
            [Utility alertMessage:resp.message];
        }
    }];    

[top](#top)

<h3 id="IPOInfo">发行上市</h3>

<h4 id="IPOInfoExplain">说明</h4>

* 查询个股发行上市资讯

<h4 id="MIPOInfoRequest">请求类：MIPOInfoRequest</h4>

* 属性说明:

| 属性名 | 说明     | 型态     | 备注 |
|--------|----------|----------|------|
| code   | 股票代码 | NSString |      |
| sourceType | 来源 | [MF10DataSourceType](#MF10DataSourceType) |   默认为MF10DataSourceGA   |


	
<h4 id="MIPOInfoResponse">应答类：MIPOInfoResponse</h4>

* 属性说明

| 属性名 | 说明     | 型态         | 备注           |
|--------|----------|--------------|----------------|
| record | 发行上市 | NSDictionary | [发行上市键值表](#MIPOInfo) |

<h4 id="IPOInfoSample">调用样例</h4>	

    //请求个股发行上市资讯
    MIPOInfoRequest *request = [[MIPOInfoRequest alloc] init];
    request.code = self.stockItem.ID; //填入股票代码
    
    //发送请求
    [MApi sendRequest:request completionHandler:^(MResponse *resp) {
        if(resp.status == MResponseStatusSuccess) {
            //应答无误，处理数据更新画面
            MIPOInfoResponse *response = (MIPOInfoResponse *)resp;
            self.record = response.record;
            [self reloadData];
        } else {
            //应答错误，显示错误信息
            [Utility alertMessage:resp.message];
        }
    }];

[top](#top)

<h3 id="FinancialSummary">财务指标</h3>

<h4 id="FinancialSummaryExplain">说明</h4>

* 查询个股财务指标

<h4 id="MFinancialSummaryRequest">请求类：MFinancialSummaryRequest</h4>

* 属性说明:

| 属性名 | 说明     | 型态     | 备注 |
|--------|----------|----------|------|
| code   | 股票代码 | NSString |      |
| sourceType | 来源 | [MF10DataSourceType](#MF10DataSourceType) |   默认为MF10DataSourceGA   |
	
<h4 id="MFinancialSummaryResponse">应答类：MFinancialSummaryResponse</h4>

* 属性说明

| 属性名  | 说明         | 型态    | 备注           |
|---------|--------------|---------|----------------|
| records | 财务指标列表 | NSArray | [财务指标键值表](#MFinancialSummary) |

<h4 id="FinancialSummarySample">调用样例</h4>

    //请求个股务报指标
    MFinancialSummaryRequest *request = [[MFinancialSummaryRequest alloc] init];
    request.code = self.stockItem.ID; //填入股票代码
    
    //发送请求
    [MApi sendRequest:request completionHandler:^(MResponse *resp) {
        if(resp.status == MResponseStatusSuccess) {
            //应答无误，处理数据更新画面
            MFinancialSummaryResponse *response = (MFinancialSummaryResponse *)resp;
            self.records = response.records;
            [self reloadData];
        } else {
            //应答错误，显示错误信息
            [Utility alertMessage:resp.message];
        }
    }];

[top](#top)

<h3 id="FinancialInfo">财务报表</h3>

<h4 id="FinancialInfoExplain">说明</h4>

* 查询个股财务报表

<h4 id="MFinancialInfoRequest">请求类：MFinancialInfoRequest</h4>

* 属性说明:

| 属性名 | 说明     | 型态     | 备注 |
|--------|----------|----------|------|
| code   | 股票代码 | NSString |      |
| sourceType | 来源 | [MF10DataSourceType](#MF10DataSourceType) |   默认为MF10DataSourceGA   |
	
<h4 id="MFinancialInfoResponse">应答类：MFinancialInfoResponse</h4>

* 属性说明

| 属性名  | 说明         | 型态    | 备注           |
|---------|--------------|---------|----------------|
| records | 财务报表列表 | NSArray | [财务报表键值表](#MFinancialInfo) |

<h4 id="FinancialInfoSample">调用样例</h4>

    //请求个股财务报表
    MFinancialInfoRequest *request = [[MFinancialInfoRequest alloc] init];
    request.code = self.stockItem.ID; //填入股票代码
    
    //发送请求
    [MApi sendRequest:request completionHandler:^(MResponse *resp) {
        if(resp.status == MResponseStatusSuccess) {
            //应答无误，处理数据更新画面
            MFinancialInfoResponse *response = (MFinancialInfoResponse *)resp;
            self.records = response.records;
            [self reloadData];
        } else {
            //应答错误，显示错误信息
            [Utility alertMessage:resp.message];
        }
    }];
    
[top](#top)    
    
<h3 id="ControlingShareHolder">控股股东</h3>

<h4 id="ControlingShareHolderExplain">说明</h4>

* 查询个股控股股东资讯

<h4 id="MControlingShareHolderRequest">请求类：MControlingShareHolderRequest</h4>

* 属性说明:

| 属性名 | 说明     | 型态     | 备注 |
|--------|----------|----------|------|
| code   | 股票代码 | NSString |      |
| sourceType | 来源 | [MF10DataSourceType](#MF10DataSourceType) |   默认为MF10DataSourceGA   |

	
<h4 id="MControlingShareHolderResponse">应答类：MControlingShareHolderResponse</h4>

* 属性说明

| 属性名  | 说明         | 型态    | 备注           |
|---------|--------------|---------|----------------|
| records | 控股股东列表 | NSArray | [控股股东键值表](#MControlingShareHolder) |

<h4 id="ControlingShareHolderSample">调用样例</h4>

    //请求个股控股股东资讯
    MControlingShareHolderRequest *request = [[MControlingShareHolderRequest alloc] init];
    request.code = self.stockItem.ID; //填入股票代码
    
    //发送请求
    [MApi sendRequest:request completionHandler:^(MResponse *resp) {
        if(resp.status == MResponseStatusSuccess) {
            //应答无误，处理数据更新画面
            MControlingShareHolderResponse *response = (MControlingShareHolderResponse *)resp;
            self.records = response.records;
            [self reloadData];
        } else {
            //应答错误，显示错误信息
            [Utility alertMessage:resp.message];
        }
    }];	

[top](#top)

<h3 id="StockShareInfo">股本结构</h3>

<h4 id="StockShareInfoExplain">说明</h4>

* 查询个股股本结构资讯

<h4 id="MStockShareInfoRequest">请求类：MStockShareInfoRequest</h4>

* 属性说明:

| 属性名 | 说明     | 型态     | 备注 |
|--------|----------|----------|------|
| code   | 股票代码 | NSString |      |
| sourceType | 来源 | [MF10DataSourceType](#MF10DataSourceType) |   默认为MF10DataSourceGA   |

	
<h4 id="MStockShareInfoResponse">应答类：MStockShareInfoResponse</h4>

* 属性说明

| 属性名 | 说明         | 型态         | 备注           |
|--------|--------------|--------------|----------------|
| record | 股本结构列表 | NSDictionary | [股本结构键值表](#MStockShareInfo) |

<h4 id="StockShareInfoSample">调用样例</h4>

    //请求个股股本结构资讯
    MStockShareInfoRequest *request = [[MStockShareInfoRequest alloc] init];
    request.code = self.stockItem.ID; //填入股票代码
    
    //发送请求
    [MApi sendRequest:request completionHandler:^(MResponse *resp) {
        if(resp.status == MResponseStatusSuccess) {
            //应答无误，处理数据更新画面
            MStockShareInfoResponse *response = (MStockShareInfoResponse *)resp;
            self.record = response.record;
            [self reloadData];
        } else {
            //应答错误，显示错误信息
            [Utility alertMessage:resp.message];
        }
    }];	

[top](#top)

<h3 id="StockShareChangeInfo">股本变动</h3>

<h4 id="StockShareChangeInfoExplain">说明</h4>

* 查询个股股本变动资讯

<h4 id="MStockShareChangeInfoRequest">请求类：MStockShareChangeInfoRequest</h4>

* 属性说明:

| 属性名 | 说明     | 型态     | 备注 |
|--------|----------|----------|------|
| code   | 股票代码 | NSString |      |
| sourceType | 来源 | [MF10DataSourceType](#MF10DataSourceType) |   默认为MF10DataSourceGA   |
	
<h4 id="MStockShareChangeInfoResponse">应答类：MStockShareChangeInfoResponse</h4>

* 属性说明

| 属性名  | 说明         | 型态    | 备注           |
|---------|--------------|---------|----------------|
| records | 股本变动列表 | NSArray | [股本变动键值表](#MStockShareChangeInfo) |

<h4 id="StockShareChangeInfoSample">调用样例</h4>	

    //请求个股股本变动资讯
    MStockShareChangeInfoRequest *request = [[MStockShareChangeInfoRequest alloc] init];
    request.code = self.stockItem.ID; //填入股票代码
    
    //发送请求
    [MApi sendRequest:request completionHandler:^(MResponse *resp) {
        if(resp.status == MResponseStatusSuccess) {
            //应答无误，处理数据更新画面
            MStockShareChangeInfoResponse *response = (MStockShareChangeInfoResponse *)resp;
            self.records = response.records;
            [self reloadData];
        } else {
            //应答错误，显示错误信息
            [Utility alertMessage:resp.message];
        }
    }];

[top](#top)

<h3 id="ShareHolderHistoryInfo">股东变动</h3>

<h4 id="ShareHolderHistoryInfoExplain">说明</h4>

* 查询个股股东变动资讯

<h4 id="MShareHolderHistoryInfoRequest">请求类：MShareHolderHistoryInfoRequest</h4>

* 属性说明:

| 属性名 | 说明     | 型态     | 备注 |
|--------|----------|----------|------|
| code   | 股票代码 | NSString |      |
| sourceType | 来源 | [MF10DataSourceType](#MF10DataSourceType) |   默认为MF10DataSourceGA   |
	
<h4 id="MShareHolderHistoryInfoResponse">应答类：MShareHolderHistoryInfoResponse</h4>

* 属性说明

| 属性名  | 说明         | 型态    | 备注           |
|---------|--------------|---------|----------------|
| records | 股东变动列表 | NSArray | [股东变动键值表](#MShareHolderHistoryInfo) |

<h4 id="ShareHolderHistoryInfoSample">调用样例</h4>	

    //请求个股股东变动资讯
    MShareHolderHistoryInfoRequest *request = [[MShareHolderHistoryInfoRequest alloc] init];
    request.code = self.stockItem.ID; //填入股票代码
    
    //发送请求
    [MApi sendRequest:request completionHandler:^(MResponse *resp) {
        if(resp.status == MResponseStatusSuccess) {
            //应答无误，处理数据更新画面
            MShareHolderHistoryInfoResponse *response = (MShareHolderHistoryInfoResponse *)resp;
            self.records = response.records;
            [self reloadData];
        } else {
            //应答错误，显示错误信息
            [Utility alertMessage:resp.message];
        }
    }];

[top](#top)

<h3 id="TopLiquidShareHolder">最新十大流通股股东</h3>

<h4 id="TopLiquidShareHolderExplain">说明</h4>

* 查询个股最新十大流通股股东

<h4 id="MTopLiquidShareHolderRequest">请求类：MTopLiquidShareHolderRequest</h4>

* 属性说明:

| 属性名 | 说明     | 型态     | 备注 |
|--------|----------|----------|------|
| code   | 股票代码 | NSString |      |
| sourceType | 来源 | [MF10DataSourceType](#MF10DataSourceType) |   默认为MF10DataSourceGA   |
	
<h4 id="MTopLiquidShareHolderResponse">应答类：MTopLiquidShareHolderResponse</h4>

* 属性说明

| 属性名  | 说明     | 型态    | 备注       |
|---------|----------|---------|------------|
| records | 股东列表 | NSArray | [股东键值表](#MTopLiquidShareHolder) |

<h4 id="TopLiquidShareHolderSample">调用样例</h4>	

    //请求个股最新十大流通股股东
    MTopLiquidShareHolderRequest *request = [[MTopLiquidShareHolderRequest alloc] init];
    request.code = self.stockItem.ID; //填入股票代码
    
    //发送请求
    [MApi sendRequest:request completionHandler:^(MResponse *resp) {
        if(resp.status == MResponseStatusSuccess) {
            //应答无误，处理数据更新画面
            MTopLiquidShareHolderResponse *response = (MTopLiquidShareHolderResponse *)resp;
            self.records = response.records;
            [self reloadData];
        } else {
            //应答错误，显示错误信息
            [Utility alertMessage:resp.message];
        }
    }];

[top](#top)

<h3 id="TopShareHolder">十大机构股东</h3>

<h4 id="TopShareHolderExplain">说明</h4>

* 查询个股十大机构股东

<h4 id="MTopShareHolderRequest">请求类：MTopShareHolderRequest</h4>

* 属性说明:

| 属性名 | 说明     | 型态     | 备注 |
|--------|----------|----------|------|
| code   | 股票代码 | NSString |      |
| sourceType | 来源 | [MF10DataSourceType](#MF10DataSourceType) |   默认为MF10DataSourceGA   |
	
<h4 id="MTopShareHolderResponse">应答类：MTopShareHolderResponse</h4>

* 属性说明

| 属性名  | 说明     | 型态    | 备注       |
|---------|----------|---------|------------|
| records | 股东列表 | NSArray | [股东键值表](#MTopShareHolder) |

<h4 id="TopShareHolderSample">调用样例</h4>

    //请求个股十大机构股东
    MTopShareHolderRequest *request = [[MTopShareHolderRequest alloc] init];
    request.code = self.stockItem.ID; //填入股票代码
    
    //发送请求
    [MApi sendRequest:request completionHandler:^(MResponse *resp) {
        if(resp.status == MResponseStatusSuccess) {
            //应答无误，处理数据更新画面
            MTopShareHolderResponse *response = (MTopShareHolderResponse *)resp;
            self.records = response.records;
            [self reloadData];
        } else {
            //应答错误，显示错误信息
            [Utility alertMessage:resp.message];
        }
    }];

[top](#top)

<h3 id="FundShareHolderInfo">最新基金持股</h3>

<h4 id="FundShareHolderInfoExplain">说明</h4>

* 查询个股最新基金持股

<h4 id="MFundShareHolderInfoRequest">请求类：MFundShareHolderInfoRequest</h4>

* 属性说明:

| 属性名 | 说明     | 型态     | 备注 |
|--------|----------|----------|------|
| code   | 股票代码 | NSString |      |
| sourceType | 来源 | [MF10DataSourceType](#MF10DataSourceType) |   默认为MF10DataSourceGA   |

	
<h4 id="MFundShareHolderInfoResponse">应答类：MFundShareHolderInfoResponse</h4>

* 属性说明

| 属性名  | 说明         | 型态    | 备注           |
|---------|--------------|---------|----------------|
| records | 基金持股列表 | NSArray | [基金持股键值表](#MFundshareholding) |

<h4 id="FundShareHolderInfoSample">调用样例</h4>	

    //请求个股最新基金持股
    MFundShareHolderInfoRequest *request = [[MFundShareHolderInfoRequest alloc] init];
    request.code = self.stockItem.ID; //填入股票代码
    
    //发送请求
    [MApi sendRequest:request completionHandler:^(MResponse *resp) {
        if(resp.status == MResponseStatusSuccess) {
            //应答无误，处理数据更新画面
            MFundShareHolderInfoResponse *response = (MFundShareHolderInfoResponse *)resp;
            self.records = response.records;
            [self reloadData];
        } else {
            //应答错误，显示错误信息
            [Utility alertMessage:resp.message];
        }
    }];
    
[top](#top)    
    
<h3 id="NewsList">财经资讯列表</h3>

<h4 id="NewsListExplain">说明</h4>

* 查询财经资讯列表

<h4 id="MNewsListRequest">请求类：MNewsListRequest</h4>

* 属性说明:

| 属性名    | 说明     | 型态      | 备注 |
|-----------|----------|-----------|------|
| newsType  | 新闻类别 | [MNewsType](#MNewsType) |      |
| pageIndex | 页次     | NSInteger |      |
| sourceType | 来源 | [MF10DataSourceType](#MF10DataSourceType) |   默认为MF10DataSourceGA   |

	
<h4 id="MNewsListResponse">应答类：MNewsListResponse</h4>

* 属性说明

| 属性名    | 说明         | 型态    | 备注                                |
|-----------|--------------|---------|-------------------------------------|
| newsItems | 财经资讯列表 | NSArray | 财经资讯列表中的对象请参考[MNewsItem](#MNewsItem) |

<h4 id="NewsListSample">调用样例</h4>

    //查询新闻
    MNewsListRequest *request = [[MNewsListRequest alloc] init];
    request.newsType = self.newsType;
    request.pageIndex = 0;
    
    //发送请求
    [MApi sendRequest:request completionHandler:^(MResponse *resp) {
        if(resp.status == MResponseStatusSuccess) {
            //应答无误，处理数据更新画面
            MNewsListResponse *response = (MNewsListResponse *)resp;
            self.newsItems = response.newsItems;
            [self reloadData];
        } else {
            //应答错误，显示错误信息
            [Utility alertMessage:resp.message];
        }
    }];

[top](#top)

<h3 id="News">财经资讯明细</h3>

<h4 id="NewsExplain">说明</h4>

* 查询财经资讯明细

<h4 id="MNewsRequest">请求类：MNewsRequest</h4>

* 属性说明:

| 属性名 | 说明         | 型态     | 备注 |
|--------|--------------|----------|------|
| newsID | 财经资讯序号 | NSString |      |
| sourceType | 来源 | [MF10DataSourceType](#MF10DataSourceType) |   默认为MF10DataSourceGA   |

	
<h4 id="MNewsResponse">应答类：MNewsResponse</h4>

* 属性说明

| 属性名         | 说明         | 型态            | 备注 |
|----------------|--------------|-----------------|------|
| newsDetailItem | 财经资讯明细 | [MNewsDetailItem](#MNewsDetailItem) |      |

<h4 id="NewsSample">调用样例</h4>

    //请求财经资讯明细
    MNewsRequest *request = [[MNewsRequest alloc] init];
    request.newsID = self.newsItem.ID; //填入新闻序号
    
    //发送请求
    [MApi sendRequest:request completionHandler:^(MResponse *resp) {
        if(resp.status == MResponseStatusSuccess) {
            //应答无误，处理数据更新画面
            MNewsResponse *response = (MNewsResponse *)resp;
            self.newsDetailItem = response.newsDetailItem;
            [self reloadData];
        } else {
            //应答错误，显示错误信息
            [Utility alertMessage:resp.message];
        }
    }];

[top](#top)

<h3 id="StockBulletinList">个股公告列表</h3>

<h4 id="StockBulletinListExplain">说明</h4>

* 查询个股公告列表

<h4 id="MStockBulletinListRequest">请求类：MStockBulletinListRequest</h4>

* 属性说明:

| 属性名 | 说明     | 型态     | 备注 |
|--------|----------|----------|------|
| code   | 股票代码 | NSString |      |
| pageIndex   | 页次 | NSString |      |
| sourceType | 来源 | [MF10DataSourceType](#MF10DataSourceType) |   默认为MF10DataSourceGA   |
	
<h4 id="MStockBulletinListResponse">应答类：MStockBulletinListResponse</h4>

* 属性说明

| 属性名             | 说明         | 型态    | 备注                                         |
|--------------------|--------------|---------|----------------------------------------------|
| stockBulletinItems | 个股公告列表 | NSArray | 个股公告列表中的对象请参考[MStockBulletinItem](#MStockBulletinItem) |

<h4 id="StockBulletinListSample">调用样例</h4>

    //查询个股公告
    MStockBulletinListRequest *request = [[MStockBulletinListRequest alloc] init];
    request.code = self.stockItem.ID;
    
    //发送请求
    [MApi sendRequest:request completionHandler:^(MResponse *resp) {
        if(resp.status == MResponseStatusSuccess) {
            //应答无误，处理数据更新画面
            MStockBulletinListResponse *response = (MStockBulletinListResponse *)resp;
            self.items = response.stockBulletinItems;
            [self reloadData];
        } else {
            //应答错误，显示错误信息
            [Utility alertMessage:resp.message];
        }
    }];

[top](#top)

<h3 id="StockBulletin">个股公告明细</h3>

<h4 id="StockBulletinExplain">说明</h4>

* 查询个股公告明细

<h4 id="MStockBulletinRequest">请求类：MStockBulletinRequest</h4>

* 属性说明:

| 属性名     | 说明         | 型态     | 备注 |
|------------|--------------|----------|------|
| bulletinID | 个股公告序号 | NSString |      |
| sourceType | 来源 | [MF10DataSourceType](#MF10DataSourceType) |   默认为MF10DataSourceGA   |
	
<h4 id="MStockBulletinResponse">应答类：MStockBulletinResponse</h4>

* 属性说明

| 属性名                  | 说明         | 型态                     | 备注 |
|-------------------------|--------------|--------------------------|------|
| stockBulletinDetailItem | 个股公告明细 | [MStockBulletinDetailItem](#MStockBulletinDetailItem) |      |

<h4 id="StockBulletinSample">调用样例</h4>

    //请求公告明细
    MStockBulletinRequest *request = [[MStockBulletinRequest alloc] init];
    request.stockBulletinID = self.stockBulletinItem.ID; //填入公告序号
    
    //发送请求
    [MApi sendRequest:request completionHandler:^(MResponse *resp) {
        if(resp.status == MResponseStatusSuccess) {
            //应答无误，处理数据更新画面
            MStockBulletinResponse *response = (MStockBulletinResponse *)resp;
            self.stockBulletinDetailItem = response.stockBulletinDetailItem;
            [self reloadData];
        } else {
            //应答错误，显示错误信息
            [Utility alertMessage:resp.message];
        }
    }];

[top](#top)

<h3 id="StockNewsList">个股新闻列表</h3>

<h4 id="StockNewsListExplain">说明</h4>

* 查询个股新闻列表

<h4 id="MStockNewsListRequest">请求类：MStockNewsListRequest</h4>

* 属性说明:

| 属性名 | 说明     | 型态     | 备注 |
|--------|----------|----------|------|
| code   | 股票代码 | NSString |      |
| pageIndex   | 页次 | NSString |      |
| sourceType | 来源 | [MF10DataSourceType](#MF10DataSourceType) |   默认为MF10DataSourceGA   |

	
<h4 id="MStockNewsListResponse">应答类：MStockNewsListResponse</h4>

* 属性说明

| 属性名         | 说明         | 型态    | 备注                                     |
|----------------|--------------|---------|------------------------------------------|
| stockNewsItems | 个股新闻列表 | NSArray | 个股新闻列表中的对象请参考[MStockNewsItem](#MStockNewsItem) |

<h4 id="StockNewsListSample">调用样例</h4>

    //查询个股新闻
    MStockNewsListRequest *request = [[MStockNewsListRequest alloc] init];
    request.code = self.stockItem.ID;
    
    //发送请求
    [MApi sendRequest:request completionHandler:^(MResponse *resp) {
        if(resp.status == MResponseStatusSuccess) {
            //应答无误，处理数据更新画面
            MStockNewsListResponse *response = (MStockNewsListResponse *)resp;
            self.items = response.stockNewsItems;
            [self reloadData];
        } else {
            //应答错误，显示错误信息
            [Utility alertMessage:resp.message];
        }
    }];

[top](#top)

<h3 id="StockNews">个股新闻明细</h3>

<h4 id="StockNewsExplain">说明</h4>

* 查询个股新闻明细

<h4 id="MStockNewsRequest">请求类：MStockNewsRequest</h4>

* 属性说明:

| 属性名      | 说明         | 型态     | 备注 |
|-------------|--------------|----------|------|
| stockNewsID | 个股新闻序号 | NSString |      |
| sourceType | 来源 | [MF10DataSourceType](#MF10DataSourceType) |   默认为MF10DataSourceGA   |

	
<h4 id="MStockNewsResponse">应答类：MStockNewsResponse</h4>

* 属性说明

| 属性名              | 说明         | 型态                 | 备注 |
|---------------------|--------------|----------------------|------|
| stockNewsDetailItem | 个股新闻明细 | [MStockNewsDetailItem](#MStockNewsDetailItem) |      |

<h4 id="StockNewsSample">调用样例</h4>

    //请求个股新闻明细
    MStockNewsRequest *request = [[MStockNewsRequest alloc] init];
    request.stockNewsID = self.stockNewsItem.ID; //填入公告序号
    
    //发送请求
    [MApi sendRequest:request completionHandler:^(MResponse *resp) {
        if(resp.status == MResponseStatusSuccess) {
            //应答无误，处理数据更新画面
            MStockNewsResponse *response = (MStockNewsResponse *)resp;
            self.stockNewsDetailItem = response.stockNewsDetailItem;
            [self reloadData];
        } else {
            //应答错误，显示错误信息
            [Utility alertMessage:resp.message];
        }
    }];

[top](#top)

<h3 id="StockReportList">个股研报列表</h3>
    
<h4 id="StockReportListExplain">说明</h4>

* 查询个股研报列表

<h4 id="MStockReportListRequest">请求类：MStockReportListRequest</h4>

* 属性说明:

| 属性名 | 说明     | 型态     | 备注 |
|--------|----------|----------|------|
| code   | 股票代码 | NSString |      |
| pageIndex   | 页次 | NSString |      |
| sourceType | 来源 | [MF10DataSourceType](#MF10DataSourceType) |   默认为MF10DataSourceGA   |

	
<h4 id="MStockReportListResponse">应答类：MStockReportListResponse</h4>

* 属性说明

| 属性名           | 说明         | 型态    | 备注                                       |
|------------------|--------------|---------|--------------------------------------------|
| stockReportItems | 个股研报列表 | NSArray | 个股研报列表中的对象请参考[MStockReportItem](#MStockReportItem) |

<h4 id="StockReportListSample">调用样例</h4>

    //查询个股研报
    MStockReportListRequest *request = [[MStockReportListRequest alloc] init];
    request.code = self.stockItem.ID;
    
    //发送请求
    [MApi sendRequest:request completionHandler:^(MResponse *resp) {
        if(resp.status == MResponseStatusSuccess) {
            //应答无误，处理数据更新画面
            MStockReportListResponse *response = (MStockReportListResponse *)resp;
            self.items = response.stockReportItems;
            [self reloadData];
        } else {
            //应答错误，显示错误信息
            [Utility alertMessage:resp.message];
        }
    }];

[top](#top)

<h3 id="StockReport">个股研报明细</h3>

<h4 id="StockReportExplain">说明</h4>

* 查询个股研报明细

<h4 id="MStockReportRequest">请求类：MStockReportRequest</h4>

* 属性说明:

| 属性名        | 说明         | 型态     | 备注 |
|---------------|--------------|----------|------|
| stockReportID | 个股研报序号 | NSString |      |
| sourceType | 来源 | [MF10DataSourceType](#MF10DataSourceType) |   默认为MF10DataSourceGA   |

	
<h4 id="MStockReportRespone">应答类：MStockReportRespone</h4>

* 属性说明

| 属性名                | 说明         | 型态                   | 备注 |
|-----------------------|--------------|------------------------|------|
| stockReportDetailItem | 个股研报明细 | [MStockReportDetailItem](#MStockReportDetailItem) |      |

<h4 id="StockReportSample">调用样例</h4>

    //请求个股研报明细
    MStockReportRequest *request = [[MStockReportRequest alloc] init];
    request.stockReportID = self.stockReportItem.ID; //填入公告序号
    
    //发送请求
    [MApi sendRequest:request completionHandler:^(MResponse *resp) {
        if(resp.status == MResponseStatusSuccess) {
            //应答无误，处理数据更新画面
            MStockReportRespone *response = (MStockReportRespone *)resp;
            self.stockReportDetailItem = response.stockReportDetailItem;
            [self reloadData];
        } else {
            //应答错误，显示错误信息
            [Utility alertMessage:resp.message];
        }
    }];

[top](#top)


<h3 id="MIPODate">新股上市日期信息</h3>

<h4 id="MIPODateExplain">说明</h4>

* 查询新股上市日期信息

<h4 id="MIPODateRequest">请求类：MIPODateRequest</h4>

* 属性说明:

| 属性名 | 说明     | 型态     | 备注 |
|--------|----------|----------|------|
| sourceType | 来源 | [MF10DataSourceType](#MF10DataSourceType) |   默认为MF10DataSourceGA   |
	
<h4 id="MIPODateRespone">应答类：MIPODateRespone</h4>

* 属性说明

| 属性名                | 说明         | 型态                   | 备注 |
|-----------------------|--------------|------------------------|------|
| infos | 新股日期及上市个数数组 |   |   JSONObject   |

* JSONObject

| 属性名                | 说明         | 型态                   | 备注 |
|-----------------------|--------------|------------------------|------|
| sg | 今日申购个数 |  NSString |      |
| zq | 今日中签个数 |  NSString |      |
| ss | 今日上市个数 |  NSString |      |
| jjfx | 今日即将发行个数 |  NSString |      |
| wss | 今日未上市个数 |  NSString |      |
| NORMALDAY | 日期 |  NSString |      |


<h4 id="MIPODateSample">调用样例</h4>

    //请求新股上市日期信息
    MIPODateRequest *request = [[MIPODateRequest alloc] init];
    
    //发送请求
    [MApi sendRequest:request completionHandler:^(MResponse *resp) {
        if(resp.status == MResponseStatusSuccess) {
            //应答无误，处理数据更新画面
            MIPODateRespone *response = (MIPODateRespone *)resp;

            [self reloadData];
        } else {
            //应答错误，显示错误信息
            [Utility alertMessage:resp.message];
        }
    }];

[top](#top)

<h3 id="MIPOCalendar">新股列表</h3>

<h4 id="MIPOCalendarExplain">说明</h4>

* 查询新股列表，某日的所有新股信息

<h4 id="MIPOCalendarRequest">请求类：MIPOCalendarRequest</h4>

* 属性说明:

| 属性名        | 说明         | 型态     | 备注 |
|---------------|--------------|----------|------|
| date | 日期 | NSString |  YYYY-MM-DD    |
| sourceType | 来源 | [MF10DataSourceType](#MF10DataSourceType) |   默认为MF10DataSourceGA   |

	
<h4 id="MIPOCalendarRespone">应答类：MIPOCalendarRespone</h4>

* 属性说明

| 属性名                | 说明         | 型态                   | 备注 |
|-----------------------|--------------|------------------------|------|
| info | 新股列表 |  |   JSONObject   |

* JSONObject

| 属性名                | 说明         | 型态                   | 备注 |
|-----------------------|--------------|------------------------|------|
| sglist | 今日申购 |  NSArray |      |
| zqlist | 今日中签 |  NSArray |      |
| sslist | 今日上市 |  NSArray |      |
| jjfxlist | 即将发行 |  NSArray |      |
| wsslist | 未上市 |  NSArray |      |
| APPLYCODE | 申购代码 |  NSString |      |
| SECUABBR | 股票简称 |  NSString |      |
| TRADINGCODE | 交易代码 |  NSString |      |
| ISSUEPRICE | 发行价格 |  NSString |      |
| PEAISSUE | 发行市盈率 |  NSString |      |
| SUCCRESULTNOTICEDATE | 中签公告日 |  NSString |      |
| CAPPLYSHARE | 申购上限 |  NSString |      |
| ALLOTRATEON | 中签率 |  NSString |      |
| LISTINGDATE | 上市日期 |  NSString |      |
| BOOKSTARTDATEON | 申购日期 |  NSString |      |
| ISSUESHARE | 发行总量 |  NSString |      |
| ISSUESHAREON | 网上发行数量 |  NSString |      |
| CAPPLYPRICE | 网上申购所需资金 |  NSString |      |
	
<h4 id="MIPOCalendarSample">调用样例</h4>

    //请求新股列表
    MIPOCalendarRequest *request = [[MIPOCalendarRequest alloc] init];
    request.date = @"2016-01-01"; 
    
    //发送请求
    [MApi sendRequest:request completionHandler:^(MResponse *resp) {
        if(resp.status == MResponseStatusSuccess) {
            //应答无误，处理数据更新画面
            MIPOCalendarRespone *response = (MIPOCalendarRespone *)resp;
            [self reloadData];
        } else {
            //应答错误，显示错误信息
            [Utility alertMessage:resp.message];
        }
    }];

[top](#top)

<h3 id="MIPOShareDetail">新股详情</h3>

<h4 id="MIPOShareDetailExplain">说明</h4>

* 依据股号查询新股详情

<h4 id="MIPOShareDetailRequest">请求类：MIPOShareDetailRequest</h4>

* 属性说明:

| 属性名        | 说明         | 型态     | 备注 |
|---------------|--------------|----------|------|
| code | 股号 | NSString |       |
| sourceType | 来源 | [MF10DataSourceType](#MF10DataSourceType) |   默认为MF10DataSourceGA   |

	
<h4 id="MIPOShareDetailRespone">应答类：MIPOShareDetailRespone</h4>

* 属性说明

| 属性名                | 说明         | 型态                   | 备注 |
|-----------------------|--------------|------------------------|------|
| info | 新股列表 |  |   JSONObject   |

* JSONObject

| 属性名                | 说明         | 型态                   | 备注 |
|-----------------------|--------------|------------------------|------|
| APPLYCODE | 申购代码 |  NSString |      |
| SECUABBR | 股票简称 |  NSString |      |
| TRADINGCODE | 交易代码 |  NSString |      |
| ISSUEPRICE | 发行价格 |  NSString |      |
| PEAISSUE | 发行市盈率 |  NSString |      |
| SUCCRESULTNOTICEDATE | 中签公告日 |  NSString |      |
| CAPPLYSHARE | 申购上限 |  NSString |      |
| ALLOTRATEON | 中签率 |  NSString |      |
| LISTINGDATE | 上市日期 |  NSString |      |
| BOOKSTARTDATEON | 申购日期 |  NSString |      |
| ISSUESHARE | 发行总量 |  NSString |      |
| ISSUESHAREON | 网上发行数量 |  NSString |      |
| CAPPLYPRICE | 网上申购所需资金 |  NSString |      |
| BOARDNAME | 所属板块 |  NSString |      |
| COMPROFILE | 公司简介 |  NSString |      |
| BUSINESSSCOPE | 经营范围 |  NSString |      |
| ISSUEALLOTNOON | 中签号 |  NSString |      |
| REFUNDDATEON | 网上申购资金解冻日期 |  NSString |      |
| LEADUNDERWRITER | 主承销商 |  NSString |      |

<h4 id="MIPOShareDetailSample">调用样例</h4>

    //请求新股列表
    MIPOCalendarRequest *request = [[MIPOCalendarRequest alloc] init];
    request.date = @"2016-01-01"; 
    
    //发送请求
    [MApi sendRequest:request completionHandler:^(MResponse *resp) {
        if(resp.status == MResponseStatusSuccess) {
            //应答无误，处理数据更新画面
            MIPOCalendarRespone *response = (MIPOCalendarRespone *)resp;
            [self reloadData];
        } else {
            //应答错误，显示错误信息
            [Utility alertMessage:resp.message];
        }
    }];

[top](#top)


<h3 id="MFundValue">基金净值</h3>

<h4 id="MFundValueExplain">说明</h4>

* 依据股号查询基金净值

<h4 id="MFundValueRequest">请求类：MFundValueRequest</h4>

* 属性说明:

| 属性名        | 说明         | 型态     | 备注 |
|---------------|--------------|----------|------|
| code | 股号 | NSString |       |
| type | 基金周期 | NSString |最多12个月       |
	
<h4 id="MFundValueResponse">应答类：MFundValueResponse</h4>

* 属性说明

| 属性名                | 说明         | 型态                   | 备注 |
|-----------------------|--------------|------------------------|------|
| items  | 基金净值数组 | NSArray |   JSONObject   |

* JSONObject

| 属性名                | 说明         | 型态                   | 备注 |
|-----------------------|--------------|------------------------|------|
| UnitNAV | 每日净值 |  NSString |      |
| ENDDATE | 日期 |  NSString |      |


<h4 id="MFundValueSample">调用样例</h4>

    //请求新股列表
    MFundValueRequest *request = [[MFundValueRequest alloc] init];
    request.code = @"502002.sh"; 
    request.type = @"12";
    
    //发送请求
    [MApi sendRequest:request completionHandler:^(MResponse *resp) {
        if(resp.status == MResponseStatusSuccess) {
            //应答无误，处理数据更新画面
            MIPOCalendarRespone *response = (MIPOCalendarRespone *)resp;
            [self reloadData];
        } else {
            //应答错误，显示错误信息
            [Utility alertMessage:resp.message];
        }
    }];

[top](#top)

<h3 id="MFundBasicInfo">基金概况</h3>

<h4 id="MFundBasicInfoExplain">说明</h4>

* 依据股号查询基金概况

<h4 id="MFundBasicInfoRequest">请求类：MFundBasicInfoRequest</h4>

* 属性说明:

| 属性名        | 说明         | 型态     | 备注 |
|---------------|--------------|----------|------|
| code | 股号 | NSString |       |
| type | 来源 | [MF10DataSourceType](#MF10DataSourceType) |   默认为MF10DataSourceGA   |
	
<h4 id="MFundBasicInfoResponse">应答类：MFundBasicInfoResponse</h4>

* 属性说明

| 属性名                | 说明         | 型态                   | 备注 |
|-----------------------|--------------|------------------------|------|
| record | 基金概况 | NSDictionary | [基金概况键值表](#MFundBasicInfoKeyValue) |

<h4 id="MFundBasicInfoSample">调用样例</h4>

    MFundBasicInfoRequest *request = [[MFundBasicInfoRequest alloc] init];
    request.code = @"500058.sh"; 
    request.type = MF10DataSourceCH;
    
    //发送请求
    [MApi sendRequest:request completionHandler:^(MResponse *resp) {
        if(resp.status == MResponseStatusSuccess) {
            //应答无误，处理数据更新画面
            MFundBasicInfoRespone *response = (MFundBasicInfoRespone *)resp;
        } else {
            //应答错误，显示错误信息
            [Utility alertMessage:resp.message];
        }
    }];

[top](#top)

<h3 id="MFundNetValue">基金净值</h3>

<h4 id="MFundNetValueExplain">说明</h4>

* 依据股号查询基金净值

<h4 id="MFundNetValueRequest">请求类：MFundNetValueRequest</h4>

* 属性说明:

| 属性名        | 说明         | 型态     | 备注 |
|---------------|--------------|----------|------|
| code | 股号 | NSString |       |
| type | 来源 | [MF10DataSourceType](#MF10DataSourceType) |   默认为MF10DataSourceGA   |
	
<h4 id="MFundNetValueResponse">应答类：MFundNetValueResponse</h4>

* 属性说明

| 属性名                | 说明         | 型态                   | 备注 |
|-----------------------|--------------|------------------------|------|
| records | 基金净值 | NSArray | [基金净值键值表](#MFundNetValueKeyValue) |

<h4 id="MFundNetValueSample">调用样例</h4>

    MFundNetValueRequest *request = [[MFundNetValueRequest alloc] init];
    request.code = @"500058.sh"; 
    request.type = MF10DataSourceCH;
    
    //发送请求
    [MApi sendRequest:request completionHandler:^(MResponse *resp) {
        if(resp.status == MResponseStatusSuccess) {
            //应答无误，处理数据更新画面
            MFundNetValueRespone *response = (MFundNetValueRespone *)resp;
        } else {
            //应答错误，显示错误信息
            [Utility alertMessage:resp.message];
        }
    }];

[top](#top)

<h3 id="MFundAssetAllocation">资产配置</h3>

<h4 id="MFundAssetAllocationExplain">说明</h4>

* 依据股号查询资产配置

<h4 id="MFundAssetAllocationRequest">请求类：MFundAssetAllocationRequest</h4>

* 属性说明:

| 属性名        | 说明         | 型态     | 备注 |
|---------------|--------------|----------|------|
| code | 股号 | NSString |       |
| type | 来源 | [MF10DataSourceType](#MF10DataSourceType) |   默认为MF10DataSourceGA   |
	
<h4 id="MFundAssetAllocationResponse">应答类：MFundAssetAllocationResponse</h4>

* 属性说明

| 属性名                | 说明         | 型态                   | 备注 |
|-----------------------|--------------|------------------------|------|
| record | 资产配置 | NSDictionary | [资产配置键值表](#MFundAssetAllocationKeyValue) |

<h4 id="MFundAssetAllocationSample">调用样例</h4>

    MFundAssetAllocationRequest *request = [[MFundAssetAllocationRequest alloc] init];
    request.code = @"500058.sh"; 
    request.type = MF10DataSourceCH;
    
    //发送请求
    [MApi sendRequest:request completionHandler:^(MResponse *resp) {
        if(resp.status == MResponseStatusSuccess) {
            //应答无误，处理数据更新画面
            MFundAssetAllocationRespone *response = (MFundAssetAllocationRespone *)resp;
        } else {
            //应答错误，显示错误信息
            [Utility alertMessage:resp.message];
        }
    }];

[top](#top)

<h3 id="MFundIndustryPortfolio">行业组合</h3>

<h4 id="MFundIndustryPortfolioExplain">说明</h4>

* 依据股号查询行业组合

<h4 id="MFundIndustryPortfolioRequest">请求类：MFundIndustryPortfolioRequest</h4>

* 属性说明:

| 属性名        | 说明         | 型态     | 备注 |
|---------------|--------------|----------|------|
| code | 股号 | NSString |       |
| type | 来源 | [MF10DataSourceType](#MF10DataSourceType) |   默认为MF10DataSourceGA   |
	
<h4 id="MFundIndustryPortfolioResponse">应答类：MFundIndustryPortfolioResponse</h4>

* 属性说明

| 属性名                | 说明         | 型态                   | 备注 |
|-----------------------|--------------|------------------------|------|
| record | 行业组合 | NSDictionary | [行业组合键值表](#MFundIndustryPortfolioKeyValue) |

<h4 id="MFundIndustryPortfolioSample">调用样例</h4>

    MFundIndustryPortfolioRequest *request = [[MFundIndustryPortfolioRequest alloc] init];
    request.code = @"500058.sh"; 
    request.type = MF10DataSourceCH;
    
    //发送请求
    [MApi sendRequest:request completionHandler:^(MResponse *resp) {
        if(resp.status == MResponseStatusSuccess) {
            //应答无误，处理数据更新画面
            MFundIndustryPortfolioRespone *response = (MFundIndustryPortfolioRespone *)resp;
        } else {
            //应答错误，显示错误信息
            [Utility alertMessage:resp.message];
        }
    }];

[top](#top)

<h3 id="MFundStockPortfolio">股票组合</h3>

<h4 id="MFundStockPortfolioExplain">说明</h4>

* 依据股号查询股票组合

<h4 id="MFundStockPortfolioRequest">请求类：MFundStockPortfolioRequest</h4>

* 属性说明:

| 属性名        | 说明         | 型态     | 备注 |
|---------------|--------------|----------|------|
| code | 股号 | NSString |       |
| type | 来源 | [MF10DataSourceType](#MF10DataSourceType) |   默认为MF10DataSourceGA   |
	
<h4 id="MFundStockPortfolioResponse">应答类：MFundStockPortfolioResponse</h4>

* 属性说明

| 属性名                | 说明         | 型态                   | 备注 |
|-----------------------|--------------|------------------------|------|
| record | 股票组合 | NSDictionary | [股票组合键值表](#MFundStockPortfolioKeyValue) |

<h4 id="MFundStockPortfolioSample">调用样例</h4>

    MFundStockPortfolioRequest *request = [[MFundStockPortfolioRequest alloc] init];
    request.code = @"500058.sh"; 
    request.type = MF10DataSourceCH;
    
    //发送请求
    [MApi sendRequest:request completionHandler:^(MResponse *resp) {
        if(resp.status == MResponseStatusSuccess) {
            //应答无误，处理数据更新画面
            MFundStockPortfolioRespone *response = (MFundStockPortfolioRespone *)resp;
        } else {
            //应答错误，显示错误信息
            [Utility alertMessage:resp.message];
        }
    }];

[top](#top)

<h3 id="MFundShareStruct">份额结构</h3>

<h4 id="MFundShareStructExplain">说明</h4>

* 依据股号查询份额结构

<h4 id="MFundShareStructRequest">请求类：MFundShareStructRequest</h4>

* 属性说明:

| 属性名        | 说明         | 型态     | 备注 |
|---------------|--------------|----------|------|
| code | 股号 | NSString |       |
| type | 来源 | [MF10DataSourceType](#MF10DataSourceType) |   默认为MF10DataSourceGA   |
	
<h4 id="MFundShareStructResponse">应答类：MFundShareStructResponse</h4>

* 属性说明

| 属性名                | 说明         | 型态                   | 备注 |
|-----------------------|--------------|------------------------|------|
| record | 份额结构 | NSDictionary | [份额结构键值表](#MFundShareStructKeyValue) |

<h4 id="MFundShareStructSample">调用样例</h4>

    MFundShareStructRequest *request = [[MFundShareStructRequest alloc] init];
    request.code = @"500058.sh"; 
    request.type = MF10DataSourceCH;
    
    //发送请求
    [MApi sendRequest:request completionHandler:^(MResponse *resp) {
        if(resp.status == MResponseStatusSuccess) {
            //应答无误，处理数据更新画面
            MFundShareStructRespone *response = (MFundShareStructRespone *)resp;
        } else {
            //应答错误，显示错误信息
            [Utility alertMessage:resp.message];
        }
    }];

[top](#top)

<h3 id="MFundFinance">基金财务</h3>

<h4 id="MFundFinanceExplain">说明</h4>

* 依据股号查询基金财务

<h4 id="MFundFinanceRequest">请求类：MFundFinanceRequest</h4>

* 属性说明:

| 属性名        | 说明         | 型态     | 备注 |
|---------------|--------------|----------|------|
| code | 股号 | NSString |       |
| type | 来源 | [MF10DataSourceType](#MF10DataSourceType) |   默认为MF10DataSourceGA   |
	
<h4 id="MFundFinanceResponse">应答类：MFundFinanceResponse</h4>

* 属性说明

| 属性名                | 说明         | 型态                   | 备注 |
|-----------------------|--------------|------------------------|------|
| record | 基金财务 | NSDictionary | [基金财务键值表](#MFundFinanceKeyValue) |

<h4 id="MFundFinanceSample">调用样例</h4>

    MFundFinanceRequest *request = [[MFundFinanceRequest alloc] init];
    request.code = @"500058.sh"; 
    request.type = MF10DataSourceCH;
    
    //发送请求
    [MApi sendRequest:request completionHandler:^(MResponse *resp) {
        if(resp.status == MResponseStatusSuccess) {
            //应答无误，处理数据更新画面
            MFundFinanceRespone *response = (MFundFinanceRespone *)resp;
        } else {
            //应答错误，显示错误信息
            [Utility alertMessage:resp.message];
        }
    }];

[top](#top)

<h3 id="MFundDividend">基金分红</h3>

<h4 id="MFundDividendExplain">说明</h4>

* 依据股号查询基金分红

<h4 id="MFundDividendRequest">请求类：MFundDividendRequest</h4>

* 属性说明:

| 属性名        | 说明         | 型态     | 备注 |
|---------------|--------------|----------|------|
| code | 股号 | NSString |       |
| type | 来源 | [MF10DataSourceType](#MF10DataSourceType) |   默认为MF10DataSourceGA   |
	
<h4 id="MFundDividendResponse">应答类：MFundDividendResponse</h4>

* 属性说明

| 属性名                | 说明         | 型态                   | 备注 |
|-----------------------|--------------|------------------------|------|
| record | 基金分红 | NSDictionary | [基金分红键值表](#MFundDividendKeyValue) |

<h4 id="MFundDividendSample">调用样例</h4>

    MFundDividendRequest *request = [[MFundDividendRequest alloc] init];
    request.code = @"500058.sh"; 
    request.type = MF10DataSourceCH;
    
    //发送请求
    [MApi sendRequest:request completionHandler:^(MResponse *resp) {
        if(resp.status == MResponseStatusSuccess) {
            //应答无误，处理数据更新画面
            MFundDividendRespone *response = (MFundDividendRespone *)resp;
        } else {
            //应答错误，显示错误信息
            [Utility alertMessage:resp.message];
        }
    }];

[top](#top)

<h3 id="MBondBasicInfo">债券概况</h3>

<h4 id="MBondBasicInfoExplain">说明</h4>

* 依据股号查询债券概况

<h4 id="MBondBasicInfoRequest">请求类：MBondBasicInfoRequest</h4>

* 属性说明:

| 属性名        | 说明         | 型态     | 备注 |
|---------------|--------------|----------|------|
| code | 股号 | NSString |       |
| type | 来源 | [MF10DataSourceType](#MF10DataSourceType) |   默认为MF10DataSourceGA   |
	
<h4 id="MBondBasicInfoResponse">应答类：MBondBasicInfoResponse</h4>

* 属性说明

| 属性名                | 说明         | 型态                   | 备注 |
|-----------------------|--------------|------------------------|------|
| record | 债券概况 | NSDictionary | [债券概况键值表](#MBondBasicInfoKeyValue) |

<h4 id="MBondBasicInfoSample">调用样例</h4>

    MBondBasicInfoRequest *request = [[MBondBasicInfoRequest alloc] init];
    request.code = @“010619.sh"; 
    request.type = MF10DataSourceCH;
    
    //发送请求
    [MApi sendRequest:request completionHandler:^(MResponse *resp) {
        if(resp.status == MResponseStatusSuccess) {
            //应答无误，处理数据更新画面
            MBondBasicInfoRespone *response = (MBondBasicInfoRespone *)resp;
        } else {
            //应答错误，显示错误信息
            [Utility alertMessage:resp.message];
        }
    }];

[top](#top)

<h3 id="MBondInterestPay">付息情况</h3>

<h4 id="MBondInterestPayExplain">说明</h4>

* 依据股号查询付息情况

<h4 id="MBondInterestPayRequest">请求类：MBondInterestPayRequest</h4>

* 属性说明:

| 属性名        | 说明         | 型态     | 备注 |
|---------------|--------------|----------|------|
| code | 股号 | NSString |       |
| type | 来源 | [MF10DataSourceType](#MF10DataSourceType) |   默认为MF10DataSourceGA   |
	
<h4 id="MBondInterestPayResponse">应答类：MBondInterestPayResponse</h4>

* 属性说明

| 属性名                | 说明         | 型态                   | 备注 |
|-----------------------|--------------|------------------------|------|
| record | 付息情况 | NSDictionary | [付息情况键值表](#MBondInterestPayKeyValue) |

<h4 id="MBondInterestPaySample">调用样例</h4>

    MBondInterestPayRequest *request = [[MBondInterestPayRequest alloc] init];
    request.code = @"010619.sh"; 
    request.type = MF10DataSourceCH;
    
    //发送请求
    [MApi sendRequest:request completionHandler:^(MResponse *resp) {
        if(resp.status == MResponseStatusSuccess) {
            //应答无误，处理数据更新画面
            MBondInterestPayRespone *response = (MBondInterestPayRespone *)resp;
        } else {
            //应答错误，显示错误信息
            [Utility alertMessage:resp.message];
        }
    }];

[top](#top)

<h3 id="MBondBuyBacks">债券回购</h3>

<h4 id="MBondBuyBacksExplain">说明</h4>

* 依据股号查询债券回购

<h4 id="MBondBuyBacksRequest">请求类：MBondBuyBacksRequest</h4>

* 属性说明:

| 属性名        | 说明         | 型态     | 备注 |
|---------------|--------------|----------|------|
| code | 股号 | NSString |       |
| type | 来源 | [MF10DataSourceType](#MF10DataSourceType) |   默认为MF10DataSourceGA   |
	
<h4 id="MBondBuyBacksResponse">应答类：MBondBuyBacksResponse</h4>

* 属性说明

| 属性名                | 说明         | 型态                   | 备注 |
|-----------------------|--------------|------------------------|------|
| record | 债券回购 | NSDictionary | [债券回购键值表](#MBondBuyBacksKeyValue) |

<h4 id="MBondBuyBacksSample">调用样例</h4>

    MBondBuyBacksRequest *request = [[MBondBuyBacksRequest alloc] init];
    request.code = @"010619.sh"; 
    request.type = MF10DataSourceCH;
    
    //发送请求
    [MApi sendRequest:request completionHandler:^(MResponse *resp) {
        if(resp.status == MResponseStatusSuccess) {
            //应答无误，处理数据更新画面
            MBondBuyBacksRespone *response = (MBondBuyBacksRespone *)resp;
        } else {
            //应答错误，显示错误信息
            [Utility alertMessage:resp.message];
        }
    }];

[top](#top)

<h2 id="数据结构">数据结构</h2>

<h3 id="个股摘要">个股摘要</h3>

<h4 id="MLatestIndex">最新指标</h4>

* 港澳数据

| 键                       | 说明             |
|--------------------------|------------------|
| NETPROFITCUTPARENTCOMYOY | 扣非净利润同比增 |
| NETPROFITCUTPARENTCOM    | 扣非净利润       |
| CUTBASICEPS              | 扣非每股收益     |
| ANNUROE                  | 净资产收益率     |
| NETPROFITPARENTCOM       | 净利润           |
| BASICEPS                 | 基本每股收益     |
| TOTALSHARE               | 总股本           |
| BVPS                     | 每股净资产       |
| TOTALSHAREL              | 流通股份合计     |
| REPTITLE                 | 标题             |
| NETCASHFLOWOPERPS        | 每股经营性现金流 |
| GROSSPROFITMARGIN        | 毛利率（%）      |
| RESERVEPS                | 每股资本公积金   |
| NETPROFITPARENTCOMYOY    | 净利润同比增     |
| RETAINEDEARNINGPS        | 每股未分配利润   |
| OPERREVENUEYOY           | 营收同比增       |
| OPERREVENUE              | 营业收入         |

* 财汇数据

| 键                       | 说明             |
|--------------------------|------------------|
| NETPROFITCUTPARENTCOMYOY | 扣非净利润同比增 |
| NETPROFITCUTPARENTCOM    | 扣非净利润       |
| CUTBASICEPS              | 扣非每股收益     |
| ANNUROE                  | 净资产收益率     |
| NETPROFITPARENTCOM       | 净利润           |
| BASICEPS                 | 基本每股收益     |
| TOTALSHARE               | 总股本           |
| BVPS                     | 每股净资产       |
| REPTITLE                 | 标题             |
| NETCASHFLOWOPERPS        | 每股经营性现金流 |
| GROSSPROFITMARGIN        | 毛利率（%）      |
| NETPROFITPARENTCOMYOY    | 净利润同比增     |
| OPERREVENUEYOY           | 营收同比增       |
| OPERREVENUE              | 营业收入         |

[top](#top)

<h4 id="MBigEventNotification">大事提醒</h4>

| 键         | 说明 |
|------------|------|
| PUBDATE    | 日期 |
| DiviScheme | 说明 |

[top](#top)

<h4 id="MBonusFinanceInfo">分红配送</h4>

* 港澳数据

| 键         | 说明         |
|------------|--------------|
| EXDIVIDATE | 除权息日     |
| DIVISCHEME | 分红扩股方案 |
| NOTICEDATE | 公布日期     |

* 财汇数据

| 键         | 说明         |
|------------|--------------|
| EXDIVIDATE | 除权息日     |
| DIVISCHEME | 分红扩股方案 |
| NOTICEDATE | 公布日期     |

[top](#top)

<h4 id="MTradeDetailInfo">融资融券</h4>

| 键            | 说明           |
|---------------|----------------|
| PAYVOLSTOCK   | 融券偿还量(股) |
| AMOUNTFINA    | 融资余额(元)   |
| PAYAMOUNTFINA | 融资偿还额(元) |
| BUYAMOUNTFINA | 融资买入额(元) |
| SELLVOLSTOCK  | 融券卖出量(股) |
| AMOUNTSTOCK   | 融资余额(元)   |
| TRADINGDAY    | 交易日期       |

[top](#top)

<h4 id="MForecastYear">机构预测</h4>

| 键             | 说明     |
|----------------|----------|
| NETEPS         | 每股收益 |
| AVGCOREREVENUE | 主营收入 |
| FORECASTYEAR   | 预测年度 |
| STATISTICDATE  | 更新日期 |
| AVGPROFIT      | 净利润   |
| ForecastYYYY   | 年份     |
| FORECASTCOUNT  | 家數     |

[top](#top)

<h4 id="MForecastRating">机构评等</h4>

| 键                 | 说明     |
|--------------------|----------|
| RatingFlag         | 评级     |
| RatingDec          | 评级敘述 |
| DATETITLE          | 更新日期 |
| WRITINGDATE        | 评级时间 |
| CHINAMEABBR        | 研究机构 |
| INVRATINGDESC      | 最新评级 |
| LAST_INVRATINGDESC | 上次评级 |

[top](#top)

<h4 id="MBlockTradeInfo">大宗交易</h4>

| 键          | 说明           |
|-------------|----------------|
| TRADINGDAY  | 交易日期       |
| STRIKEPRICE | 成交价格（元） |
| TURNOVERVOL | 成交量（股）   |
| TURNOVERVAL | 成交金额（元） |
| BUYERNAME   | 买方营业部名称 |
| SELLERNAME  | 卖方营业部名称 |

<h3 id="个股简况">个股简况</h3>

<h4 id="MCompanyInfo">基本情况</h4>

* 港澳数据

| 键            | 说明     |
|---------------|----------|
| LEGALREPR     | 法人代表 |
| COREBUSINESS  | 主营业务 |
| PROVINCENAME  | 地域     |
| LISTINGDATE   | 上市时间 |
| BUSINESSSCOPE | 经营范围 |
| INDUNAMESW    | 当前行业 |
| REGCAPITAL    | 注册资本 |
| CHINAME       | 公司名称 |
| REGADDRESS    | 注册地址 |

* 财汇数据

| 键            | 说明     |
|---------------|----------|
| CHINAME     | 公司名称 |
| SEENGNAME  | 英文简称 |
| AUTHCAPSK  | 法定股本 |
| LISTINGDATE   | 上市时间 |
| ISSUECAPSK | 发行股本 |
| CURNAME    | 交易币别 |
| PARVALUE    | 面值 |
| DEBTBOARDLOT       | 买卖单位 |

[top](#top)

<h4 id="MCoreBusiness">主要业务</h4>

| 键               | 说明             |
|------------------|------------------|
| BUSSINESSNATURE  | 产品名称         |
| OperCost         | 营业成本（元）   |
| OPERREVENUETOTOR | 占总营业收入比例 |
| OperProfit       | 营业利润（元）   |
| OperRevenue      | 营业收入         |
| ENDDATE          | 日期             |

[top](#top)

<h4 id="MLeaderPersonInfo">管理层</h4>

* 港澳数据

| 键           | 说明     |
|--------------|----------|
| POSITIONNAME | 公司职务 |
| LEADERNAME   | 姓名     |
| AGE          | 年龄     |
| GENDER       | 性别     |
| EDUCATION    | 学历     |

* 财汇数据

| 键           | 说明     |
|--------------|----------|
| LEADERNAME   | 姓名     |
| DUTY          | 公司职务     |
| DUTYTYPE       | 职务类型     |
| BEGINDATE    | 就职日期     |

[top](#top)

<h4 id="MIPOInfo">发行上市</h4>

| 键              | 说明               |
|-----------------|--------------------|
| BOOKSTARTDATEON | 网上发行日期       |
| LISTINGDATE     | 上市日期           |
| PARVAL          | 每股面值(元)       |
| ISSUESHARE      | 发行量(万股)       |
| ISSUEPRICE      | 每股发行价(元)     |
| ISSUECOST       | 发行费用(万元)     |
| RAISENETFUND    | 募集资金净额(万元) |
| LEADUNDERWRITER | 主承销商           |

<h3 id="个股财务">个股财务</h3>

<h4 id="MFinancialSummary">财务指标</h4>

* 港澳数据

<h5 id="MFinancialSummary">主要指标（同花顺版)</h5>

| 键                  | 说明             |
|---------------------|------------------|
| BasicEPS            | 每股收益         |
| BVPS                | 每股净资产       |
| NetCashFlowOperPS   | 每股经营性现金流 |
| WEIGHTEDROE         | 净资产收益率     |
| ROA                 | 总资产报酬率     |

[top](#top)

<h5 id="MFinancialSummary">利润表（同花顺版)</h5>

| 键                  | 说明             |
|---------------------|------------------|
| TotalOperRevenue | 营业收入     |
| ROA_EBIT         | 总资产报酬率 |
| OperProfit       | 营业利润     |
| NetProfit        | 净利润       |

[top](#top)

<h5 id="MFinancialSummary">资产负债表（同花顺版)</h5>

| 键                  | 说明             |
|---------------------|------------------|
| TotalAsset    | 资产合计       |
| TotalLiab     | 负债合计   |
| TotalSHEquity | 所有者权益合计 |

<h5 id="MFinancialSummary">成长能力（同花顺版)</h5>

| 键                  | 说明             |
|---------------------|------------------|
| NetCashFlowOper | 经营现金流量净额     |
| NetCashFlowInv  | 投资现金流量净额     |
| NetCashFlowFina | 筹资现金流量净额     |
| CashEquiNetIncr | 现金及现金等价净增额 |

* 财汇数据

| 键                  | 说明             |
|---------------------|------------------|
| BASICEPS  		| 每股收益 		|
| BVPS			| 每股净资产 		|
| TOTALOPERINCOMEPS	| 每股营业收入 		|
| EBITPS		| 每股息税前利润		|
| RETAINEDEARNINGPS	| 每股未分配利润		|
| NETCASHFLOWOPERPS	| 每股经营性现金流		|
| NETCASHFLOWPS		| 每股经营性现金流量净额	|
| WEIGHTEDROE		| 净资产利益率		|
| ROA_EBIT		| 总资产报酬率		|
| GROSSPROFITMARGIN	| 销售毛利率		|
| PROFITMARGIN		| 销售净利率		|
| TLTOTA		| 资产负债率		|
| TATOSHE		| 权益乘数		|
| CURRENTRATIO		| 流动比率		|
| QUICKRATIO		| 速冻比率		|
| EBITTOIE		| 利息保障倍数		|
| INVENTORYTURNOVER	| 存货周期率		|
| ACCOUNTRECTURNOVER	| 应收帐款周转率		|
| FIXEDASSETTURNOVER	| 固定资产周转率		|
| TOTALASSETTURNOVER	| 总资产周转率		|
| OPERREVENUEYOY	| 营业收入同比增长		|
| OPERPROFITYOY		| 营业利润同比增长		|
| NETPROFITPARENTCOMYOY	| 净利润同比增长		|
| NETCASHFLOWOPERYOY	| 经营活动现金流量净额同比增长|
| ROEYOY		| 净资产收益(摊薄)同比增长	|
| NETASSETYOY		| 净资产同比增长		|
| TOTALASSETYOY		| 总资产同比增长		|
| REPORTTITLE		| 标题			|

[top](#top)

<h4 id="MFinancialInfo">财务报表</h4>

* 港澳数据

<h5 id="MFinancialInfo">每股指标（同花顺版)</h5>

| 键                  | 说明             |
|---------------------|------------------|
| BasicEPS          | 每股收益               |
| RESERVEPS         | 每股公积金             |
| BVPS              | 每股净资产             |
| TotalOperIncomePS | 每股营业收入           |
| EBITPS            | 每股息税前利润         |
| RetainedEarningPS | 每股未分配利润         |
| NetCashFlowOperPS | 每股经营性现金流量净额 |

[top](#top)

<h5 id="MFinancialInfo">盈利能力（同花顺版)</h5>

| 键                  | 说明             |
|---------------------|------------------|
| WEIGHTEDROE       | 净资产收益率 |
| ROA_EBIT          | 总资产报酬率 |
| GROSSPROFITMARGIN | 销售毛利率   |
| PROFITMARGIN      | 销售净利率   |

[top](#top)

<h5 id="MFinancialInfo">资本结构（同花顺版)</h5>

| 键                  | 说明             |
|---------------------|------------------|
| TLToTA  | 资产负债率 |
| TAToSHE | 权益乘数   |

[top](#top)

<h5 id="MFinancialInfo">偿债能力（同花顺版)</h5>

| 键                  | 说明             |
|---------------------|------------------|
| CurrentRatio | 流动比率     |
| QuickRatio   | 速动比率     |
| EBITToIE     | 利息保障倍数 |

[top](#top)

<h5 id="MFinancialInfo">营运能力（同花顺版)</h5>

| 键                  | 说明             |
|---------------------|------------------|
| InventoryTurnover  | 存货周转率     |
| ACCOUNTRECTURNOVER | 应收帐款周转率 |
| FixedAssetTurnover | 固定资产周转率 |
| TotalAssetTurnover | 总资产周转率   |

[top](#top)

<h5 id="MFinancialInfo">成长能力（同花顺版)</h5>

| 键                  | 说明             |
|---------------------|------------------|
| OperRevenueYOY        | 营业收入同比增长             |
| OperProfitYOY         | 营业利润同比增长             |
| NETPROFITPARENTCOMYOY | 净利润同比增长               |
| NetCashFlowOperYOY    | 经营活动现金流量净额同比增长 |
| ROEYOY                | 净资产收益(摊薄)同比增长     |
| NetAssetYOY           | 净资产同比增长               |
| TotalAssetYOY         | 总资产同比增长               |

* 财汇数据

| 键                  | 说明             |
|---------------------|------------------|
| BASICEPS		| 基本每股收益	|
| BVPS			| 每股净资产	|
| NETCASHFLOWOPERPS	| 每股现金流	|
| WEIGHTEDROE		| 净资产收益率	|
| ROA			| 总资产报酬率	|
| TOTALOPERREVENUE	| 营业收入	|
| OPERPROFIT		| 营业利润	|
| NETPROFIT		| 净利润		|
| TOTALASSET		| 资产合计	|
| TOTALLIAB		| 负债合计	|
| TOTALSHEQUITY		| 所有者权益合计	|
| NETCASHFLOWOPER	| 经营现金流量净额	|
| NETCASHFLOWINV	| 投资现金流量净额	|
| NETCASHFLOWFINA	| 筹资现金流量金额	|
| CASHEQUINETINCR	| 现金及现金等价净增额|
| REPORTTITLE		| 标题		|

[top](#top)

<h4 id="MStockShareInfo">股本结构</h4>

| 键           | 说明               |
|--------------|--------------------|
| TotalShareUL | 未流通股份         |
| HRatio       | 境外上市流通股占比 |
| ARatio       | 已上市流通A股占比  |
| URRatio      | 无限售流通股份占比 |
| TotalShareUR | 无限售流通股份     |
| AListedShare | 已上市流通A股      |
| BListedShare | 已上市流通B股      |
| BRatio       | 已上市流通B股占比  |
| TotalShare   | 总股本             |
| TotalShareL  | 流通股份合计       |
| TotalShareR  | 限售流通股份       |
| LRatio       | 已上市流通股份占比 |
| RRatio       | 限售流通股份占比   |
| ULRatio      | 未流通股份占比     |
| HTotalShare  | 境外上市流通股     |

[top](#top)

<h4 id="MStockShareChangeInfo">股本变动</h4>

* 港澳数据

| 键             | 说明     |
|----------------|----------|
| TotalShare     | 总股本   |
| CONSTDESC      | 变动说明 |
| AListedShare   | 流通A股  |
| LastChangeDate | 日期     |

* 财汇数据

| 键             | 说明     |
|----------------|----------|
| CHANGEAMT     | 变动数量（股）   |
| CONSTDESC      | 变动原因 |
| CHANGEDIRE   | 变动方向  |
| LASTCHANGEDATE | 时间     |
| TOTALSHARE | 股本数量（股）     |

[top](#top)

<h4 id="MShareHolderHistoryInfo">股东变动</h4>

* 港澳数据

| 键           | 说明                     |
|--------------|--------------------------|
| AVGSHAREM    | 股东人数                 |
| CLOSINGPRICE | 较上期变化               |
| AVGSHARE     | 流通股户均持股数         |
| PCTOFTOTALSH | 股东总数较上一报告期变化 |
| TOTALSH      | 股东总数                 |
| ENDDATE      | 截止日期                 |

* 财汇数据

| 键           | 说明                     |
|--------------|--------------------------|
| CLOSINGPRICE | 较上期变化               |
| PCTOFTOTALSH | 股东总数较上一报告期变化 |
| TOTALSH      | 股东总数                 |
| ENDDATE      | 截止日期                 |

[top](#top)

<h4 id="MTopLiquidShareHolder">最新十大流通股股东</h4>

* 港澳数据

| 键              | 说明         |
|-----------------|--------------|
| SHNO            | 排名         |
| SHNAME          | 股东名称     |
| SHCODE          | 股东编号     |
| PCTTOTALSHAREUR | 占流通股比例 |
| HOLDASHAREUR    | 持股数       |
| ENDDATE         | 日期         |

* 财汇数据

| 键              | 说明         |
|-----------------|--------------|
| SHNAME          | 股东名称     |
| SHCODE          | 股东编号     |
| PCTTOTALSHAREUR | 占流通股比例 |
| DIFF            | 增减         |
| HOLDASHAREUR    | 持股数       |
| ENDDATE         | 日期         |

[top](#top)

<h4 id="MTopShareHolder">最新十大机构股东</h4>

* 港澳数据

| 键              | 说明         |
|-----------------|--------------|
| SHNO            | 排名         |
| SHNAME          | 股东名称     |
| SHCODE          | 股东编号     |
| PCTTOTALSHAREUR | 占流通股比例 |
| DIFF            | 增减         |
| HOLDASHAREUR    | 持股数       |
| ENDDATE         | 日期         |

* 财汇数据

| 键              | 说明         |
|-----------------|--------------|
| SHNAME          | 股东名称     |
| SHCODE          | 股东编号     |
| PCTTOTALSHAREUR | 占流通股比例 |
| DIFF            | 增减         |
| HOLDASHAREUR    | 持股数       |
| ENDDATE         | 日期         |


[top](#top)

<h4 id="MFundshareholding">最新基金持股</h4>

| 键              | 说明                |
|-----------------|---------------------|
| COUNT           | 最新基金持股共xxx家 |
| ENDDATE         | 日期                |
| CHINAMEABBR     | 股东名称            |
| PCTTOTALSHAREUR | 占流通股比例        |
| HOLDINGVOL      | 持股数              |

[top](#top)

<h4 id="MControllingsh">控股股东-OPTION</h4>

| 键            | 说明     |
|---------------|----------|
| SHNAME        | 股东名称 |
| PCTTOTALSHARE | 持股比例 |

[top](#top)

<h3 id="个股资讯">个股资讯</h3>

<h4 id="MStockbulletinlist">个股/自选公告</h4>

* 港澳数据

| 键        | 说明                                                    |
|-----------|---------------------------------------------------------|
| PUBDATE   | 日期                                                    |
| ID        | 序号                                                    |
| TITLE     | 标题                                                    |
| STOCKNAME | 个股名称 {page_index} 每页预设笔数30笔, 系统由第0页开始 |

* 财汇数据

| 键        | 说明                                                    |
|-----------|---------------------------------------------------------|
| PUBDATE   | 日期                                                    |
| ID        | 序号                                                    |
| TITLE     | 标题                                                    |
| STOCKNAME | 个股名称 {page_index} 每页预设笔数30笔, 系统由第0页开始 |

[top](#top)

<h4 id="MStockbulletin">个股公告内文</h4>

* 港澳数据

| 键            | 说明 |
|---------------|------|
| PUBDATE       | 日期 |
| ID            | 序号 |
| Content       | 内文 |
| CONTENTFORMAT | 格式 |

* 财汇数据

| 键            | 说明 |
|---------------|------|
| PUBDATE       | 日期 |
| ID            | 序号 |
| CONTENT       | 内文 |

[top](#top)

<h4 id="MStocknewslist">个股/自选新闻</h4>

| 键          | 说明                                                    |
|-------------|---------------------------------------------------------|
| INIPUBDATE  | 日期                                                    |
| ID          | 序号                                                    |
| REPORTTITLE | 标题                                                    |
| REPORTLEVEL | 报告级别                                                |
| MEDIANAME   | 来源                                                    |
| STOCKNAME   | 个股名称 {page_index} 每页预设笔数30笔, 系统由第0页开始 |

[top](#top)

<h4 id="MStocknews">个股新闻内文</h4>

| 键             | 说明 |
|----------------|------|
| INIPUBDATE     | 日期 |
| ID             | 序号 |
| ABSTRACT       | 内文 |
| ABSTRACTFORMAT | 格式 |
| MEDIANAME      | 来源 |

[top](#top)

<h4 id="MStockreportlist">个股/自选研报</h4>

| 键          | 说明                                                    |
|-------------|---------------------------------------------------------|
| PUBDATE     | 日期                                                    |
| ID          | 序号                                                    |
| ReportTitle | 标题                                                    |
| REPORTLEVEL | 报告级别                                                |
| ComName     | 来源                                                    |
| STOCKNAME   | 个股名称 {page_index} 每页预设笔数30笔, 系统由第0页开始 |

[top](#top)

<h4 id="MStockreport">个股研报内文</h4>

| 键             | 说明 |
|----------------|------|
| PUBDATE        | 日期 |
| ID             | 序号 |
| ABSTRACT       | 内文 |
| ABSTRACTFORMAT | 格式 |
| ComName        | 来源 |

[top](#top)

<h3 id="新闻资讯">新闻资讯</h3>

<h4 id="MNewsItem">财经资讯(MNewsItem)</h4>

| 属性名   | 说明             | 型态     | 备注 |
|----------|------------------|----------|------|
| ID       | 识别号           | NSString |      |
| datetime | 首次发布日期     | NSString |      |
| title    | 标题             | NSString |      |
| source   | 媒体出处(Option) | NSString |      |
| format   | 内容格式         | NSString |      |

[top](#top)

<h4 id="MNewsDetailItem">财经资讯明细(MNewsDetailItem)</h4>

| 属性名   | 说明             | 型态     | 备注 |
|----------|------------------|----------|------|
| content  | 内容             | NSString |      |
| dateTime | 首次发布日期     | NSString |      |
| source   | 媒体出处(Option) | NSString |      |
| format   | 内容格式         | NSString |      |

[top](#top)

<h4 id="MStockBulletinItem">个股公告(MStockBulletinItem)</h4>

| 属性名   | 说明 | 型态     | 备注 |
|----------|------|----------|------|
| datetime | 日期 | NSString |      |
| ID       | 序号 | NSString |      |
| title    | 标题 | NSString |      |

[top](#top)

<h4 id="MStockBulletinDetailItem">个股公告内文(MStockBulletinDetailItem)</h4>

| 属性名   | 说明 | 型态     | 备注 |
|----------|------|----------|------|
| datetime | 日期 | NSString |      |
| ID       | 序号 | NSString |      |
| content  | 内文 | NSString |      |
| format   | 格式 | NSString |      |

[top](#top)

<h4 id="MStockNewsItem">个股新闻(MStockNewsItem)</h4>

| 属性名   | 说明     | 型态     | 备注 |
|----------|----------|----------|------|
| dateTime | 日期     | NSString |      |
| ID       | 序号     | NSString |      |
| title    | 标题     | NSString |      |
| level    | 报告级别 | NSString |      |
| source   | 来源     | NSString |      |

[top](#top)

<h4 id="MStockNewsDetailItem">个股新闻内文(MStockNewsDetailItem)</h4>

| 属性名   | 说明             | 型态     | 备注 |
|----------|------------------|----------|------|
| datetime | 日期             | NSString |      |
| ID       | 序号             | NSString |      |
| content  | 内文             | NSString |      |
| format   | 内容格式         | NSString |      |
| source   | 媒体出处(Option) | NSString |      |

[top](#top)

<h4 id="MStockReportItem">个股研报(MStockReportItem)</h4>

| 属性名   | 说明     | 型态     | 备注 |
|----------|----------|----------|------|
| datetime | 日期     | NSString |      |
| ID       | 序号     | NSString |      |
| title    | 标题     | NSString |      |
| level    | 报告级别 | NSString |      |
| source   | 来源     | NSString |      |

[top](#top)

<h4 id="MStockReportDetailItem">个股研报内文(MStockReportDetailItem)</h4>

| 属性名   | 说明             | 型态     | 备注 |
|----------|------------------|----------|------|
| datetime | 日期             | NSString |      |
| ID       | 序号             | NSString |      |
| content  | 内文             | NSString |      |
| format   | 内容格式         | NSString |      |
| source   | 媒体出处(Option) | NSString |      |

[top](#top)

<h4 id="MFininfolist">财经资讯列表</h4>

| 名称           | 说明             | 备注 |
|----------------|------------------|------|
| ID             | 序號             |      |
| INIPUBDATE     | 首次发布日期     |      |
| REPORTTITLE    | 标题             |      |
| MEDIANAME      | 媒体出处(Option) |      |
| ABSTRACTFORMAT | 内容格式         |      |

[top](#top)

<h4 id="MFininfodetail">财经资讯明细</h4>

| 名称           | 说明             | 备注 |
|----------------|------------------|------|
| ABSTRACT       | ABSTRACT         |      |
| INIPUBDATE     | 首次发布日期     |      |
| MEDIANAME      | 媒体出处(Option) |      |
| ABSTRACTFORMAT | 内容格式         |      |

[top](#top)

<h4 id="MNewsType">新闻列表请求类别</h4>

| 名称                      | 说明                              | 备注 |
|--------------------------|-----------------------------------|------|
| MNewsTypeImportant       | 要闻 - 精辟解析当日重点财经新闻        | 0000 |
| MNewsTypeRoll            | 滚动 - 7X24小时即时新闻              |      |
| MNewsTypeFinance         | 财经 - 汇聚重点国内外总体财经新闻      | 13   |
| MNewsTypeIndustry        | 行业 - 汇聚各行业重点行业新闻与市况分析 | 14   |
| MNewsTypeStock           | 股票 - 盘点当日重点股票新闻与市况分析   | 15   |
| MNewsTypeFuture          | 期货 - 汇聚期货相关重点新闻           | 11   |
| MNewsTypeForeignExchange | 外汇 - 汇聚外汇相关新闻与市况分析      | 10   |
| MNewsTypeFund            | 基金 - 汇聚基金相关新闻与市况分析      | 16   |
| MNewsTypeBond            | 债券 - 汇聚债券相关新闻与市况分析      | 17   |
| MNewsTypeGold            | 黄金 - 汇聚黄金相关新闻与市况分析      | 12   |
| MNewsTypeOthers          | 其他 - 汇聚基金相关新闻与市况分析      | 99   |


[top](#top)

<h4 id="MF10DataSourceType">f10数据来源类型</h4>

| 名称                      | 说明                              | 备注 |
|--------------------------|-----------------------------------|------|
| MF10DataSourceGA       | 港澳  |      |
| MF10DataSourceCH      | 财汇 |      |


[top](#top)

<h4 id="MFundBasicInfoKeyValue">基金概况</h4>

* 财汇数据

| 名称           | 说明             | 备注 |
|----------------|------------------|------|
| FDNAME       		| 基金名称       	|      |
| FDSNAME     		| 基金简称     	|      |
| FSYMBOL     		| 基金代码 	|      |
| FDTYPE 		| 基金类型        |      |
| FOUNDDATE       	| 成立日期        |      |
| TRUSTEENAME     	| 托管人     	|      |
| KEEPERNAME      	| 管理人 		|      |
| MANAGERNAME 		| 基金经理        |      |
| FDINVCATEGORY       	| 投资类型        |      |
| INVRULE     		| 投资理念     	|      |

[top](#top)

<h4 id="MFundNetValueKeyValue">基金净值</h4>

* 财汇数据

| 名称           | 说明             | 备注 |
|----------------|------------------|------|
| ACCUNITNAV       	| 累计净值       	|      |
| UNITNAV     		| 单位净值     	|      |
| NAVDATE     		| 发生日期 	|      |
| GROWRATE 		| 净值涨跌额      |      |

[top](#top)

<h4 id="MFundAssetAllocationKeyValue">资产配置</h4>

* 财汇数据

| 名称           | 说明             | 备注 |
|----------------|------------------|------|
| ASSESECI       	| 资产支持证券投资 |      |
| BDINVE     		| 债券投资     	|      |
| FDINVE     		| 基金投资 	|      |
| STKINVE 		| 股票投资      |      |
| TOTASSET 		| 资产总计      |      |
| TOTASSETYOY 		| 应收及其他资产      |      |

[top](#top)

<h4 id="MFundIndustryPortfolioKeyValue">行业组合</h4>

* 财汇数据

| 名称           | 说明             | 备注 |
|----------------|------------------|------|
| ENDDATE       	| 期末日期 |      |
| INDUSTRYNAME 		| 行业类别     	|      |
| FAIRVALUE     	| 公允价值（万元） 	|      |
| NAVRATIO 		| 占净值比（％）      |      |

[top](#top)

<h4 id="MFundStockPortfolioKeyValue">股票组合</h4>

* 财汇数据

| 名称           | 说明             | 备注 |
|----------------|------------------|------|
| ENDDATE       	| 期末日期 |      |
| FDSNAME 		| 简称     	|      |
| HOLDVOL     		| 持股（万） 	|      |
| ACCTFORNAV 		| 占比（％）      |      |
| HOLDVALUE 		| 价值（万）      |      |

[top](#top)

<h4 id="MFundShareStructKeyValue">份额结构</h4>

* 财汇数据

| 名称           | 说明             | 备注 |
|----------------|------------------|------|
| ENDDATE       	| 期末日期 |      |
| ENDFDSHARE 		| 基金总份额     	|      |
| SUBSHARETOT     	| 报告期总申购额 	|      |
| REDTOTSHARE 		| 报告期总赎回额      |      |

[top](#top)

<h4 id="MFundFinanceKeyValue">基金财务</h4>

* 财汇数据

| 名称           | 说明             | 备注 |
|----------------|------------------|------|
| PUBLISHDATE       	| 公布日期 |      |
| ENDDATE 		| 期末日期     	|      |
| UNFDDISTNETINC     	| 单位净收益 	|      |
| FINAUNFDASSNAV 	| 单位资产净值      |      |
| FDNETPROPER       	| 净收益 |      |
| FINAFDASSETNAV 	| 资产净值     	|      |
| NAVGRORATE     	| 净值增长率 	|      |

[top](#top)

<h4 id="MFundDividendKeyValue">基金分红</h4>

* 财汇数据

| 名称           | 说明             | 备注 |
|----------------|------------------|------|
| DEFSHAREMODE       	| 分配说明 |      |
| INNERDEVDATE     	| 红利发放日     	|      |
| INNERDEVPSETDATE     	| 红利结转份额日 	|      |
| INNERRIGHTDATE 	| 除息日      |      |
| ISBONUS 		| 进展说明      |      |
| PUBLISHDATE 		| 公布日期      |      |
| RECORDDATE 		| 权益登记日      |      |
| UNITPTAXDEV 		| 每10份基金单位派现      |      |

[top](#top)

<h4 id="MBondBasicInfoKeyValue">债券概况</h4>

* 财汇数据

| 名称           | 说明             | 备注 |
|----------------|------------------|------|
| BONDNAME       	| 债券名称 |      |
| BONDSNAME     	| 债券简称     	|      |
| SYMBOL     		| 债券代码 	|      |
| BONDTYPE2 		| 债券性质      |      |
| INITIALCREDITRATE 	| 债券信用级别      |      |
| PARVALUE 		| 债券面额      |      |
| MATURITYYEAR 		| 债券年限      |      |
| BASERATE     		| 债券基准利率（％） |      |
| CALCAMODE 		| 计息方式      |      |
| PAYMENTMODE 		| 付息方式      |      |
| LISTDATE 		| 上市日期      |      |
| EXCHANGENAME 		| 市场      |      |
| LISTSTATE     	| 上市状态 	|      |
| PAYMENTDATE 		| 兑付日      |      |

[top](#top)

<h4 id="MBondInterestPayKeyValue">付息情况</h4>

* 财汇数据

| 名称           | 说明             | 备注 |
|----------------|------------------|------|
| BONDNAME       	| 债券名称 |      |
| BONDSNAME     	| 债券简称     	|      |
| SYMBOL     		| 债券代码 	|      |
| PERPAYDATEYEAR 	| 付息年度      |      |
| PRETAXINT	 	| 每百元面值所得利息      |      |
| IPRATE 		| 本期利率（％）      |      |
| EQURECORDDATE 	| 债券登记日      |      |
| PERPAYDATE     	| 利息支付日 |      |
| XDRDATE 		| 除息基准日      |      |
| REPAYDATE 		| 集中兑付期      |      |

[top](#top)

<h4 id="MBondBuyBacksKeyValue">债券回购</h4>

* 财汇数据

| 名称           | 说明             | 备注 |
|----------------|------------------|------|
| BONDNAME       	| 债券名称   |      |
| BONDSNAME     	| 债券简称     	|      |
| SYMBOL     		| 债券代码 	|      |
| EXERENDDATE	 	| 调整日      |      |
| PARVALUE	 	| 现券面额      |      |
| CONVERTRATE 		| 折算比率（％）      |      |
| CONVERTPRC	 	| 折换价      |      |
| REPAYDATE     	| 集中兑付期（启始-截止） |      |

[top](#top)