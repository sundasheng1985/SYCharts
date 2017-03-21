//
// MApi_MQTTDecoder.h
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
#import "MApi_MQTTMessage.h"

typedef enum {
    MApi_MQTTDecoderEventProtocolError,
    MApi_MQTTDecoderEventConnectionClosed,
    MApi_MQTTDecoderEventConnectionError
} MApi_MQTTDecoderEvent;

typedef enum {
    MApi_MQTTDecoderStateInitializing,
    MApi_MQTTDecoderStateDecodingHeader,
    MApi_MQTTDecoderStateDecodingLength,
    MApi_MQTTDecoderStateDecodingData,
    MApi_MQTTDecoderStateConnectionClosed,
    MApi_MQTTDecoderStateConnectionError,
    MApi_MQTTDecoderStateProtocolError
} MApi_MQTTDecoderState;

@class MApi_MQTTDecoder;

@protocol MApi_MQTTDecoderDelegate <NSObject>

- (void)decoder:(MApi_MQTTDecoder *)sender didReceiveMessage:(NSData *)data;
- (void)decoder:(MApi_MQTTDecoder *)sender handleEvent:(MApi_MQTTDecoderEvent)eventCode error:(NSError *)error;

@end


@interface MApi_MQTTDecoder : NSObject <NSStreamDelegate>
@property (nonatomic)    MApi_MQTTDecoderState       state;
@property (strong, nonatomic)    NSRunLoop*      runLoop;
@property (strong, nonatomic)    NSString*       runLoopMode;
@property (nonatomic)    UInt32          length;
@property (nonatomic)    UInt32          lengthMultiplier;
@property (nonatomic)    int          offset;
@property (strong, nonatomic)    NSMutableData*  dataBuffer;

@property (weak, nonatomic ) id<MApi_MQTTDecoderDelegate> delegate;

- (void)open;
- (void)close;
- (void)decodeMessage:(NSData *)data;
@end


