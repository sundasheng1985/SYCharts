//
// MApi_MQTTMessage.m
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

#import "MApi_MQTTMessage.h"

#import "MApi_MQTTLog.h"

@implementation MApi_MQTTMessage

+ (MApi_MQTTMessage *)connectMessageWithClientId:(NSString *)clientId
                                  userName:(NSString *)userName
                                  password:(NSString *)password
                                 keepAlive:(NSInteger)keepAlive
                              cleanSession:(BOOL)cleanSessionFlag
                                      will:(BOOL)will
                                 willTopic:(NSString *)willTopic
                                   willMsg:(NSData *)willMsg
                                   willQoS:(MApi_MQTTQosLevel)willQoS
                                willRetain:(BOOL)willRetainFlag
                             protocolLevel:(UInt8)protocolLevel {
    /*
     * setup flags w/o basic plausibility checks
     *
     */
    UInt8 flags = 0x00;
    
    if (cleanSessionFlag) {
        flags |= 0x02;
    }
    
    if (userName) {
        flags |= 0x80;
    }
    if (password) {
        flags |= 0x40;
    }
    
    if (will) {
        flags |= 0x04;
    }
    
    flags |= ((willQoS & 0x03) << 3);
    
    if (willRetainFlag) {
        flags |= 0x20;
    }
    
    NSMutableData* data = [NSMutableData data];
    
    switch (protocolLevel) {
        case 4:
            [data appendMQTTString:@"MQTT"];
            [data appendByte:4];
            break;
        case 3:
            [data appendMQTTString:@"MQIsdp"];
            [data appendByte:3];
            break;
        case 0:
            [data appendMQTTString:@""];
            [data appendByte:protocolLevel];
            break;
        default:
            [data appendMQTTString:@"MQTT"];
            [data appendByte:protocolLevel];
            break;
    }
    [data appendByte:flags];
    [data appendUInt16BigEndian:keepAlive];
    [data appendMQTTString:clientId];
    if (willTopic) {
        [data appendMQTTString:willTopic];
    }
    if (willMsg) {
        [data appendUInt16BigEndian:[willMsg length]];
        [data appendData:willMsg];
    }
    if (userName) {
        [data appendMQTTString:userName];
    }
    if (password) {
        [data appendMQTTString:password];
    }
    
    MApi_MQTTMessage *msg = [[MApi_MQTTMessage alloc] initWithType:MApi_MQTTConnect
                                                    data:data];
    return msg;
}

+ (MApi_MQTTMessage *)pingreqMessage {
    return [[MApi_MQTTMessage alloc] initWithType:MApi_MQTTPingreq];
}

+ (MApi_MQTTMessage *)disconnectMessage {
    return [[MApi_MQTTMessage alloc] initWithType:MApi_MQTTDisconnect];
}

+ (MApi_MQTTMessage *)subscribeMessageWithMessageId:(UInt16)msgId
                                       topics:(NSDictionary *)topics {
    NSMutableData* data = [NSMutableData data];
    [data appendUInt16BigEndian:msgId];
    for (NSString *topic in topics.allKeys) {
        [data appendMQTTString:topic];
        [data appendByte:[topics[topic] intValue]];
    }
    MApi_MQTTMessage* msg = [[MApi_MQTTMessage alloc] initWithType:MApi_MQTTSubscribe
                                                     qos:1
                                                    data:data];
    msg.mid = msgId;
    return msg;
}

+ (MApi_MQTTMessage *)unsubscribeMessageWithMessageId:(UInt16)msgId
                                         topics:(NSArray *)topics {
    NSMutableData* data = [NSMutableData data];
    [data appendUInt16BigEndian:msgId];
    for (NSString *topic in topics) {
        [data appendMQTTString:topic];
    }
    MApi_MQTTMessage* msg = [[MApi_MQTTMessage alloc] initWithType:MApi_MQTTUnsubscribe
                                                     qos:1
                                                    data:data];
    msg.mid = msgId;
    return msg;
}

