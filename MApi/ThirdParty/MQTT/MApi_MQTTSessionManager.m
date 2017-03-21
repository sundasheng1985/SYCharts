//
//  MApi_MQTTSessionManager.m
//  MApi_MQTTClient
//
//  Created by Christoph Krey on 09.07.14.
//  Copyright © 2013-2016 Christoph Krey. All rights reserved.
//

#import "MApi_MQTTSessionManager.h"
#import "MApi_MQTTCoreDataPersistence.h"

#import "MApi_MQTTLog.h"

@interface MApi_MQTTSessionManager()
@property (nonatomic, readwrite) MApi_MQTTSessionManagerState state;
@property (nonatomic, readwrite) NSError *lastErrorCode;

@property (strong, nonatomic) NSTimer *reconnectTimer;
@property (nonatomic) double reconnectTime;
@property (nonatomic) BOOL reconnectFlag;

@property (strong, nonatomic) MApi_MQTTSession *session;

@property (strong, nonatomic) NSString *host;
@property (nonatomic) UInt32 port;
@property (nonatomic) BOOL tls;
@property (nonatomic) NSInteger keepalive;
@property (nonatomic) BOOL clean;
@property (nonatomic) BOOL auth;
@property (nonatomic) BOOL will;
@property (strong, nonatomic) NSString *user;
@property (strong, nonatomic) NSString *pass;
@property (strong, nonatomic) NSString *willTopic;
@property (strong, nonatomic) NSData *willMsg;
@property (nonatomic) NSInteger willQos;
@property (nonatomic) BOOL willRetainFlag;
@property (strong, nonatomic) NSString *clientId;
@property (strong, nonatomic) MApi_MQTTSSLSecurityPolicy *securityPolicy;
@property (strong, nonatomic) NSArray *certificates;
@property (nonatomic) MApi_MQTTProtocolVersion protocolLevel;

@property (strong, nonatomic) NSTimer *disconnectTimer;
@property (strong, nonatomic) NSTimer *activityTimer;
#if TARGET_OS_IPHONE == 1
@property (nonatomic) UIBackgroundTaskIdentifier backgroundTask;
#endif

@property (nonatomic) BOOL persistent;
@property (nonatomic) NSUInteger maxWindowSize;
@property (nonatomic) NSUInteger maxSize;
@property (nonatomic) NSUInteger maxMessages;

@property (strong, nonatomic) NSDictionary<NSString *, NSNumber *> *internalSubscriptions;
@property (strong, nonatomic) NSDictionary<NSString *, NSNumber *> *effectiveSubscriptions;

@end

#define RECONNECT_TIMER 1.0
#define RECONNECT_TIMER_MAX 64.0
#define BACKGROUND_DISCONNECT_AFTER 8.0

@implementation MApi_MQTTSessionManager

- (void)dealloc {
#if TARGET_OS_IPHONE == 1

  NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
  [defaultCenter removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
  [defaultCenter removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
  [defaultCenter removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];

#endif
}

- (id)init {
    self = [super init];

    self.state = MApi_MQTTSessionManagerStateStarting;
    self.internalSubscriptions = [[NSMutableDictionary alloc] init];
    self.effectiveSubscriptions = [[NSMutableDictionary alloc] init];
    
    //Use the default value 
    self.persistent = MApi_MQTT_PERSISTENT;
    self.maxSize = MApi_MQTT_MAX_SIZE;
    self.maxMessages = MApi_MQTT_MAX_MESSAGES;
    self.maxWindowSize = MApi_MQTT_MAX_WINDOW_SIZE;

    self.persistent = MApi_MQTT_PERSISTENT;
    self.maxWindowSize = MApi_MQTT_MAX_WINDOW_SIZE;
    self.maxSize = MApi_MQTT_MAX_SIZE;
    self.maxMessages = MApi_MQTT_MAX_MESSAGES;

#if TARGET_OS_IPHONE == 1
    self.backgroundTask = UIBackgroundTaskInvalid;

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
#endif
    return self;
}

- (MApi_MQTTSessionManager *)initWithPersistence:(BOOL)persistent
                              maxWindowSize:(NSUInteger)maxWindowSize
                                maxMessages:(NSUInteger)maxMessages
                                    maxSize:(NSUInteger)maxSize {
    self = [self init];
    self.persistent = persistent;
    self.maxWindowSize = maxWindowSize;
    self.maxSize = maxSize;
    self.maxMessages = maxMessages;
    return self;
}

#if TARGET_OS_IPHONE == 1
- (void)appWillResignActive {
    [self disconnect];
}

- (void)appDidEnterBackground {
    __weak MApi_MQTTSessionManager *weakSelf = self;
    self.backgroundTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        __strong MApi_MQTTSessionManager *strongSelf = weakSelf;
        if (strongSelf.backgroundTask) {
            [[UIApplication sharedApplication] endBackgroundTask:strongSelf.backgroundTask];
            strongSelf.backgroundTask = UIBackgroundTaskInvalid;
        }
    }];
}

