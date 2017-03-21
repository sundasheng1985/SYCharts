//
// MApi_MQTTCFSocketDecoder.m
// MApi_MQTTClient.framework
//
// Copyright © 2013-2016, Christoph Krey
//

#import "MApi_MQTTCFSocketDecoder.h"

#import "MApi_MQTTLog.h"

@interface MApi_MQTTCFSocketDecoder()

@end

@implementation MApi_MQTTCFSocketDecoder

- (instancetype)init {
    self = [super init];
    self.state = MApi_MQTTCFSocketDecoderStateInitializing;
    
    self.stream = nil;
    self.runLoop = [NSRunLoop currentRunLoop];
    self.runLoopMode = NSRunLoopCommonModes;
    return self;
}

- (void)open {
    if (self.state == MApi_MQTTCFSocketDecoderStateInitializing) {
        [self.stream setDelegate:self];
        [self.stream scheduleInRunLoop:self.runLoop forMode:self.runLoopMode];
        [self.stream open];
    }
}

- (void)dealloc {
    [self close];
}

- (void)close {
    [self.stream close];
    [self.stream removeFromRunLoop:self.runLoop forMode:self.runLoopMode];
    [self.stream setDelegate:nil];
}

- (void)stream:(NSStream*)sender handleEvent:(NSStreamEvent)eventCode {
    
    if (eventCode & NSStreamEventOpenCompleted) {
        DDLogVerbose(@"[MApi_MQTTCFSocketDecoder] NSStreamEventOpenCompleted");
        self.state = MApi_MQTTCFSocketDecoderStateReady;
        [self.delegate decoderDidOpen:self];
    }
    
    if (eventCode &  NSStreamEventHasBytesAvailable) {
        DDLogVerbose(@"[MApi_MQTTCFSocketDecoder] NSStreamEventHasBytesAvailable");
        if (self.state == MApi_MQTTCFSocketDecoderStateInitializing) {
            self.state = MApi_MQTTCFSocketDecoderStateReady;
        }
        
        if (self.state == MApi_MQTTCFSocketDecoderStateReady) {
            NSInteger n;
            UInt8 buffer[768];
            
            n = [self.stream read:buffer maxLength:sizeof(buffer)];
            if (n == -1) {
                self.state = MApi_MQTTCFSocketDecoderStateError;
                [self.delegate decoder:self didFailWithError:nil];
            } else {
                NSData *data = [NSData dataWithBytes:buffer length:n];
                DDLogVerbose(@"[MApi_MQTTCFSocketDecoder] received (%lu)=%@...", (unsigned long)data.length,
                             [data subdataWithRange:NSMakeRange(0, MIN(256, data.length))]);
                [self.delegate decoder:self didReceiveMessage:data];
            }
        }
    }
    if (eventCode &  NSStreamEventHasSpaceAvailable) {
        DDLogVerbose(@"[MApi_MQTTCFSocketDecoder] NSStreamEventHasSpaceAvailable");
    }
    
    if (eventCode &  NSStreamEventEndEncountered) {
        DDLogVerbose(@"[MApi_MQTTCFSocketDecoder] NSStreamEventEndEncountered");
        self.state = MApi_MQTTCFSocketDecoderStateInitializing;
        self.error = nil;
        [self.delegate decoderdidClose:self];
    }
    
    if (eventCode &  NSStreamEventErrorOccurred) {
        DDLogVerbose(@"[MApi_MQTTCFSocketDecoder] NSStreamEventErrorOccurred");
        self.state = MApi_MQTTCFSocketDecoderStateError;
        self.error = self.stream.streamError;
        [self.delegate decoder:self didFailWithError:self.error];
    }
}

@end
