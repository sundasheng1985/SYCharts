//
// MApi_MQTTSession.h
// MApi_MQTTClient.framework
//

/**
 Using MApi_MQTT in your Objective-C application
 
 @author Christoph Krey krey.christoph@gmail.com
 @copyright Copyright © 2013-2016, Christoph Krey 
 
 based on Copyright (c) 2011, 2013, 2lemetry LLC
    All rights reserved. This program and the accompanying materials
    are made available under the terms of the Eclipse Public License v1.0
    which accompanies this distribution, and is available at
    http://www.eclipse.org/legal/epl-v10.html
 
 @see http://mqtt.org
 */


#import <Foundation/Foundation.h>

#import "MApi_MQTTMessage.h"
#import "MApi_MQTTPersistence.h"
#import "MApi_MQTTTransport.h"

@class MApi_MQTTSession;
@class MApi_MQTTSSLSecurityPolicy;

/**
 Enumeration of MApi_MQTTSession states
 */
typedef NS_ENUM(NSInteger, MApi_MQTTSessionStatus) {
    MApi_MQTTSessionStatusCreated,
    MApi_MQTTSessionStatusConnecting,
    MApi_MQTTSessionStatusConnected,
    MApi_MQTTSessionStatusDisconnecting,
    MApi_MQTTSessionStatusClosed,
    MApi_MQTTSessionStatusError
};

/**
 Enumeration of MApi_MQTTSession events
 */
typedef NS_ENUM(NSInteger, MApi_MQTTSessionEvent) {
    MApi_MQTTSessionEventConnected,
    MApi_MQTTSessionEventConnectionRefused,
    MApi_MQTTSessionEventConnectionClosed,
    MApi_MQTTSessionEventConnectionError,
    MApi_MQTTSessionEventProtocolError,
    MApi_MQTTSessionEventConnectionClosedByBroker
};

/**
 The error domain used for all errors created by MApi_MQTTSession
 */
extern NSString * const MApi_MQTTSessionErrorDomain;

/**
 The error codes used for all errors created by MApi_MQTTSession
 */
typedef NS_ENUM(NSInteger, MApi_MQTTSessionError) {
    MApi_MQTTSessionErrorConnectionRefused = -8, // Sent if the server closes the connection without sending an appropriate error CONNACK
    MApi_MQTTSessionErrorIllegalMessageReceived = -7,
    MApi_MQTTSessionErrorDroppingOutgoingMessage = -6, // For some reason the value is the same as for MApi_MQTTSessionErrorNoResponse
    MApi_MQTTSessionErrorNoResponse = -6, // For some reason the value is the same as for MApi_MQTTSessionErrorDroppingOutgoingMessage
    MApi_MQTTSessionErrorEncoderNotReady = -5,
    MApi_MQTTSessionErrorInvalidConnackReceived = -2, // Sent if the message received from server was an invalid connack message
    MApi_MQTTSessionErrorNoConnackReceived = -1, // Sent if first message received from server was no connack message
    MApi_MQTTSessionErrorConnackUnacceptableProtocolVersion = 1, // Value as defined by MApi_MQTT Protocol
    MApi_MQTTSessionErrorConnackIdentifierRejected = 2, // Value as defined by MApi_MQTT Protocol
    MApi_MQTTSessionErrorConnackServeUnavailable = 3, // Value as defined by MApi_MQTT Protocol
    MApi_MQTTSessionErrorConnackBadUsernameOrPassword = 4, // Value as defined by MApi_MQTT Protocol
    MApi_MQTTSessionErrorConnackNotAuthorized = 5, // Value as defined by MApi_MQTT Protocol
    MApi_MQTTSessionErrorConnackReserved = 6, // Should be value 6-255, as defined by MApi_MQTT Protocol
};

/** Session delegate gives your application control over the MApi_MQTTSession
 @note all callback methods are optional
 */

@protocol MApi_MQTTSessionDelegate <NSObject>

@optional

/** gets called when a new message was received
 @param session the MApi_MQTTSession reporting the new message
 @param data the data received, might be zero length
 @param topic the topic the data was published to
 @param qos the qos of the message
 @param retained indicates if the data retransmitted from server storage
 @param mid the Message Identifier of the message if qos = 1 or 2, zero otherwise
 */
- (void)newMessage:(MApi_MQTTSession *)session
              data:(NSData *)data
           onTopic:(NSString *)topic
               qos:(MApi_MQTTQosLevel)qos
          retained:(BOOL)retained
               mid:(unsigned int)mid;