- (void)appDidBecomeActive {
    [self connectToLast];
}
#endif

- (void)connectTo:(NSString *)host
             port:(NSInteger)port
              tls:(BOOL)tls
        keepalive:(NSInteger)keepalive
            clean:(BOOL)clean
             auth:(BOOL)auth
             user:(NSString *)user
             pass:(NSString *)pass
        willTopic:(NSString *)willTopic
             will:(NSData *)will
          willQos:(MApi_MQTTQosLevel)willQos
   willRetainFlag:(BOOL)willRetainFlag
     withClientId:(NSString *)clientId {
  [self connectTo:host
               port:port
                tls:tls
          keepalive:keepalive
              clean:clean
               auth:auth
               user:user
               pass:pass
               will:YES
          willTopic:willTopic
            willMsg:will
            willQos:willQos
     willRetainFlag:willRetainFlag
       withClientId:clientId];
}

- (void)connectTo:(NSString *)host
             port:(NSInteger)port
              tls:(BOOL)tls
        keepalive:(NSInteger)keepalive
            clean:(BOOL)clean
             auth:(BOOL)auth
             user:(NSString *)user
             pass:(NSString *)pass
             will:(BOOL)will
        willTopic:(NSString *)willTopic
          willMsg:(NSData *)willMsg
          willQos:(MApi_MQTTQosLevel)willQos
   willRetainFlag:(BOOL)willRetainFlag
     withClientId:(NSString *)clientId {
    [self connectTo:host
               port:port
                tls:tls
          keepalive:keepalive
              clean:clean
               auth:auth
               user:user
               pass:pass
               will:will
          willTopic:willTopic
            willMsg:willMsg
            willQos:willQos
     willRetainFlag:willRetainFlag
       withClientId:clientId
     securityPolicy:nil
       certificates:nil];
}

- (void)connectTo:(NSString *)host
             port:(NSInteger)port
              tls:(BOOL)tls
        keepalive:(NSInteger)keepalive
            clean:(BOOL)clean
             auth:(BOOL)auth
             user:(NSString *)user
             pass:(NSString *)pass
             will:(BOOL)will
        willTopic:(NSString *)willTopic
          willMsg:(NSData *)willMsg
          willQos:(MApi_MQTTQosLevel)willQos
   willRetainFlag:(BOOL)willRetainFlag
     withClientId:(NSString *)clientId
   securityPolicy:(MApi_MQTTSSLSecurityPolicy *)securityPolicy
     certificates:(NSArray *)certificates {
    [self connectTo:host
               port:port
                tls:tls
          keepalive:keepalive
              clean:clean
               auth:auth
               user:user
               pass:pass
               will:will
          willTopic:willTopic
            willMsg:willMsg
            willQos:willQos
     willRetainFlag:willRetainFlag
       withClientId:clientId
     securityPolicy:securityPolicy
       certificates:certificates
      protocolLevel:MApi_MQTTProtocolVersion311]; // use this level as default, keeps it backwards compatible
}

