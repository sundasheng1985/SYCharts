/////////////////////////////////////////////////////////
//                                                     //
// Copyright (c) 2016年 上证云平台. All rights reserved. //
//                                                     //
/////////////////////////////////////////////////////////


#import "MApiObject.h"

#pragma mark - 数据结构类

#pragma mark 个股摘要

typedef NS_ENUM(NSUInteger, MNewsListSendType) {
    MNewsListSendRefresh,
    MNewsListSendGetMore
};

/** f10数据来源类型 */
typedef NS_ENUM(NSUInteger, MF10DataSourceType) {
    /** 港澳数据 */
    MF10DataSourceGA = 1,
    /** 财汇数据 */
    MF10DataSourceCH = 2
};

/*! @brief 最新指标
 */
@interface MLatestIndex : MBaseItem
/** 扣非净利润同比增 */
@property (nonatomic, copy) NSString *profitCutYOY;
/** 扣非净利润 */
@property (nonatomic, copy) NSString *profitCut;
/** 扣非每股收益 */
@property (nonatomic, copy) NSString *cutBasicEPS;
/** 净资产收益率 */
@property (nonatomic, copy) NSString *annuROE;
/** 净利润 */
@property (nonatomic, copy) NSString *profit;
/** 基本每股收益 */
@property (nonatomic, copy) NSString *basicEPS;
/** 总股本 */
@property (nonatomic, copy) NSString *totalShare;
/** 每股净资产 */
@property (nonatomic, copy) NSString *BVPS;
/** 流通股份合计 */
@property (nonatomic, copy) NSString *totalShareLiquid;
/** 每股资本公积金 */
@property (nonatomic, copy) NSString *captitalReservePS;
/** 标题 */
@property (nonatomic, copy) NSString *title;
/** 每股经营性现金流 */
@property (nonatomic, copy) NSString *netCashFlowOperPS;
/** 毛利率（%） */
@property (nonatomic, copy) NSString *grossProfitMargin;
/** 净利润同比增 */
@property (nonatomic, copy) NSString *profitYOY;
/** 每股未分配利润 */
@property (nonatomic, copy) NSString *retainedEarningPS;
/** 营收同比增 */
@property (nonatomic, copy) NSString *operRevenueYOY;
/** 营业收入 */
@property (nonatomic, copy) NSString *operRevenue;
@end

/*! @brief 大事提醒
 */
@interface MBigEventNotification : MBaseItem
/** 日期 */
@property (nonatomic, copy) NSString *datetime;
/** 说明 */
@property (nonatomic, copy) NSString *info;
@end

/*! @brief 分红配送
 */
@interface MBonusFinanceInfo : MBaseItem
/** 除权息日 */
@property (nonatomic, copy) NSString *excludeDividendDate;
/** 分红扩股方案 */
@property (nonatomic, copy) NSString *dividendScheme;
/** 公布日期 */
@property (nonatomic, copy) NSString *noticeDate;
@end

/*! @brief 融资融券
 */
@interface MTradeDetailInfo : MBaseItem
/** 融券偿还量(股) */
@property (nonatomic, copy) NSString *payStockVolume;
/** 融资余额(元) */
@property (nonatomic, copy) NSString *financeAmount;
/** 融资偿还额(元) */
@property (nonatomic, copy) NSString *payFinanceAmount;
/** 融资买入额(元) */
@property (nonatomic, copy) NSString *buyFinanceAmount;
/** 融券卖出量(股) */
@property (nonatomic, copy) NSString *sellFinanceVolume;
/** 融资余额(元) */
@property (nonatomic, copy) NSString *stockAmount;
/** 交易日期 */
@property (nonatomic, copy) NSString *dateTime;
@end

/*! @brief 机构预测
 */@interface MForecastYear : MBaseItem
/** 每股收益 */
@property (nonatomic, copy) NSString *netEPS;
/** 主营收入 */
@property (nonatomic, copy) NSString *averageCoreRevenue;
/** 预测年度 */
@property (nonatomic, copy) NSString *forecastYear;
/** 更新日期 */
@property (nonatomic, copy) NSString *datetime;
/** 净利润 */
@property (nonatomic, copy) NSString *averageProfit;
@end

/*! @brief 机构评等
 */
@interface MForecastRating : MBaseItem
/** 评级时间 */
@property (nonatomic, copy) NSString *datetime;
/** 研究机构 */
@property (nonatomic, copy) NSString *organization;
/** 最新评级 */
@property (nonatomic, copy) NSString *rating;
/** 上次评级 */
@property (nonatomic, copy) NSString *lastRating;
@end

/*! @brief 大宗交易
 */
