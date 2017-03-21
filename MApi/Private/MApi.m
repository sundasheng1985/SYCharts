

///
#ifndef MAPI_SDK_VER
#define MAPI_SDK_VER @"0.2.15.0"
#endif

#ifndef MAPI_ARCH
#define MAPI_ARCH @"undefined"
#endif

////////

#import "MApi.h"

#import "Defines.h"

#import "MRequest.h"
#import "MAuthRequest.h"
#import "MMarketInfoRequest.h"
#import "MEchoRequest.h"
#import "MStockXRRequest.h"
#import "MPingRequest.h"
#import "MPingResponse.h"


#import "MResponse.h"
#import "MAuthResponse.h"
#import "MMarketInfoResponse.h"
#import "MEchoResponse.h"
#import "MStockXRResponse.h"
#import "MOHLCResponse.h"

#import "MCoreDataHelper.h"
#import "MApiCache.h"
#import "MApi_MKNetworkOperation.h"

#import "MKNetworkKit.h"
#import "MApi_Reachability.h"
#import "MBase64.h"
#import "GZIP.h"
#import "MApi_OpenUDID.h"

#import "NSData+MApiAdditions.h"
#import "MApi+StockNewsList.h"

#import "MApiHelper.h"
#import "MServerItem.h"
#import "MApiDebug.h"
#import "_MDispatchQueuePool.h"

#import <objc/runtime.h>

/// MApi_MQTT
#import "MApi_MQTTCFSocketTransport.h"
#import "MApi_MQTTSession.h"
#import "MApi_MQTTSessionSynchron.h"
#import "MStockItem.h"
#import "zstd.h"

/// Crash report
#import "_MCrashReporter.h"
#import "MCrashReportRequest.h"
#define CRASH_REPORT_UPLOAD_URL @"http://114.80.155.142:22018"
/// Crash report end

#import "_MApiLogger.h"
static NSString * const kNetworkReportDirectory = @"network";

#define DEBUG_MODE_TOKEN @"|F)w*7sYaoIdM+!#8d10LsT#0x|cA.xX/a@;a~"
#define DEBUG_IP_MODE_TOKEN @")f3*Flasjd_djw*wd2JPfK}sddoas0I~213tfdLKdkksaq~"

#define MAPI_DES_ENCRYPT_KEY @"b68384a66092849f10f72d0e"  //auth POST body 加密key

/// pooling get server
#import "MGetServerRequest.h"
#import "MGetServerResponse.h"

NSString * const MApiRegisterOptionGetServerPoolingTimeKey = @"MAPI_GET_SERVER_POOLING_TIME";

NSString * const MApiSourceLevelChangedNotification = @"MAPI_NOTI_SOURCE_LEVEL_CHANGED";

NSString * const MApiSourceLevelChangedMarketKey = @"MAPI_NOTI_OBJ_MARKET";
NSString * const MApiSourceLevelChangedToKey = @"MAPI_NOTI_OBJ_CHANGE_TO";

static NSString * const kGetServerPoolingDateUserDefaultKey = @"MAPI_GET_SERVER_LIST_POOLING_DATE";

static NSTimeInterval g_GetServerPoolingTime = (60*5); /// 秒


static const NSTimeInterval MAPI_MQTT_AUTO_DISCONNECT_TIME = (30.0); /// 秒
static const NSTimeInterval MAPI_MQTT_SUBSCRIBE_TIMEOUT = (10.0); /// 秒
static const NSTimeInterval MAPI_MQTT_UNSUBSCRIBE_TIMEOUT = (10.0); /// 秒
static const NSTimeInterval MAPI_MQTT_CONNECT_TIMEOUT = (15.0); /// 秒
static const NSTimeInterval MAPI_MQTT_HEART_BEAT_TIMEOUT = (10.0); /// 秒
static const NSInteger MAPI_MQTT_RECONNECT_RETRY_COUNT = (3); /// 次


static NSString * const kSendOptionResendKey = @"MAPI_RESEND";

static struct {
    unsigned int isAuthenticating:1;
    unsigned int isRandomIp:1;
    unsigned int isAppActive:1;
    unsigned int isFirstSuccessRegister:1;
    unsigned int debugRecordServerEnabled:1;
    unsigned int ignorePoolingGetServer:1;
} MApiState;

enum {
    kCodeNoCallbackHandler = 80000
};

typedef void (^MApiInteralCompletionHandler)(NSError *error);

static dispatch_queue_t mapi_request_processing_queue() {
    return _MDispatchQueueGetForQOS(NSQualityOfServiceUtility);
}

static dispatch_queue_t mapi_chart_request_processing_queue() {
    /// 因列表走势请求太频繁, 造成concurrent thread cpu占用太大, 所以限制一下
        static dispatch_queue_t mapi_request_processing_queue;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            mapi_request_processing_queue = dispatch_queue_create("com.mitake.mapi.chart.request.processing",
                                                                  DISPATCH_QUEUE_SERIAL);
        });
        return mapi_request_processing_queue;
}


/// global variable
static NSInteger g_AuthIPIndex = 0;
static dispatch_semaphore_t g_RequestsLock;
static NSMutableDictionary *g_DebugServerNameMap;
static MApiSourceLevel g_SourceLevel = -1;
static NSMutableDictionary *g_CurrentServerItems;
static dispatch_semaphore_t g_RandomIpLock;
static NSMutableSet *g_AcceptPingMarkets;
static NSMutableDictionary *g_CurrentSourceLevel;

static NSTimer *g_GetServerTimer = nil;

static NSRunLoop *g_TCPStreamRunLoop = nil;
static dispatch_queue_t mapi_tcp_request_processing_queue() {
    static dispatch_queue_t mapi_tcp_request_processing_queue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mapi_tcp_request_processing_queue = dispatch_queue_create("com.mitake.mapi.tcp.request.processing",
                                                              DISPATCH_QUEUE_SERIAL);
    });
    return mapi_tcp_request_processing_queue;
}


////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

static void ___fixes_20161125_tcp_change_level2_to_level1(NSString *market);
static NSString *___fixes_20161125_http_change_level2_to_level1(NSString *market);
static void ___fixes_20161125_check_source_level_resumed(NSString *market);
static void ___fixes_20161117_accept_ping_market(NSString *market);


NS_INLINE NSString *MApiGetPureMarket(NSString *market) {
    NSRange pureMarketRange = NSMakeRange(NSNotFound, 0);
    NSString *pureMarket = nil;
    if ((pureMarketRange = [market rangeOfString:@"sh"]).location != NSNotFound ||
        (pureMarketRange = [market rangeOfString:@"sz"]).location != NSNotFound ||
        (pureMarketRange = [market rangeOfString:@"hk"]).location != NSNotFound) {
        pureMarket = [market substringWithRange:pureMarketRange];
    }
    return pureMarket;
}

NS_INLINE NSString *__MApiGetTcpMarket(NSString *market) {
    return [market stringByAppendingString:@"-tcp"];
}

NS_INLINE BOOL __MApiRemoveFirstIP(NSMutableArray *ips, NSString *URLString) {
    if (URLString) {
        MServerItem *item = [ips firstObject];
        if ([item.IPAddress isEqualToString:URLString]) {
            [ips removeObjectAtIndex:0];
        }
    } else {
        [ips removeObjectAtIndex:0];
    }
    return ips.count == 0; /// change level
}

static MServerItem * MApiGetServerItemWithMarket(NSString *market) {
    @synchronized (g_CurrentServerItems) {
        NSRange r = [market rangeOfString:@"l2"];
        BOOL isLevel2 = r.location != NSNotFound;
        
        MServerItem *item = [g_CurrentServerItems[market] firstObject];
        if (isLevel2 && item == nil) { /// 取 Level1 ip
            NSString *marketOfLevel1 = [market stringByReplacingOccurrencesOfString:@"l2"
                                                                         withString:@""];
            item = [g_CurrentServerItems[marketOfLevel1] firstObject];
        }
        return item;
    }
}

static NSURL * MApiGetURLByMarket(NSString *market) {
    MServerItem *serverItem = MApiGetServerItemWithMarket(market);
    return [NSURL URLWithString:serverItem.IPAddress];
}

static void MApiCheckSourceLevelResumed(NSString *market, bool invokeFixesFunc) {
    /// 注册时使用Level1就不检查
    if (g_SourceLevel == MApiSourceLevel1) {
        return;
    }
    
    @synchronized (g_CurrentServerItems) {
        NSString *pureMarket = MApiGetPureMarket(market);
        if (pureMarket) {
            /// 当前的市场别还在Level2就不检查
            MApiSourceLevel currentLevel = [g_CurrentSourceLevel[pureMarket] integerValue];
            if (currentLevel == MApiSourceLevel2) {
                return;
            }
            
            NSRange r = [market rangeOfString:@"l2"];
            BOOL isLevel2 = r.location != NSNotFound;
            /// Level2的请求才检查
            if (isLevel2) {
                MServerItem *item = [g_CurrentServerItems[market] firstObject];
                /// 执行到这里Level2的IP还存在表示之前是Level1, 现在可以正常使用Level2
                if (item) {
                    NSNumber *toLevel = @(MApiSourceLevel2);
                    g_CurrentSourceLevel[pureMarket] = toLevel;
                    NSDictionary *obj = @{ MApiSourceLevelChangedMarketKey : pureMarket,
                                           MApiSourceLevelChangedToKey : toLevel };
                    [[NSNotificationCenter defaultCenter] postNotificationName:MApiSourceLevelChangedNotification
                                                                        object:obj];
                    MAPI_LOG(@"[NOTIFICATION] 💧💧💧💧💧 post level changed %@", obj);
                }
            }
        }
    }
    if (invokeFixesFunc) {
        ___fixes_20161125_check_source_level_resumed(market);
    }
}

typedef NS_ENUM(NSUInteger, MApiChangeServerState) {
    MApiChangeServerStateNone,
    MApiChangeServerStateChangeLevel,
    MApiChangeServerStateLastestIP
};

static void MApiChangeServerItemPostNotification(NSString *market) {
    NSString *pureMarket = MApiGetPureMarket(market);
    if (pureMarket) {
        MApiSourceLevel currentLevel = [g_CurrentSourceLevel[pureMarket] integerValue];
        if (currentLevel == MApiSourceLevel2) {
            NSNumber *toLevel = @(MApiSourceLevel1);
            g_CurrentSourceLevel[pureMarket] = toLevel;
            NSDictionary *obj = @{ MApiSourceLevelChangedMarketKey : pureMarket,
                                   MApiSourceLevelChangedToKey : toLevel };
            [[NSNotificationCenter defaultCenter] postNotificationName:MApiSourceLevelChangedNotification
                                                                object:obj];
            MAPI_LOG(@"[NOTIFICATION] 💧💧💧💧💧 post level changed %@", obj);
        }
    }
}

static MApiChangeServerState MApiChangeServerItem(NSString *market, NSString *URLString/*, void(^completion)(void)*/) {

    @synchronized (g_CurrentServerItems) {
        NSRange r = [market rangeOfString:@"l2"];
        BOOL isLevel2 = r.location != NSNotFound;
        
        MApiChangeServerState state = MApiChangeServerStateNone;
        
        NSMutableArray *ips = g_CurrentServerItems[market];
        if (isLevel2) {
            if (ips.count > 0) {
                
                BOOL changeLevel = __MApiRemoveFirstIP(ips, URLString);
                
                /// 处理 Level2 -> Level1
                if (changeLevel) {
                    
                    state = MApiChangeServerStateChangeLevel;
                    
                    NSRange tcpLiteralRange = [market rangeOfString:@"-tcp"];
                    BOOL isTcp = tcpLiteralRange.location != NSNotFound;
                    /// 如果是tcp则做以下事情：
                    /// 例如 market == "shl2-tcp",
                    /// 且__MApiRemoveFirstIP回传YES, 表示此Level2的tcp ip已经被清空, 则把shl2的ip也清空
                    /// 目的是要让tcp和http的sourceLevel一致
                    NSString *willCleanMarket = @"NoMarket";
                    if (isTcp) {
                        willCleanMarket = [market substringToIndex:tcpLiteralRange.location];
                        MAPI_MQTT_LOG(@"现在是TCP Level2切换Level1, 即将把市场[%@]的 Level2 HTTP IP 也清空.", willCleanMarket);
                        [g_CurrentServerItems[willCleanMarket] removeAllObjects];

                        ___fixes_20161125_tcp_change_level2_to_level1(willCleanMarket);

                    }
                    /// 如果是http则反过来把tcp ip也清空,
                    /// 如果是http触发tcp ip清空的话, 这个method return changeLevel后, 要把tcp断线重新选择ip并连线
                    else {
                        
                        NSString *____market = ___fixes_20161125_http_change_level2_to_level1(market);
                        
                        willCleanMarket = __MApiGetTcpMarket(____market);
                        MAPI_MQTT_LOG(@"现在是HTTP Level2切换Level1, 即将把市场[%@]的 Level2 TCP IP 也清空.", willCleanMarket);
                        [g_CurrentServerItems[willCleanMarket] removeAllObjects];
                    }
                    
                    /// 发通知
                    MApiChangeServerItemPostNotification(willCleanMarket);
                }
            } else {
                NSString *marketOfLevel1 = [market stringByReplacingOccurrencesOfString:@"l2"
                                                                             withString:@""];
                
                /// 递回Level1的key
                return MApiChangeServerItem(marketOfLevel1, URLString);
            }
        }
        /// else Level1
        else {
            /// 保留至少一个ip
            if (ips.count > 1) {
                __MApiRemoveFirstIP(ips, URLString); /// always return NO
            } else {
                /// 最后一个IP了
                state = MApiChangeServerStateLastestIP;
            }
        }
        
        MAPI_MQTT_LOG(@"[ChangeServer] state: %@, market: %@, URL: %@ => %@", ({
            NSString *str = @"MApiChangeServerStateNone";
            if (state == MApiChangeServerStateChangeLevel)
                str = @"MApiChangeServerStateChangeLevel";
            else if (state == MApiChangeServerStateLastestIP)
                str = @"MApiChangeServerStateLastestIP";
            str;
        }), market, URLString, MApiGetURLByMarket(market));

        return state;
    }
}