+ (MApi_MQTTMessage *)publishMessageWithData:(NSData *)payload
                               onTopic:(NSString *)topic
                                   qos:(MApi_MQTTQosLevel)qosLevel
                                 msgId:(UInt16)msgId
                            retainFlag:(BOOL)retain
                               dupFlag:(BOOL)dup {
    NSMutableData *data = [[NSMutableData alloc] init];
    [data appendMQTTString:topic];
    if (msgId) [data appendUInt16BigEndian:msgId];
    [data appendData:payload];
    MApi_MQTTMessage *msg = [[MApi_MQTTMessage alloc] initWithType:MApi_MQTTPublish
                                                     qos:qosLevel
                                              retainFlag:retain
                                                 dupFlag:dup
                                                    data:data];
    msg.mid = msgId;
    return msg;
}

+ (MApi_MQTTMessage *)pubackMessageWithMessageId:(UInt16)msgId {
    NSMutableData* data = [NSMutableData data];
    [data appendUInt16BigEndian:msgId];
    MApi_MQTTMessage *msg = [[MApi_MQTTMessage alloc] initWithType:MApi_MQTTPuback
                                                    data:data];
    msg.mid = msgId;
    return msg;
}

+ (MApi_MQTTMessage *)pubrecMessageWithMessageId:(UInt16)msgId {
    NSMutableData* data = [NSMutableData data];
    [data appendUInt16BigEndian:msgId];
    MApi_MQTTMessage *msg = [[MApi_MQTTMessage alloc] initWithType:MApi_MQTTPubrec
                                                    data:data];
    msg.mid = msgId;
    return msg;
}

+ (MApi_MQTTMessage *)pubrelMessageWithMessageId:(UInt16)msgId {
    NSMutableData* data = [NSMutableData data];
    [data appendUInt16BigEndian:msgId];
    MApi_MQTTMessage *msg = [[MApi_MQTTMessage alloc] initWithType:MApi_MQTTPubrel
                                                     qos:1
                                                    data:data];
    msg.mid = msgId;
    return msg;
}

+ (MApi_MQTTMessage *)pubcompMessageWithMessageId:(UInt16)msgId {
    NSMutableData* data = [NSMutableData data];
    [data appendUInt16BigEndian:msgId];
    MApi_MQTTMessage *msg = [[MApi_MQTTMessage alloc] initWithType:MApi_MQTTPubcomp
                                                    data:data];
    msg.mid = msgId;
    return msg;
}

- (instancetype)init {
    self = [super init];
    self.type = 0;
    self.qos = MApi_MQTTQosLevelAtMostOnce;
    self.retainFlag = false;
    self.mid = 0;
    self.data = nil;
    return self;
}

- (instancetype)initWithType:(MApi_MQTTCommandType)type {
    self = [self init];
    self.type = type;
    return self;
}

- (instancetype)initWithType:(MApi_MQTTCommandType)type
                        data:(NSData *)data {
    self = [self init];
    self.type = type;
    self.data = data;
    return self;
}

- (instancetype)initWithType:(MApi_MQTTCommandType)type
                         qos:(MApi_MQTTQosLevel)qos
                        data:(NSData *)data {
    self = [self init];
    self.type = type;
    self.qos = qos;
    self.data = data;
    return self;
}

- (instancetype)initWithType:(MApi_MQTTCommandType)type
                         qos:(MApi_MQTTQosLevel)qos
                  retainFlag:(BOOL)retainFlag
                     dupFlag:(BOOL)dupFlag
                        data:(NSData *)data {
    self = [self init];
    self.type = type;
    self.qos = qos;
    self.retainFlag = retainFlag;
    self.dupFlag = dupFlag;
    self.data = data;
    return self;
}