@interface MBlockTradeInfo : MBaseItem
/** 交易日期 */
@property (nonatomic, copy) NSString *tradeDate;
/** 成交价格（元） */
@property (nonatomic, copy) NSString *price;
/** 成交量（股） */
@property (nonatomic, copy) NSString *volume;
/** 成交金额（元） */
@property (nonatomic, copy) NSString *totalValue;
/** 买方营业部名称 */
@property (nonatomic, copy) NSString *buyer;
/** 卖方营业部名称 */
@property (nonatomic, copy) NSString *seller;
@end

#pragma mark 个股概况

/*! @brief 基本情况
 */
@interface MCompanyInfo  : MBaseItem
/** 公司名称 */
@property (nonatomic, copy) NSString *name;
/** 公司英文名称 */
@property (nonatomic, copy) NSString *englishName;
/** 中文简称 */
@property (nonatomic, copy) NSString *shortName;
/** 证券代码 */
@property (nonatomic, copy) NSString *tradingCode;
/** 证券类别 */
@property (nonatomic, copy) NSString *tradingCategory;
/** 上市日期 */
@property (nonatomic, copy) NSString *listingDate;
/** 董秘姓名 */
@property (nonatomic, copy) NSString *secretaryName;
/** 总经理 */
@property (nonatomic, copy) NSString *generalManagerName;
/** 法人代表 */
@property (nonatomic, copy) NSString *leaglePerson;
/** 公司电话 */
@property (nonatomic, copy) NSString *telNumber;
/** 公司传真 */
@property (nonatomic, copy) NSString *faxNumber;
/** 公司网址 */
@property (nonatomic, copy) NSString *webSite;
/** 信息披露网址 */
@property (nonatomic, copy) NSString *disclosureSite;
/** 电子邮件 */
@property (nonatomic, copy) NSString *email;
/** 注册地址 */
@property (nonatomic, copy) NSString *registeredAddress;
/** 办公地址 */
@property (nonatomic, copy) NSString *officeAddress;
/** 主营业务 */
@property (nonatomic, copy) NSString *coreBusiness;
/** 基本情况 */
@property (nonatomic, copy) NSString *profile;
@end

/*! @brief 主要业务
 */
@interface MCoreBusiness : MBaseItem
/** 产品名称 */
@property (nonatomic, copy) NSString *productName;
/** 营业成本（元） */
@property (nonatomic, copy) NSString *operationCost;
/** 占总营业收入比例 */
@property (nonatomic, copy) NSString *operationCostRatio;
/** 营业利润（元） */
@property (nonatomic, copy) NSString *operationProfit;
/** 营业收入 */
@property (nonatomic, copy) NSString *operationRevenue;
/** 日期 */
@property (nonatomic, copy) NSString *dateTime;
@end

/*! @brief 管理层
 */
@interface MLeaderPersonInfo : MBaseItem
/** 姓名 */
@property (nonatomic, copy) NSString *name;
/** 职务 */
@property (nonatomic, copy) NSString *position;
/** 年龄 */
@property (nonatomic, copy) NSString *age;
/** 性别 */
@property (nonatomic, copy) NSString *gender;
/** 学历 */
@property (nonatomic, copy) NSString *education;
@end

/*! @brief 发行上市
 */
@interface MIPOInfo : MBaseItem
/** 网上发行日期 */
@property (nonatomic, copy) NSString *bookStartDate;
/** 上市日期 */
@property (nonatomic, copy) NSString *listingDate;
/** 每股面值(元) */
@property (nonatomic, copy) NSString *parval;
/** 发行量(万股) */
@property (nonatomic, copy) NSString *issueShare;
/** 每股发行价(元) */
@property (nonatomic, copy) NSString *issuePrice;
/** 发行费用(万元) */
@property (nonatomic, copy) NSString *issueCost;
/** 募集资金净额(万元) */
@property (nonatomic, copy) NSString *raiseFund;
/** 主承销商 */
@property (nonatomic, copy) NSString *leadUnderWriter;
@end

#pragma mark 个股财务

/*! @brief 财报概要
 */
@interface MFinancialSummary : MBaseItem
/** 资产负债率 */
@property (nonatomic, copy) NSString *debtToAssetRatio;
/** 扣除非经常性损益后的基本每股收益 */
@property (nonatomic, copy) NSString *cutBasicEPS;
/** 每股盈余公积 */
@property (nonatomic, copy) NSString *surplusReservePS;
/** 近三年复合增长率 */
@property (nonatomic, copy) NSString *nearThreeYearGrowRatio;
/** 速动比率 */
@property (nonatomic, copy) NSString *quickRatio;
/** 总资产周转率 */
@property (nonatomic, copy) NSString *totalAssetTurnover;
/** 基本每股收益 */
@property (nonatomic, copy) NSString *basicEPS;
/** 净资产收益率ROE */
@property (nonatomic, copy) NSString *averageROE;
/** 每股净资产 */
@property (nonatomic, copy) NSString *BVPS;
/** 流动比率 */
@property (nonatomic, copy) NSString *liquidRatio;
/** 归属上市公司股东的净利润同比增长 */
@property (nonatomic, copy) NSString *companyProfitYOY;
/** 应收账款周转天数 */
@property (nonatomic, copy) NSString *accountReceivableTurnoverDay;
/** 每股资本公积 */
@property (nonatomic, copy) NSString *captitalReservePS;
/** 销售净利率 */
@property (nonatomic, copy) NSString *profitMargin;
/** 每股经营活动产生的现金流量净额 */
@property (nonatomic, copy) NSString *netCashFlowOperPS;
/** 销售毛利率 */
@property (nonatomic, copy) NSString *grossProfitMargin;
/** 每股未分配利润 */
@property (nonatomic, copy) NSString *retainedEarningPS;
/** 营业收入同比增长 */
@property (nonatomic, copy) NSString *operRevenueYOY;
@end