////////////////////////////////////////////////////////////////////////////////
static void ___fixes_20161125_tcp_change_level2_to_level1(NSString *market) {
    //// 垃圾CODE开始 //////////////////////////////
    /// 深圳目前独立主机
    if ([market rangeOfString:@"sz"].location != NSNotFound) {
        // 上面已经 removeAllObjects了
    }
    /// 上海、港股目前同一台, tcp ip后台目前都配在上海
    else {
        /// 如果前面删的是SH, HK也要删
        if ([market rangeOfString:@"sh"].location != NSNotFound) {
            NSString *willCleanMarket = [market stringByReplacingOccurrencesOfString:@"sh" withString:@"hk"];
            [g_CurrentServerItems[willCleanMarket] removeAllObjects];
            MApiChangeServerItemPostNotification(willCleanMarket);
        }
        /// 如果前面删的是HK, SH也要删
        else if ([market rangeOfString:@"hk"].location != NSNotFound){
            NSString *willCleanMarket = [market stringByReplacingOccurrencesOfString:@"hk" withString:@"sh"];
            [g_CurrentServerItems[willCleanMarket] removeAllObjects];
            MApiChangeServerItemPostNotification(willCleanMarket);
        }
    }
    //// 垃圾CODE结束, 以后要改掉 ///////////////////
}

static NSString *___fixes_20161125_http_change_level2_to_level1(NSString *market) {
    //// 垃圾CODE开始 //////////////////////////////
    /// 深圳目前独立主机
    if ([market rangeOfString:@"sz"].location != NSNotFound) {
        // do nothing
    }
    /// 上海、港股目前同一台, tcp ip后台目前都配在上海
    else {
        return @"shl2";
    }
    //// 垃圾CODE结束, 以后要改掉 ///////////////////
    return market;
}

static void ___fixes_20161125_check_source_level_resumed(NSString *market) {
    //// 垃圾CODE开始 //////////////////////////////
    /// 深圳目前独立主机
    if ([market rangeOfString:@"sz"].location != NSNotFound) {
        
    }
    /// 上海、港股目前同一台
    else {
        NSRange r = [market rangeOfString:@"l2"];
        BOOL isLevel2 = r.location != NSNotFound;
        if (isLevel2) {
            /// 如果前面恢复到Level2的是SH, HK也要跟著恢复
            if ([market rangeOfString:@"sh"].location != NSNotFound) {
                MApiCheckSourceLevelResumed([market stringByReplacingOccurrencesOfString:@"sh" withString:@"hk"], false);
            }
            /// 如果前面恢复到Level2的是HK, SH也要跟著恢复
            else if ([market rangeOfString:@"hk"].location != NSNotFound){
                MApiCheckSourceLevelResumed([market stringByReplacingOccurrencesOfString:@"hk" withString:@"sh"], false);
            }
        }
    }
    //// 垃圾CODE结束, 以后要改掉 ///////////////////
}

static void ___fixes_20161117_accept_ping_market(NSString *market) {
    //// 垃圾CODE开始 //////////////////////////////
    /// 深圳目前独立主机
    if ([market rangeOfString:@"sz"].location != NSNotFound) {
        // 上面已经 addObject了
    }
    /// 上海、港股目前同一台, tcp ip后台目前都配在上海
    else {
        /// 如果前面加的是SH, HK也要加
        if ([market rangeOfString:@"sh"].location != NSNotFound) {
            [g_AcceptPingMarkets addObject:@"hkl2"];
        }
        /// 如果前面加的是HK, SH也要加
        else if ([market rangeOfString:@"hk"].location != NSNotFound){
            [g_AcceptPingMarkets addObject:@"shl2"];
        }
    }
    //// 垃圾CODE结束, 以后要改掉 ///////////////////
}

////////////////////////////////////////////////////////////////////////////////

MAPI_OVERLOADABLE static void __MApiRecordDebugServer(NSString *market, NSURLRequest *URLRequest, NSHTTPURLResponse *HTTPResponse, BOOL TCPConnectionSuccess) {
    if (MApiState.debugRecordServerEnabled) {
        NSString *serverInfoString = nil;
        if (URLRequest && HTTPResponse) {
            serverInfoString = [NSString stringWithFormat:@"%@://%@",
                                URLRequest.URL.scheme,
                                URLRequest.URL.host];
            if (URLRequest.URL.port) {
                serverInfoString = [serverInfoString stringByAppendingFormat:@":%@", URLRequest.URL.port];
            }
            NSString *serverName = HTTPResponse.allHeaderFields[@"n"];
            if (serverName) {
                serverInfoString = [serverInfoString stringByAppendingFormat:@"::%@", serverName];
            }
        }
        else {
            serverInfoString = [NSString stringWithFormat:@"%@::%@",
                                MApiGetURLByMarket(market),
                                TCPConnectionSuccess ? @"OK" : @"FAILED"];
        }
        g_DebugServerNameMap[market] = serverInfoString;
    }
}

MAPI_OVERLOADABLE static void __MApiRecordDebugServer(NSString *market, BOOL TCPConnectionSuccess) {
    __MApiRecordDebugServer(market, nil, nil, TCPConnectionSuccess);
}

MAPI_OVERLOADABLE static void __MApiRecordDebugServer(NSString *market, NSURLRequest *URLRequest, NSHTTPURLResponse *HTTPResponse) {
    __MApiRecordDebugServer(market, URLRequest, HTTPResponse, NO);
}

////////////////////////////////////////////////////////////////////////////////

typedef NS_ENUM(NSInteger, MApiMQTTSubscriberStatus) {
    MApiMQTTSubscriberStatusWaitingForConnect,
    MApiMQTTSubscriberStatusConnecting,
    MApiMQTTSubscriberStatusConnected,
    MApiMQTTSubscriberStatusClosing,
    MApiMQTTSubscriberStatusClosed,
    MApiMQTTSubscriberStatusError
};

@interface MApiMQTTSubscriber : NSObject <MApi_MQTTSessionDelegate> {
    dispatch_queue_t sync_q;
    dispatch_queue_t connection_q;
    struct {
        unsigned int subing:1;
        unsigned int unsubing:1;
    } syncFlags;
}
@property (nonatomic, strong) MApi_MQTTSession *session;
@property (nonatomic, strong) NSMutableSet *prepareSubCode;
@property (nonatomic, strong) NSMutableSet *subingCode;
@property (nonatomic, strong) NSMutableSet *prepareUnsubCode;
@property (nonatomic, strong) NSMutableSet *unsubingCode;
@property (nonatomic, strong) NSMutableSet *subscribedCode;


@property (nonatomic, assign) NSInteger connectionRetryCount;
@property (nonatomic, strong) NSURL *connectionURL;

@property (nonatomic, copy) NSString *market;
@property (nonatomic, strong) NSTimer *closeConnectionTimer;
@property (nonatomic, strong) NSTimer *retryTimer;
@property (nonatomic, strong) NSTimer *reconnectionTimer;
@property (nonatomic, strong) NSTimer *heartBeatTimer;

@property (nonatomic) UIBackgroundTaskIdentifier backgroundTask;
@property (nonatomic, assign) MApiMQTTSubscriberStatus status;

@end

@implementation MApiMQTTSubscriber

- (void)dealloc {
    [self disconnect];
    
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    [defaultCenter removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
    [defaultCenter removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
    [defaultCenter removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        
        sync_q = dispatch_queue_create([NSString stringWithFormat:@"com.mitake.mapi.subscriber.sync%d", arc4random()].UTF8String, DISPATCH_QUEUE_SERIAL);
        connection_q = dispatch_queue_create([NSString stringWithFormat:@"com.mitake.mapi.subscriber.connecting%d", arc4random()].UTF8String, DISPATCH_QUEUE_SERIAL);
        
        _session = [[MApi_MQTTSession alloc] init];
        _session.delegate = self;
        
        _prepareSubCode = [[NSMutableSet alloc] init];
        _subingCode = [[NSMutableSet alloc] init];
        _prepareUnsubCode = [[NSMutableSet alloc] init];
        _unsubingCode = [[NSMutableSet alloc] init];
        _subscribedCode = [[NSMutableSet alloc] init];
    
        _connectionRetryCount = 0;
        
        _status = MApiMQTTSubscriberStatusWaitingForConnect;
        _backgroundTask = UIBackgroundTaskInvalid;

        NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
        
        [defaultCenter addObserver:self
                          selector:@selector(appWillResignActive)
                              name:UIApplicationWillResignActiveNotification
                            object:nil];

        [defaultCenter addObserver:self
                          selector:@selector(appDidEnterBackground)
                              name:UIApplicationDidEnterBackgroundNotification
                            object:nil];

        [defaultCenter addObserver:self
                          selector:@selector(appDidBecomeActive)
                              name:UIApplicationDidBecomeActiveNotification
                            object:nil];

    }
    return self;
}


#pragma mark private methods

- (void)_mqttDisconnectIfNeeded {
    BOOL delayClose = NO;
    @synchronized (self) {
        delayClose = (self.subscribedCode.count == 0);
    }
    if (delayClose) {
        MAPI_MQTT_LOG(@"[%@] %@ => ⏰开始延迟%.1f秒关闭连线", __MApiGetTcpMarket(self.market), self.connectionURL, MAPI_MQTT_AUTO_DISCONNECT_TIME);
        [self.closeConnectionTimer invalidate];
        self.closeConnectionTimer = [NSTimer timerWithTimeInterval:MAPI_MQTT_AUTO_DISCONNECT_TIME
                                                            target:self
                                                          selector:@selector(disconnect)
                                                          userInfo:nil
                                                           repeats:NO];
        [[NSRunLoop mainRunLoop] addTimer:self.closeConnectionTimer forMode:NSRunLoopCommonModes];
    }
}

- (void)_prepareUnsubscribeQuoteCode:(NSString *)codeString {
    if (codeString && codeString.length > 0) {
        [self _cancelConnectionDelayCloseTimer];
        
        NSArray *codeComps = [codeString componentsSeparatedByString:@","];
        @synchronized (self) {
            for (NSString *code in codeComps) {
                if (code.length > 0) {
                    [self.prepareUnsubCode addObject:code];
                    [self.prepareSubCode removeObject:code];
                }
            }
            MAPI_MQTT_LOG(@"[%@] %@ => 🔶准备取消订阅[subing:%d,unsubing:%d]: %@",
                          __MApiGetTcpMarket(self.market),
                          self.connectionURL ?: @"tcp://---.---.---.---:-----",
                          syncFlags.subing, syncFlags.unsubing,
                          [[self.prepareUnsubCode allObjects] componentsJoinedByString:@","]);

        }
    }
}

- (void)_unsubscribeQuoteCode {
    if (syncFlags.unsubing) {
        return;
    }
    syncFlags.unsubing = true;
    dispatch_async(sync_q, ^{
        
        NSArray *prepareCode = nil;
        @synchronized (self) {
            prepareCode = [[self.prepareUnsubCode allObjects] copy];
            if (prepareCode.count == 0) {
                [self _mqttDisconnectIfNeeded];
                syncFlags.unsubing = false;
                return;
            } else {
                [self.unsubingCode addObjectsFromArray:prepareCode];
            }
        }
        
        [self _cancelConnectionDelayCloseTimer];
        
        BOOL success = [self.session unsubscribeAndWaitTopics:prepareCode timeout:MAPI_MQTT_UNSUBSCRIBE_TIMEOUT];
        
        @synchronized (self) {
            for (NSString *code in prepareCode) {
                [self.subscribedCode removeObject:code];
                [self.prepareUnsubCode removeObject:code];
            }
            [self.unsubingCode removeAllObjects];
            syncFlags.unsubing = false;
        }
        
        if (success) {
            MAPI_MQTT_LOG(@"[%@] %@ => ✅取消订阅成功: %@",
                          __MApiGetTcpMarket(self.market), self.connectionURL, [prepareCode componentsJoinedByString:@","]);
            dispatch_async(dispatch_get_main_queue(), ^{
                [self _unsubscribeQuoteCode];
            });
        } else {
            MAPI_MQTT_LOG(@"[%@] %@ => ❎订阅失败: %@",
                          __MApiGetTcpMarket(self.market), self.connectionURL, [prepareCode componentsJoinedByString:@","]);
            dispatch_async(dispatch_get_main_queue(), ^{
                [self _enqueueCodeForReconnect];
                if (self.status != MApiMQTTSubscriberStatusClosing) {
                    [self disconnect];
                    [self RETRY_OR_CHANGE_IP];
                }
            });
        }
    });
}

- (void)_prepareSubscribeQuoteCode:(NSString *)codeString {
    if (codeString && codeString.length > 0) {
        [self _cancelConnectionDelayCloseTimer];
        
        NSArray *codeComps = [codeString componentsSeparatedByString:@","];
        @synchronized (self) {
            for (NSString *code in codeComps) {
                if (code.length > 0) {
                    [self.prepareSubCode addObject:code];
                    [self.prepareUnsubCode removeObject:code];
                }
            }
            if ([self.prepareSubCode allObjects].count > 0) {
                MAPI_MQTT_LOG(@"[%@] %@ => 🔷准备订阅[subing:%d,unsubing:%d]: %@",
                              __MApiGetTcpMarket(self.market),
                              self.connectionURL ?: @"tcp://---.---.---.---:-----",
                              syncFlags.subing, syncFlags.unsubing,
                              [[self.prepareSubCode allObjects] componentsJoinedByString:@","]);
            }
        }
    }
}

- (void)_subscribeQuoteCode {
    if (syncFlags.subing) {
        return;
    }
    syncFlags.subing = true;
    dispatch_async(sync_q, ^{
        
        NSArray *prepareCode = nil;
        @synchronized (self) {
            prepareCode = [[self.prepareSubCode allObjects] copy];
            if (prepareCode.count == 0) {
                [self _mqttDisconnectIfNeeded];
                syncFlags.subing = false;
                return;
            } else {
                [self.subingCode addObjectsFromArray:prepareCode];
            }
        }

        [self _cancelConnectionDelayCloseTimer];
        
        NSMutableDictionary *dict = [@{} mutableCopy];
        
        for (NSString *code in prepareCode) {
            if (code.length > 0) {
                [dict setObject:@(MApi_MQTTQosLevelAtLeastOnce) forKey:code];
            }
        }
        
        if (dict.count == 0) {
            syncFlags.subing = false;
            return;
        }
        
        BOOL success = [self.session subscribeAndWaitToTopics:[dict copy] timeout:MAPI_MQTT_SUBSCRIBE_TIMEOUT];
        
        if (success) {
            MAPI_MQTT_LOG(@"[%@] %@ => ✅订阅成功: %@",
                          __MApiGetTcpMarket(self.market), self.connectionURL, [[dict allKeys] componentsJoinedByString:@","]);
            
            @synchronized (self) {
                for (NSString *code in prepareCode) {
                    [self.subscribedCode addObject:code];
                    [self.prepareSubCode removeObject:code];
                }
                [self.subingCode removeAllObjects];
                syncFlags.subing = false;
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [self _subscribeQuoteCode];
            });
        } else {
            MAPI_MQTT_LOG(@"[%@] %@ => ❎订阅失败: %@",
                          __MApiGetTcpMarket(self.market), self.connectionURL, [[dict allKeys] componentsJoinedByString:@","]);
            
            @synchronized (self) {
                [self.subingCode removeAllObjects];
                syncFlags.subing = false;
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [self _enqueueCodeForReconnect];
                if (self.status != MApiMQTTSubscriberStatusClosing) {
                    [self disconnect];
                    [self RETRY_OR_CHANGE_IP];
                }
            });
        }
        
    });
}