- (NSData *)wireFormat {
    NSMutableData *buffer = [[NSMutableData alloc] init];
    
    // encode fixed header
    UInt8 header;
    header = (self.type & 0x0f) << 4;
    if (self.dupFlag) {
        header |= 0x08;
    }
    header |= (self.qos & 0x03) << 1;
    if (self.retainFlag) {
        header |= 0x01;
    }
    [buffer appendBytes:&header length:1];
    
    // encode remaining length
    NSInteger length = self.data.length;
    do {
        UInt8 digit = length % 128;
        length /= 128;
        if (length > 0) {
            digit |= 0x80;
        }
        [buffer appendBytes:&digit length:1];
    }
    while (length > 0);
    
    // encode message data
    if (self.data != nil) {
        [buffer appendData:self.data];
    }
    
    DDLogVerbose(@"[MApi_MQTTMessage] wireFormat(%lu)=%@...",
              (unsigned long)buffer.length,
              [buffer subdataWithRange:NSMakeRange(0, MIN(256, buffer.length))]);
    
    return buffer;
}

+ (MApi_MQTTMessage *)messageFromData:(NSData *)data {
    MApi_MQTTMessage *message = nil;
    if (data.length >= 2) {
        UInt8 header;
        [data getBytes:&header length:sizeof(header)];
        UInt8 type = (header >> 4) & 0x0f;
        UInt8 dupFlag = (header >> 3) & 0x01;
        UInt8 qos = (header >> 1) & 0x03;
        UInt8 retainFlag = header & 0x01;
        UInt32 remainingLength = 0;
        UInt32 multiplier = 1;
        UInt8 offset = 1;
        UInt8 digit;
        do {
            if (data.length < offset) {
                DDLogWarn(@"[MApi_MQTTMessage] message data incomplete remaining length");
                offset = -1;
                break;
            }
            [data getBytes:&digit range:NSMakeRange(offset, 1)];
            offset++;
            remainingLength += (digit & 0x7f) * multiplier;
            multiplier *= 128;
            if (multiplier > 128*128*128) {
                DDLogWarn(@"[MApi_MQTTMessage] message data too long remaining length");
                multiplier = -1;
                break;
            }
        } while ((digit & 0x80) != 0);
        
        if (type >= MApi_MQTTConnect &&
            type <= MApi_MQTTDisconnect) {
            if (offset > 0 &&
                multiplier > 0 &&
                data.length == remainingLength + offset) {
                if ((type == MApi_MQTTPublish && (qos >= MApi_MQTTQosLevelAtMostOnce && qos <= MApi_MQTTQosLevelExactlyOnce)) ||
                    (type == MApi_MQTTConnect && qos == 0) ||
                    (type == MApi_MQTTConnack && qos == 0) ||
                    (type == MApi_MQTTPuback && qos == 0) ||
                    (type == MApi_MQTTPubrec && qos == 0) ||
                    (type == MApi_MQTTPubrel && qos == 1) ||
                    (type == MApi_MQTTPubcomp && qos == 0) ||
                    (type == MApi_MQTTSubscribe && qos == 1) ||
                    (type == MApi_MQTTSuback && qos == 0) ||
                    (type == MApi_MQTTUnsubscribe && qos == 1) ||
                    (type == MApi_MQTTUnsuback && qos == 0) ||
                    (type == MApi_MQTTPingreq && qos == 0) ||
                    (type == MApi_MQTTPingresp && qos == 0) ||
                    (type == MApi_MQTTDisconnect && qos == 0)) {
                    message = [[MApi_MQTTMessage alloc] init];
                    message.type = type;
                    message.dupFlag = dupFlag == 1;
                    message.retainFlag = retainFlag == 1;
                    message.qos = qos;
                    message.data = [data subdataWithRange:NSMakeRange(offset, remainingLength)];
                    if ((type == MApi_MQTTPublish &&
                         (qos == MApi_MQTTQosLevelAtLeastOnce ||
                          qos == MApi_MQTTQosLevelExactlyOnce)
                         ) ||
                        type == MApi_MQTTPuback ||
                        type == MApi_MQTTPubrec ||
                        type == MApi_MQTTPubrel ||
                        type == MApi_MQTTPubcomp ||
                        type == MApi_MQTTSubscribe ||
                        type == MApi_MQTTSuback ||
                        type == MApi_MQTTUnsubscribe ||
                        type == MApi_MQTTUnsuback) {
                        if (message.data.length >= 2) {
                            [message.data getBytes:&digit range:NSMakeRange(0, 1)];
                            message.mid = digit * 256;
                            [message.data getBytes:&digit range:NSMakeRange(1, 1)];
                            message.mid += digit;
                        } else {
                            DDLogWarn(@"[MApi_MQTTMessage] missing packet identifier");
                            message = nil;
                        }
                    }
                    if (type == MApi_MQTTPuback ||
                        type == MApi_MQTTPubrec ||
                        type == MApi_MQTTPubrel ||
                        type == MApi_MQTTPubcomp ||
                        type == MApi_MQTTUnsuback ) {
                        if (message.data.length > 2) {
                            DDLogWarn(@"[MApi_MQTTMessage] unexpected payload after packet identifier");
                            message = nil;
                        }
                    }
                    if (type == MApi_MQTTPingreq ||
                        type == MApi_MQTTPingresp ||
                        type == MApi_MQTTDisconnect) {
                        if (message.data.length > 2) {
                            DDLogWarn(@"[MApi_MQTTMessage] unexpected payload");
                            message = nil;
                        }
                    }
                    if (type == MApi_MQTTConnect) {
                        if (message.data.length < 3) {
                            DDLogWarn(@"[MApi_MQTTMessage] missing connect variable header");
                            message = nil;
                        }
                    }
                    if (type == MApi_MQTTConnack) {
                        if (message.data.length != 2) {
                            DDLogWarn(@"[MApi_MQTTMessage] missing connack variable header");
                            message = nil;
                        }
                    }
                    if (type == MApi_MQTTSubscribe) {
                        if (message.data.length < 3) {
                            DDLogWarn(@"[MApi_MQTTMessage] missing subscribe variable header");
                            message = nil;
                        }
                    }
                    if (type == MApi_MQTTSuback) {
                        if (message.data.length < 3) {
                            DDLogWarn(@"[MApi_MQTTMessage] missing suback variable header");
                            message = nil;
                        }
                    }
                    if (type == MApi_MQTTUnsubscribe) {
                        if (message.data.length < 3) {
                            DDLogWarn(@"[MApi_MQTTMessage] missing unsubscribe variable header");
                            message = nil;
                        }
                    }
                } else {
                    DDLogWarn(@"[MApi_MQTTMessage] illegal header flags");
                }
            } else {
                DDLogWarn(@"[MApi_MQTTMessage] remaining data wrong length");
            }
        } else {
            DDLogWarn(@"[MApi_MQTTMessage] illegal message type");
        }
    } else {
        DDLogWarn(@"[MApi_MQTTMessage] message data length < 2");
    }
    return message;
}

@end

@implementation NSMutableData (MApi_MQTT)

- (void)appendByte:(UInt8)byte
{
    [self appendBytes:&byte length:1];
}

- (void)appendUInt16BigEndian:(UInt16)val
{
    [self appendByte:val / 256];
    [self appendByte:val % 256];
}

- (void)appendMQTTString:(NSString *)string
{
    if (string) {
        //        UInt8 buf[2];
        //        if (DEBUGMSG) NSLog(@"String=%@", string);
        //        const char* utf8String = [string UTF8String];
        //        if (DEBUGMSG) NSLog(@"UTF8=%s", utf8String);
        //
        //        size_t strLen = strlen(utf8String);
        //        buf[0] = strLen / 256;
        //        buf[1] = strLen % 256;
        //        [self appendBytes:buf length:2];
        //        [self appendBytes:utf8String length:strLen];
        
        // This updated code allows for all kind or UTF characters including 0x0000
        NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
        UInt8 buf[2];
        UInt16 len = data.length;
        buf[0] = len / 256;
        buf[1] = len % 256;
        
        [self appendBytes:buf length:2];
        [self appendData:data];
    }
}

@end