- (void)connectTo:(NSString *)host
             port:(NSInteger)port
              tls:(BOOL)tls
        keepalive:(NSInteger)keepalive
            clean:(BOOL)clean
             auth:(BOOL)auth
             user:(NSString *)user
             pass:(NSString *)pass
             will:(BOOL)will
        willTopic:(NSString *)willTopic
          willMsg:(NSData *)willMsg
          willQos:(MApi_MQTTQosLevel)willQos
   willRetainFlag:(BOOL)willRetainFlag
     withClientId:(NSString *)clientId
   securityPolicy:(MApi_MQTTSSLSecurityPolicy *)securityPolicy
     certificates:(NSArray *)certificates
    protocolLevel:(MApi_MQTTProtocolVersion)protocolLevel {
    DDLogVerbose(@"MApi_MQTTSessionManager connectTo:%@", host);
    BOOL shouldReconnect = self.session != nil;
    if (!self.session ||
        ![host isEqualToString:self.host] ||
        port != self.port ||
        tls != self.tls ||
        keepalive != self.keepalive ||
        clean != self.clean ||
        auth != self.auth ||
        ![user isEqualToString:self.user] ||
        ![pass isEqualToString:self.pass] ||
        ![willTopic isEqualToString:self.willTopic] ||
        ![willMsg isEqualToData:self.willMsg] ||
        willQos != self.willQos ||
        willRetainFlag != self.willRetainFlag ||
        ![clientId isEqualToString:self.clientId] ||
        securityPolicy != self.securityPolicy ||
        certificates != self.certificates) {
        self.host = host;
        self.port = (int)port;
        self.tls = tls;
        self.keepalive = keepalive;
        self.clean = clean;
        self.auth = auth;
        self.user = user;
        self.pass = pass;
        self.will = will;
        self.willTopic = willTopic;
        self.willMsg = willMsg;
        self.willQos = willQos;
        self.willRetainFlag = willRetainFlag;
        self.clientId = clientId;
        self.securityPolicy = securityPolicy;
        self.certificates = certificates;
        self.protocolLevel = protocolLevel;

        self.session = [[MApi_MQTTSession alloc] initWithClientId:clientId
                                                    userName:auth ? user : nil
                                                    password:auth ? pass : nil
                                                   keepAlive:keepalive
                                                cleanSession:clean
                                                        will:will
                                                   willTopic:willTopic
                                                     willMsg:willMsg
                                                     willQoS:willQos
                                              willRetainFlag:willRetainFlag
                                               protocolLevel:protocolLevel
                                                     runLoop:[NSRunLoop currentRunLoop]
                                                     forMode:NSDefaultRunLoopMode
                                              securityPolicy:securityPolicy
                                                certificates:certificates];

        MApi_MQTTCoreDataPersistence *persistence = [[MApi_MQTTCoreDataPersistence alloc] init];

        persistence.persistent = self.persistent;
        persistence.maxWindowSize = self.maxWindowSize;
        persistence.maxSize = self.maxSize;
        persistence.maxMessages = self.maxMessages;

        self.session.persistence = persistence;

        self.session.delegate = self;
        self.reconnectTime = RECONNECT_TIMER;
        self.reconnectFlag = FALSE;
    }
    if(shouldReconnect){
        DDLogVerbose(@"[MApi_MQTTSessionManager] reconnecting");
        [self disconnect];
        [self reconnect];
    }else{
        DDLogVerbose(@"[MApi_MQTTSessionManager] connecting");
        [self connectToInternal];
    }
}

- (UInt16)sendData:(NSData *)data topic:(NSString *)topic qos:(MApi_MQTTQosLevel)qos retain:(BOOL)retainFlag
{
    if (self.state != MApi_MQTTSessionManagerStateConnected) {
        [self connectToLast];
    }
    UInt16 msgId = [self.session publishData:data
                                     onTopic:topic
                                      retain:retainFlag
                                         qos:qos];
    return msgId;
}

- (void)disconnect
{
    self.state = MApi_MQTTSessionManagerStateClosing;
    [self.session close];

    if (self.reconnectTimer) {
        [self.reconnectTimer invalidate];
        self.reconnectTimer = nil;
    }
}

#pragma mark - MApi_MQTT Callback methods

- (void)handleEvent:(MApi_MQTTSession *)session event:(MApi_MQTTSessionEvent)eventCode error:(NSError *)error
{
#ifdef DEBUG
    __unused const NSDictionary *events = @{
                                   @(MApi_MQTTSessionEventConnected): @"connected",
                                   @(MApi_MQTTSessionEventConnectionRefused): @"connection refused",
                                   @(MApi_MQTTSessionEventConnectionClosed): @"connection closed",
                                   @(MApi_MQTTSessionEventConnectionError): @"connection error",
                                   @(MApi_MQTTSessionEventProtocolError): @"protocoll error",
                                   @(MApi_MQTTSessionEventConnectionClosedByBroker): @"connection closed by broker"
                                   };
    DDLogVerbose(@"[MApi_MQTTSessionManager] eventCode: %@ (%ld) %@", events[@(eventCode)], (long)eventCode, error);
#endif
    [self.reconnectTimer invalidate];
    switch (eventCode) {
        case MApi_MQTTSessionEventConnected:
        {
            self.lastErrorCode = nil;
            self.state = MApi_MQTTSessionManagerStateConnected;
            break;
        }
        case MApi_MQTTSessionEventConnectionClosed:
        case MApi_MQTTSessionEventConnectionClosedByBroker:
            self.state = MApi_MQTTSessionManagerStateClosed;
#if TARGET_OS_IPHONE == 1
            if (self.backgroundTask) {
                [[UIApplication sharedApplication] endBackgroundTask:self.backgroundTask];
                self.backgroundTask = UIBackgroundTaskInvalid;
            }
#endif
            self.state = MApi_MQTTSessionManagerStateStarting;
            break;
        case MApi_MQTTSessionEventProtocolError:
        case MApi_MQTTSessionEventConnectionRefused:
        case MApi_MQTTSessionEventConnectionError:
        {
            self.reconnectTimer = [NSTimer timerWithTimeInterval:self.reconnectTime
                                                          target:self
                                                        selector:@selector(reconnect)
                                                        userInfo:Nil repeats:FALSE];
            NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
            [runLoop addTimer:self.reconnectTimer
                      forMode:NSDefaultRunLoopMode];

            self.state = MApi_MQTTSessionManagerStateError;
            self.lastErrorCode = error;
            break;
        }
        default:
            break;
    }
}

