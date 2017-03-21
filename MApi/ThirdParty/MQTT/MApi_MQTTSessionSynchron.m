//
// MApi_MQTTSessionSynchron.m
// MApi_MQTTClient.framework
//
// Copyright © 2013-2016, Christoph Krey
//

/**
 Synchronous API
 
 @author Christoph Krey krey.christoph@gmail.com
 @see http://mqtt.org
 */

#import "MApi_MQTTSession.h"
#import "MApi_MQTTSessionLegacy.h"
#import "MApi_MQTTSessionSynchron.h"

#import "MApi_MQTTLog.h"

@interface MApi_MQTTSession()
@property (nonatomic) BOOL synchronPub;
@property (nonatomic) UInt16 synchronPubMid;
@property (nonatomic) UInt16 synchronUnsubMid;
@property (nonatomic) UInt16 synchronSubMid;
@property (nonatomic) BOOL synchronDisconnect;
- (dispatch_semaphore_t)semaphoreSub;
- (dispatch_semaphore_t)semaphoreUnsub;
- (dispatch_semaphore_t)semaphoreConnect;
@end

@implementation MApi_MQTTSession(Synchron)

/** Synchron connect
 *
 */
- (BOOL)connectAndWaitTimeout:(NSTimeInterval)timeout {
    
    [self connect];
    
    dispatch_semaphore_wait([self semaphoreConnect],
                            dispatch_time(DISPATCH_TIME_NOW, (int64_t)(timeout * NSEC_PER_SEC)));
    
    DDLogVerbose(@"[MApi_MQTTSessionSynchron] end connect");
    
    return (self.status == MApi_MQTTSessionStatusConnected);
}

/**
 * @deprecated
 */
 - (BOOL)connectAndWaitToHost:(NSString*)host port:(UInt32)port usingSSL:(BOOL)usingSSL {
    return [self connectAndWaitToHost:host port:port usingSSL:usingSSL timeout:0];
}

/**
 * @deprecated
 */
- (BOOL)connectAndWaitToHost:(NSString*)host port:(UInt32)port usingSSL:(BOOL)usingSSL timeout:(NSTimeInterval)timeout {
    
    [self connectToHost:host port:port usingSSL:usingSSL];
    
    dispatch_semaphore_wait([self semaphoreConnect],
                            dispatch_time(DISPATCH_TIME_NOW, (int64_t)(timeout * NSEC_PER_SEC)));
    
    DDLogVerbose(@"[MApi_MQTTSessionSynchron] end connect");
    
    return (self.status == MApi_MQTTSessionStatusConnected);
}

- (BOOL)subscribeAndWaitToTopic:(NSString *)topic atLevel:(MApi_MQTTQosLevel)qosLevel {
    return [self subscribeAndWaitToTopic:topic atLevel:qosLevel timeout:0];
}

- (BOOL)subscribeAndWaitToTopic:(NSString *)topic atLevel:(MApi_MQTTQosLevel)qosLevel timeout:(NSTimeInterval)timeout {
    
    UInt16 mid = [self subscribeToTopic:topic atLevel:qosLevel];
    self.synchronSubMid = mid;
    
    dispatch_semaphore_wait([self semaphoreSub],
                            dispatch_time(DISPATCH_TIME_NOW, (int64_t)(timeout * NSEC_PER_SEC)));
    
    DDLogVerbose(@"[MApi_MQTTSessionSynchron] end subscribe");
    
    if (self.synchronSubMid != mid) {
        return FALSE;
    } else {
        return TRUE;
    }
}

- (BOOL)subscribeAndWaitToTopics:(NSDictionary<NSString *, NSNumber *> *)topics {
    return [self subscribeAndWaitToTopics:topics timeout:0];
}

- (BOOL)subscribeAndWaitToTopics:(NSDictionary<NSString *, NSNumber *> *)topics timeout:(NSTimeInterval)timeout {
    NSDate *started = [NSDate date];

    UInt16 mid = [self subscribeToTopics:topics];
    self.synchronSubMid = mid;
    
    dispatch_semaphore_wait([self semaphoreSub],
                            dispatch_time(DISPATCH_TIME_NOW, (int64_t)(timeout * NSEC_PER_SEC)));

    DDLogVerbose(@"[MApi_MQTTSessionSynchron] end subscribe");
    
    if (self.synchronSubMid != mid ||
        [[NSDate date] timeIntervalSince1970] > [started timeIntervalSince1970] + timeout) {
        return FALSE;
    } else {
        return TRUE;
    }
}