/*! @brief 财报指标
 */
@interface MFinancialInfo : MBaseItem
/** 日期 */
@property (nonatomic, copy) NSString *date;
/** 基本每股收益(元) */
@property (nonatomic, copy) NSString *baseEPS;
/** 摊薄每股收益(元) */
@property (nonatomic, copy) NSString *EPS;
/** 每股净资产(元) */
@property (nonatomic, copy) NSString *BVPS;
/** 净利润(元) */
@property (nonatomic, copy) NSString *profit;
/** 每股经营现金流(元) */
@property (nonatomic, copy) NSString *cashFlowERPS;
/** 主营业务收入(元) */
@property (nonatomic, copy) NSString *revenue;
/** 利润总额 */
@property (nonatomic, copy) NSString *totalProfit;
/** 摊薄净资产收益率(%) */
@property (nonatomic, copy) NSString *ROE;
@end

#pragma mark 个股股东

/*! @brief 股本结构
 */
@interface MStockShareInfo : MBaseItem
/** 未流通股份 */
@property (nonatomic, copy) NSString *totalShareUL;
/** 境外上市流通股占比 */
@property (nonatomic, copy) NSString *HRatio;
/** 已上市流通A股占比 */
@property (nonatomic, copy) NSString *ARatio;
/** 无限售流通股份占比 */
@property (nonatomic, copy) NSString *URRatio;
/** 无限售流通股份 */
@property (nonatomic, copy) NSString *totalShareUR;
/** 已上市流通A股 */
@property (nonatomic, copy) NSString *AShare;
/** 已上市流通B股 */
@property (nonatomic, copy) NSString *BShare;
/** 已上市流通B股占比 */
@property (nonatomic, copy) NSString *BRatio;
/** 总股本 */
@property (nonatomic, copy) NSString *totalShare;
/** 流通股份合计 */
@property (nonatomic, copy) NSString *totalShareL;
/** 限售流通股份 */
@property (nonatomic, copy) NSString *totalShareR;
/** 已上市流通股份占比 */
@property (nonatomic, copy) NSString *LRatio;
/** 限售流通股份占比 */
@property (nonatomic, copy) NSString *RRatio;
/** 未流通股份占比 */
@property (nonatomic, copy) NSString *ULRatio;
/** 境外上市流通股 */
@property (nonatomic, copy) NSString *HTotalShare;
@end

/*! @brief 股本变动
 */
@interface MStockShareChangeInfo : MBaseItem
/** 总股本 */
@property (nonatomic, copy) NSString *totalShare;
/** 变动说明 */
@property (nonatomic, copy) NSString *changeDescription;
/** 流通A股 */
@property (nonatomic, copy) NSString *listedShare;
/** 日期 */
@property (nonatomic, copy) NSString *dateTime;
@end

/*! @brief 控股股东
 */
@interface MControlingShareHolder : MBaseItem
/** 股东名称 */
@property (nonatomic, copy) NSString *name;
/** 持股比例 */
@property (nonatomic, copy) NSString *sharePercantage;
@end

/*! @brief 股东变动
 */
@interface MShareHolderHistoryInfo : MBaseItem
/** 股东人数 */
@property (nonatomic, copy) NSString *avrageNumber;
/** 较上期变化 */
@property (nonatomic, copy) NSString *difference;
/** 流通股户均持股数 */
@property (nonatomic, copy) NSString *avrageShare;
/** 股东总数较上一报告期变化 */
@property (nonatomic, copy) NSString *differenceNumber;
/** 股东总数 */
@property (nonatomic, copy) NSString *totalNumber;
/** 截止日期 */
@property (nonatomic, copy) NSString *date;
@end

/*! @brief 股东
 */