/** gets called when a new message was received
 @param session the MApi_MQTTSession reporting the new message
 @param data the data received, might be zero length
 @param topic the topic the data was published to
 @param qos the qos of the message
 @param retained indicates if the data retransmitted from server storage
 @param mid the Message Identifier of the message if qos = 1 or 2, zero otherwise
 @return true if the message was or will be processed, false if the message shall not be ack-ed
 */
- (BOOL)newMessageWithFeedback:(MApi_MQTTSession *)session
                          data:(NSData *)data
                       onTopic:(NSString *)topic
                           qos:(MApi_MQTTQosLevel)qos
                      retained:(BOOL)retained
                           mid:(unsigned int)mid;

/** for mqttio-OBJC backward compatibility
 @param session see newMessage for description
 @param data see newMessage for description
 @param topic see newMessage for description
 */
- (void)session:(MApi_MQTTSession*)session newMessage:(NSData*)data onTopic:(NSString*)topic;

/** gets called when a connection is established, closed or a problem occurred
 @param session the MApi_MQTTSession reporting the event
 @param eventCode the code of the event
 @param error an optional additional error object with additional information
 */
- (void)handleEvent:(MApi_MQTTSession *)session event:(MApi_MQTTSessionEvent)eventCode error:(NSError *)error;

/** for mqttio-OBJC backward compatibility
 @param session the MApi_MQTTSession reporting the event
 @param eventCode the code of the event
 */
- (void)session:(MApi_MQTTSession*)session handleEvent:(MApi_MQTTSessionEvent)eventCode;

/** gets called when a connection has been successfully established
 @param session the MApi_MQTTSession reporting the connect
 
 */
- (void)connected:(MApi_MQTTSession *)session;

/** gets called when a connection has been successfully established
 @param session the MApi_MQTTSession reporting the connect
 @param sessionPresent represents the Session Present flag sent by the broker
 
 */
- (void)connected:(MApi_MQTTSession *)session sessionPresent:(BOOL)sessionPresent;

/** gets called when a connection has been refused
 @param session the MApi_MQTTSession reporting the refusal
 @param error an optional additional error object with additional information
 */
- (void)connectionRefused:(MApi_MQTTSession *)session error:(NSError *)error;

/** gets called when a connection has been closed
 @param session the MApi_MQTTSession reporting the close

 */
- (void)connectionClosed:(MApi_MQTTSession *)session;

/** gets called when a connection error happened
 @param session the MApi_MQTTSession reporting the connect error
 @param error an optional additional error object with additional information
 */
- (void)connectionError:(MApi_MQTTSession *)session error:(NSError *)error;

/** gets called when an MApi_MQTT protocol error happened
 @param session the MApi_MQTTSession reporting the protocol error
 @param error an optional additional error object with additional information
 */
- (void)protocolError:(MApi_MQTTSession *)session error:(NSError *)error;

/** gets called when a published message was actually delivered
 @param session the MApi_MQTTSession reporting the delivery
 @param msgID the Message Identifier of the delivered message
 @note this method is called after a publish with qos 1 or 2 only
 */
- (void)messageDelivered:(MApi_MQTTSession *)session msgID:(UInt16)msgID;

/** gets called when a subscription is acknowledged by the MApi_MQTT broker
 @param session the MApi_MQTTSession reporting the acknowledge
 @param msgID the Message Identifier of the SUBSCRIBE message
 @param qoss an array containing the granted QoS(s) related to the SUBSCRIBE message
    (see subscribeTopic, subscribeTopics)
 */
- (void)subAckReceived:(MApi_MQTTSession *)session msgID:(UInt16)msgID grantedQoss:(NSArray<NSNumber *> *)qoss;

/** gets called when an unsubscribe is acknowledged by the MApi_MQTT broker
 @param session the MApi_MQTTSession reporting the acknowledge
 @param msgID the Message Identifier of the UNSUBSCRIBE message
 */
- (void)unsubAckReceived:(MApi_MQTTSession *)session msgID:(UInt16)msgID;

/** gets called when a command is sent to the MApi_MQTT broker
 use this for low level monitoring of the MApi_MQTT connection
 @param session the MApi_MQTTSession reporting the sent command
 @param type the MApi_MQTT command type
 @param qos the Quality of Service of the command
 @param retained the retained status of the command
 @param duped the duplication status of the command
 @param mid the Message Identifier of the command
 @param data the payload data of the command if any, might be zero length
 */