- (BOOL)unsubscribeAndWaitTopic:(NSString *)theTopic {
    return [self unsubscribeAndWaitTopic:theTopic timeout:0];
}

- (BOOL)unsubscribeAndWaitTopic:(NSString *)theTopic timeout:(NSTimeInterval)timeout {
    NSDate *started = [NSDate date];
    
    UInt16 mid = [self unsubscribeTopic:theTopic];
    self.synchronUnsubMid = mid;
 
    dispatch_semaphore_wait([self semaphoreUnsub],
                            dispatch_time(DISPATCH_TIME_NOW, (int64_t)(timeout * NSEC_PER_SEC)));
    
    DDLogVerbose(@"[MApi_MQTTSessionSynchron] end unsubscribe");
    
    if (self.synchronUnsubMid != mid ||
        [[NSDate date] timeIntervalSince1970] > [started timeIntervalSince1970] + timeout) {
        return FALSE;
    } else {
        return TRUE;
    }
}

- (BOOL)unsubscribeAndWaitTopics:(NSArray<NSString *> *)topics {
    return [self unsubscribeAndWaitTopics:topics timeout:0];
}

- (BOOL)unsubscribeAndWaitTopics:(NSArray<NSString *> *)topics timeout:(NSTimeInterval)timeout {
    NSDate *started = [NSDate date];

    UInt16 mid = [self unsubscribeTopics:topics];
    self.synchronUnsubMid = mid;
    
    dispatch_semaphore_wait([self semaphoreUnsub],
                            dispatch_time(DISPATCH_TIME_NOW, (int64_t)(timeout * NSEC_PER_SEC)));
    
    DDLogVerbose(@"[MApi_MQTTSessionSynchron] end unsubscribe");
    
    if (self.synchronUnsubMid != mid ||
        [[NSDate date] timeIntervalSince1970] > [started timeIntervalSince1970] + timeout) {
        return FALSE;
    } else {
        return TRUE;
    }
}

- (BOOL)publishAndWaitData:(NSData*)data
                   onTopic:(NSString*)topic
                    retain:(BOOL)retainFlag
                       qos:(MApi_MQTTQosLevel)qos {
    return [self publishAndWaitData:data onTopic:topic retain:retainFlag qos:qos timeout:0];
}

- (BOOL)publishAndWaitData:(NSData*)data
                   onTopic:(NSString*)topic
                    retain:(BOOL)retainFlag
                       qos:(MApi_MQTTQosLevel)qos
                   timeout:(NSTimeInterval)timeout {
    NSDate *started = [NSDate date];

    if (qos != MApi_MQTTQosLevelAtMostOnce) {
        self.synchronPub = TRUE;
    }
    
    UInt16 mid = self.synchronPubMid = [self publishData:data onTopic:topic retain:retainFlag qos:qos];
    if (qos == MApi_MQTTQosLevelAtMostOnce) {
        return TRUE;
    } else {        
        while (self.synchronPub && (timeout == 0 || [started timeIntervalSince1970] + timeout > [[NSDate date] timeIntervalSince1970])) {
            DDLogVerbose(@"[MApi_MQTTSessionSynchron] waiting for mid %d", mid);
            [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:.1]];
        }
        
        DDLogVerbose(@"[MApi_MQTTSessionSynchron] end publish");
        
        if (self.synchronPub || self.synchronPubMid != mid) {
            return FALSE;
        } else {
            return TRUE;
        }
    }
}

- (void)closeAndWait {
    [self closeAndWait:0];
}

- (void)closeAndWait:(NSTimeInterval)timeout {
    NSDate *started = [NSDate date];
    self.synchronDisconnect = TRUE;
    [self close];
    
    while (self.synchronDisconnect && (timeout == 0 || [started timeIntervalSince1970] + timeout > [[NSDate date] timeIntervalSince1970])) {
        DDLogVerbose(@"[MApi_MQTTSessionSynchron] waiting for close");
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:.1]];
    }
    DDLogVerbose(@"[MApi_MQTTSessionSynchron] end close");
}

@end