@interface MShareHolderInfo : MBaseItem
/** 排名 */
@property (nonatomic, copy) NSString *order;
/** 股东名称 */
@property (nonatomic, copy) NSString *name;
/** 股东编号 */
@property (nonatomic, copy) NSString *ID;
/** 占流通股比例 */
@property (nonatomic, copy) NSString *shareRatio;
/** 持股数 */
@property (nonatomic, copy) NSString *holdVolume;
/** 日期 */
@property (nonatomic, copy) NSString *date;
@end

/*! @brief 基金持股
 */
@interface MFundShareHolderInfo : MBaseItem
/** 股东名称 */
@property (nonatomic, copy) NSString *name;
/** 占流通股比例 */
@property (nonatomic, copy) NSString *shareRatio;
/** 持股数 */
@property (nonatomic, copy) NSString *holdVolume;
@end

#pragma mark 个股资讯

/*! @brief 个股公告
 */
@interface MStockBulletinItem : MBaseItem
/** 日期 */
@property (nonatomic, copy) NSString *datetime;
/** 序号 */
@property (nonatomic, copy) NSString *ID;
/** 标题 */
@property (nonatomic, copy) NSString *title;
/** 个股名称*/
@property (nonatomic, copy) NSString *stockName;
@end

/*! @brief 个股公告内文
 */
@interface MStockBulletinDetailItem : MBaseItem
/** 日期 */
@property (nonatomic, copy) NSString *datetime;
/** 序号 */
@property (nonatomic, copy) NSString *ID;
/** 内文 */
@property (nonatomic, copy) NSString *content;
/** 格式 */
@property (nonatomic, copy) NSString *format;
@end

/*! @brief 个股新闻
 */
@interface MStockNewsItem : MBaseItem
/** 日期 */
@property (nonatomic, copy) NSString *datetime;
/** 序号 */
@property (nonatomic, copy) NSString *ID;
/** 标题 */
@property (nonatomic, copy) NSString *title;
/** 内文 */
@property (nonatomic, copy) NSString *level;
/** 来源 */
@property (nonatomic, copy) NSString *source;
/** 个股名称*/
@property (nonatomic, copy) NSString *stockName;
@end

/*! @brief 个股新闻内文
 */
@interface MStockNewsDetailItem : MBaseItem
/** 日期 */
@property (nonatomic, copy) NSString *datetime;
/** 序号 */
@property (nonatomic, copy) NSString *ID;
/** 内文 */
@property (nonatomic, copy) NSString *content;
/** 内容格式 */
@property (nonatomic, copy) NSString *format;
/** 媒体出处(Option) */
@property (nonatomic, copy) NSString *source;
@end

/*! @brief 个股研报
 */
@interface MStockReportItem : MBaseItem
/** 日期 */
@property (nonatomic, copy) NSString *datetime;
/** 序号 */
@property (nonatomic, copy) NSString *ID;
/** 内文 */
@property (nonatomic, copy) NSString *title;
/** 报告级别 */
@property (nonatomic, copy) NSString *level;
/** 来源 */
@property (nonatomic, copy) NSString *source;
/** 个股名称*/
@property (nonatomic, copy) NSString *stockName;
@end

/*! @brief 个股研报内文
 */
@interface MStockReportDetailItem : MBaseItem
/** 日期 */
@property (nonatomic, copy) NSString *datetime;
/** 序号 */
@property (nonatomic, copy) NSString *ID;
/** 内文 */
@property (nonatomic, copy) NSString *content;
/** 内容格式 */
@property (nonatomic, copy) NSString *format;
/** 媒体出处(Option) */
@property (nonatomic, copy) NSString *source;
@end

#pragma mark 新闻资讯

/*! @brief 财经资讯
 */
@interface MNewsItem : MBaseItem
/** 识别号 */
@property (nonatomic, copy) NSString *ID;
/** 首次发布日期 */
@property (nonatomic, copy) NSString *datetime;
/** 标题 */
@property (nonatomic, copy) NSString *title;
/** 媒体出处(Option) */
@property (nonatomic, copy) NSString *source;
/** 内容格式 */
@property (nonatomic, copy) NSString *format;
@end

/*! @brief 财经资讯明細
 */
@interface MNewsDetailItem : MBaseItem
/** 内容 */
@property (nonatomic, copy) NSString *content;
/** 首次发布日期 */
@property (nonatomic, copy) NSString *datetime;
/** 媒体出处(Option) */
@property (nonatomic, copy) NSString *source;
/** 内容格式 */
@property (nonatomic, copy) NSString *format;
@end

#pragma mark - 请求类

#pragma mark 个股摘要
/** f10数据请求基类 */
@interface MDataRequest : MRequest
/** 数据来源,默认为 MF10DataSourceGA */
@property (nonatomic , assign) MF10DataSourceType sourceType;
@end

/*! @brief 最新指标请求类
 */
@interface MLatestIndexRequest : MDataRequest
/** 股票代码 */
@property (nonatomic, copy) NSString *code;
@end