- (void)_connect {
    /// 強制关端口
    if (self.status == MApiMQTTSubscriberStatusClosing) {
        [self.session close];
    }
    
    self.connectionRetryCount = 0;
    
    NSString *marketForTcp = __MApiGetTcpMarket(self.market);
    self.connectionURL = MApiGetURLByMarket(marketForTcp);

    if (self.connectionURL) {
        MApi_MQTTCFSocketTransport *transport = [[MApi_MQTTCFSocketTransport alloc] init];
        transport.host = self.connectionURL.host;
        transport.port = self.connectionURL.port.integerValue;
        self.session.transport = transport;
        self.session.cleanSessionFlag = YES;
        [self _connectToInternal];
    } else {
        MAPI_MQTT_LOG(@"[%@] => 😢无法建立连线", __MApiGetTcpMarket(self.market));
    }
    
}

- (void)_enqueueCodeForReconnect {
    NSString *resendCode = nil;
    @synchronized (self) {
        if (self.subscribedCode.count > 0) {
            /// for reconnect
            resendCode = [[self.subscribedCode allObjects] componentsJoinedByString:@","];
            [self.subscribedCode removeAllObjects];
        }
    }
   [self _prepareSubscribeQuoteCode:resendCode];
}

- (void)_connectToInternal {
    
    if (self.status == MApiMQTTSubscriberStatusWaitingForConnect && self.session) {
        MAPI_MQTT_LOG(@"[%@] %@ => 🤓正在建立连线", __MApiGetTcpMarket(self.market), self.connectionURL);

        self.status = MApiMQTTSubscriberStatusConnecting;
        
        dispatch_async(connection_q, ^{
            
            _session.runLoop = g_TCPStreamRunLoop;
            
            NSDate *startDate = [NSDate date];
            BOOL success = [_session connectAndWaitTimeout:MAPI_MQTT_CONNECT_TIMEOUT];
            BOOL isTimeout = [[NSDate date] timeIntervalSinceDate:startDate] >= MAPI_MQTT_CONNECT_TIMEOUT;
            if (!success && isTimeout) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    MAPI_MQTT_LOG(@"[%@] %@ => 🕑连接超时", __MApiGetTcpMarket(self.market), self.connectionURL);
                    [self disconnect];
                    [self RETRY_OR_CHANGE_IP];
                });
            }
        });
    }
}

- (void)_delayRetry:(NSTimeInterval)time {
    MAPI_MQTT_LOG(@"[%@] %@ => ⏰延迟%.1f秒重连", __MApiGetTcpMarket(self.market), self.connectionURL, time);

    // DEBUG ////////////////////////////////////////////////
    NSString *marketForTcp = __MApiGetTcpMarket(self.market);
    __MApiRecordDebugServer(marketForTcp, NO);
    // DEBUG ////////////////////////////////////////////////
    
    self.status = MApiMQTTSubscriberStatusWaitingForConnect;
    [self.retryTimer invalidate];
    self.retryTimer = [NSTimer timerWithTimeInterval:time
                                              target:self
                                            selector:@selector(_connectToInternal)
                                            userInfo:nil
                                             repeats:NO];
    [[NSRunLoop mainRunLoop] addTimer:self.retryTimer forMode:NSRunLoopCommonModes];
}

- (void)RETRY_OR_CHANGE_IP {
    if (self.connectionRetryCount < MAPI_MQTT_RECONNECT_RETRY_COUNT) {
        self.connectionRetryCount++;
        [self _delayRetry:1.0];
    }
    else {
        
        /// 换ip
        NSString *marketForTcp = __MApiGetTcpMarket(self.market);
        MApiChangeServerState state = MApiChangeServerItem(marketForTcp, self.connectionURL.absoluteString);
        if (state == MApiChangeServerStateChangeLevel) {
            MAPI_SP_LOCK(g_RandomIpLock);
            /// MARK: [ACCEPT PING MARKETS]
            /// 加入set里面，轮循GetServer时random ip要用
            [g_AcceptPingMarkets addObject:marketForTcp];
            /// 把跟tcp对应的market也放入同步改变
            [g_AcceptPingMarkets addObject:self.market];
            
            ___fixes_20161117_accept_ping_market(self.market);
            
            MAPI_SP_UNLOCK(g_RandomIpLock);
        }
        
        self.status = MApiMQTTSubscriberStatusWaitingForConnect;
        /// delay 1~3 sec
        NSTimeInterval time = ((arc4random() % 3) + 1);
        MAPI_MQTT_LOG(@"[%@] %@ => ⏰延迟%.1f秒重连", __MApiGetTcpMarket(self.market), MApiGetURLByMarket(__MApiGetTcpMarket(self.market)), time);

        [self.reconnectionTimer invalidate];
        self.reconnectionTimer = [NSTimer timerWithTimeInterval:time
                                                  target:self
                                                selector:@selector(_connect)
                                                userInfo:nil
                                                 repeats:NO];
        [[NSRunLoop mainRunLoop] addTimer:self.reconnectionTimer forMode:NSRunLoopCommonModes];
    }
}

- (void)_cancelConnectionDelayCloseTimer {
    if (self.closeConnectionTimer) {
        MAPI_MQTT_LOG(@"[%@] %@ => ❌取消延迟%.1f秒关闭连线", __MApiGetTcpMarket(self.market), self.connectionURL, MAPI_MQTT_AUTO_DISCONNECT_TIME);

        [self.closeConnectionTimer invalidate];
        self.closeConnectionTimer = nil;
    }
}

#pragma mark public methods

- (void)reconnectIfNeeded {
    [self _enqueueCodeForReconnect];
    MApiMQTTSubscriberStatus previousStatus = self.status;
    [self disconnect];
    if (previousStatus == MApi_MQTTSessionStatusConnecting || previousStatus == MApi_MQTTSessionStatusConnected) {
        [self _connect];
    }
}

- (void)disconnect {
    self.status = MApiMQTTSubscriberStatusClosing;
    [self.session close];
    if (self.closeConnectionTimer) {
        [self.closeConnectionTimer invalidate];
        self.closeConnectionTimer = nil;
    }
    if (self.retryTimer) {
        [self.retryTimer invalidate];
        self.retryTimer = nil;
    }
    if (self.reconnectionTimer) {
        [self.reconnectionTimer invalidate];
        self.reconnectionTimer = nil;
    }
    if (self.heartBeatTimer) {
        [self.heartBeatTimer invalidate];
        self.heartBeatTimer = nil;
    }
}

- (void)unsubscribeQuoteCode:(NSString *)codeString {
    
    if (codeString.length > 0) {
        [self _prepareUnsubscribeQuoteCode:codeString];
        
        if (self.status == MApiMQTTSubscriberStatusConnected) {
            [self _unsubscribeQuoteCode];
        }
        else if (self.status != MApiMQTTSubscriberStatusConnecting) {
            [self _connect];
        }
    }
}

- (void)unsubscribeAllQuoteCode {
    NSMutableArray *willUnsubCode = [NSMutableArray array];
    @synchronized (self) {
        [willUnsubCode addObjectsFromArray:[self.prepareSubCode allObjects]];
        [willUnsubCode addObjectsFromArray:[self.subingCode allObjects]];
        [willUnsubCode addObjectsFromArray:[self.subscribedCode allObjects]];
    }
    [self unsubscribeQuoteCode:[willUnsubCode componentsJoinedByString:@","]];
}

- (void)subscribeQuoteCode:(NSString *)code didReceiveUpdate:(MApiTcpReceiveBlock)didReceiveUpdate {
    
    [self _prepareSubscribeQuoteCode:code];
    
    self.session.clientId = MAPI_ACCESS_TOKEN;
    __weak MApiMQTTSubscriber *weakSelf = self;
    self.session.messageHandler = ^(NSData* message, NSString* topic) {
        __strong MApiMQTTSubscriber *strongSelf = weakSelf;
        BOOL effectiveCode = NO;
        @synchronized (strongSelf) {
            effectiveCode = [strongSelf.subscribedCode containsObject:topic] || [strongSelf.subingCode containsObject:topic];
        }
        if (effectiveCode) {
            MAPI_MQTT_LOG(@"[%@] %@ => 🚩收到 %@ 数据长度 %zd", __MApiGetTcpMarket(strongSelf.market), strongSelf.connectionURL, topic, message.length);
        } else {
            MAPI_MQTT_LOG(@"[%@] %@ => ❓忽略 %@ 数据长度 %zd", __MApiGetTcpMarket(strongSelf.market), strongSelf.connectionURL, topic, message.length);
            return;
        }
        
        /// zstd decompress start
        unsigned long long size = ZSTD_getDecompressedSize(message.bytes, message.length);
        char dst[size];
        ZSTD_decompress(&dst, size, message.bytes, message.length);
        NSData *decompressMessage = [[NSData alloc] initWithBytes:&dst length:size];
        /// end of zstd decompress
        
        /// update
        NSString *targetQuoteCode = topic;
        
        if (targetQuoteCode) {
            dispatch_async(dispatch_get_main_queue(), ^{
                didReceiveUpdate(targetQuoteCode, ^(MStockItem *stockItem) {
                    @try {
                        [stockItem update:decompressMessage code:targetQuoteCode];
                        return YES;
                    } @catch (NSException *exception) {
                        MAPI_MQTT_LOG(@"[%@] %@ => 🔴更新股票[%@]失败: %@", __MApiGetTcpMarket(strongSelf.market), strongSelf.connectionURL, topic, exception.reason);
                        return NO;
                    } @finally { }
                });
            });
        }
    };
    
    if (self.status == MApiMQTTSubscriberStatusConnected) {
        [self _subscribeQuoteCode];
    }
    else if (self.status != MApiMQTTSubscriberStatusConnecting) {
        [self _connect];
    }
}


#pragma mark MApi_MQTTSessionDelegate

- (void)sending:(MApi_MQTTSession *)session type:(MApi_MQTTCommandType)type qos:(MApi_MQTTQosLevel)qos retained:(BOOL)retained duped:(BOOL)duped mid:(UInt16)mid data:(NSData *)data {
    switch (type) {
        case MApi_MQTTPingreq:
        {
            MAPI_MQTT_LOG(@"[%@] %@ => ❤️发送心跳包 %@ @%.0f", __MApiGetTcpMarket(self.market), self.connectionURL, session.clientId, [[NSDate date] timeIntervalSince1970]);
            self.heartBeatTimer = [NSTimer timerWithTimeInterval:MAPI_MQTT_HEART_BEAT_TIMEOUT
                                                      target:self
                                                    selector:@selector(reconnectIfNeeded)
                                                    userInfo:nil
                                                     repeats:NO];
            [[NSRunLoop mainRunLoop] addTimer:self.heartBeatTimer forMode:NSRunLoopCommonModes];

            break;
        }
        case MApi_MQTTDisconnect:
        {
            MAPI_MQTT_LOG(@"[%@] %@ => 🙏发送关闭连线报文", __MApiGetTcpMarket(self.market), self.connectionURL);
            break;
        }
        case MApi_MQTTConnect:
        {
            MAPI_MQTT_LOG(@"[%@] %@ => ➡️发送请求连线报文", __MApiGetTcpMarket(self.market), self.connectionURL);
            break;
        }
        default:
        {
            //MAPI_MQTT_LOG(@"[%@] %@ => ➡️发送[%zd]", __MApiGetTcpMarket(self.market), self.connectionURL, type);
            break;
        }
    }
}

