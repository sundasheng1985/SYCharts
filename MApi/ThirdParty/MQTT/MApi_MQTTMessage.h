//
// MApi_MQTTMessage.h
// MApi_MQTTClient.framework
//
// Copyright © 2013-2016, Christoph Krey
//
// based on
//
// Copyright (c) 2011, 2013, 2lemetry LLC
//
// All rights reserved. This program and the accompanying materials
// are made available under the terms of the Eclipse Public License v1.0
// which accompanies this distribution, and is available at
// http://www.eclipse.org/legal/epl-v10.html
//
// Contributors:
//    Kyle Roche - initial API and implementation and/or initial documentation
//

#import <Foundation/Foundation.h>
/**
 Enumeration of MApi_MQTT Quality of Service levels
 */
typedef NS_ENUM(UInt8, MApi_MQTTQosLevel) {
    MApi_MQTTQosLevelAtMostOnce = 0,
    MApi_MQTTQosLevelAtLeastOnce = 1,
    MApi_MQTTQosLevelExactlyOnce = 2
};

/**
 Enumeration of MApi_MQTT protocol version
 */
typedef NS_ENUM(UInt8, MApi_MQTTProtocolVersion) {
    MApi_MQTTProtocolVersion31 = 3,
    MApi_MQTTProtocolVersion311 = 4
};

typedef NS_ENUM(UInt8, MApi_MQTTCommandType) {
    MApi_MQTT_None = 0,
    MApi_MQTTConnect = 1,
    MApi_MQTTConnack = 2,
    MApi_MQTTPublish = 3,
    MApi_MQTTPuback = 4,
    MApi_MQTTPubrec = 5,
    MApi_MQTTPubrel = 6,
    MApi_MQTTPubcomp = 7,
    MApi_MQTTSubscribe = 8,
    MApi_MQTTSuback = 9,
    MApi_MQTTUnsubscribe = 10,
    MApi_MQTTUnsuback = 11,
    MApi_MQTTPingreq = 12,
    MApi_MQTTPingresp = 13,
    MApi_MQTTDisconnect = 14
};

@interface MApi_MQTTMessage : NSObject
@property (nonatomic) MApi_MQTTCommandType type;
@property (nonatomic) MApi_MQTTQosLevel qos;
@property (nonatomic) BOOL retainFlag;
@property (nonatomic) BOOL dupFlag;
@property (nonatomic) UInt16 mid;
@property (strong, nonatomic) NSData * data;

/**
 Enumeration of MApi_MQTT Connect return codes
 */

typedef NS_ENUM(NSUInteger, MApi_MQTTConnectReturnCode) {
    MApi_MQTTConnectAccepted = 0,
    MApi_MQTTConnectRefusedUnacceptableProtocolVersion,
    MApi_MQTTConnectRefusedIdentiferRejected,
    MApi_MQTTConnectRefusedServerUnavailable,
    MApi_MQTTConnectRefusedBadUserNameOrPassword,
    MApi_MQTTConnectRefusedNotAuthorized
};

// factory methods
+ (MApi_MQTTMessage *)connectMessageWithClientId:(NSString*)clientId
                                   userName:(NSString*)userName
                                   password:(NSString*)password
                                  keepAlive:(NSInteger)keeplive
                               cleanSession:(BOOL)cleanSessionFlag
                                       will:(BOOL)will
                                  willTopic:(NSString*)willTopic
                                    willMsg:(NSData*)willData
                                    willQoS:(MApi_MQTTQosLevel)willQoS
                                 willRetain:(BOOL)willRetainFlag
                              protocolLevel:(UInt8)protocolLevel;

+ (MApi_MQTTMessage *)pingreqMessage;
+ (MApi_MQTTMessage *)disconnectMessage;
+ (MApi_MQTTMessage *)subscribeMessageWithMessageId:(UInt16)msgId
                                        topics:(NSDictionary *)topics;
+ (MApi_MQTTMessage *)unsubscribeMessageWithMessageId:(UInt16)msgId
                                          topics:(NSArray *)topics;
+ (MApi_MQTTMessage *)publishMessageWithData:(NSData*)payload
                                onTopic:(NSString*)topic
                                    qos:(MApi_MQTTQosLevel)qosLevel
                                  msgId:(UInt16)msgId
                             retainFlag:(BOOL)retain
                                dupFlag:(BOOL)dup;
+ (MApi_MQTTMessage *)pubackMessageWithMessageId:(UInt16)msgId;
+ (MApi_MQTTMessage *)pubrecMessageWithMessageId:(UInt16)msgId;
+ (MApi_MQTTMessage *)pubrelMessageWithMessageId:(UInt16)msgId;
+ (MApi_MQTTMessage *)pubcompMessageWithMessageId:(UInt16)msgId;
+ (MApi_MQTTMessage *)messageFromData:(NSData *)data;

// instance methods
- (instancetype)initWithType:(MApi_MQTTCommandType)type;
- (instancetype)initWithType:(MApi_MQTTCommandType)type
                        data:(NSData *)data;
- (instancetype)initWithType:(MApi_MQTTCommandType)type
                         qos:(MApi_MQTTQosLevel)qos
                        data:(NSData *)data;
- (instancetype)initWithType:(MApi_MQTTCommandType)type
                         qos:(MApi_MQTTQosLevel)qos
                  retainFlag:(BOOL)retainFlag
                     dupFlag:(BOOL)dupFlag
                        data:(NSData *)data;

- (NSData *)wireFormat;


@end

@interface NSMutableData (MApi_MQTT)
- (void)appendByte:(UInt8)byte;
- (void)appendUInt16BigEndian:(UInt16)val;
- (void)appendMQTTString:(NSString*)s;

@end