- (void)newMessage:(MApi_MQTTSession *)session data:(NSData *)data onTopic:(NSString *)topic qos:(MApi_MQTTQosLevel)qos retained:(BOOL)retained mid:(unsigned int)mid
{
    if (self.delegate) {
        [self.delegate handleMessage:data onTopic:topic retained:retained];
    }
}

- (void)connected:(MApi_MQTTSession *)session sessionPresent:(BOOL)sessionPresent {
    if (self.clean || !self.reconnectFlag || !sessionPresent) {
        NSDictionary *subscriptions = [self.internalSubscriptions copy];
        @synchronized(self.effectiveSubscriptions) {
            self.effectiveSubscriptions = [[NSMutableDictionary alloc] init];
        }
        if (subscriptions.count) {
            [self.session subscribeToTopics:subscriptions subscribeHandler:^(NSError *error, NSArray<NSNumber *> *gQoss) {
                if (!error) {
                    NSArray<NSString *> *allTopics = subscriptions.allKeys;
                    for (int i = 0; i < allTopics.count; i++) {
                        NSString *topic = allTopics[i];
                        NSNumber *gQos = gQoss[i];
                        @synchronized(self.effectiveSubscriptions) {
                            NSMutableDictionary *newEffectiveSubscriptions = [self.subscriptions mutableCopy];
                            [newEffectiveSubscriptions setObject:gQos forKey:topic];
                            self.effectiveSubscriptions = newEffectiveSubscriptions;
                        }
                    }
                }
            }];

        }
        self.reconnectFlag = TRUE;
    }
}

- (void)messageDelivered:(MApi_MQTTSession *)session msgID:(UInt16)msgID {
    if (self.delegate) {
        if ([self.delegate respondsToSelector:@selector(messageDelivered:)]) {
            [self.delegate messageDelivered:msgID];
        }
    }
}


- (void)connectToInternal
{
    if (self.state == MApi_MQTTSessionManagerStateStarting
        && self.session != nil) {
        self.state = MApi_MQTTSessionManagerStateConnecting;
        [self.session connectToHost:self.host
                               port:self.port
                           usingSSL:self.tls];
    }
}

- (void)reconnect
{
    self.reconnectTimer = nil;
    self.state = MApi_MQTTSessionManagerStateStarting;

    if (self.reconnectTime < RECONNECT_TIMER_MAX) {
        self.reconnectTime *= 2;
    }
    [self connectToInternal];
}

- (void)connectToLast
{
    self.reconnectTime = RECONNECT_TIMER;

    [self connectToInternal];
}

- (NSDictionary<NSString *, NSNumber *> *)subscriptions {
    return self.internalSubscriptions;
}

- (void)setSubscriptions:(NSDictionary<NSString *, NSNumber *> *)newSubscriptions
{
    if (self.state == MApi_MQTTSessionManagerStateConnected) {
        NSDictionary *currentSubscriptions = [self.effectiveSubscriptions copy];
        
        for (NSString *topicFilter in currentSubscriptions) {
            if (![newSubscriptions objectForKey:topicFilter]) {
                [self.session unsubscribeTopic:topicFilter unsubscribeHandler:^(NSError *error) {
                    if (!error) {
                        @synchronized(self.effectiveSubscriptions) {
                            NSMutableDictionary *newEffectiveSubscriptions = [self.subscriptions mutableCopy];
                            [newEffectiveSubscriptions removeObjectForKey:topicFilter];
                            self.effectiveSubscriptions = newEffectiveSubscriptions;
                        }
                    }
                }];
            }
        }
        
        for (NSString *topicFilter in newSubscriptions) {
            if (![currentSubscriptions objectForKey:topicFilter]) {
                NSNumber *number = newSubscriptions[topicFilter];
                MApi_MQTTQosLevel qos = [number unsignedIntValue];
                [self.session subscribeToTopic:topicFilter atLevel:qos subscribeHandler:^(NSError *error, NSArray<NSNumber *> *gQoss) {
                    if (!error) {
                        NSNumber *gQos = gQoss[0];
                        @synchronized(self.effectiveSubscriptions) {
                            NSMutableDictionary *newEffectiveSubscriptions = [self.subscriptions mutableCopy];
                            [newEffectiveSubscriptions setObject:gQos forKey:topicFilter];
                            self.effectiveSubscriptions = newEffectiveSubscriptions;
                        }
                    }
                }];
            }
        }
    }
    self.internalSubscriptions = newSubscriptions;
    DDLogVerbose(@"MApi_MQTTSessionManager internalSubscriptions: %@", self.internalSubscriptions);
}

@end