- (void)received:(MApi_MQTTSession *)session type:(MApi_MQTTCommandType)type qos:(MApi_MQTTQosLevel)qos retained:(BOOL)retained duped:(BOOL)duped mid:(UInt16)mid data:(NSData *)data {
    switch (type) {
        case MApi_MQTTPingresp:
        {
            MAPI_MQTT_LOG(@"[%@] %@ => ❤️收到服务端心跳包反馈 %@ @%.0f", __MApiGetTcpMarket(self.market), self.connectionURL, session.clientId, [[NSDate date] timeIntervalSince1970]);
            if (self.heartBeatTimer) {
                [self.heartBeatTimer invalidate];
                self.heartBeatTimer = nil;
            }
            break;
        }
        case MApi_MQTTConnack:
        {
            MAPI_MQTT_LOG(@"[%@] %@ => ⬅️收到连线ACK", __MApiGetTcpMarket(self.market), self.connectionURL);
            break;
        }
        default:
        {
            //MAPI_MQTT_LOG(@"[%@] %@ => ⬅️收到[%zd]", __MApiGetTcpMarket(self.market), self.connectionURL, type);
            break;
        }
    }
}

- (void)handleEvent:(MApi_MQTTSession *)session event:(MApi_MQTTSessionEvent)eventCode error:(NSError *)error {
    
    [self _enqueueCodeForReconnect];

    if (error) {
        
        MAPI_MQTT_LOG(@"[%@] %@ => 🔴发生错误[%zd], %@", __MApiGetTcpMarket(self.market), self.connectionURL, eventCode, error);

        self.status = MApiMQTTSubscriberStatusError;
        switch (error.code) {
            case 60: //Error Domain=NSPOSIXErrorDomain Code=60 "Operation timed out"
            case 61: //Error Domain=NSPOSIXErrorDomain Code=61 "Connection refused" // server关闭
            {
                [self RETRY_OR_CHANGE_IP];
                break;
            }
            case 50: //Error Domain=NSPOSIXErrorDomain Code=50 "Network is down"
            case 51: //Error Domain=NSPOSIXErrorDomain Code=51 "Network is unreachable"
            case 57: //Error Domain=NSPOSIXErrorDomain Code=57 "Socket is not connected"
            default:
            {
                [self _delayRetry:3.0];
                break;
            }
        }
    }
    else {
        switch (eventCode) {
            case MApi_MQTTSessionEventConnected:
            {
                // DEBUG ////////////////////////////////////////////////
                NSString *marketForTcp = __MApiGetTcpMarket(self.market);
                __MApiRecordDebugServer(marketForTcp, YES);
                // DEBUG ////////////////////////////////////////////////

                MAPI_MQTT_LOG(@"[%@] %@ => 👍成功建立连线", __MApiGetTcpMarket(self.market), self.connectionURL);
                self.status = MApiMQTTSubscriberStatusConnected;
                /// 检查是否 Level1 -> Level2
                MApiCheckSourceLevelResumed(self.market, true);
                
                self.connectionRetryCount = 0;
                
                [self _subscribeQuoteCode];
                [self _unsubscribeQuoteCode];
                
                break;
            }
            case MApi_MQTTSessionEventConnectionClosed:
            case MApi_MQTTSessionEventConnectionClosedByBroker:
            {
                /// 实际：收到Broker关闭连线 -> 手机关闭端口
                /// 回调：MApi_MQTTSessionEventConnectionClosed -> MApi_MQTTSessionEventConnectionClosedByBroker
                
                self.status = MApiMQTTSubscriberStatusClosed;
                if (self.backgroundTask) {
                    [[UIApplication sharedApplication] endBackgroundTask:self.backgroundTask];
                    self.backgroundTask = UIBackgroundTaskInvalid;
                }
                self.status = MApiMQTTSubscriberStatusWaitingForConnect;
                
                if (eventCode == MApi_MQTTSessionEventConnectionClosedByBroker) {
                    BOOL reconnect = NO;
                    @synchronized (self) {
                        reconnect = self.prepareSubCode.count > 0 && MApiState.isAppActive;
                    }
                    /// 这里用来判断 => 服务端是收到手机请求断线的报文, 或是直接关闭主机
                    if (reconnect) {
                        MAPI_MQTT_LOG(@"[%@] %@ => 🔴服务端连线关闭，重新连线: %@", __MApiGetTcpMarket(self.market), self.connectionURL, [[self.prepareSubCode allObjects] componentsJoinedByString:@","]);
                        [self RETRY_OR_CHANGE_IP];
                    }
                }
                else if (eventCode == MApi_MQTTSessionEventConnectionClosed && self.connectionURL) {
                    MAPI_MQTT_LOG(@"[%@] %@ => ✅手机端口关闭", __MApiGetTcpMarket(self.market), self.connectionURL);
                }
                break;
            }
            case MApi_MQTTSessionEventConnectionRefused:
            case MApi_MQTTSessionEventConnectionError:
            case MApi_MQTTSessionEventProtocolError:
            default:
            {
                MAPI_MQTT_LOG(@"[%@] %@ => catched unhandle eventCode:%zd without error.", __MApiGetTcpMarket(self.market), self.connectionURL, eventCode);
                break;
            }
        } /// end case
    } /// end else
}


#pragma mark System notification

- (void)appWillResignActive {
    [self _enqueueCodeForReconnect];
    [self disconnect];
}

- (void)appDidEnterBackground {
    __weak MApiMQTTSubscriber *weakSelf = self;
    self.backgroundTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        __strong MApiMQTTSubscriber *strongSelf = weakSelf;
        if (strongSelf.backgroundTask) {
            [[UIApplication sharedApplication] endBackgroundTask:strongSelf.backgroundTask];
            strongSelf.backgroundTask = UIBackgroundTaskInvalid;
        }
    }];
}

- (void)appDidBecomeActive {
    BOOL reconnect = NO;
    @synchronized (self) {
        reconnect = self.prepareSubCode.count > 0;
    }
    if (reconnect) {
        [self _connect];
    }
}

@end


////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

static NSMutableDictionary <NSString *, MApiMQTTSubscriber *> *g_MQTTSubscribers;

@implementation MApi

+ (void)initialize {
    if (self == [MApi class]) {
        
        MApiState.isFirstSuccessRegister = false;
        MApiState.ignorePoolingGetServer = false;
        
        g_RequestsLock = MAPI_GET_SP_LOCKER();
        g_RandomIpLock = MAPI_GET_SP_LOCKER();
        g_DebugServerNameMap = [@{} mutableCopy];
        g_CurrentServerItems = [@{} mutableCopy];
        g_MQTTSubscribers = [@{} mutableCopy];
        g_AcceptPingMarkets = [[NSMutableSet alloc] init];
        g_CurrentSourceLevel = [@{} mutableCopy];
        
        dispatch_async(mapi_tcp_request_processing_queue(), ^{
            g_TCPStreamRunLoop = [NSRunLoop currentRunLoop];
            [[NSRunLoop currentRunLoop] addPort:[NSMachPort port] forMode:NSRunLoopCommonModes];
            [[NSRunLoop currentRunLoop] run];
        });
        
        NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
        
        [defaultCenter addObserver:self
                          selector:@selector(_mapi_appWillResignActive)
                              name:UIApplicationWillResignActiveNotification
                            object:nil];
        
        [defaultCenter addObserver:self
                          selector:@selector(_mapi_appDidBecomeActive)
                              name:UIApplicationDidBecomeActiveNotification
                            object:nil];
    }
}

+ (MApi_MKNetworkEngine *)httpEngine {
    static MApi_MKNetworkEngine *httpEngine = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        httpEngine = [[MApi_MKNetworkEngine alloc] init];
    });
    return httpEngine;
}

+ (MApi_MKNetworkHost *)HTTPEngine_v2 {
    static MApi_MKNetworkHost *HTTPEngine = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        HTTPEngine = [[MApi_MKNetworkHost alloc] initWithHostName:nil];
    });
    return HTTPEngine;
}


#pragma mark Notification

+ (void)_mapi_appWillResignActive {
    MAPI_LOG(@"MApiState.isAppActive = false");
    MApiState.isAppActive = false;
}

+ (void)_mapi_appDidBecomeActive {
    MAPI_LOG(@"MApiState.isAppActive = ture");
    MApiState.isAppActive = true;
    if (MApiState.isFirstSuccessRegister) {
        [self checkServerList]; /// 检查上一次更新
    }
}


#pragma mark - public

+ (void)registerAPP:(NSString *)appkey completionHandler:(MApiInteralCompletionHandler)handler {
    [self registerAPP:appkey withOptions:nil completionHandler:handler];
}

+ (void)registerAPP:(NSString *)appkey sourceLevel:(MApiSourceLevel)sourceLevel completionHandler:(void (^)(NSError *error))handler {
    [self registerAPP:appkey withOptions:nil sourceLevel:sourceLevel completionHandler:handler];
}

+ (void)registerAPP:(NSString *)appkey withOptions:(NSDictionary *)options completionHandler:(MApiInteralCompletionHandler)handler {
    [self registerAPP:appkey withOptions:options sourceLevel:MApiSourceLevel1 completionHandler:handler];
}

+ (void)registerAPP:(NSString *)appkey withOptions:(NSDictionary *)options sourceLevel:(MApiSourceLevel)sourceLevel completionHandler:(MApiInteralCompletionHandler)handler {

    if (!handler) [self _raiseExceptionWithCode:kCodeNoCallbackHandler];
    
    if (MApiState.isAuthenticating) return;
    
    MApiState.isAuthenticating = true;
    
    /// 当恶意多次注册时 如果已经认证成功并且 所传参数均相同则直接判定认真成功
    if (MApiState.isFirstSuccessRegister &&
        g_SourceLevel == sourceLevel &&
        [[MApiHelper sharedHelper].appKey isEqualToString:appkey] &&
        ([MApiHelper sharedHelper].registerOptions == options || [[MApiHelper sharedHelper].registerOptions isEqualToDictionary:options])) {
        MApiState.isAuthenticating = false;
        handler(nil);
        return;
    }
    
    [MApiHelper sharedHelper].appKey = appkey;

    MApiInteralCompletionHandler interHandler = ^(NSError *error) {
        
        if (!MApiState.isFirstSuccessRegister && !error) {
            [self _startDelayGetServer];
            [self _getServer:^{ /// 这里执行GetServer, 里面会判断上次GetServer的日期, 如果是token未失效就可以顺便更新ServerList
                MApiState.isFirstSuccessRegister = true;
                MApiState.isAuthenticating = false;
                handler(error);
            }];
        } else {
            if (error) {
                [[MApiHelper sharedHelper] clearAuthInfo];
            }
            MApiState.isAuthenticating = false;
            handler(error);
        }
    };
    
    /// MApi_MQTT 断线
    [g_MQTTSubscribers enumerateKeysAndObjectsUsingBlock:^(NSString *key, MApiMQTTSubscriber *suber, BOOL * _Nonnull stop) {
        [suber disconnect];
    }];
    
    g_SourceLevel = sourceLevel;
    
    if (!(options && [options[@"MAPI_IGNORE_RESTORE_AUTH_INFO"] boolValue])) {
        /// 从plist中取得 AccessToken, QuoteServers, MarketInfos authServers
        [[MApiHelper sharedHelper] restoreAuthInfo];
    }

    ///
    MApiState.debugRecordServerEnabled = false;

    if (options) {
        [MApiHelper sharedHelper].registerOptions = options;
        if (options[@"MAPI_DEBUG_AUTH_SERVERS"]) {
            /// 因为使用debug auth server, 所以清掉token重新认证
            [[MApiHelper sharedHelper] clearAuthInfo];
            MAPI_AUTH_SERVERS = options[@"MAPI_DEBUG_AUTH_SERVERS"];
        }
        if (options[@"MAPI_DEBUG_QUOTE_SERVERS"]) {
            /// 使用debug quote server, 覆盖原本的server list
            MAPI_QUOTE_SERVERS = options[@"MAPI_DEBUG_QUOTE_SERVERS"];
        }
        if (options[@"MAPI_DEBUG_RECORD_SERVER_ENABLED"] &&
            [options[@"MAPI_DEBUG_RECORD_SERVER_ENABLED"] boolValue]) {
            MApiState.debugRecordServerEnabled = true;
        }
        if (options[@"MAPI_DEBUG_CRASH_REPORT_ENABLED"] &&
            [options[@"MAPI_DEBUG_CRASH_REPORT_ENABLED"] boolValue]) {
            _MCrashReporter *cp = [_MCrashReporter sharedInstance];
            [cp sendCrashReport];
        }
        
        if (options[@"MAPI_DEBUG_CORP_ID"]) {
            [MApiHelper sharedHelper].corpID = options[@"MAPI_DEBUG_CORP_ID"];
        }
        if (options[@"MAPI_DEBUG_BUNDLE_ID"]) {
            [MApiHelper sharedHelper].unitTest_bundleID = options[@"MAPI_DEBUG_BUNDLE_ID"];
        }
        if (options[@"MAPI_DEBUG_APP_VER"]) {
            [MApiHelper sharedHelper].unitTest_version = options[@"MAPI_DEBUG_APP_VER"];
        }
//        if (options[@"MAPI_NETWORK_ERR_REPORT_ENABLED"] &&
//            [options[@"MAPI_NETWORK_ERR_REPORT_ENABLED"] boolValue]) {
//            [_MApiLogger sendReportInDirectory:kNetworkReportDirectory];
//        }
        if (options[@"MAPI_DEBUG_IGNORE_POOLING_GET_SERVER"]) {
            MApiState.ignorePoolingGetServer = true;
        }
        if (options[MApiRegisterOptionGetServerPoolingTimeKey]) {
            g_GetServerPoolingTime = [options[MApiRegisterOptionGetServerPoolingTimeKey] doubleValue];
        }
    }
    
    /// 发送上次的网路请求error
    [_MApiLogger sendReportInDirectory:kNetworkReportDirectory];
    
    g_AuthIPIndex = 0;
    
#ifdef MAPI_CORP_ID
    [self _setCorpID:MAPI_CORP_ID];
#else
    [self _setCorpID:@"168"];
#endif
    
    /////////////////////////
    ///当APP重新启动时如果本地缓存有效
    if (MAPI_ACCESS_TOKEN && MAPI_QUOTE_SERVERS) {
    
        MAPI_LOG(@"-------------------------\n使用本地缓存 \nMAPI_ACCESS_TOKEN:%@ \nMAPI_QUOTE_SERVERS:\n%@ \n----------------------", MAPI_ACCESS_TOKEN, MAPI_QUOTE_SERVERS);

        [self _handleGenerateIpList:MAPI_QUOTE_SERVERS /* 传nil, 方法里面会使用MAPI_QUOTE_SERVERS去选IP */
                          completed:^{
                              [self _fetchingMarkInfoWithHandler:interHandler];
                          }];
    } else {
        [self _sendEchoWithAPPKey:appkey completionHandler:interHandler];
    }
    
    /////////////////////////
    
}

