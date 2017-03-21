//
//  MApi_MQTTSSLSecurityPolicyTransport.h
//  MApi_MQTTClient
//
//  Created by Christoph Krey on 06.12.15.
//  Copyright © 2015-2016 Christoph Krey. All rights reserved.
//

#import "MApi_MQTTTransport.h"
#import "MApi_MQTTSSLSecurityPolicy.h"
#import "MApi_MQTTCFSocketTransport.h"

/** MApi_MQTTSSLSecurityPolicyTransport
 * implements an extension of the MApi_MQTTCFSocketTransport by replacing the OS's certificate chain evaluation
 */
@interface MApi_MQTTSSLSecurityPolicyTransport : MApi_MQTTCFSocketTransport

/**
 * The security policy used to evaluate server trust for secure connections.
 *
 * if your app using security model which require pinning SSL certificates to helps prevent man-in-the-middle attacks
 * and other vulnerabilities. you need to set securityPolicy to properly value(see MApi_MQTTSSLSecurityPolicy.h for more detail).
 *
 * NOTE: about self-signed server certificates:
 * if your server using Self-signed certificates to establish SSL/TLS connection, you need to set property:
 * MApi_MQTTSSLSecurityPolicy.allowInvalidCertificates=YES.
 */
@property (strong, nonatomic) MApi_MQTTSSLSecurityPolicy *securityPolicy;

@end