- (void)sending:(MApi_MQTTSession *)session type:(MApi_MQTTCommandType)type qos:(MApi_MQTTQosLevel)qos retained:(BOOL)retained duped:(BOOL)duped mid:(UInt16)mid data:(NSData *)data;

/** gets called when a command is received from the MApi_MQTT broker
 use this for low level monitoring of the MApi_MQTT connection
 @param session the MApi_MQTTSession reporting the received command
 @param type the MApi_MQTT command type
 @param qos the Quality of Service of the command
 @param retained the retained status of the command
 @param duped the duplication status of the command
 @param mid the Message Identifier of the command
 @param data the payload data of the command if any, might be zero length
 */
- (void)received:(MApi_MQTTSession *)session type:(MApi_MQTTCommandType)type qos:(MApi_MQTTQosLevel)qos retained:(BOOL)retained duped:(BOOL)duped mid:(UInt16)mid data:(NSData *)data;

/** gets called when a command is received from the MApi_MQTT broker
 use this for low level control of the MApi_MQTT connection
 @param session the MApi_MQTTSession reporting the received command
 @param type the MApi_MQTT command type
 @param qos the Quality of Service of the command
 @param retained the retained status of the command
 @param duped the duplication status of the command
 @param mid the Message Identifier of the command
 @param data the payload data of the command if any, might be zero length
 @return true if the sessionmanager should ignore the received message
 */
- (BOOL)ignoreReceived:(MApi_MQTTSession *)session type:(MApi_MQTTCommandType)type qos:(MApi_MQTTQosLevel)qos retained:(BOOL)retained duped:(BOOL)duped mid:(UInt16)mid data:(NSData *)data;

/** gets called when the content of MApi_MQTTClients internal buffers change
 use for monitoring the completion of transmitted and received messages
 @param session the MApi_MQTTSession reporting the change
 @param queued for backward compatibility only: MApi_MQTTClient does not queue messages anymore except during QoS protocol
 @param flowingIn the number of incoming messages not acknowledged by the MApi_MQTTClient yet
 @param flowingOut the number of outgoing messages not yet acknowledged by the MApi_MQTT broker
 */
- (void)buffered:(MApi_MQTTSession *)session
          queued:(NSUInteger)queued
       flowingIn:(NSUInteger)flowingIn
      flowingOut:(NSUInteger)flowingOut;

/** gets called when the content of MApi_MQTTClients internal buffers change
 use for monitoring the completion of transmitted and received messages
 @param session the MApi_MQTTSession reporting the change
 @param flowingIn the number of incoming messages not acknowledged by the MApi_MQTTClient yet
 @param flowingOut the number of outgoing messages not yet acknowledged by the MApi_MQTT broker
 */
- (void)buffered:(MApi_MQTTSession *)session
       flowingIn:(NSUInteger)flowingIn
      flowingOut:(NSUInteger)flowingOut;

@end

typedef void (^MApi_MQTTConnectHandler)(NSError *error);
typedef void (^MApi_MQTTDisconnectHandler)(NSError *error);
typedef void (^MApi_MQTTSubscribeHandler)(NSError *error, NSArray<NSNumber *> *gQoss);
typedef void (^MApi_MQTTUnsubscribeHandler)(NSError *error);
typedef void (^MApi_MQTTPublishHandler)(NSError *error);

/** Session implements the MApi_MQTT protocol for your application
 *
 */

@interface MApi_MQTTSession : NSObject

/** set this member variable to receive delegate messages
 @code
 #import "MApi_MQTTClient.h"
 
 @interface MyClass : NSObject <MApi_MQTTSessionDelegate>
 ...
 @end
 
 ...
 MApi_MQTTSession *session = [[MApi_MQTTSession alloc] init];
 session.delegate = self;
 ...
 - (void)handleEvent:(MApi_MQTTSession *)session
        event:(MApi_MQTTSessionEvent)eventCode
        error:(NSError *)error {
    ...
 }
 - (void)newMessage:(MApi_MQTTSession *)session
        data:(NSData *)data
        onTopic:(NSString *)topic
        qos:(MApi_MQTTQosLevel)qos
        retained:(BOOL)retained
        mid:(unsigned int)mid {
    ...
 }
 @endcode
 
 */