/*! @brief 大事提醒请求类
 */
@interface MBigEventNotificationRequest : MDataRequest
/** 股票代码 */
@property (nonatomic, copy) NSString *code;
@end

/*! @brief 分红配送请求类
 */
@interface MBonusFinanceRequest : MDataRequest
/** 股票代码 */
@property (nonatomic, copy) NSString *code;
@end

/*! @brief 融资融券请求类
 */
@interface MTradeDetailInfoRequest : MDataRequest
/** 股票代码 */
@property (nonatomic, copy) NSString *code;
@end

/*! @brief 机构预测请求类
 */
@interface MForecastYearRequest : MDataRequest
/** 股票代码 */
@property (nonatomic, copy) NSString *code;
@end

/*! @brief 机构评等请求类
 */
@interface MForecastRatingRequest : MDataRequest
/** 股票代码 */
@property (nonatomic, copy) NSString *code;
@end

/*! @brief 大宗交易请求类
 */
@interface MBlockTradeInfoRequest : MDataRequest
/** 股票代码 */
@property (nonatomic, copy) NSString *code;
@end

#pragma mark 个股简况

/*! @brief 基本情况请求类
 */
@interface MCompanyInfoRequest : MDataRequest
/** 股票代码 */
@property (nonatomic, copy) NSString *code;
@end

/*! @brief 主要业务请求类
 */
@interface MCoreBusinessRequest : MDataRequest
/** 股票代码 */
@property (nonatomic, copy) NSString *code;
@end

/*! @brief 管理层请求类
 */
@interface MLeaderPersonInfoRequest : MDataRequest
/** 股票代码 */
@property (nonatomic, copy) NSString *code;
@end

/*! @brief 发行上市请求类
 */
@interface MIPOInfoRequest : MDataRequest
/** 股票代码 */
@property (nonatomic, copy) NSString *code;
@end

#pragma mark 个股财务

/*! @brief 财务指标请求类
 */
@interface MFinancialSummaryRequest : MDataRequest
/** 股票代码 */
@property (nonatomic, copy) NSString *code;
@end

/*! @brief 财务报表请求类
 */
@interface MFinancialInfoRequest : MDataRequest
/** 股票代码 */
@property (nonatomic, copy) NSString *code;
@end

#pragma mark 个股股东

/*! @brief 控股股东请求类
 */
@interface MControlingShareHolderRequest : MDataRequest
/** 股票代码 */
@property (nonatomic, copy) NSString *code;
@end

/*! @brief 股本结构请求类
 */
@interface MStockShareInfoRequest : MDataRequest
/** 股票代码 */
@property (nonatomic, copy) NSString *code;
@end

/*! @brief 股本变动请求类
 */
@interface MStockShareChangeInfoRequest : MDataRequest
/** 股票代码 */
@property (nonatomic, copy) NSString *code;
@end

/*! @brief 股东变动请求类
 */
@interface MShareHolderHistoryInfoRequest : MDataRequest
/** 股票代码 */
@property (nonatomic, copy) NSString *code;
@end

/*! @brief 最新十大流通股股东请求类
 */
@interface MTopLiquidShareHolderRequest : MDataRequest
/** 股票代码 */
@property (nonatomic, copy) NSString *code;
@end

/*! @brief 最新十大机构股东请求类
 */
@interface MTopShareHolderRequest : MDataRequest
/** 股票代码 */
@property (nonatomic, copy) NSString *code;
@end

/*! @brief 最新基金持股请求类
 */
@interface MFundShareHolderInfoRequest : MDataRequest
/** 股票代码 */
@property (nonatomic, copy) NSString *code;
@end

/*! @brief 基金概况请求类
 */
@interface MFundBasicInfoRequest : MDataRequest
/** 股票代码 */
@property (nonatomic, copy) NSString *code;
@end

/*! @brief 基金净值请求类
 */
@interface MFundNetValueRequest : MDataRequest
/** 股票代码 */
@property (nonatomic, copy) NSString *code;
@end

/*! @brief 资产配置请求类
 */
@interface MFundAssetAllocationRequest : MDataRequest
/** 股票代码 */
@property (nonatomic, copy) NSString *code;
@end

/*! @brief 行业组合请求类
 */
@interface MFundIndustryPortfolioRequest : MDataRequest
/** 股票代码 */
@property (nonatomic, copy) NSString *code;
@end

/*! @brief 股票组合请求类
 */
@interface MFundStockPortfolioRequest : MDataRequest
/** 股票代码 */
@property (nonatomic, copy) NSString *code;
@end

/*! @brief 份额结构请求类
 */
@interface MFundShareStructRequest : MDataRequest
/** 股票代码 */
@property (nonatomic, copy) NSString *code;
@end

/*! @brief 基金财务请求类
 */
