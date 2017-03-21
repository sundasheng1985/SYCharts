//
// MApi_MQTTSSLSecurityPolicyEncoder.h
// MApi_MQTTClient.framework
//
// Copyright © 2013-2016, Christoph Krey
//

#import <Foundation/Foundation.h>
#import "MApi_MQTTSSLSecurityPolicy.h"
#import "MApi_MQTTCFSocketEncoder.h"

@interface MApi_MQTTSSLSecurityPolicyEncoder : MApi_MQTTCFSocketEncoder
@property(strong, nonatomic) MApi_MQTTSSLSecurityPolicy *securityPolicy;
@property(strong, nonatomic) NSString *securityDomain;

@end

