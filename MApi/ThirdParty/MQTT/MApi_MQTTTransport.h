//
//  MApi_MQTTTransport.h
//  MApi_MQTTClient
//
//  Created by Christoph Krey on 06.12.15.
//  Copyright © 2015-2016 Christoph Krey. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MApi_MQTTTransportDelegate;

/** MApi_MQTTTransport is a protocol abstracting the underlying transport level for MApi_MQTTClient
 *
 */
@protocol MApi_MQTTTransport <NSObject>

/** MApi_MQTTTransport state defines the possible state of an abstract transport
 *
 */
 typedef NS_ENUM(NSInteger, MApi_MQTTTransportState) {
     
     /** MApi_MQTTTransportCreated indicates an initialized transport */
     MApi_MQTTTransportCreated = 0,
     
     /** MApi_MQTTTransportOpening indicates a transport in the process of opening a connection */
     MApi_MQTTTransportOpening,
     
     /** MApi_MQTTTransportCreated indicates a transport opened ready for communication */
     MApi_MQTTTransportOpen,
     
     /** MApi_MQTTTransportCreated indicates a transport in the process of closing */
     MApi_MQTTTransportClosing,
     
     /** MApi_MQTTTransportCreated indicates a closed transport */
     MApi_MQTTTransportClosed
 };

/** runLoop The runLoop where the streams are scheduled. If nil, defaults to [NSRunLoop currentRunLoop]. */
@property (strong, nonatomic) NSRunLoop * _Nonnull runLoop;

/** runLoopMode The runLoopMode where the streams are scheduled. If nil, defaults to NSRunLoopCommonModes. */
@property (strong, nonatomic) NSString * _Nonnull runLoopMode;

/** MApi_MQTTTransportDelegate needs to be set to a class implementing th MApi_MQTTTransportDelegate protocol
 * to receive delegate messages.
 */
@property (strong, nonatomic) _Nullable id<MApi_MQTTTransportDelegate> delegate;

/** state contains the current MApi_MQTTTransportState of the transport */
@property (nonatomic) MApi_MQTTTransportState state;

/** open opens the transport and prepares it for communication
 * actual transports may require additional parameters to be set before opening
 */
- (void)open;

/** send transmits a data message
 * @param data data to be send, might be zero length
 * @result a boolean indicating if the data could be send or not
 */
- (BOOL)send:(nonnull NSData *)data;

/** close closes the transport */
- (void)close;

@end

/** MApi_MQTTTransportDelegate protocol
 * Note: the implementation of the didReceiveMessage method is mandatory, the others are optional 
 */
@protocol MApi_MQTTTransportDelegate <NSObject>

/** didReceiveMessage gets called when a message was received
 * @param mqttTransport the transport on which the message was received
 * @param message the data received which may be zero length
 */
 - (void)mqttTransport:(nonnull id<MApi_MQTTTransport>)mqttTransport didReceiveMessage:(nonnull NSData *)message;

@optional

/** mqttTransportDidOpen gets called when a transport is successfully opened
 * @param mqttTransport the transport which was successfully opened
 */
- (void)mqttTransportDidOpen:(_Nonnull id<MApi_MQTTTransport>)mqttTransport;

/** didFailWithError gets called when an error was detected on the transport
 * @param mqttTransport the transport which detected the error
 * @param error available error information, might be nil
 */
- (void)mqttTransport:(_Nonnull id<MApi_MQTTTransport>)mqttTransport didFailWithError:(nullable NSError *)error;

/** mqttTransportDidClose gets called when the transport closed
 * @param mqttTransport the transport which was closed
 */
- (void)mqttTransportDidClose:(_Nonnull id<MApi_MQTTTransport>)mqttTransport;

@end

@interface MApi_MQTTTransport : NSObject <MApi_MQTTTransport>
@end