@interface MFundFinanceRequest : MDataRequest
/** 股票代码 */
@property (nonatomic, copy) NSString *code;
@end

/*! @brief 基金分红请求类
 */
@interface MFundDividendRequest : MDataRequest
/** 股票代码 */
@property (nonatomic, copy) NSString *code;
@end

/*! @brief 债券概况请求类
 */
@interface MBondBasicInfoRequest : MDataRequest
/** 股票代码 */
@property (nonatomic, copy) NSString *code;
@end

/*! @brief 付息情况请求类
 */
@interface MBondInterestPayRequest : MDataRequest
/** 股票代码 */
@property (nonatomic, copy) NSString *code;
@end

/*! @brief 债券回购请求类
 */
@interface MBondBuyBacksRequest : MDataRequest
/** 股票代码 */
@property (nonatomic, copy) NSString *code;
@end

#pragma mark 个股资讯

/*! @brief 个股公告列表请求类
 */
@interface MStockBulletinListRequest : MListRequest
/** 数据来源 */
@property (nonatomic , assign) MF10DataSourceType sourceType;
/** 股票代码 */
@property (nonatomic, copy) NSString *code;
/** 刷新或是取得更多 */
@property (nonatomic) MNewsListSendType newsListSendType __attribute__((deprecated));
@end

/*! @brief 个股公告明細请求类
 */
@interface MStockBulletinRequest : MDataRequest
/** 个股公告序号 */
@property (nonatomic, copy) NSString *stockBulletinID;
@end

/*! @brief 个股新闻列表请求类
 */
@interface MStockNewsListRequest : MListRequest
/** 数据来源 */
@property (nonatomic , assign) MF10DataSourceType sourceType;
/** 股票代码 */
@property (nonatomic, copy) NSString *code;
/** 刷新或是取得更多 */
@property (nonatomic) MNewsListSendType newsListSendType __attribute__((deprecated));
@end

/*! @brief 个股新闻明細请求类
 */
@interface MStockNewsRequest : MDataRequest
/** 个股新闻序号 */
@property (nonatomic, copy) NSString *stockNewsID;
@end

/*! @brief 个股研报列表请求类
 */
@interface MStockReportListRequest : MListRequest
/** 数据来源 */
@property (nonatomic , assign) MF10DataSourceType sourceType;
/** 股票代码 */
@property (nonatomic, copy) NSString *code;
/** 刷新或是取得更多 */
@property (nonatomic) MNewsListSendType newsListSendType __attribute__((deprecated));
@end

/*! @brief 个股研报明細请求类
 */
@interface MStockReportRequest : MDataRequest
/** 个股研报序号 */
@property (nonatomic, copy) NSString *stockReportID;
@end


#pragma mark 新股资讯

/*! @brief 新股上市日期信息请求类
 */
@interface MIPODateRequest : MDataRequest

@end

/*! @brief 某日的所有新股信息请求类
 */
@interface MIPOCalendarRequest : MDataRequest
/** 查询日期 YYYY-MM-DD */
@property (nonatomic, copy) NSString *date;
@end

/*! @brief 新股信息请求类
 */
@interface MIPOShareDetailRequest : MDataRequest
/** 股号 */
@property (nonatomic, copy) NSString *code;
@end


#pragma mark 新闻资讯

/*! @brief 财经资讯列表请求类
 */
@interface MNewsListRequest : MListRequest
/** 数据来源 */
@property (nonatomic , assign) MF10DataSourceType sourceType;
/** 新闻类别, 参照下方定义 */
@property (nonatomic, copy) NSString *newsType;
/** 刷新或是取得更多 */
@property (nonatomic) MNewsListSendType newsListSendType __attribute__((deprecated));

@end

extern NSString *const MNewsTypeImportant;       // 要闻
extern NSString *const MNewsTypeRoll;            // 滚动
extern NSString *const MNewsTypeFinance;         // 财经
extern NSString *const MNewsTypeIndustry;        // 行业
extern NSString *const MNewsTypeStock;           // 股票
extern NSString *const MNewsTypeFuture;          // 期货
extern NSString *const MNewsTypeForeignExchange; // 外汇
extern NSString *const MNewsTypeFund;            // 基金
extern NSString *const MNewsTypeBond;            // 债券
extern NSString *const MNewsTypeGold;            // 黄金
extern NSString *const MNewsTypeOthers;          // 其他


/*! @brief 财经资讯明細请求类
 */
@interface MNewsRequest : MDataRequest
/** 财经资讯序号 */
@property (nonatomic, copy) NSString *newsID;
@end

/*! @brief 财经资讯图片请求类
 */
@interface MNewsImgRequest : MDataRequest
/** 财经资讯序号 */
@property (nonatomic, copy) NSString *newsID;
@end

/*! @brief 基金净值请求类
 */
