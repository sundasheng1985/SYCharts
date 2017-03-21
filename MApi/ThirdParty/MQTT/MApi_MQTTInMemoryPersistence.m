//
//  MApi_MQTTInMemoryPersistence.m
//  MApi_MQTTClient
//
//  Created by Christoph Krey on 22.03.15.
//  Copyright © 2015-2016 Christoph Krey. All rights reserved.
//

#import "MApi_MQTTInMemoryPersistence.h"

#import "MApi_MQTTLog.h"

@implementation MApi_MQTTInMemoryFlow
@synthesize clientId;
@synthesize incomingFlag;
@synthesize retainedFlag;
@synthesize commandType;
@synthesize qosLevel;
@synthesize messageId;
@synthesize topic;
@synthesize data;
@synthesize deadline;

@end

@interface MApi_MQTTInMemoryPersistence()
@end

static NSMutableDictionary *clientIds;

@implementation MApi_MQTTInMemoryPersistence
@synthesize maxSize;
@synthesize persistent;
@synthesize maxMessages;
@synthesize maxWindowSize;

- (MApi_MQTTInMemoryPersistence *)init {
    self = [super init];
    self.maxMessages = MApi_MQTT_MAX_MESSAGES;
    self.maxWindowSize = MApi_MQTT_MAX_WINDOW_SIZE;
    @synchronized(clientIds) {
        if (!clientIds) {
            clientIds = [[NSMutableDictionary alloc] init];
        }
    }
    return self;
}

- (NSUInteger)windowSize:(NSString *)clientId {
    NSUInteger windowSize = 0;
    NSArray *flows = [self allFlowsforClientId:clientId
                                  incomingFlag:NO];
    for (MApi_MQTTInMemoryFlow *flow in flows) {
        if ([flow.commandType intValue] != MApi_MQTT_None) {
            windowSize++;
        }
    }
    return windowSize;
}

- (MApi_MQTTInMemoryFlow *)storeMessageForClientId:(NSString *)clientId
                                        topic:(NSString *)topic
                                         data:(NSData *)data
                                   retainFlag:(BOOL)retainFlag
                                          qos:(MApi_MQTTQosLevel)qos
                                        msgId:(UInt16)msgId
                                 incomingFlag:(BOOL)incomingFlag
                                  commandType:(UInt8)commandType
                                     deadline:(NSDate *)deadline {
    @synchronized(clientIds) {
        
        if (([self allFlowsforClientId:clientId incomingFlag:incomingFlag].count <= self.maxMessages)) {
            MApi_MQTTInMemoryFlow *flow = (MApi_MQTTInMemoryFlow *)[self createFlowforClientId:clientId
                                                                        incomingFlag:incomingFlag
                                                                           messageId:msgId];
            flow.topic = topic;
            flow.data = data;
            flow.retainedFlag = [NSNumber numberWithBool:retainFlag];
            flow.qosLevel = [NSNumber numberWithUnsignedInteger:qos];
            flow.commandType = [NSNumber numberWithUnsignedInteger:commandType];
            flow.deadline = deadline;
            return flow;
        } else {
            return nil;
        }
    }
}

- (void)deleteFlow:(MApi_MQTTInMemoryFlow *)flow {
    @synchronized(clientIds) {
        
        NSMutableDictionary *clientIdFlows = [clientIds objectForKey:flow.clientId];
        if (clientIdFlows) {
            NSMutableDictionary *clientIdDirectedFlow = [clientIdFlows objectForKey:flow.incomingFlag];
            if (clientIdDirectedFlow) {
                [clientIdDirectedFlow removeObjectForKey:flow.messageId];
            }
        }
    }
}

- (void)deleteAllFlowsForClientId:(NSString *)clientId {
    @synchronized(clientIds) {
        
        DDLogInfo(@"[MApi_MQTTInMemoryPersistence] deleteAllFlowsForClientId %@", clientId);
        [clientIds removeObjectForKey:clientId];
    }
}

- (void)sync {
    //
}

- (NSArray *)allFlowsforClientId:(NSString *)clientId
                    incomingFlag:(BOOL)incomingFlag {
    @synchronized(clientIds) {
        
        NSArray *flows = nil;
        NSMutableDictionary *clientIdFlows = [clientIds objectForKey:clientId];
        if (clientIdFlows) {
            NSMutableDictionary *clientIdDirectedFlow = [clientIdFlows objectForKey:[NSNumber numberWithBool:incomingFlag]];
            if (clientIdDirectedFlow) {
                flows = clientIdDirectedFlow.allValues;
            }
        }
        return flows;
    }
}

- (MApi_MQTTInMemoryFlow *)flowforClientId:(NSString *)clientId
                         incomingFlag:(BOOL)incomingFlag
                            messageId:(UInt16)messageId {
    @synchronized(clientIds) {
        
        MApi_MQTTInMemoryFlow *flow = nil;
        
        NSMutableDictionary *clientIdFlows = [clientIds objectForKey:clientId];
        if (clientIdFlows) {
            NSMutableDictionary *clientIdDirectedFlow = [clientIdFlows objectForKey:[NSNumber numberWithBool:incomingFlag]];
            if (clientIdDirectedFlow) {
                flow = [clientIdDirectedFlow objectForKey:[NSNumber numberWithUnsignedInteger:messageId]];
            }
        }
        
        return flow;
    }
}

- (MApi_MQTTInMemoryFlow *)createFlowforClientId:(NSString *)clientId
                               incomingFlag:(BOOL)incomingFlag
                                  messageId:(UInt16)messageId {
    @synchronized(clientIds) {
        NSMutableDictionary *clientIdFlows = [clientIds objectForKey:clientId];
        if (!clientIdFlows) {
            clientIdFlows = [[NSMutableDictionary alloc] init];
            [clientIds setObject:clientIdFlows forKey:clientId];
        }
        
        NSMutableDictionary *clientIdDirectedFlow = [clientIdFlows objectForKey:[NSNumber numberWithBool:incomingFlag]];
        if (!clientIdDirectedFlow) {
            clientIdDirectedFlow = [[NSMutableDictionary alloc] init];
            [clientIdFlows setObject:clientIdDirectedFlow forKey:[NSNumber numberWithBool:incomingFlag]];
        }
        
        MApi_MQTTInMemoryFlow *flow = [[MApi_MQTTInMemoryFlow alloc] init];
        flow.clientId = clientId;
        flow.incomingFlag = [NSNumber numberWithBool:incomingFlag];
        flow.messageId = [NSNumber numberWithUnsignedInteger:messageId];
        
        [clientIdDirectedFlow setObject:flow forKey:[NSNumber numberWithUnsignedInteger:messageId]];
        
        return flow;
    }
}

@end
