//
//  MApi_MQTTPersistence.h
//  MApi_MQTTClient
//
//  Created by Christoph Krey on 22.03.15.
//  Copyright © 2015-2016 Christoph Krey. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MApi_MQTTMessage.h"

static BOOL const MApi_MQTT_PERSISTENT = NO;
static NSInteger const MApi_MQTT_MAX_SIZE = 64 * 1024 * 1024;
static NSInteger const MApi_MQTT_MAX_WINDOW_SIZE = 16;
static NSInteger const MApi_MQTT_MAX_MESSAGES = 1024;

/** MApi_MQTTFlow is an abstraction of the entity to be stored for persistence */
 
@protocol MApi_MQTTFlow
/** The clientID of the flow element */
@property (strong, nonatomic) NSString *clientId;

/** The flag indicating incoming or outgoing flow element */
@property (strong, nonatomic) NSNumber *incomingFlag;

/** The flag indicating if the flow element is retained*/
@property (strong, nonatomic) NSNumber *retainedFlag;

/** The MApi_MQTTCommandType of the flow element, might be MApi_MQTT_None for offline queueing */
@property (strong, nonatomic) NSNumber *commandType;

/** The MApi_MQTTQosLevel of the flow element */
@property (strong, nonatomic) NSNumber *qosLevel;

/** The messageId of the flow element */
@property (strong, nonatomic) NSNumber *messageId;

/** The topic of the flow element */
@property (strong, nonatomic) NSString *topic;

/** The data of the flow element */
@property (strong, nonatomic) NSData *data;

/** The deadline of the flow elelment before (re)trying transmission */
@property (strong, nonatomic) NSDate *deadline;

@end

/** The MApi_MQTTPersistence protocol is an abstraction of persistence classes for MApi_MQTTSession */

@protocol MApi_MQTTPersistence

/** The maximum Window Size for outgoing inflight messages per clientID. Defaults to 16 */
@property (nonatomic) NSUInteger maxWindowSize;

/** The maximum number of messages kept per clientID and direction. Defaults to 1024 */
@property (nonatomic) NSUInteger maxMessages;

/** Indicates if the persistence implementation should make the information permannent. Defaults to NO */
@property (nonatomic) BOOL persistent;

/** The maximum size of the storage used for persistence in total in bytes. Defaults to 1024*1024 bytes */
@property (nonatomic) NSUInteger maxSize;

/** The current Window Size for outgoing inflight messages per clientID.
 * @param clientId
 * @return the current size of the outgoing inflight window
 */
- (NSUInteger)windowSize:(NSString *)clientId;

/** Stores one new message
 * @param clientId
 * @param topic
 * @param data
 * @param retainFlag
 * @param qos
 * @param msgId
 * @param incomingFlag
 * @param commandType
 * @param deadline
 * @return the created MApi_MQTTFlow element or nil if the maxWindowSize has been exceeded
 */
- (id<MApi_MQTTFlow>)storeMessageForClientId:(NSString *)clientId
                                  topic:(NSString *)topic
                                   data:(NSData *)data
                             retainFlag:(BOOL)retainFlag
                                    qos:(MApi_MQTTQosLevel)qos
                                  msgId:(UInt16)msgId
                           incomingFlag:(BOOL)incomingFlag
                            commandType:(UInt8)commandType
                               deadline:(NSDate *)deadline;

/** Deletes an MApi_MQTTFlow element
 * @param flow
 */
- (void)deleteFlow:(id<MApi_MQTTFlow>)flow;

/** Deletes all MApi_MQTTFlow elements of a clientId
 * @param clientId
 */
- (void)deleteAllFlowsForClientId:(NSString *)clientId;

/** Retrieves all MApi_MQTTFlow elements of a clientId and direction
 * @param clientId
 * @param incomingFlag
 * @return an NSArray of the retrieved MApi_MQTTFlow elements
 */
- (NSArray *)allFlowsforClientId:(NSString *)clientId
                    incomingFlag:(BOOL)incomingFlag;

/** Retrieves an MApi_MQTTFlow element
 * @param clientId
 * @param incomingFlag
 * @param messageId
 * @return the retrieved MApi_MQTTFlow element or nil if the elememt was not found
 */
- (id<MApi_MQTTFlow>)flowforClientId:(NSString *)clientId
                   incomingFlag:(BOOL)incomingFlag
                      messageId:(UInt16)messageId;

/** sync is called to allow the MApi_MQTTPersistence implemetation to save data permanently */
- (void)sync;

@end
