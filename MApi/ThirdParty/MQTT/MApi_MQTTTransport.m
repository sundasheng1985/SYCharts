//
//  MApi_MQTTTransport.m
//  MApi_MQTTClient
//
//  Created by Christoph Krey on 05.01.16.
//  Copyright © 2016 Christoph Krey. All rights reserved.
//

#import "MApi_MQTTTransport.h"

#import "MApi_MQTTLog.h"

@implementation MApi_MQTTTransport
@synthesize state;
@synthesize runLoop;
@synthesize runLoopMode;
@synthesize delegate;

- (instancetype)init {
    self = [super init];
    self.state = MApi_MQTTTransportCreated;
    self.runLoop = [NSRunLoop currentRunLoop];
    self.runLoopMode = NSRunLoopCommonModes;
    return self;
}

- (void)open {
    DDLogError(@"MApi_MQTTTransport is abstract class");
}

- (void)close {
    DDLogError(@"MApi_MQTTTransport is abstract class");
}

- (BOOL)send:(NSData *)data {
    DDLogError(@"MApi_MQTTTransport is abstract class");
    return FALSE;
}

@end