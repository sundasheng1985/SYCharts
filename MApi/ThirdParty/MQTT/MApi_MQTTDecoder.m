//
// MApi_MQTTDecoder.m
// MApi_MQTTClient.framework
//
// Copyright © 2013-2016, Christoph Krey
//

#import "MApi_MQTTDecoder.h"

#import "MApi_MQTTLog.h"

@interface MApi_MQTTDecoder()
@property (nonatomic) NSMutableArray<NSInputStream *> *streams;
@end

@implementation MApi_MQTTDecoder

- (instancetype)init {
    self = [super init];
    self.state = MApi_MQTTDecoderStateInitializing;
    self.runLoop = [NSRunLoop currentRunLoop];
    self.runLoopMode = NSRunLoopCommonModes;
    self.streams = [NSMutableArray arrayWithCapacity:5];
    return self;
}

- (void)dealloc {
    [self close];
}

- (void)decodeMessage:(NSData *)data {
    NSInputStream *stream = [NSInputStream inputStreamWithData:data];
    [self openStream:stream];
}

- (void)openStream:(NSInputStream*)stream {
    [self.streams addObject:stream];
    [stream setDelegate:self];
    DDLogVerbose(@"[MApi_MQTTDecoder] #streams=%lu", (unsigned long)self.streams.count);
    if (self.streams.count == 1) {
        [stream scheduleInRunLoop:self.runLoop forMode:self.runLoopMode];
        [stream open];
    }
}

- (void)open {
    self.state = MApi_MQTTDecoderStateDecodingHeader;
}

- (void)close {
    if (self.streams) {
        for (NSInputStream *stream in self.streams) {
            [stream close];
            [stream removeFromRunLoop:self.runLoop forMode:self.runLoopMode];
            [stream setDelegate:nil];
        }
        [self.streams removeAllObjects];
    }
}

- (void)stream:(NSStream*)sender handleEvent:(NSStreamEvent)eventCode {
    NSInputStream *stream = (NSInputStream *)sender;
    
    if (eventCode & NSStreamEventOpenCompleted) {
        DDLogVerbose(@"[MApi_MQTTDecoder] NSStreamEventOpenCompleted");
    }
    
    if (eventCode & NSStreamEventHasBytesAvailable) {
        DDLogVerbose(@"[MApi_MQTTDecoder] NSStreamEventHasBytesAvailable");
        
        if (self.state == MApi_MQTTDecoderStateDecodingHeader) {
            UInt8 buffer;
            NSInteger n = [stream read:&buffer maxLength:1];
            if (n == -1) {
                self.state = MApi_MQTTDecoderStateConnectionError;
                [self.delegate decoder:self handleEvent:MApi_MQTTDecoderEventConnectionError error:stream.streamError];
            } else if (n == 1) {
                self.length = 0;
                self.lengthMultiplier = 1;
                self.state = MApi_MQTTDecoderStateDecodingLength;
                self.dataBuffer = [[NSMutableData alloc] init];
                [self.dataBuffer appendBytes:&buffer length:1];
                self.offset = 1;
                DDLogVerbose(@"[MApi_MQTTDecoder] fixedHeader=0x%02x", buffer);
            }
        }
        while (self.state == MApi_MQTTDecoderStateDecodingLength) {
            // TODO: check max packet length(prevent evil server response)
            UInt8 digit;
            NSInteger n = [stream read:&digit maxLength:1];
            if (n == -1) {
                self.state = MApi_MQTTDecoderStateConnectionError;
                [self.delegate decoder:self handleEvent:MApi_MQTTDecoderEventConnectionError error:stream.streamError];
                break;
            } else if (n == 0) {
                break;
            }
            DDLogVerbose(@"[MApi_MQTTDecoder] digit=0x%02x 0x%02x %d %d", digit, digit & 0x7f, (unsigned int)self.length, (unsigned int)self.lengthMultiplier);
            [self.dataBuffer appendBytes:&digit length:1];
            self.offset++;
            self.length += ((digit & 0x7f) * self.lengthMultiplier);
            if ((digit & 0x80) == 0x00) {
                self.state = MApi_MQTTDecoderStateDecodingData;
            } else {
                self.lengthMultiplier *= 128;
            }
        }
        DDLogVerbose(@"[MApi_MQTTDecoder] remainingLength=%d", (unsigned int)self.length);

        if (self.state == MApi_MQTTDecoderStateDecodingData) {
            if (self.length > 0) {
                NSInteger n, toRead;
                UInt8 buffer[768];
                toRead = self.length + self.offset - self.dataBuffer.length;
                if (toRead > sizeof buffer) {
                    toRead = sizeof buffer;
                }
                n = [stream read:buffer maxLength:toRead];
                if (n == -1) {
                    self.state = MApi_MQTTDecoderStateConnectionError;
                    [self.delegate decoder:self handleEvent:MApi_MQTTDecoderEventConnectionError error:stream.streamError];
                } else {
                    DDLogVerbose(@"[MApi_MQTTDecoder] read %ld %ld", (long)toRead, (long)n);
                    [self.dataBuffer appendBytes:buffer length:n];
                }
            }
            if (self.dataBuffer.length == self.length + self.offset) {
                DDLogVerbose(@"[MApi_MQTTDecoder] received (%lu)=%@...", (unsigned long)self.dataBuffer.length,
                                    [self.dataBuffer subdataWithRange:NSMakeRange(0, MIN(256, self.dataBuffer.length))]);
                [self.delegate decoder:self didReceiveMessage:self.dataBuffer];
                self.dataBuffer = nil;
                self.state = MApi_MQTTDecoderStateDecodingHeader;
            }
        }
    }
    
    if (eventCode & NSStreamEventHasSpaceAvailable) {
        DDLogVerbose(@"[MApi_MQTTDecoder] NSStreamEventHasSpaceAvailable");
    }
    
    if (eventCode & NSStreamEventEndEncountered) {
        DDLogVerbose(@"[MApi_MQTTDecoder] NSStreamEventEndEncountered");
        
        if (self.streams) {
            [stream setDelegate:nil];
            [stream close];
            [self.streams removeObject:stream];
            if (self.streams.count) {
                NSInputStream *stream = [self.streams objectAtIndex:0];
                [stream scheduleInRunLoop:self.runLoop forMode:self.runLoopMode];
                [stream open];
            }
        }
    }
    
    if (eventCode & NSStreamEventErrorOccurred) {
        DDLogVerbose(@"[MApi_MQTTDecoder] NSStreamEventErrorOccurred");
        
        self.state = MApi_MQTTDecoderStateConnectionError;
        NSError *error = [stream streamError];
        if (self.streams) {
            [self.streams removeObject:stream];
            if (self.streams.count) {
                NSInputStream *stream = [self.streams objectAtIndex:0];
                [stream scheduleInRunLoop:self.runLoop forMode:self.runLoopMode];
                [stream open];
            }
        }
        [self.delegate decoder:self handleEvent:MApi_MQTTDecoderEventConnectionError error:error];
    }
}

@end