@interface MFundValueRequest : MDataRequest
/** 基金代码*/
@property (nonatomic, copy) NSString *code;
/** 基金净值周期 最长12月*/
@property (nonatomic, copy) NSString *type;
@end


#pragma mark - 应答类

#pragma mark 个股简要

/*! @brief 最新指标应答类
 */
@interface MLatestIndexResponse : MResponse
/** 最新指标对象 */
@property (nonatomic, strong) NSDictionary *record;
@end

/*! @brief 大事提醒应答类
 */
@interface MBigEventNotificationResponse : MResponse
/** 最新指标对象 */
@property (nonatomic, strong) NSArray *records;
@end

/*! @brief 分红配送应答类
 */
@interface MBonusFinanceResponse : MResponse
/** 分红配送列表 */
@property (nonatomic, strong) NSArray *records;
@end

/*! @brief 融资融券应答类
 */
@interface MTradeDetailInfoResponse : MResponse
/** 融资融券对象 */
@property (nonatomic, strong) NSDictionary *record;
@end

/*! @brief 机构预测应答类
 */
@interface MForecastYearResponse : MResponse
/** 机构预测对象 */
@property (nonatomic, strong) NSDictionary *record;
@end

/*! @brief 机构评等应答类
 */
@interface MForecastRatingResponse : MResponse
/** 评级 */
@property (nonatomic, copy) NSString *ratingFlag;
/** 评级敘述 */
@property (nonatomic, copy) NSString *ratingDescription;
/** 更新日期 */
@property (nonatomic, copy) NSString *dateTitle;
/** 机构评等列表 */
@property (nonatomic, strong) NSArray *records;
@end

/*! @brief 发行上市应答类
 */
@interface MIPOInfoResponse : MResponse
/** 发行上市对象 */
@property (nonatomic, strong) NSDictionary *record;
@end

#pragma mark 个股概况

/*! @brief 基本情况应答类
 */
@interface MCompanyInfoResponse : MResponse
/** 基本情况对象 */
@property (nonatomic, strong) NSDictionary *record;
@end

/*! @brief 主要业务应答类
 */
@interface MCoreBusinessResponse : MResponse
/** 主要业务列表 */
@property (nonatomic, strong) NSArray *records;
@end

/*! @brief 管理层应答类
 */
@interface MLeaderPersonInfoResponse : MResponse
/** 管理层列表 */
@property (nonatomic, strong) NSArray *records;
@end

/*! @brief 大宗交易应答类
 */
@interface MBlockTradeInfoResponse : MResponse
/** 大宗交易列表 */
@property (nonatomic, strong) NSArray *records;
@end

#pragma mark 个股股东

/*! @brief 控股股东应答类
 */
@interface MControlingShareHolderResponse : MResponse
/** 控股股东对象 */
@property (nonatomic, strong) NSArray *records;
@end

/*! @brief 股本结构应答类
 */
@interface MStockShareInfoResponse : MResponse
/** 股本结构对象 */
@property (nonatomic, strong) NSDictionary *record;
@end

/*! @brief 股本变动应答类
 */
@interface MStockShareChangeInfoResponse : MResponse
/** 股本变动对象 */
@property (nonatomic, strong) NSArray *records;
@end

/*! @brief 股东变动应答类
 */
@interface MShareHolderHistoryInfoResponse : MResponse
/** 股东变动列表 */
@property (nonatomic, strong) NSArray *records;
@end

/*! @brief 最新十大流通股股东应答类
 */
@interface MTopLiquidShareHolderResponse : MResponse
/** 股东变动列表 */
@property (nonatomic, strong) NSArray *records;
@end

/*! @brief 十大流通股股东应答类
 */
@interface MTopShareHolderResponse : MResponse
/** 股东列表 */
@property (nonatomic, strong) NSArray *records;
@end

/*! @brief 最新基金持股应答类
 */
@interface MFundShareHolderInfoResponse : MResponse
@property (nonatomic, readonly) NSInteger count;
@property (nonatomic, readonly) NSString *endDate;
/** 基金持股列表 */
@property (nonatomic, strong) NSArray *records;
@end

#pragma mark 个股财务

/*! @brief 财务指标应答类
 */
@interface MFinancialInfoResponse : MResponse
/** 财务指标列表 */
@property (nonatomic, strong) NSDictionary *record;
@end

/*! @brief 财务概要应答类
 */
@interface MFinancialSummaryResponse : MResponse
/** 财务概要列表 */
@property (nonatomic, strong) NSDictionary *record;
@end

/*! @brief 基金概况应答类
 */
@interface MFundBasicInfoResponse : MResponse
/** 基金概况列表 */
@property (nonatomic, strong) NSDictionary *record;
@end

/*! @brief 基金净值应答类
 */
@interface MFundNetValueResponse : MResponse
/** 基金净值列表 */
@property (nonatomic, strong) NSArray *records;
@end