@property (weak, nonatomic) id<MApi_MQTTSessionDelegate> delegate;

/** Control MApi_MQTT persistence by setting the properties of persistence before connecting to an MApi_MQTT broker.
    The settings are specific to a clientId.
 
    persistence.persistent = YES or NO (default) to establish file or in memory persistence. IMPORTANT: set immediately after creating the MApi_MQTTSession before calling any other method. Otherwise the default value (NO) will be used
        for this session.
 
    persistence.maxWindowSize (a positive number, default is 16) to control the number of messages sent before waiting for acknowledgement in Qos 1 or 2. Additional messages are
        stored and transmitted later.
 
    persistence.maxSize (a positive number of bytes, default is 64 MB) to limit the size of the persistence file. Messages published after the limit is reached are dropped.
 
    persistence.maxMessages (a positive number, default is 1024) to limit the number of messages stored. Additional messages published are dropped.
 
    Messages are deleted after they have been acknowledged.
*/
@property (strong, nonatomic) id<MApi_MQTTPersistence> persistence;

/** block called once when connection is established
 */
@property (copy, nonatomic) MApi_MQTTConnectHandler connectHandler;

/** block called when connection is established
 */
@property (strong) void (^connectionHandler)(MApi_MQTTSessionEvent event);

/** block called when message is received
 */
@property (strong) void (^messageHandler)(NSData* message, NSString* topic);

/** Session status
 */
@property (nonatomic, readonly) MApi_MQTTSessionStatus status;

/** Indicates if the broker found a persistent session when connecting with cleanSession:FALSE
 */
@property (nonatomic, readonly) BOOL sessionPresent;

/** see initWithClientId for description
 * @param clientId The Client Identifier identifies the Client to the Server. If nil, a random clientId is generated.

 */
@property (strong, nonatomic) NSString *clientId;

/** see userName an NSString object containing the user's name (or ID) for authentication. May be nil. */
@property (strong, nonatomic) NSString *userName;

/** see password an NSString object containing the user's password. If userName is nil, password must be nil as well.*/
@property (strong, nonatomic) NSString *password;

/** see keepAliveInterval The Keep Alive is a time interval measured in seconds.
 * The MApi_MQTTClient ensures that the interval between Control Packets being sent does not exceed
 * the Keep Alive value. In the  absence of sending any other Control Packets, the Client sends a PINGREQ Packet.
 */
@property (nonatomic) UInt16 keepAliveInterval;

/** leanSessionFlag specifies if the server should discard previous session information. */
@property (nonatomic) BOOL cleanSessionFlag;

/** willFlag If the Will Flag is set to YES this indicates that
 * a Will Message MUST be published by the Server when the Server detects
 * that the Client is disconnected for any reason other than the Client flowing a DISCONNECT Packet.
 */
@property (nonatomic) BOOL willFlag;

/** willTopic If the Will Flag is set to YES, the Will Topic is a string, nil otherwise. */
@property (strong, nonatomic) NSString *willTopic;

/** willMsg If the Will Flag is set to YES the Will Message must be specified, nil otherwise. */
@property (strong, nonatomic) NSData *willMsg;

/** willQoS specifies the QoS level to be used when publishing the Will Message.
 * If the Will Flag is set to NO, then the Will QoS MUST be set to 0.
 * If the Will Flag is set to YES, the Will QoS MUST be a valid MApi_MQTTQosLevel.
 */
@property (nonatomic) MApi_MQTTQosLevel willQoS;

/** willRetainFlag indicates if the server should publish the Will Messages with retainFlag.
 * If the Will Flag is set to NO, then the Will Retain Flag MUST be set to NO .
 * If the Will Flag is set to YES: If Will Retain is set to NO, the Serve
 * MUST publish the Will Message as a non-retained publication [MApi_MQTT-3.1.2-14].
 * If Will Retain is set to YES, the Server MUST publish the Will Message as a retained publication [MApi_MQTT-3.1.2-15].
 */
@property (nonatomic) BOOL willRetainFlag;

/** protocolLevel specifies the protocol to be used */
@property (nonatomic) MApi_MQTTProtocolVersion protocolLevel;

/** runLoop The runLoop where the streams are scheduled. If nil, defaults to [NSRunLoop currentRunLoop]. */
@property (strong, nonatomic) NSRunLoop *runLoop;

/** runLoopMode The runLoopMode where the streams are scheduled. If nil, defaults to NSRunLoopCommonModes. */
@property (strong, nonatomic) NSString *runLoopMode;