+ (void)cancelAllRequests {
    [self _cancelAllRequestsForResend:NO];
}

+ (void)cancelRequest:(MRequest *)request {
    if (!request) return;
    MAPI_SP_LOCK(g_RequestsLock);
    NSInteger foundIdx;
    if ((foundIdx = [self.requests indexOfObject:request]) != NSNotFound) {
        request = self.requests[foundIdx];
        [request _cancel];
        [self.requests removeObjectAtIndex:foundIdx];
        MAPI_LOG(@"取消请求:%@  所有请求数:%@\n%@", NSStringFromClass([request class]), @(self.requests.count), request);
    } 
    MAPI_SP_UNLOCK(g_RequestsLock);
}

+ (void)cancelRequest_ptr:(MRequest **)request {
    if (!*request) return;
    MAPI_SP_LOCK(g_RequestsLock);
    if ([self.requests indexOfObject:*request] != NSNotFound) {
        MRequest *sendingRequest = *request;
        *request = [*request copy];
        [sendingRequest _cancel];
        [self.requests removeObject:sendingRequest];
        MAPI_LOG(@"取消请求:%@  所有请求数:%@", NSStringFromClass([sendingRequest class]), @(self.requests.count));
    }
    MAPI_SP_UNLOCK(g_RequestsLock);
}

+ (void)sendRequest:(MRequest *)request completionHandler:(MApiCompletionHandler)handler {
    [self sendRequest:request completionHandler:handler timeoutHandler:nil];
}

+ (void)sendRequest:(MRequest *)request completionHandler:(MApiCompletionHandler)handler timeoutHandler:(MApTimeoutHandler)timeoutHandler {
    [self _sendRequest:request completionHandler:handler timeoutHandler:timeoutHandler options:nil];
}

+ (void)_sendRequest:(MRequest *)request completionHandler:(MApiCompletionHandler)handler timeoutHandler:(MApTimeoutHandler)timeoutHandler options:(NSDictionary *)options {
    
    if (!request) return;
    
    request = [request copy];
    
    request.handler = handler;
    request.timeoutHandler = timeoutHandler;
    request.level = g_SourceLevel; /// Request实作 _market 时会用到
    
    [request start:[options[kSendOptionResendKey] boolValue]];
    
    /// 加入佇列
    BOOL isSending = [self _addRequest:request];
    if (isSending) {
        [request _cancelOperation];
    }
    
    dispatch_async([self _processingQueue:request], ^{

        if (![request isValidate]) {
            [self _responseErrorForRequest:request status:MResponseStatusParameterError];
            return;
        }
        
        if (request.isCancelled) return;

        if ([request isKindOfClass:[MSearchRequest class]]) {
            MSearchRequest *searchRequest = (MSearchRequest *)request;
            if (searchRequest.keyword.length == 0) {
                [self _responseErrorForRequest:request status:MResponseStatusSuccess];
                return;
            }
            else if (searchRequest.searchLocal) {
                // 搜寻股票查询本地的CoreData
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self _searchingStockFromDatabaseWithRequest:searchRequest];
                });
                
                return;
            }
        }
    
        // Process cache
        BOOL isContinue = [self _isContinueAfterFetchingCacheResponseWithRequest:request];
        if (!isContinue || request.isCancelled) {
            [self _removeRequest:request];
            return;
        }

        /// 没有token时的处理
        BOOL ignoreAccessToken =
        [request isKindOfClass:[MEchoRequest class]] ||
        [request isKindOfClass:[MAuthRequest class]] ||
        [request isKindOfClass:[MCrashReportRequest class]];
        if (!ignoreAccessToken && [[MApiHelper sharedHelper] isTokenEmpty]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self _handleTokenExpiredEvent];
            });
            return;
        }
        
        static float deviceVersion;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            deviceVersion = [[UIDevice currentDevice] systemVersion].floatValue;
        });
        
        /////////////////////////////////////////////////
        // Setup request & operation
        NSString *HTTPMethod = [request httpMethod];
        NSString *URLString = [MApi _URLStringByRequest:request];
        NSString *debugMarketString = [request._market copy];
        
        if (!URLString) {
            [self _responseErrorForRequest:request status:MResponseStatusServerSiteNotFound];
            return;
        }
        NSDictionary *POSTParam = [request postParam];
        BOOL isKindOfCrashReportRequest = [request isKindOfClass:[MCrashReportRequest class]];
        
        /////////////////////////////////////////////////
        // v2
        if (deviceVersion >= 8.0) {
            NSData *bodyData = nil;
            if ([HTTPMethod isEqualToString:MApiHttpMethodPOST]) {
                if (isKindOfCrashReportRequest) {
                    bodyData = [[POSTParam mapi_urlEncodedKeyValueString] dataUsingEncoding:NSUTF8StringEncoding];
                } else {
                    NSData *JSONData = [NSJSONSerialization dataWithJSONObject:POSTParam options:NSJSONWritingPrettyPrinted error:nil];
                    NSData *encryptedData = [JSONData tripleDESEncryptWithKey:MAPI_DES_ENCRYPT_KEY];
                    NSString *postBody = [MBase64 base64EncodedStringFrom:encryptedData];
                    bodyData = [postBody dataUsingEncoding:NSUTF8StringEncoding];
                }
            }
            MApi_MKNetworkRequest *operation_v2 =
            [[MApi_MKNetworkRequest alloc] initWithURLString:URLString
                                                      params:nil
                                                    bodyData:bodyData
                                                  httpMethod:HTTPMethod];
            operation_v2.doNotCache = YES;
            if (request.timeoutInterval > 0) {
                operation_v2.timeoutInterval = request.timeoutInterval;
            }
            [operation_v2 addHeaders:[request HTTPHeaderFields]];
            request.operation_v2 = operation_v2;
            [operation_v2 addCompletionHandler:^(MApi_MKNetworkRequest *completedRequest) {
                
                if (request.isCancelled) {
                    return;
                }
                
                NSHTTPURLResponse *HTTPResponse = completedRequest.response;
                
                // DEBUG ////////////////////////////////////////////////
                __MApiRecordDebugServer(debugMarketString, completedRequest.request, HTTPResponse);
                /////////////////////////////////////////////////////////
                
                if (completedRequest.state == MApi_MKNKRequestStateCompleted) {
                    MAPI_CURL_LOG(@"\n🔵%@\n\n", [completedRequest description]);
                    
                    [self _handleCompletionWithHTTPResponse:HTTPResponse
                                               responseData:completedRequest.responseData
                                                    request:request];
                }
                else if (completedRequest.state == MApi_MKNKRequestStateError) {
                    [self _handleErrorWithHTTPResponse:HTTPResponse
                                       connectionError:completedRequest.error
                                               request:request
                                           description:[completedRequest description]];
                }
            }];
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [[self HTTPEngine_v2] startRequest:operation_v2];
                [request increaseSendCount];

            });
            
        }
        // v2 end
        /////////////////////////////////////////////////
        // v1
        else {
            MApi_MKNetworkEngine *httpEngine = [MApi httpEngine];
            MApi_MKNetworkOperation *operation =
            [httpEngine operationWithURLString:URLString
                                        params:POSTParam
                                    httpMethod:HTTPMethod];
            
            if (request.timeoutInterval > 0) {
                operation.mapi_timeoutInterval = request.timeoutInterval;
            }
            [operation addHeaders:[request HTTPHeaderFields]];
            request.operation = operation;
            
            // Auth Post Body
            if ([HTTPMethod isEqualToString:MApiHttpMethodPOST]) {
                [operation setCustomPostDataEncodingHandler:^NSString *(NSDictionary *postDataDict) {
                    if (isKindOfCrashReportRequest) {
                        return [POSTParam mapi_urlEncodedKeyValueString];
                    } else {
                        NSData *JSONData = [NSJSONSerialization dataWithJSONObject:postDataDict options:NSJSONWritingPrettyPrinted error:nil];
                        NSData *encryptedData = [JSONData tripleDESEncryptWithKey:MAPI_DES_ENCRYPT_KEY];
                        NSString *postBody = [MBase64 base64EncodedStringFrom:encryptedData];
                        return postBody;
                    }
                } forType:@"text/plain"];
            }
            
            __weak MApi_MKNetworkOperation *weakOperation = operation;
            MApi_MKNKResponseBlock completionHandler =
            ^(MApi_MKNetworkOperation *completedOperation) {
                MAPI_ASSERT_MAIN_THREAD();
                __strong MApi_MKNetworkOperation *strongOperation = weakOperation;
                if (strongOperation != completedOperation) {
                    return;
                }
                if (request.isCancelled) {
                    return;
                }
                
                // DEBUG ////////////////////////////////////////////////
                __MApiRecordDebugServer(debugMarketString, completedOperation.readonlyRequest, completedOperation.readonlyResponse);
                /////////////////////////////////////////////////////////
                
                MAPI_CURL_LOG(@"\n🔵%@\n\n", [completedOperation description]);
                [self _handleCompletionWithHTTPResponse:completedOperation.readonlyResponse
                                           responseData:completedOperation.responseData
                                                request:request];
                
            }; // end of completionHandler
            
            MApi_MKNKResponseErrorBlock errorHandler =
            ^(MApi_MKNetworkOperation *completedOperation, NSError *error) {
                MAPI_ASSERT_MAIN_THREAD();
                __strong MApi_MKNetworkOperation *strongOperation = weakOperation;
                if (strongOperation != completedOperation) {
                    return;
                }
                if (request.isCancelled) {
                    return;
                }
                
                // DEBUG ////////////////////////////////////////////////
                __MApiRecordDebugServer(debugMarketString, completedOperation.readonlyRequest, completedOperation.readonlyResponse);
                /////////////////////////////////////////////////////////
                
                [self _handleErrorWithHTTPResponse:completedOperation.readonlyResponse
                                   connectionError:error
                                           request:request];
            }; // end of errorHandler
            
            if (request.isCancelled) {
                return;
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                @try {
                    [operation addCompletionHandler:completionHandler errorHandler:errorHandler];
                } @catch (NSException *exception) {
                    [self cancelRequest:request];
                    return;
                }
                [[MApi httpEngine] enqueueOperation:operation];
                [request increaseSendCount];
            });
        }
        // v1 end
        /////////////////////////////////////////////////

    }); // end of async queue dispatch
}

+ (MStockTableRequest *)downloadStockTableWithCompletionHandler:(MApiInteralCompletionHandler)handler {
    return [MCoreDataHelper getStockTableWithCompletionHandler:handler];
}

+ (MMarketInfo *)marketInfoWithMarket:(NSString *)market subtype:(NSString *)subtype {
    return [MApiHelper marketInfoWithMarket:market subtype:subtype];
}

+ (NSDictionary *)fetchMarketLastestTradeDays {
    return [MApiHelper sharedHelper].marketTradeDates;
}

+ (void)clearCache {
    [MApiCache clearCache];
}

+ (NSString *)cacheSize __attribute__((deprecated)) {
    return [NSString stringWithFormat:@"%.2f M", (double)[self num_CacheSize] / (double)(1024 * 1024)];
}

+ (unsigned long long)num_CacheSize {
    unsigned long long cacheSize = [MApiCache cacheSize];
    return cacheSize;
}

+ (MApiNetworkStatus)networkStatus {
    MApi_Reachability *reachability = [MApi_Reachability reachabilityForInternetConnection];
    return (MApiNetworkStatus)reachability.currentReachabilityStatus;
}

+ (NSString *)setDebugMode:(NSDictionary *)configure {
    NSString *token = configure[@"token"];
    if ([token isEqualToString:DEBUG_MODE_TOKEN]) {
        __mapi_setDebugMode(configure[@"enabled"], (u_int16_t)[configure[@"mode"] integerValue]);
    }
    if ([token isEqualToString:DEBUG_IP_MODE_TOKEN]) {
        return [self __mapi_ip_string];
    }
    return nil;
}


#pragma mark - MApi_MQTT handle
+ (MApiMQTTSubscriber *)_MQTTSubscriber:(NSString *)market {
    return [self _MQTTSubscriber:market createAtomically:YES];
}

+ (MApiMQTTSubscriber *)_MQTTSubscriber:(NSString *)market createAtomically:(BOOL)createAtomically {
    MApiMQTTSubscriber *suber = g_MQTTSubscribers[market];
    if (!suber && createAtomically) {
        suber = [[MApiMQTTSubscriber alloc] init];
        suber.market = market;
        g_MQTTSubscribers[market] = suber;
    }
    return suber;
}

+ (void)unsubscribeAllQuoteCode {
    [g_MQTTSubscribers enumerateKeysAndObjectsUsingBlock:^(NSString *key, MApiMQTTSubscriber *suber, BOOL * _Nonnull stop) {
        [suber unsubscribeAllQuoteCode];
    }];
}

