//
// MApi_MQTTSSLSecurityPolicyEncoder.m
// MApi_MQTTClient.framework
//
// Copyright © 2013-2016, Christoph Krey
//

#import "MApi_MQTTSSLSecurityPolicyEncoder.h"

#import "MApi_MQTTLog.h"

@interface MApi_MQTTSSLSecurityPolicyEncoder()
@property (nonatomic) BOOL securityPolicyApplied;

@end

@implementation MApi_MQTTSSLSecurityPolicyEncoder

- (instancetype)init {
    self = [super init];
    self.securityPolicy = nil;
    self.securityDomain = nil;
    
    return self;
}

- (BOOL)applySSLSecurityPolicy:(NSStream *)writeStream withEvent:(NSStreamEvent)eventCode;
{
    if(!self.securityPolicy){
        return YES;
    }
    
    if(self.securityPolicyApplied){
        return YES;
    }
    
    SecTrustRef serverTrust = (__bridge SecTrustRef) [writeStream propertyForKey: (__bridge NSString *)kCFStreamPropertySSLPeerTrust];
    if(!serverTrust){
        return NO;
    }
    
    self.securityPolicyApplied = [self.securityPolicy evaluateServerTrust:serverTrust forDomain:self.securityDomain];
    return self.securityPolicyApplied;
}

- (void)stream:(NSStream*)sender handleEvent:(NSStreamEvent)eventCode {
    
    if (eventCode & NSStreamEventHasSpaceAvailable) {
        DDLogVerbose(@"[MApi_MQTTCFSocketEncoder] NSStreamEventHasSpaceAvailable");
        if(![self applySSLSecurityPolicy:sender withEvent:eventCode]){
            self.state = MApi_MQTTCFSocketEncoderStateError;
            self.error = [NSError errorWithDomain:@"MApi_MQTT"
                                             code:errSSLXCertChainInvalid
                                         userInfo:@{NSLocalizedDescriptionKey: @"Unable to apply security policy, the SSL connection is insecure!"}];
        }
    }
    [super stream:sender handleEvent:eventCode];
}

@end