/** The security policy used to evaluate server trust for secure connections.
 * (see MApi_MQTTSSLSecurityPolicy.h for more detail).
 */
@property (strong, nonatomic) MApi_MQTTSSLSecurityPolicy *securityPolicy;

/** for mqttio-OBJC backward compatibility
 the connect message used is stored here
 */
@property (strong, nonatomic) MApi_MQTTMessage *connectMessage;

/** the transport provider for MApi_MQTTClient
 *
 * assign an in instance of a class implementing the MApi_MQTTTransport protocol e.g.
 * MApi_MQTTCFSocketTransport before connecting.
 */
@property (strong, nonatomic) id <MApi_MQTTTransport> transport;

/** certificates an NSArray holding client certificates or nil */
@property (strong, nonatomic) NSArray *certificates;

/** connect to the given host through the given transport with the given
 *  MApi_MQTT session parameters asynchronously
 *
 *  @exception NSInternalInconsistencyException if the parameters are invalid
 *
 */


- (void)connect;

/** connects to the specified MApi_MQTT server
 
 @param connectHandler identifies a block which is executed on successfull or unsuccessfull connect. Might be nil
 error is nil in the case of a successful connect
 sessionPresent indicates in MApi_MQTT 3.1.1 if persistent session data was present at the server
 
 @return nothing and returns immediately. To check the connect results, register as an MApi_MQTTSessionDelegate and
 - watch for events
 - watch for connect or connectionRefused messages
 - watch for error messages
 or use the connectHandler block
 
 @code
 #import "MApi_MQTTClient.h"
 
 MApi_MQTTSession *session = [[MApi_MQTTSession alloc] init];
 ...
 [session connectWithConnectHandler:^(NSError *error, BOOL sessionPresent) {
 if (error) {
 NSLog(@"Error Connect %@", error.localizedDescription);
 } else {
 NSLog(@"Connected sessionPresent:%d", sessionPresent);
 }
 }];
 @endcode
 
 */

- (void)connectWithConnectHandler:(MApi_MQTTConnectHandler)connectHandler;


/** disconnect gracefully
 *
 */
- (void)disconnect;

/** initialises the MApi_MQTT session with default values
 @return the initialised MApi_MQTTSession object
 @code
 #import "MApi_MQTTClient.h"
 
 MApi_MQTTSession *session = [[MApi_MQTTSession alloc] init];
 @endcode
 */
- (MApi_MQTTSession *)init;



/** subscribes to a topic at a specific QoS level
 
 @param topic see subscribeToTopic:atLevel:subscribeHandler: for description
 @param qosLevel  see subscribeToTopic:atLevel:subscribeHandler: for description
 @return the Message Identifier of the SUBSCRIBE message.
 
 @note returns immediately. To check results, register as an MApi_MQTTSessionDelegate and watch for events.
 
 @code
 #import "MApi_MQTTClient.h"
 
 MApi_MQTTSession *session = [[MApi_MQTTSession alloc] init];
 ...
 [session connect];
 ...
 [session subscribeToTopic:@"example/#" atLevel:2];
 
 @endcode
 
 */

- (UInt16)subscribeToTopic:(NSString *)topic atLevel:(MApi_MQTTQosLevel)qosLevel;
/** subscribes to a topic at a specific QoS level
 
 @param topic the Topic Filter to subscribe to.
 
 @param qosLevel specifies the QoS Level of the subscription.
 qosLevel can be 0, 1, or 2.
 @param subscribeHandler identifies a block which is executed on successfull or unsuccessfull subscription.
 Might be nil. error is nil in the case of a successful subscription. In this case gQoss represents an
 array of grantes Qos
 
 
 @return the Message Identifier of the SUBSCRIBE message.
 
 @note returns immediately. To check results, register as an MApi_MQTTSessionDelegate and watch for events.
 
 @code
 #import "MApi_MQTTClient.h"
 
 MApi_MQTTSession *session = [[MApi_MQTTSession alloc] init];
 ...
 [session connect];
 ...
 [session subscribeToTopic:@"example/#" atLevel:2 subscribeHandler:^(NSError *error, NSArray<NSNumber *> *gQoss){
    if (error) {
        NSLog(@"Subscription failed %@", error.localizedDescription);
    } else {
        NSLog(@"Subscription sucessfull! Granted Qos: %@", gQoss);
    }
 }];
 
 @endcode
 
 */