+ (void)unsubscribeQuoteCode:(NSString *)code {
    if (g_SourceLevel == MApiSourceLevel2) {
        NSArray *stockIds = [code componentsSeparatedByString:@","];
        NSMutableArray *SZs = [@[] mutableCopy];
        NSMutableArray *others = [@[] mutableCopy];
        
        [stockIds enumerateObjectsUsingBlock:^(NSString *stockId, NSUInteger idx, BOOL * _Nonnull stop) {
            NSString *lowercaseStockId = [stockId lowercaseString];
            if ([lowercaseStockId hasSuffix:@".sz"]) {
                [SZs addObject:lowercaseStockId];
            } else {
                [others addObject:lowercaseStockId];
            }
        }];
        if (SZs.count > 0) {
            [[self _MQTTSubscriber:@"szl2"] unsubscribeQuoteCode:[SZs componentsJoinedByString:@","]];
        }
        if (others.count > 0) {
            [[self _MQTTSubscriber:@"shl2"] unsubscribeQuoteCode:[others componentsJoinedByString:@","]];
        }
    } else {
        [[self _MQTTSubscriber:@"sh"] unsubscribeQuoteCode:code];
    }
}


+ (void)subscribeQuoteCode:(NSString *)code didReceiveUpdate:(MApiTcpReceiveBlock)didReceiveUpdate {

    if (g_SourceLevel == MApiSourceLevel2) {
        NSArray *stockIds = [code componentsSeparatedByString:@","];
        NSMutableArray *SZs = [@[] mutableCopy];
        NSMutableArray *others = [@[] mutableCopy];
        
        [stockIds enumerateObjectsUsingBlock:^(NSString *stockId, NSUInteger idx, BOOL * _Nonnull stop) {
            NSString *lowercaseStockId = [stockId lowercaseString];
            if ([lowercaseStockId hasSuffix:@".sz"]) {
                [SZs addObject:lowercaseStockId];
            } else {
                [others addObject:lowercaseStockId];
            }
        }];
        
        if (SZs.count > 0) {
            [[self _MQTTSubscriber:@"szl2"] subscribeQuoteCode:[SZs componentsJoinedByString:@","]
                                               didReceiveUpdate:didReceiveUpdate];
        }
        if (others.count > 0) {
            [[self _MQTTSubscriber:@"shl2"] subscribeQuoteCode:[others componentsJoinedByString:@","]
                                            didReceiveUpdate:didReceiveUpdate];
        }
    } else {
        [[self _MQTTSubscriber:@"sh"] subscribeQuoteCode:code didReceiveUpdate:didReceiveUpdate];
    }

}

+ (MApiSourceLevel)sourceLevelWithMarket:(NSString *)market {
    NSString *pureMarket = MApiGetPureMarket(market);
    return [g_CurrentSourceLevel[pureMarket] integerValue];
}

+ (void)checkServerList {
    [self _getServer:NULL];
}

#pragma mark - private request management

+ (dispatch_queue_t)_processingQueue:(MRequest *)request {
    if ([request isKindOfClass:[MChartRequest class]]) {
        return mapi_chart_request_processing_queue();
    } else if ([request isKindOfClass:[MPingRequest class]]) {
        return dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    } else if ([request isKindOfClass:[MStockTableRequest class]]) {
        return dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
    }
    return mapi_request_processing_queue();
}

+ (NSMutableArray<MRequest *> *)requests {
    static NSMutableArray *requests = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        requests = [NSMutableArray array];
    });
    return requests;
}

+ (BOOL)_addRequest:(MRequest *)request {
    MAPI_SP_LOCK(g_RequestsLock);
    BOOL sending = [self.requests indexOfObject:request] != NSNotFound;
    if (!sending) {
        [self.requests addObject:request];
        MAPI_LOG(@"加入请求:%@  所有请求数:%@\n%@", NSStringFromClass([request class]), @(self.requests.count), request);
    }
    MAPI_SP_UNLOCK(g_RequestsLock);
    return sending;
}

+ (void)_removeRequest:(MRequest *)request {
    MAPI_SP_LOCK(g_RequestsLock);
    NSInteger foundIdx = [self.requests indexOfObject:request];;
    BOOL sending = foundIdx != NSNotFound;
    if (sending) {
        [self.requests removeObjectAtIndex:foundIdx];
        MAPI_LOG(@"移除请求:%@  所有请求数:%@\n%@", NSStringFromClass([request class]), @(self.requests.count), request);
    }
    MAPI_SP_UNLOCK(g_RequestsLock);
}

+ (void)_cancelAllRequestsForResend:(BOOL)resend {
    MAPI_SP_LOCK(g_RequestsLock);
    for (MRequest *request in self.requests) {
        if (resend) {
            [request _cancelOperation];
        } else {
            [request _cancel];
        }
    }
    if (!resend) {
        [self.requests removeAllObjects];
    }
    MAPI_SP_UNLOCK(g_RequestsLock);
}

#pragma mark - private

+ (void)_resendRequest:(MRequest *)request {
    [self _removeRequest:request];

    if (request.isCancelled) return;
    [self _sendRequest:request completionHandler:request.handler timeoutHandler:request.timeoutHandler
               options:@{ kSendOptionResendKey : @YES }];
}

+ (void)_sendEchoWithAPPKey:(NSString *)appkey completionHandler:(MApiInteralCompletionHandler)interHandler {
    
    MEchoRequest *echoRequest = [[MEchoRequest alloc] init];
    [self sendRequest:echoRequest completionHandler:^(MResponse *resp) {
        MAPI_ASSERT_MAIN_THREAD();
        if (resp.status == MResponseStatusSuccess && resp) {
            MEchoResponse *response = (MEchoResponse *)resp;
            [MApiHelper sharedHelper].marketTradeDates = response.marketTradeDates;
            NSString *timestamp = response.marketTradeDates[@"timestamp"];
            
            if (!timestamp) {
                interHandler([NSError errorWithDomain:@"MApi.ErrorDomain"
                                            code:-60001
                                        userInfo:@{NSLocalizedDescriptionKey:@"echo timestamp error"}]);
                return;
            }
            
            MAuthRequest *request = [[MAuthRequest alloc] init];
            request.sdkVer = MAPI_SDK_VER;
            request.appkey = appkey;
            request.corpID = [MApiHelper sharedHelper].corpID;
            request.timestamp = timestamp;
            MAPI_LOG(@"MAPI_AUTH_SERVERS:%@", MAPI_AUTH_SERVERS);
            MAPI_LOG(@"%@", request);
            [self sendRequest:request completionHandler:^(MResponse *resp) {
                MAPI_ASSERT_MAIN_THREAD();
                MAuthResponse *response = (MAuthResponse *)resp;
                if (resp.status == MResponseStatusSuccess) {
                    MAPI_CURL_LOG(@"\n✅%@\n", [response description]);
                    
                    /// 储存 token, quote ips,
                    /// * IMPORTANT: 两个都会存到plist, 但....
                    ///     1. token会存一份到内存
                    ///     2. quoteServers如果没有被register的options赋值，则会存一份到内存
                    [[MApiHelper sharedHelper] archiveToken:response.token];
                    MAPI_ACCESS_TOKEN = response.token;
                    [[MApiHelper sharedHelper] archiveQuoteServers:response.quoteServers];
                    if ([MApiHelper sharedHelper].registerOptions[@"MAPI_DEBUG_QUOTE_SERVERS"] == nil) {
                        MAPI_QUOTE_SERVERS = response.quoteServers;
                    }
                    
                    /// 更新GetServerPoolingDate, 因认证已经有回ServerList了
                    [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:kGetServerPoolingDateUserDefaultKey];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    
                    [self _handleGenerateIpList:MAPI_QUOTE_SERVERS completed:^{
                        //取得市场资讯
                        [self _fetchingMarkInfoWithHandler:interHandler];
                    }];
                } else {
                    if (++g_AuthIPIndex < MAPI_AUTH_SERVERS.count) {
                        [self _sendEchoWithAPPKey:appkey completionHandler:interHandler];
                    }
                    else if (interHandler) {
                        interHandler([NSError errorWithDomain:@"MApi.ErrorDomain"
                                                    code:response.status
                                                userInfo:@{NSLocalizedDescriptionKey:response.message}]);
                    }
                }
            }];
        }
        else {
            if (++g_AuthIPIndex < MAPI_AUTH_SERVERS.count) {
                [self _sendEchoWithAPPKey:appkey completionHandler:interHandler];
            }
            else if (interHandler) {
                interHandler([NSError errorWithDomain:@"MApi.ErrorDomain"
                                            code:resp.status
                                        userInfo:@{NSLocalizedDescriptionKey:resp.message}]);
            }
        }
    }];
}

//拼接Url并根据请求类名决定服务器
+ (NSString *)_URLStringByRequest:(MRequest *)request {
    
    NSString *domainIP = nil;
    //选择服务器
    if ([request isKindOfClass:[MPingRequest class]]) {
        domainIP = ((MPingRequest *)request).URLString;
    }
    else if ([request isKindOfClass:[MAuthRequest class]] || [request isKindOfClass:[MEchoRequest class]]) {
        domainIP = MAPI_AUTH_SERVERS[g_AuthIPIndex];
    }
    else if ([request isKindOfClass:[MCrashReportRequest class]]) {
        domainIP = CRASH_REPORT_UPLOAD_URL;
    }
    else if (request.sendingURLString)
    {
        domainIP = request.sendingURLString;
    }
    else {
        MAPI_SP_LOCK(g_RandomIpLock);
        NSURL *URL = MApiGetURLByMarket(request._market);
        domainIP = URL.absoluteString;
        MAPI_SP_UNLOCK(g_RandomIpLock);
    }
    request.sendingURLString = domainIP;
    
    if (domainIP && ![domainIP hasPrefix:@"tcp"]) {
        NSMutableString *URLString = [NSMutableString string];
        if (![domainIP hasPrefix:@"http"]) {
            [URLString appendString:@"http://"];
        }
        NSString *path = [[request APIVersion] stringByAppendingPathComponent:[request path]];
        [URLString appendFormat:@"%@/%@", domainIP, path];
        return [URLString copy];
    }
    return nil;
}

+ (void)_fetchingMarkInfoWithHandler:(MApiInteralCompletionHandler)interHandler {
    
    /// 取硬盘的MarketInfo, 存在的话就不重新取了
    if (MAPI_MARKET_INFOS) {
        interHandler(nil);
    }
    else {
        MMarketInfoRequest *request = [[MMarketInfoRequest alloc] init];
        [self sendRequest:request completionHandler:^(MResponse *resp) {
            MAPI_ASSERT_MAIN_THREAD();
            if (resp.status == MResponseStatusSuccess) {
                MMarketInfoResponse *response = (MMarketInfoResponse *)resp;
                [[MApiHelper sharedHelper] archiveMarketInfos:response.marketInfos];
                MAPI_MARKET_INFOS = response.marketInfos;
                interHandler(nil);
            }
            else {
                NSError *error = [NSError errorWithDomain:@"MApi.ErrorDomain"
                                                     code:resp.status
                                                 userInfo:@{NSLocalizedDescriptionKey: @"获取市场资讯失败"}];
                interHandler(error);
            }
        }];
    }
}

+ (BOOL)_isContinueAfterFetchingCacheResponseWithRequest:(MRequest *)request {
    BOOL isContinue = YES;
    id<MApiCaching> cachedObject = [request cachedObject];
    if (cachedObject) {
        if ([cachedObject isKindOfClass:[MResponse class]]) {
            MResponse *cachedResponse = (MResponse *)cachedObject;
            BOOL returnByCache = YES;
            
            /// 新闻列表相关处理
            if ([self isStockNewsListRequest:request]) {
                if ([self isStockNewsListResponse:cachedResponse]) {
                    returnByCache = [self processItemsOfCachedResponse:cachedResponse
                                                           withRequest:request];
                }
                else {
                    returnByCache = NO;
                    [MApiCache removeObjectFromPath:[(id<MApiCaching>)request cachePath]];
                }
            }
            
            if (returnByCache) {
                cachedResponse.isCacheResponse = YES;
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (request.handler && !request.isCancelled) {
                        request.handler(cachedResponse);
                    }
                });
                isContinue = [request isContinueAfterGetCache]; /// If return by cached object, do not continue to request
            }
            
        } else {
            [MApiCache removeObjectFromPath:[(id<MApiCaching>)request cachePath]];
        }
    }
    return isContinue;
}

+ (void)_handleCompletionWithHTTPResponse:(NSHTTPURLResponse *)HTTPResponse responseData:(NSData *)responseData request:(MRequest *)request {
    
    if (request.handler == nil) return;
    
    NSString *responseClassName = MApiResponseClassMap(NSStringFromClass([request class]));
    NSAssert(responseClassName, @"Response class(%@) not found.", responseClassName);
    
    if (!responseClassName) return;
    
    NSString *timestamp = HTTPResponse.allHeaderFields[@"Timestamp"];
    NSString *pages = HTTPResponse.allHeaderFields[@"Pages"];

    Class class = NSClassFromString(responseClassName);
    if (class) {
        dispatch_async([self _processingQueue:request], ^{
            
            if (responseData) {
                MResponse *response = [[class alloc] initWithData:responseData
                                                          request:request
                                                        timestamp:timestamp
                                                          headers:HTTPResponse.allHeaderFields];
                response.numberOfPages = [pages intValue];
                
                /// Request Cancelled
                if (request.isCancelled) {
                    return;
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self _removeRequest:request];
                    
                    if (response.status == MResponseStatusSuccess) {
                        [self _handleSuccessResponse:response forRequest:request];
                        [self _cleanCacheWhenEmptyJSONData:responseData request:request];
                    } else if (request.handler && !request.isCancelled) {
                        request.handler(response);
                    }
                    
                });
            }
            else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self _removeRequest:request];

                    [self _responseErrorForRequest:request status:MResponseStatusDataNil];
                });
            }
        });
    }
}

+ (void)_handleErrorWithHTTPResponse:(NSHTTPURLResponse *)HTTPResponse connectionError:(NSError *)connectionError request:(MRequest *)request {
    [self _handleErrorWithHTTPResponse:HTTPResponse connectionError:connectionError request:request description:@""];
}

