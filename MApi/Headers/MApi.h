/////////////////////////////////////////////////////////
//                                                     //
// Copyright (c) 2016年 上证云平台. All rights reserved. //
//                                                     //
/////////////////////////////////////////////////////////

#import <Foundation/Foundation.h>
#import "MApiObject.h"
#import "MApiObject+Info.h"

#define __MAPI_TCP_ENABLED 1

extern NSString * const MApiRegisterOptionGetServerPoolingTimeKey; /// 单位:秒

/// 行情源切换通知
extern NSString * const MApiSourceLevelChangedNotification;
/// 行情源切换通知：市场别
extern NSString * const MApiSourceLevelChangedMarketKey;
/// 行情源切换通知：切换方向
extern NSString * const MApiSourceLevelChangedToKey;

typedef void (^MApiCompletionHandler)(MResponse *resp);
typedef void (^MApTimeoutHandler)(MRequest *request, BOOL *reload);

typedef BOOL (^MApiTcpUpdateBlock)(MStockItem *stockItem);
typedef void (^MApiTcpReceiveBlock)(NSString *code, MApiTcpUpdateBlock update);

#pragma mark -

/*! @brief 上证云平台终端API
 */
@interface MApi : NSObject

/*! @brief MApi的静态函数，与服务器注册接口的使用许可。
 *
 * 需要在每次启动第三方应用程序时调用。
 * @param appkey 许可键值
 * @param error 注册失败错误对象
 *
 * @param sourceLevel 行情源类别。 默认: MApiSourceLevel1
 */
+ (void)registerAPP:(NSString *)appkey completionHandler:(void (^)(NSError *error))handler;

+ (void)registerAPP:(NSString *)appkey sourceLevel:(MApiSourceLevel)sourceLevel completionHandler:(void (^)(NSError *error))handler;

+ (void)registerAPP:(NSString *)appkey withOptions:(NSDictionary *)options completionHandler:(void (^)(NSError *error))handler;

+ (void)registerAPP:(NSString *)appkey withOptions:(NSDictionary *)options sourceLevel:(MApiSourceLevel)sourceLevel completionHandler:(void (^)(NSError *error))handler;

/*! @brief 发送请求至行情服务器
 *
 *  发起请求，请先建立请求对象，依照不同的请求目的，生成具体的请求对象后传入。当服务器应答会回调handler，将可从该回调函式返回应答对象，并从中获取数据。
 *  @param request 具体的请求对象
 *  @param handler 回调函式(返回回应内容对象)
 */
+ (void)sendRequest:(MRequest *)request completionHandler:(MApiCompletionHandler)handler;

/*! @brief 发送请求至行情服务器
 *
 *  发起请求，请先建立请求对象，依照不同的请求目的，生成具体的请求对象后传入。当服务器应答会回调handler，将可从该回调函式返回应答对象，并从中获取数据。
 *  @param request 具体的请求对象
 *  @param handler 回调函式(返回回应内容对象)
 *  @param timeoutHandler(指定是否在server timeout時重發request)
 *  @example 将reload的指针设定为YES, 即可在timeout时重新请求
 *      timeoutHandler = ^(MRequest *request, BOOL *reload) {
 *            *reload = YES;
 *      };
 */
+ (void)sendRequest:(MRequest *)request completionHandler:(MApiCompletionHandler)handler timeoutHandler:(MApTimeoutHandler)timeoutHandler;

/*! @brief 设置唯一识别代码
 *
 *  已弃用
 */
+ (void)setUDID:(NSString *)UDID __attribute__((deprecated));

/**
 *  已弃用
 */
+ (void)searchingStockFromLocal __attribute__((deprecated("请使用MSearchRequest参数searchLocal")));

/*! @brief 取消所有请求
 *
 *  当发起请求，请求尚未响应时，会在伫列里等待服务器应答，调用此方法将可取消所有在伫列中的请求。
 */
+ (void)cancelAllRequests;

/*! @brief 取消单一请求
 *
 *  当发起请求，请求尚未响应时，会在伫列里等待服务器应答，调用此方法将可取消某一个在伫列中的请求。
 */
+ (void)cancelRequest:(MRequest *)request;
+ (void)cancelRequest_ptr:(MRequest **)request;

/*! @brief 清除缓存
 *
 *  此库支持部分行情缓存，调用此方法可清除所有缓存数据，释放内存及硬盘空间。
 */
+ (void)clearCache;

/*! @brief 获取缓存大小
 *
 *  此库支持部分行情缓存，调用此方法可获取当前缓存使用量
 *  单位:Byte
 *  @return 返回缓存大小
 */
+ (NSString *)cacheSize __attribute__((deprecated("请先使用num_CacheSize, cacheSize后续版本返回型别将改为(unsigned long long)")));
+ (unsigned long long)num_CacheSize;

/**
 *  获取网路状态
 *
 *  调用此方法可获取当前装置的网路状态，状态可参照@see MApiNetworkStatus
 *  @return 网路状态
 *  @see MApiNetworkStatus
 */
+ (MApiNetworkStatus)networkStatus;

/**
 *  取得市场资讯
 *
 *  若欲查询股票的市场资讯(包含小数位数、开收盘时间等信息)，可调用此方法
 *  @param market  市场别
 *  @param subtype 次类别
 *
 *  @return 市场资讯对象
 */
+ (MMarketInfo *)marketInfoWithMarket:(NSString *)market subtype:(NSString *)subtype;

/**
 *  取得各个市场最新交易日期数组
 *
 *  @return 市场交易日期数组
 */
+ (NSDictionary *)fetchMarketLastestTradeDays;

/**
 *  取得全市场股票代码表
 *
 * @param handler 下载完毕的回调
 */
+ (MStockTableRequest *)downloadStockTableWithCompletionHandler:(void (^)(NSError *error))handler;

/**
 *  设置除错模式
 */
+ (NSString *)setDebugMode:(NSDictionary *)configure;

/**
 *  当前版本信息
 */
+ (NSString *)version;

/**
 *  注册的行情源
 */
+ (MApiSourceLevel)sourceLevel;

/**
 *  订阅股票信息
 *
 *  若要使用长连接接收实时股票行情，可调用此方法
 *  @param code  股票代码
 *  @param didReceiveUpdate 回调方法
 *
 */
+ (void)subscribeQuoteCode:(NSString *)code didReceiveUpdate:(MApiTcpReceiveBlock)didReceiveUpdate;

/**
 *  取消订阅股票信息
 *
 *  若要取消长连接接收实时股票行情，可调用此方法
 *  @param code  股票代码
 *
 */
+ (void)unsubscribeQuoteCode:(NSString *)code;
+ (void)unsubscribeAllQuoteCode;

/**
 *  获取某市场别行情源类别
 *
 *  若要知道某市场别当前使用的行情源，可以调用此方法
 *  @param market 市场别 [sh, sz, hk, ...]
 *
 */
+ (MApiSourceLevel)sourceLevelWithMarket:(NSString *)market;

/**
 *  更新服务器列表
 *
 *  若要更新当前服务器列表，可调用此方法
 *
 */
+ (void)checkServerList;

@end