- (UInt16)subscribeToTopic:(NSString *)topic atLevel:(MApi_MQTTQosLevel)qosLevel subscribeHandler:(MApi_MQTTSubscribeHandler)subscribeHandler;

/** subscribes a number of topics
 
 @param topics an NSDictionary<NSString *, NSNumber *> containing the Topic Filters to subscribe to as keys and
    the corresponding QoS as NSNumber values
 
 @return the Message Identifier of the SUBSCRIBE message.
 
 @note returns immediately. To check results, register as an MApi_MQTTSessionDelegate and watch for events.
 
 @code
 #import "MApi_MQTTClient.h"
 
 MApi_MQTTSession *session = [[MApi_MQTTSession alloc] init];
 ...
 [session connect];
 
 [session subscribeToTopics:@{
 @"example/#": @(0),
 @"example/status": @(2),
 @"other/#": @(1)
 }];
 
 @endcode
 */


- (UInt16)subscribeToTopics:(NSDictionary<NSString *, NSNumber *> *)topics;

/** subscribes a number of topics
 
 @param topics an NSDictionary<NSString *, NSNumber *> containing the Topic Filters to subscribe to as keys and
    the corresponding QoS as NSNumber values
 @param subscribeHandler identifies a block which is executed on successfull or unsuccessfull subscription.
    Might be nil. error is nil in the case of a successful subscription. In this case gQoss represents an
    array of grantes Qos
 
 @return the Message Identifier of the SUBSCRIBE message.
 
 @note returns immediately. To check results, register as an MApi_MQTTSessionDelegate and watch for events.
 
 @code
 #import "MApi_MQTTClient.h"
 
 MApi_MQTTSession *session = [[MApi_MQTTSession alloc] init];
 ...
 [session connect];
 
 [session subscribeToTopics:@{
    @"example/#": @(0),
    @"example/status": @(2),
    @"other/#": @(1)
 } subscribeHandler:^(NSError *error, NSArray<NSNumber *> *gQoss){
    if (error) {
        NSLog(@"Subscription failed %@", error.localizedDescription);
    } else {
        NSLog(@"Subscription sucessfull! Granted Qos: %@", gQoss);
    }
 }];

 
 @endcode
 */


- (UInt16)subscribeToTopics:(NSDictionary<NSString *, NSNumber *> *)topics subscribeHandler:(MApi_MQTTSubscribeHandler)subscribeHandler;

/** unsubscribes from a topic
 
 @param topic the Topic Filter to unsubscribe from.

 @return the Message Identifier of the UNSUBSCRIBE message.
 
 @note returns immediately. To check results, register as an MApi_MQTTSessionDelegate and watch for events.
 
 @code
 #import "MApi_MQTTClient.h"
 
 MApi_MQTTSession *session = [[MApi_MQTTSession alloc] init];
 ...
 [session connect];
 
 [session unsubscribeTopic:@"example/#"];
 
 @endcode
 */

- (UInt16)unsubscribeTopic:(NSString *)topic;

/** unsubscribes from a topic
 
 @param topic the Topic Filter to unsubscribe from.
 @param unsubscribeHandler identifies a block which is executed on successfull or unsuccessfull subscription.
 Might be nil. error is nil in the case of a successful subscription. In this case gQoss represents an
 array of grantes Qos
 
 @return the Message Identifier of the UNSUBSCRIBE message.
 
 @note returns immediately.
 
 */


- (UInt16)unsubscribeTopic:(NSString *)topic unsubscribeHandler:(MApi_MQTTUnsubscribeHandler)unsubscribeHandler;

/** unsubscribes from a number of topics
 
 @param topics an NSArray<NSString *> of topics to unsubscribe from
 
 @return the Message Identifier of the UNSUBSCRIBE message.
 
 @note returns immediately. To check results, register as an MApi_MQTTSessionDelegate and watch for events.
 
 @code
 #import "MApi_MQTTClient.h"
 
 MApi_MQTTSession *session = [[MApi_MQTTSession alloc] init];
 ...
 [session connect];
 
 [session unsubscribeTopics:@[
 @"example/#",
 @"example/status",
 @"other/#"
 ]];
 
 @endcode
 
 */

- (UInt16)unsubscribeTopics:(NSArray<NSString *> *)topics;