+ (void)_handleErrorWithHTTPResponse:(NSHTTPURLResponse *)HTTPResponse connectionError:(NSError *)connectionError request:(MRequest *)request description:(NSString *)description {
    
    /// auth error record and upload
    if ([request isKindOfClass:[MAuthRequest class]]) {
        [self _recordAuthRequestError:(MAuthRequest *)request
                      connectionError:connectionError
                      curlDescription:description];
    }
    
    /// Ping ip 的错误都不处理
    if ([request isKindOfClass:[MPingRequest class]]) {
        if (connectionError) {
            [self _responseErrorForRequest:request status:connectionError.code];
        } else {
            [self _responseErrorForRequest:request status:HTTPResponse.statusCode];
        }
    }
    //401.
    else if (HTTPResponse.statusCode == 401) {
        /// Appkey 或 券商id 或 bundleId错误
        if ([request isKindOfClass:[MAuthRequest class]]) {
            MAPI_CURL_LOG(@"\n🚫%@\n\n", description);
            [self _responseErrorForRequest:request status:MResponseStatusCertificationAuditError];
        }
        /// token过期，特别处理
        else {
            MAPI_CURL_LOG(@"\n🕤%@\n\n", description);
            dispatch_async(dispatch_get_main_queue(), ^{
                [self _handleTokenExpiredEvent];
            });
        }
    }
    //404.无资料，特别处理
    //check version不管何種情況都當正常
    else if (HTTPResponse.statusCode == 404 ||
             [request isKindOfClass:[MCheckVersionRequest class]]) {
        MAPI_CURL_LOG(@"\n🔴%@\n\n", description);
        [self _handleCompletionWithHTTPResponse:HTTPResponse responseData:[NSData data] request:request];
    }
    /// 后续的错误 auth, echo 直接报错register那边会换ip
    else if ([request isKindOfClass:[MAuthRequest class]] || [request isKindOfClass:[MEchoRequest class]]) {
        if (connectionError) {
            [self _responseErrorForRequest:request status:connectionError.code];
        } else {
            [self _responseErrorForRequest:request status:HTTPResponse.statusCode];
        }
    }
    //307.连线限制, 重新random ip
    else if (HTTPResponse.statusCode == 307) {
        [self _changeServerItem:request statusCode:HTTPResponse.statusCode resendEnabled:YES];
    }
    //其他
    else {
        MAPI_CURL_LOG(@"\n❎%@\n\n", description);
        
        /// Request Cancelled
        if (request.isCancelled) {
            return;
        }
        
        if (connectionError) {
            // 网络层(NSURLConnection)的错误
            // ref: https://developer.apple.com/library/ios/documentation/Cocoa/Reference/Foundation/Miscellaneous/Foundation_Constants/index.html#//apple_ref/doc/uid/TP40003793-CH3g-SW40
            switch (connectionError.code) {
                case NSURLErrorCannotConnectToHost: // port 错误
                case NSURLErrorCannotFindHost:
                {
                    // 手机本身没网路
                    if ([self networkStatus] == MApiNotReachable) {
                        [self _responseErrorForRequest:request status:MResponseStatusNotReachabled];
                    }
                    // Maybe server down
                    else {
                        [self _changeServerItem:request statusCode:connectionError.code resendEnabled:YES];
                    }
                    break;
                }
                case NSURLErrorTimedOut:
                case NSURLErrorNetworkConnectionLost:
                {
                    // 手机本身没网路
                    if ([self networkStatus] == MApiNotReachable) {
                        BOOL isReload = NO;
                        if (request.timeoutHandler) {
                            request.timeoutHandler(request, &isReload);
                        }
                        if (isReload) {
                            [self _resendRequest:request];
                        } else {
                            [self _responseErrorForRequest:request status:MResponseStatusTimeout];
                        }
                    }
                    // Maybe server down
                    else {
                        [self _changeServerItem:request statusCode:connectionError.code resendEnabled:YES];
                    }
                    
                    break;
                }
                case NSURLErrorNotConnectedToInternet:
                {
                    [self _responseErrorForRequest:request status:NSURLErrorNotConnectedToInternet];
                    break;
                }
                case NSURLErrorCannotDecodeRawData: // 参数带空或带错 有些request会回
                {
                    [self _responseErrorForRequest:request status:MResponseStatusParameterError];
                    break;
                }
                case NSURLErrorCancelled:
                {
                    break; // Cancelled do nothing
                }
                default:
                {
                    // HTTP protocol error
                    if (connectionError.code >= 0) {
                        [self _responseErrorForRequest:request status:connectionError.code];
                    }
                    /// refer Foundation/NSURLError.h
                    else {
                        [self _responseErrorForRequest:request status:connectionError.code - 100000];
                    }
                    break;
                }
            }
        }
        else {
            //HTTP错误
            [self _responseErrorForRequest:request status:HTTPResponse.statusCode];
        }
    } // end the else
}


+ (void)_searchingStockFromDatabaseWithRequest:(MSearchRequest *)request {
    [[MCoreDataHelper sharedHelper] fetchStockRecordsWithRequest:request
                                               completionHandler:^(NSArray *resultItems)
     {
         MSearchResponse *response = [[MSearchResponse alloc] init];
         response.status = MResponseStatusSuccess;
         response.resultItems = resultItems;
         dispatch_async(dispatch_get_main_queue(), ^{
             if (request.handler && !request.isCancelled) {
                 request.handler(response);
             }
             [self _removeRequest:request];
         });
     }];
}

//处理成功的response
+ (void)_handleSuccessResponse:(MResponse *)response forRequest:(MRequest *)request {
    MAPI_ASSERT_MAIN_THREAD();
    
    /// 检查是否Level1 -> Level2
    MApiCheckSourceLevelResumed(request._market, true);
    
    // 期权行情快照
    if ([response isKindOfClass:[MSnapQuoteResponse class]] &&
        [(MSnapQuoteResponse *)response stockItem].isOption) {
        MSnapQuoteResponse *snapQuoteResponse = (MSnapQuoteResponse *)response;
        MOptionItem *optionItem = (MOptionItem *)[(MSnapQuoteResponse *)response stockItem];
        
        MQuoteRequest *newRequest = [[MQuoteRequest alloc] init];
        newRequest.code = optionItem.stockID;
        
        if (request.isCancelled) return;
        
        [MApi sendRequest:newRequest completionHandler:^(MResponse *resp) {
            if (resp.status == MResponseStatusSuccess) {
                MQuoteResponse *newResponse = (MQuoteResponse *)resp;
                MStockItem *newStockItem = newResponse.stockItems[0];
                optionItem.stockLast = newStockItem.lastPrice;
                snapQuoteResponse.stockItem = optionItem;
                MAPI_ASSERT_MAIN_THREAD();
                if (request.handler && !request.isCancelled) {
                    request.handler(snapQuoteResponse);
                }
            }
            else {
                [self _responseErrorForRequest:request status:resp.status];
            }
        } timeoutHandler:request.timeoutHandler];
    }
    /// K线复权请求
    else if ([request isKindOfClass:[MOHLCRequest class]] &&
             ((MOHLCRequest *)request).priceAdjustedMode != MOHLCPriceAdjustedModeNone) {
        MOHLCRequest *OHLCRequest = (MOHLCRequest *)request;
        MOHLCResponse *OHLCResponse = (MOHLCResponse *)response;
        MStockXRRequest *XRReq = [[MStockXRRequest alloc] init];
        XRReq.code = OHLCRequest.code;
        
        if (request.isCancelled) return;
        
        [MApi sendRequest:XRReq completionHandler:^(MResponse *resp) {
            MAPI_ASSERT_MAIN_THREAD();
            MStockXRResponse *XRResp = (MStockXRResponse *)resp;
            if (resp.status == MResponseStatusSuccess) {
                OHLCResponse.fq = XRResp.fq;
                if (request.handler && !request.isCancelled) {
                    dispatch_async([self _processingQueue:request], ^{
                        [OHLCResponse _XR_calculate];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self _callbackAndArchiveCacheDataWithRequest:OHLCRequest response:OHLCResponse];
                        });
                    });
                }
            }
            else {
                [self _responseErrorForRequest:request status:resp.status];
            }
        }];
    } else {
        [self _callbackAndArchiveCacheDataWithRequest:request response:response];
    }
}

+ (void)_callbackAndArchiveCacheDataWithRequest:(MRequest *)request response:(MResponse *)response {
    NSString *cachePath = [(id<MApiCaching>)request cachePath];
    if (cachePath) {
        //Stock news list modify.
        if ([self isStockNewsListRequest:request]) {
            if (request.isCancelled) return;
            [self processNewsListRequestSuccessOfResponse:response andRequest:request];
        }
        //Other class
        else {
            [MApiCache cacheObject:response toPath:cachePath];
        }
    }
    MAPI_ASSERT_MAIN_THREAD();
    if (request.handler && !request.isCancelled) {
        request.handler(response);
    }
}

+ (void)_cleanCacheWhenEmptyJSONData:(NSData *)data request:(MRequest <MApiCaching>*)request {
    if (data.length <= 2 &&
        [request cachedObject] &&
        ![request isKindOfClass:[MOHLCRequest class]] &&
        ![request isKindOfClass:[MChartRequest class]]) {
        [MApiCache removeObjectFromPath:[request cachePath]];
    }
}

+ (void)_handleTokenExpiredEvent {
    MAPI_ASSERT_MAIN_THREAD();
    /**
     * 取消所有正在发送的电文, 重新认证审计, 成功认证后再将伫列里所有电文重新发送
     */
    [self _cancelAllRequestsForResend:YES];
    
    //// 清除认证资料
    [[MApiHelper sharedHelper] clearAuthInfo];
    
    [self registerAPP:[[MApiHelper sharedHelper] appKey] completionHandler:^(NSError *error) {
        NSArray *requests = [self.requests copy];
        for (MRequest *request in requests) {
            if (error) {
                [self _responseErrorForRequest:request status:MResponseStatusSessionExpired];
            }
            else {
                [self _resendRequest:request];
            }
        }
    }];
}

+ (void)_setCorpID:(NSString *)corpID {
#if DEBUG
    if ([MApiHelper sharedHelper].corpID) {
        return;
    }
#endif
    [MApiHelper sharedHelper].corpID = corpID;
}

+ (void)_responseErrorForRequest:(MRequest *)request status:(MResponseStatus)status {
    [self _responseErrorForRequest:request status:status truelyError:nil];
}

+ (void)_responseErrorForRequest:(MRequest *)request status:(MResponseStatus)status truelyError:(NSError *)truelyError {
    if (request.handler) {
        NSString *responseClassName = MApiResponseClassMap(NSStringFromClass([request class]));
        NSAssert(responseClassName, @"Response class not found.");
        if (!responseClassName) return;
        
        Class class = NSClassFromString(responseClassName);
        MResponse *response;
        if (class) {
            response = [[class alloc] init];
        } else {
            response = [[MResponse alloc] init];
        }
        response.status = status;
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!request.isCancelled) {
                request.handler(response);
            }
        });
        
    }
    [self _removeRequest:request];
}

+ (void)_recordAuthRequestError:(MAuthRequest *)request connectionError:(NSError *)connectionError curlDescription:(NSString *)description {
    NSMutableString *log = [NSMutableString string];
    [log appendString:description?:@""];
    [log appendString:@"\n=================================\n"];
    [log appendFormat:@"%@", [request postParam]];
    [log appendString:@"\n=================================\n"];
    [log appendString:[connectionError description]];
    [_MApiLogger writeContent:log inDirectory:kNetworkReportDirectory];
}

// @return 是否完成测速及解析ip list
+ (void)_handleGenerateIpList:(NSDictionary *)servers completed:(void(^)(void))completed {
    MAPI_ASSERT_MAIN_THREAD();
    /// 重置市场别默认SourceLevel
    g_CurrentSourceLevel[@"sh"] = @(g_SourceLevel);
    g_CurrentSourceLevel[@"sz"] = @(g_SourceLevel);
    g_CurrentSourceLevel[@"hk"] = @(g_SourceLevel);
    
    [g_AcceptPingMarkets addObjectsFromArray:servers.allKeys];
    [self _randomIpList:servers completed:^{
        completed();
    }];
}

+ (void)_reconnectMQTTWithMarket:(NSString *)market {
    MApiMQTTSubscriber *suber = [self _MQTTSubscriber:market];
    [suber reconnectIfNeeded];
}

+ (void)_changeServerItem:(MRequest *)request statusCode:(NSInteger)statusCode resendEnabled:(BOOL)resendEnabled {
    MApiChangeServerState state = MApiChangeServerItem(request._market, request.sendingURLString);
    
    if (state == MApiChangeServerStateLastestIP) {
        [self _responseErrorForRequest:request status:statusCode];
    } else {
        if (state == MApiChangeServerStateChangeLevel) {
            [self _reconnectMQTTWithMarket:request._market];
            MAPI_SP_LOCK(g_RandomIpLock);
            /// MARK: [ACCEPT PING MARKETS]
            /// 加入set里面，轮循GetServer时random ip要用
            [g_AcceptPingMarkets addObject:request._market];
            [g_AcceptPingMarkets addObject:__MApiGetTcpMarket(request._market)];
            
            ___fixes_20161117_accept_ping_market(request._market);
            
            MAPI_SP_UNLOCK(g_RandomIpLock);
        }
        if (resendEnabled) {
            [self _resendRequest:request];
        }
    }

}


#pragma mark schedule get server

+ (void)_stopDelayGetServer {
    [g_GetServerTimer invalidate];
}

+ (void)_startDelayGetServer {
    [g_GetServerTimer invalidate];
    g_GetServerTimer = [NSTimer timerWithTimeInterval:g_GetServerPoolingTime + 1.0/*tolerance*/
                                               target:self
                                             selector:@selector(_timeToGetServer:)
                                             userInfo:nil
                                              repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:g_GetServerTimer forMode:NSRunLoopCommonModes];
}

