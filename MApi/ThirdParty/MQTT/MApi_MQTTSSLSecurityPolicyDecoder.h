//
// MApi_MQTTSSLSecurityPolicyDecoder.h
// MApi_MQTTClient.framework
// 
// Copyright © 2013-2016, Christoph Krey
//

#import <Foundation/Foundation.h>
#import "MApi_MQTTSSLSecurityPolicy.h"
#import "MApi_MQTTCFSocketDecoder.h"

@interface MApi_MQTTSSLSecurityPolicyDecoder : MApi_MQTTCFSocketDecoder
@property(strong, nonatomic) MApi_MQTTSSLSecurityPolicy *securityPolicy;
@property(strong, nonatomic) NSString *securityDomain;

@end