/** unsubscribes from a number of topics
 
 @param topics an NSArray<NSString *> of topics to unsubscribe from
 
 @param unsubscribeHandler identifies a block which is executed on successfull or unsuccessfull subscription.
    Might be nil. error is nil in the case of a successful subscription. In this case gQoss represents an
    array of grantes Qos
 
 @return the Message Identifier of the UNSUBSCRIBE message.
 
 @note returns immediately.
 
 */
- (UInt16)unsubscribeTopics:(NSArray<NSString *> *)topics unsubscribeHandler:(MApi_MQTTUnsubscribeHandler)unsubscribeHandler;

/** publishes data on a given topic at a specified QoS level and retain flag
 
 @param data the data to be sent. length may range from 0 to 268,435,455 - 4 - _lengthof-topic_ bytes. Defaults to length 0.
 @param topic the Topic to identify the data
 @param retainFlag if YES, data is stored on the MApi_MQTT broker until overwritten by the next publish with retainFlag = YES
 @param qos specifies the Quality of Service for the publish
 qos can be 0, 1, or 2.
 @return the Message Identifier of the PUBLISH message. Zero if qos 0. If qos 1 or 2, zero if message was dropped
 
 @note returns immediately. To check results, register as an MApi_MQTTSessionDelegate and watch for events.
 
 @code
 #import "MApi_MQTTClient.h"
 
 MApi_MQTTSession *session = [[MApi_MQTTSession alloc] init];
 ...
 [session connect];
 
 [session publishData:[@"Sample Data" dataUsingEncoding:NSUTF8StringEncoding]
 topic:@"example/data"
 retain:YES
 qos:1];
 @endcode
 
 */

- (UInt16)publishData:(NSData *)data onTopic:(NSString *)topic retain:(BOOL)retainFlag qos:(MApi_MQTTQosLevel)qos;

/** publishes data on a given topic at a specified QoS level and retain flag
 
 @param data the data to be sent. length may range from 0 to 268,435,455 - 4 - _lengthof-topic_ bytes. Defaults to length 0.
 @param topic the Topic to identify the data
 @param retainFlag if YES, data is stored on the MApi_MQTT broker until overwritten by the next publish with retainFlag = YES
 @param qos specifies the Quality of Service for the publish
 qos can be 0, 1, or 2.
 
 
 @param publishHandler identifies a block which is executed on successfull or unsuccessfull connect. Might be nil
 error is nil in the case of a successful connect
 sessionPresent indicates in MApi_MQTT 3.1.1 if persistent session data was present at the server
 

 @return the Message Identifier of the PUBLISH message. Zero if qos 0. If qos 1 or 2, zero if message was dropped
 
 @note returns immediately. To check results, register as an MApi_MQTTSessionDelegate and watch for events.
 
 @code
 #import "MApi_MQTTClient.h"
 
 MApi_MQTTSession *session = [[MApi_MQTTSession alloc] init];
 ...
 [session connect];
 
 [session publishData:[@"Sample Data" dataUsingEncoding:NSUTF8StringEncoding]
 topic:@"example/data"
 retain:YES
 qos:1
 publishHandler:^(NSError *error){
 if (error) {
 DDLogVerbose(@"error: %@ %@", error.localizedDescription, payload);
 } else {
 DDLogVerbose(@"delivered:%@", payload);
 delivered++;
 }
 }];
 @endcode
 
 */

- (UInt16)publishData:(NSData *)data onTopic:(NSString *)topic retain:(BOOL)retainFlag qos:(MApi_MQTTQosLevel)qos publishHandler:(MApi_MQTTPublishHandler)publishHandler;

/** closes an MApi_MQTTSession gracefully
 
 If the connection was successfully established before, a DISCONNECT is sent.
 
 @param disconnectHandler identifies a block which is executed on successfull or unsuccessfull disconnect. Might be nil. error is nil in the case of a successful disconnect

 @code
 #import "MApi_MQTTClient.h"
 
 MApi_MQTTSession *session = [[MApi_MQTTSession alloc] init];
 ...
 [session connect];
 
 ...
 
 [session closeWithDisconnectHandler^(NSError *error) {
    if (error) {
        NSLog(@"Error Disconnect %@", error.localizedDescription);
    }
    NSLog(@"Session closed");
 }];

 
 @endcode
 
 */
- (void)closeWithDisconnectHandler:(MApi_MQTTDisconnectHandler)disconnectHandler;

/** closes an MApi_MQTTSession gracefully
  */
- (void)close;

@end