+ (void)_timeToGetServer:(NSTimer *)timer {
    [self _getServer:NULL];
}

+ (void)_getServer:(void(^)(void))completion {
    /*
     调用处：
       1. Register完成时
       2. Pooling Timer执行时
       3. _mapi_appDidBecomeActive时
       4. Public function: checkServerList调用时
     几种执行结果：
       1. Register Options有设ignorePoolingGetServer则直接返回
       2. 检查上次GetServer的日期, 大于g_GetServerPoolingTime, 执行GetServerRequest
         a. GetServerResponse成功, 检查本地GerServerVersion再判断是否要RandomIP, 不需要则直接返回, 否则完成后返回
         b. GetServerResponse失败, 直接返回
     */

    if (MApiState.ignorePoolingGetServer) {
        if (completion) {
            completion();
        }
        return;
    }

    static NSString * const kMapiMGSLVKey = @"MAPI_GET_SERVER_LIST_VERSION";
    
    NSDate *lastPoolingDate = [[NSUserDefaults standardUserDefaults] objectForKey:kGetServerPoolingDateUserDefaultKey];
    
    MAPI_LOG(@"[GetServer] start if needed, lastPoolingTimeSinceNow:%f", fabs([lastPoolingDate timeIntervalSinceNow]));
    
    if (lastPoolingDate == nil || fabs([lastPoolingDate timeIntervalSinceNow]) >= g_GetServerPoolingTime) {
        MAPI_LOG(@"[GetServer] started, lastPoolingTimeSinceNow:%f", fabs([lastPoolingDate timeIntervalSinceNow]));
        
        NSString *localListVersion = [[NSUserDefaults standardUserDefaults] stringForKey:kMapiMGSLVKey];
        
        MGetServerRequest *request = [[MGetServerRequest alloc] init];
        [self _sendRequest:request completionHandler:^(MResponse *resp) {
            MGetServerResponse *response = (MGetServerResponse *)resp;
            if (response.status == MResponseStatusSuccess) {
                NSString *serverVersion = response.fileVersion;
                MAPI_LOG(@"[GetServer] handle get server.\nserver ver:%@\nlocal ver:%@",
                         serverVersion,
                         localListVersion);
                
                if (response.servers) {
                    /// 写档
                    [[MApiHelper sharedHelper] archiveQuoteServers:response.servers];
                    /// 如果注册时没有给值，这里会赋值
                    if ([MApiHelper sharedHelper].registerOptions[@"MAPI_DEBUG_QUOTE_SERVERS"] == nil) {
                        MAPI_QUOTE_SERVERS = response.servers;
                    }
                }
                
                if (serverVersion && ![localListVersion isEqualToString:serverVersion]) {
                    if (localListVersion) {
                        /// 版号不同, 加入所有市场别, 全量更新ip list
                        @try {
                            [g_AcceptPingMarkets addObjectsFromArray:response.servers.allKeys];
                        } @catch (NSException *exception) {
                            MAPI_LOG(@"[GetServer] %@\n\n%@\n\n", response, exception.reason);
                        } @finally {
                            
                        }
                    } else {
                        /// 如果跑这里就表示第一次使用sdk, 第一次使用就记住serverVersion就好
                        /// 从register到delayGetServer的时间内改变ip list的机率不高
                        /// 这样做可以免去第一次使用一定会在这里randomIp的动作
                        /// 如果这段时间后台真的变更ip list的话, 就等下一次delayGetServer
                    }
                    [[NSUserDefaults standardUserDefaults] setObject:serverVersion forKey:kMapiMGSLVKey];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                }
                
                NSArray *copyMarkets = [g_AcceptPingMarkets.allObjects copy];
                BOOL didStart = [self _randomIpList:MAPI_QUOTE_SERVERS invokeByGetServer:YES completed:^{
                    /// 检查市场别是否L1->L2, 以及tcp是否重新连线(重连为了抓新的IP)
                    for (NSString *market in @[@"shl2", @"szl2", @"hkl2"]) {
                        MApiCheckSourceLevelResumed(market, true);
                    }
                    [copyMarkets enumerateObjectsUsingBlock:^(NSString *market, NSUInteger idx, BOOL * _Nonnull stop) {
                        [[self _MQTTSubscriber:market createAtomically:NO] reconnectIfNeeded];
                    }];
                    if (completion) {
                        completion();
                    }
                }];
                
                if (!didStart && completion) {
                    completion();
                }
            } else if (completion) {
                completion();
            }
            [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:kGetServerPoolingDateUserDefaultKey];
            [[NSUserDefaults standardUserDefaults] synchronize];
        } timeoutHandler:NULL options:nil];
    } else if (completion) {
        completion();
    }
}


#pragma mark - Error handle

+ (NSString *)_errorMessageWithCode:(NSInteger)code {
    switch (code) {
        case kCodeNoCallbackHandler: return @" Callback handler不可为NULL ";
    }
    return nil;
}

+ (void)_raiseExceptionWithCode:(NSInteger)code {
    NSString *errorMessage = [self _errorMessageWithCode:code];
    [[NSException exceptionWithName:@"MApiExceptionDomain" reason:errorMessage userInfo:nil] raise];
}

#pragma mark - temp 处理level2市场别

+ (BOOL)_randomIpList:(NSDictionary *)inputServers completed:(void(^)(void))completed {
    return [self _randomIpList:inputServers invokeByGetServer:NO completed:completed];
}

+ (BOOL)_randomIpList:(NSDictionary *)inputServers invokeByGetServer:(BOOL)invokeByGetServer completed:(void(^)(void))completed {
    
    if (!inputServers) {
        MAPI_LOG(@"[RandomIp] do not random ip. because servers:%@\n", inputServers);
        return NO;
    }
    else if (MApiState.isRandomIp == true) {
        MAPI_LOG(@"[RandomIp] do not random ip. because isRandomIp:%@\n", MApiState.isRandomIp ? @"true" : @"false");
        return NO;
    }
    else if (g_AcceptPingMarkets.count == 0) {
        MAPI_LOG(@"[RandomIp] do not random ip. because g_AcceptPingMarkets:%@\n", g_AcceptPingMarkets);
        return NO;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        MAPI_SP_LOCK(g_RandomIpLock);
        
        MAPI_LOG(@"[RandomIp] 🙏🙏🙏🙏 start random ip, accept markets\n%@\n\n", g_AcceptPingMarkets);
        MApiState.isRandomIp = true;
        
        NSDictionary *servers = inputServers;

        /////////// fix20160908: 相容旧的用户.
        /// 因为旧的市场仅有sh, hk, nf, 而sz市场导向sh的ip, 但level2上线后则有些Request是根据各个市场别来发送的.
        if ( ![servers.allKeys containsObject:@"sz"] && servers[@"sh"] ) {
            NSMutableDictionary *mutableServers = [servers mutableCopy];
            mutableServers[@"sz"] = [servers[@"sh"] copy];
            servers = [mutableServers copy];
        } /// end fix20160908

        __block NSMutableDictionary <NSString *, NSMutableArray *> *sendingPingRequests = [@{} mutableCopy];
        
        void (^__Finally)(void) = ^{
            //        @synchronized (sendingPingRequests) // if serverIps use concurrent enumerate
            {
                if (sendingPingRequests && [sendingPingRequests allValues].count == 0) {
                    sendingPingRequests = nil;
                    [[g_AcceptPingMarkets copy] enumerateObjectsUsingBlock:^(NSString * _Nonnull market, NSUInteger idx, BOOL * _Nonnull stop) {
                        if ([g_CurrentServerItems[market] count] > 0) {
                            [g_AcceptPingMarkets removeObject:market];
                        }
                    }];
                    MApiState.isRandomIp = false;
                    MAPI_SP_UNLOCK(g_RandomIpLock);
                    if (completed) {
                        completed();
                    }
                }
            }
        };
        
        [servers enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull market, NSArray * _Nonnull serverIps, BOOL * _Nonnull stop) {
            if ([market isEqualToString:@"h5"] ||
                ![g_AcceptPingMarkets containsObject:market] ||
                [market isEqualToString:@"auth"] ||
                serverIps.count == 0) {
                [g_AcceptPingMarkets removeObject:market];
                MAPI_LOG(@"[RandomIp] ignore market: %@", market);
                return ;
            }
            
            /// 打乱ServerList处理
            NSMutableArray *randomServerIps = [serverIps mutableCopy];
            NSInteger count = [randomServerIps count];
            for (NSInteger i = 0; i < count - 1; i++) {
                NSInteger swap = arc4random() % (count - i) + i;
                [randomServerIps exchangeObjectAtIndex:swap withObjectAtIndex:i];
            }
            
            
            NSString *marketForTcp = __MApiGetTcpMarket(market);
            
            sendingPingRequests[market] = [@[] mutableCopy];
            g_CurrentServerItems[market] = [@[] mutableCopy];
            g_CurrentServerItems[marketForTcp] = [@[] mutableCopy];
            
            __block NSInteger pingCounter = randomServerIps.count;
            __block MServerItem *firstServerItem = nil;
            
            void (^__FianlPingRequestCheck)(MPingRequest *) = ^(MPingRequest *__req){
                pingCounter--;
                [sendingPingRequests[market] removeObject:__req];
                if (pingCounter == 0) {
                    sendingPingRequests[market] = nil;
                    
                    NSRange r = [market rangeOfString:@"l2"];
                    BOOL isLevel2 = r.location != NSNotFound;
                    BOOL atLeastOneIP = !invokeByGetServer || !isLevel2;
                    if ([g_CurrentServerItems[market] count] == 0 && atLeastOneIP && firstServerItem) {
                        [g_CurrentServerItems[market] addObject:firstServerItem];
                    }
                }
                __Finally();
            };
            
            [randomServerIps enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull dict, NSUInteger idx, BOOL * _Nonnull stop) {
                
                MServerItem *serverItem = [MServerItem serverItemWithIPAddress:dict[@"ip"]
                                                                        market:market
                                                                      priority:dict[@"priority"]];
                
                /// tcp处理
                if ([serverItem.IPAddress hasPrefix:@"tcp"]) {
                    [g_CurrentServerItems[marketForTcp] addObject:serverItem];
                    __FianlPingRequestCheck(nil);
                }
                /// 一般http, https处理
                else {
                    if (!firstServerItem) {
                        firstServerItem = serverItem;
                    }
                    
                    MPingRequest *req = [MPingRequest new];
                    req.timeoutInterval = 5.0;
                    req.URLString = serverItem.IPAddress;
                    req.startDate = [NSDate date];
                    
                    [sendingPingRequests[market] addObject:req];
                    
                    [self _sendRequest:req completionHandler:^(MResponse *resp) {
                        MPingResponse *response = (MPingResponse *)resp;
                        
                        if (response.status == MResponseStatusSuccess ||
                            response.status == MResponseStatusNotReachabled) {
                            
                            [g_CurrentServerItems[market] addObject:serverItem];
                            
                            MAPI_LOG(@"\n🔵 market:%@  IP:%@  权重:%@  响应时间:%fms\n", market, serverItem.IPAddress, serverItem.priority, response.responseTime*1000);
                        }
                        else {
                            MAPI_LOG(@"\n🔴 market:%@  IP:%@  权重:%@  响应时间:%fms\n", market, serverItem.IPAddress, serverItem.priority, response.responseTime*1000);
                        }

                        __FianlPingRequestCheck(req);
                    } timeoutHandler:^(MRequest *request, BOOL *reload) {
                        [g_CurrentServerItems[market] addObject:serverItem];
                        MAPI_LOG(@"\n🕤 market:%@  IP:%@  权重:%@  响应时间:timeout\n", market, serverItem.IPAddress, serverItem.priority);
                        __FianlPingRequestCheck(req);
                    } options:nil];
                    
                } /// end if, 一般http, https处理
                
            }]; // end ip array enumerate
            
        }]; // end market dict enumerate
        
        NSSet *copyAcceptPingMarkets = [g_AcceptPingMarkets copy];
        [copyAcceptPingMarkets enumerateObjectsUsingBlock:^(id  _Nonnull obj, BOOL * _Nonnull stop) {
            if (![servers.allKeys containsObject:obj]) {
                [g_AcceptPingMarkets removeObject:obj];
            }
        }];
        
    }); // end dispatch_async
    
    return YES;
}

#pragma mark - DEBUG

+ (NSString *)__mapi_ip_string {
    NSMutableString *returnString = [NSMutableString string];
    
    NSArray *displayMarkets = nil;
    if (g_SourceLevel == MApiSourceLevel1) {
        displayMarkets = @[@"auth", @"pb", @"sh", @"sh-tcp", @"sz", @"sz-tcp", @"hk", @"hk-tcp", @"nf"];
    } else {
        displayMarkets = @[@"auth", @"pb", @"sh", @"sh-tcp", @"shl2", @"shl2-tcp", @"sz", @"sz-tcp", @"szl2", @"szl2-tcp", @"hk", @"hk-tcp", @"hkl2", @"hkl2-tcp", @"nf"];
    }
    [displayMarkets enumerateObjectsUsingBlock:^(NSString *market, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *string = g_DebugServerNameMap[market];
        if (string) {
            [returnString appendFormat:@"%@ => %@\n", market, string];
        }
        else {
            [returnString appendFormat:@"%@ => %@\n", market, MApiGetURLByMarket(market)?:@""];
        }
    }];
    return returnString;
}

+ (NSString *)version {
    return [NSString stringWithFormat:@"MApi Version %@; %@_%@; ", MAPI_SDK_VER, [MApiHelper archiveType], MAPI_ARCH];
}

+ (MApiSourceLevel)sourceLevel {
    return g_SourceLevel;
}

#pragma mark - deprecated
+ (void)setUDID:(NSString *)UDID {}
+ (void)searchingStockFromServer {}
+ (void)searchingStockFromLocal {}

@end

