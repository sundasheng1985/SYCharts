//
// MApi_MQTTCFSocketEncoder.m
// MApi_MQTTClient.framework
//
// Copyright © 2013-2016, Christoph Krey
//

#import "MApi_MQTTCFSocketEncoder.h"

#import "MApi_MQTTLog.h"

@interface MApi_MQTTCFSocketEncoder()
@property (strong, nonatomic) NSMutableData *buffer;

@end

@implementation MApi_MQTTCFSocketEncoder

- (instancetype)init {
    self = [super init];
    self.state = MApi_MQTTCFSocketEncoderStateInitializing;
    self.buffer = [[NSMutableData alloc] init];
    
    self.stream = nil;
    self.runLoop = [NSRunLoop currentRunLoop];
    self.runLoopMode = NSRunLoopCommonModes;
    
    return self;
}

- (void)dealloc {
    [self close];
}

- (void)open {
    [self.stream setDelegate:self];
    [self.stream scheduleInRunLoop:self.runLoop forMode:self.runLoopMode];
    [self.stream open];
}

- (void)close {
    [self.stream close];
    [self.stream removeFromRunLoop:self.runLoop forMode:self.runLoopMode];
    [self.stream setDelegate:nil];
}

- (void)setState:(MApi_MQTTCFSocketEncoderState)state {
    DDLogVerbose(@"[MApi_MQTTCFSocketEncoder] setState %ld/%ld", (long)_state, (long)state);
    _state = state;
}

- (void)stream:(NSStream*)sender handleEvent:(NSStreamEvent)eventCode {
    
    if (eventCode & NSStreamEventOpenCompleted) {
        DDLogVerbose(@"[MApi_MQTTCFSocketEncoder] NSStreamEventOpenCompleted");

    }
    if (eventCode & NSStreamEventHasBytesAvailable) {
        DDLogVerbose(@"[MApi_MQTTCFSocketEncoder] NSStreamEventHasBytesAvailable");
    }
    
    if (eventCode & NSStreamEventHasSpaceAvailable) {
        DDLogVerbose(@"[MApi_MQTTCFSocketEncoder] NSStreamEventHasSpaceAvailable");
        if (self.state == MApi_MQTTCFSocketEncoderStateInitializing) {
            self.state = MApi_MQTTCFSocketEncoderStateReady;
            [self.delegate encoderDidOpen:self];
        }
        
        if (self.state == MApi_MQTTCFSocketEncoderStateReady) {
            if (self.buffer.length) {
                [self send:nil];
            }
        }
    }
    
    if (eventCode &  NSStreamEventEndEncountered) {
        DDLogVerbose(@"[MApi_MQTTCFSocketEncoder] NSStreamEventEndEncountered");
        self.state = MApi_MQTTCFSocketEncoderStateInitializing;
        self.error = nil;
        [self.delegate encoderdidClose:self];
    }
    
    if (eventCode &  NSStreamEventErrorOccurred) {
        DDLogVerbose(@"[MApi_MQTTCFSocketEncoder] NSStreamEventErrorOccurred");
        self.state = MApi_MQTTCFSocketEncoderStateError;
        self.error = self.stream.streamError;
        [self.delegate encoder:self didFailWithError:self.error];
    }
}

- (BOOL)send:(NSData *)data {
    @synchronized(self) {
        if (self.state != MApi_MQTTCFSocketEncoderStateReady) {
            DDLogInfo(@"[MApi_MQTTCFSocketEncoder] not MApi_MQTTCFSocketEncoderStateReady");
            return FALSE;
        }
        
        if (data) {
            [self.buffer appendData:data];
        }
        
        if (self.buffer.length) {
            DDLogVerbose(@"[MApi_MQTTCFSocketEncoder] buffer to write (%lu)=%@...",
                         (unsigned long)self.buffer.length,
                         [self.buffer subdataWithRange:NSMakeRange(0, MIN(256, self.buffer.length))]);
            
            NSInteger n = [self.stream write:self.buffer.bytes maxLength:self.buffer.length];
            
            if (n == -1) {
                DDLogVerbose(@"[MApi_MQTTCFSocketEncoder] streamError: %@", self.error);
                self.state = MApi_MQTTCFSocketEncoderStateError;
                self.error = self.stream.streamError;
                return FALSE;
            } else {
                if (n < self.buffer.length) {
                    DDLogVerbose(@"[MApi_MQTTCFSocketEncoder] buffer partially written: %ld", (long)n);
                }
                [self.buffer replaceBytesInRange:NSMakeRange(0, n) withBytes:NULL length:0];
            }
        }
        return TRUE;
    }
}

@end