//
//  MApi_MQTTCFSocketTransport.h
//  MApi_MQTTClient
//
//  Created by Christoph Krey on 06.12.15.
//  Copyright © 2015-2016 Christoph Krey. All rights reserved.
//

#import "MApi_MQTTTransport.h"
#import "MApi_MQTTCFSocketDecoder.h"
#import "MApi_MQTTCFSocketEncoder.h"

/** MApi_MQTTCFSocketTransport
 * implements an MApi_MQTTTransport on top of CFNetwork
 */
@interface MApi_MQTTCFSocketTransport : MApi_MQTTTransport <MApi_MQTTTransport, MApi_MQTTCFSocketDecoderDelegate, MApi_MQTTCFSocketEncoderDelegate>

/** host an NSString containing the hostName or IP address of the host to connect to
 * defaults to @"localhost"
 */
@property (strong, nonatomic) NSString *host;

/** port an unsigned 16 bit integer containing the IP port number to connect to 
 * defaults to 1883
 */
@property (nonatomic) UInt16 port;

/** tls a boolean indicating whether the transport should be using security 
 * defaults to NO
 */
@property (nonatomic) BOOL tls;

/** certificates An identity certificate used to reply to a server requiring client certificates according
 * to the description given for SSLSetCertificate(). You may build the certificates array yourself or use the
 * sundry method clientCertFromP12.
 */
@property (strong, nonatomic) NSArray *certificates;

/** reads the content of a PKCS12 file and converts it to an certificates array for initWith...
 @param path the path to a PKCS12 file
 @param passphrase the passphrase to unlock the PKCS12 file
 @returns a certificates array or nil if an error occured
 
 @code
 NSString *path = [[NSBundle bundleForClass:[MApi_MQTTClientTests class]] pathForResource:@"filename"
 ofType:@"p12"];
 
 NSArray *myCerts = [MApi_MQTTCFSocketTransport clientCertsFromP12:path passphrase:@"passphrase"];
 if (myCerts) {
 
 self.session = [[MApi_MQTTSession alloc] init];
 ...
 self.session.certificates = myCerts;
 
 [self.session connect];
 ...
 }
 
 @endcode
 
 */

+ (NSArray *)clientCertsFromP12:(NSString *)path passphrase:(NSString *)passphrase;

@end