/*! @brief 资产配置应答类
 */
@interface MFundAssetAllocationResponse : MResponse
/** 资产配置列表 */
@property (nonatomic, strong) NSDictionary *record;
@end

/*! @brief 行业组合应答类
 */
@interface MFundIndustryPortfolioResponse : MResponse
/** 行业组合列表 */
@property (nonatomic, strong) NSDictionary *record;
@end

/*! @brief 股票组合应答类
 */
@interface MFundStockPortfolioResponse : MResponse
/** 股票组合列表 */
@property (nonatomic, strong) NSDictionary *record;
@end

/*! @brief 份额结构应答类
 */
@interface MFundShareStructResponse : MResponse
/** 份额结构列表 */
@property (nonatomic, strong) NSDictionary *record;
@end

/*! @brief 基金财务应答类
 */
@interface MFundFinanceResponse : MResponse
/** 基金财务列表 */
@property (nonatomic, strong) NSDictionary *record;
@end

/*! @brief 基金分红应答类
 */
@interface MFundDividendResponse : MResponse
/** 基金分红列表 */
@property (nonatomic, strong) NSDictionary *record;
@end

/*! @brief 债券概况应答类
 */
@interface MBondBasicInfoResponse : MResponse
/** 债券概况列表 */
@property (nonatomic, strong) NSDictionary *record;
@end

/*! @brief 付息情况应答类
 */
@interface MBondInterestPayResponse : MResponse
/** 付息情况列表 */
@property (nonatomic, strong) NSDictionary *record;
@end

/*! @brief 债券回购应答类
 */
@interface MBondBuyBacksResponse : MResponse
/** 债券回购列表 */
@property (nonatomic, strong) NSDictionary *record;
@end

#pragma mark 个股资讯

/*! @brief 个股公告列表应答类
 */
@interface MStockBulletinListResponse : MResponse
/** 个股公告列表 */
@property (nonatomic, strong) NSArray *stockBulletinItems;
/** 是否超过10笔资料更新 */
@property (nonatomic) BOOL overpage;
@end

/*! @brief 个股公告明細应答类
 */
@interface MStockBulletinResponse : MResponse
/** 个股公告明細对象 */
@property (nonatomic, strong) MStockBulletinDetailItem *stockBulletinDetailItem;
@end

/*! @brief 个股新闻列表应答类
 */
@interface MStockNewsListResponse : MResponse
/** 个股新闻列表 */
@property (nonatomic, strong) NSArray *stockNewsItems;
/** 是否超过10笔资料更新 */
@property (nonatomic) BOOL overpage;
@end

/*! @brief 个股新闻明細应答类
 */
@interface MStockNewsResponse : MResponse
/** 个股公告明細对象 */
@property (nonatomic, strong) MStockNewsDetailItem *stockNewsDetailItem;
@end

/*! @brief 个股研报列表应答类
 */
@interface MStockReportListResponse : MResponse
/** 个股研报列表 */
@property (nonatomic, strong) NSArray *stockReportItems;
/** 是否超过10笔资料更新 */
@property (nonatomic) BOOL overpage;
@end

/*! @brief 个股研报明細应答类
 */
@interface MStockReportResponse : MResponse
/** 个股研报明細对象 */
@property (nonatomic, strong) MStockReportDetailItem *stockReportDetailItem;
@end

#pragma mark 新闻资讯

/*! @brief 财经资讯列表应答类
 */
@interface MNewsListResponse : MResponse
/** 财经资讯列表 */
@property (nonatomic, strong) NSArray *newsItems;
/** 是否超过10笔资料更新 */
@property (nonatomic) BOOL overpage;
@end

/*! @brief 财经资讯明細应答类
 */
@interface MNewsResponse : MResponse
/** 财经资讯明細对象 */
@property (nonatomic, strong) MNewsDetailItem *newsDetailItem;
@end

@interface MNewsImgResponse : MResponse
/** 财经资讯图片NSdata */
@property (nonatomic, strong) NSData *imageData;
@end

#pragma mark 新股资讯

/*! @brief 新股上市日期信息应答类
 */
@interface MIPODateResponse : MResponse
/** 新股日期及上市个数数组 */
@property (nonatomic, strong) NSArray *infos;
@end

/*! @brief 某日的所有新股信息应答类
 */
@interface MIPOCalendarResponse : MResponse
/** 新股列表信息 */
@property (nonatomic, strong) NSDictionary *info;
@end

/*! @brief 新股信息应答类
 */
@interface MIPOShareDetailResponse : MResponse
/** 新股详细信息 */
@property (nonatomic, strong) NSDictionary *info;
@end

/*! @brief 基金净值应答类
 */
@interface MFundValueResponse : MResponse
/** 基金净值信息 */
@property (nonatomic, strong) NSArray *items;
@end

