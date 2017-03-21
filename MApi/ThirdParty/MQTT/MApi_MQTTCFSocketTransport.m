//
//  MApi_MQTTCFSocketTransport.m
//  MApi_MQTTClient
//
//  Created by Christoph Krey on 06.12.15.
//  Copyright © 2015-2016 Christoph Krey. All rights reserved.
//

#import "MApi_MQTTCFSocketTransport.h"

#import "MApi_MQTTLog.h"

@interface MApi_MQTTCFSocketTransport()
@property (strong, nonatomic) MApi_MQTTCFSocketEncoder *encoder;
@property (strong, nonatomic) MApi_MQTTCFSocketDecoder *decoder;
@end

@implementation MApi_MQTTCFSocketTransport
@synthesize state;
@synthesize delegate;
@synthesize runLoop;
@synthesize runLoopMode;

- (instancetype)init {
    self = [super init];
    self.host = @"localhost";
    self.port = 1883;
    self.tls = false;
    self.certificates = nil;
    return self;
}

- (void)open {
    DDLogVerbose(@"[MApi_MQTTCFSocketTransport] open");
    self.state = MApi_MQTTTransportOpening;

    NSError* connectError;

    CFReadStreamRef readStream;
    CFWriteStreamRef writeStream;

    CFStreamCreatePairWithSocketToHost(NULL, (__bridge CFStringRef)self.host, self.port, &readStream, &writeStream);

    CFReadStreamSetProperty(readStream, kCFStreamPropertyShouldCloseNativeSocket, kCFBooleanTrue);
    CFWriteStreamSetProperty(writeStream, kCFStreamPropertyShouldCloseNativeSocket, kCFBooleanTrue);
    
    if (self.tls) {
        NSMutableDictionary *sslOptions = [[NSMutableDictionary alloc] init];
        
        [sslOptions setObject:(NSString *)kCFStreamSocketSecurityLevelNegotiatedSSL
                       forKey:(NSString*)kCFStreamSSLLevel];
        
        if (self.certificates) {
            [sslOptions setObject:self.certificates
                           forKey:(NSString *)kCFStreamSSLCertificates];
        }
        
        if(!CFReadStreamSetProperty(readStream, kCFStreamPropertySSLSettings, (__bridge CFDictionaryRef)(sslOptions))){
            connectError = [NSError errorWithDomain:@"MApi_MQTT"
                                               code:errSSLInternal
                                           userInfo:@{NSLocalizedDescriptionKey : @"Fail to init ssl input stream!"}];
        }
        if(!CFWriteStreamSetProperty(writeStream, kCFStreamPropertySSLSettings, (__bridge CFDictionaryRef)(sslOptions))){
            connectError = [NSError errorWithDomain:@"MApi_MQTT"
                                               code:errSSLInternal
                                           userInfo:@{NSLocalizedDescriptionKey : @"Fail to init ssl output stream!"}];
        }
    }
    
    if(!connectError){
        self.encoder.delegate = nil;
        self.encoder = [[MApi_MQTTCFSocketEncoder alloc] init];
        self.encoder.stream = CFBridgingRelease(writeStream);
        self.encoder.runLoop = self.runLoop;
        self.encoder.runLoopMode = self.runLoopMode;
        self.encoder.delegate = self;
        [self.encoder open];
        
        self.decoder.delegate = nil;
        self.decoder = [[MApi_MQTTCFSocketDecoder alloc] init];
        self.decoder.stream =  CFBridgingRelease(readStream);
        self.decoder.runLoop = self.runLoop;
        self.decoder.runLoopMode = self.runLoopMode;
        self.decoder.delegate = self;
        [self.decoder open];
        
    } else {
        [self close];
    }
}

- (void)close {
    DDLogVerbose(@"[MApi_MQTTCFSocketTransport] close");
    self.state = MApi_MQTTTransportClosing;

    if (self.encoder) {
        [self.encoder close];
        self.encoder.delegate = nil;
    }
    
    if (self.decoder) {
        [self.decoder close];
        self.decoder.delegate = nil;
    }
}

- (BOOL)send:(nonnull NSData *)data {
    return [self.encoder send:data];
}

- (void)decoder:(MApi_MQTTCFSocketDecoder *)sender didReceiveMessage:(nonnull NSData *)data {
    [self.delegate mqttTransport:self didReceiveMessage:data];
}

- (void)decoder:(MApi_MQTTCFSocketDecoder *)sender didFailWithError:(NSError *)error {
    //self.state = MApi_MQTTTransportClosing;
    //[self.delegate mqttTransport:self didFailWithError:error];
}
- (void)encoder:(MApi_MQTTCFSocketEncoder *)sender didFailWithError:(NSError *)error {
    self.state = MApi_MQTTTransportClosing;
    [self.delegate mqttTransport:self didFailWithError:error];
}

- (void)decoderdidClose:(MApi_MQTTCFSocketDecoder *)sender {
    self.state = MApi_MQTTTransportClosed;
    [self.delegate mqttTransportDidClose:self];
}
- (void)encoderdidClose:(MApi_MQTTCFSocketEncoder *)sender {
    //self.state = MApi_MQTTTransportClosed;
    //[self.delegate mqttTransportDidClose:self];
}

- (void)decoderDidOpen:(MApi_MQTTCFSocketDecoder *)sender {
    //self.state = MApi_MQTTTransportOpen;
    //[self.delegate mqttTransportDidOpen:self];
}
- (void)encoderDidOpen:(MApi_MQTTCFSocketEncoder *)sender {
    self.state = MApi_MQTTTransportOpen;
    [self.delegate mqttTransportDidOpen:self];
}

+ (NSArray *)clientCertsFromP12:(NSString *)path passphrase:(NSString *)passphrase {
    if (!path) {
        DDLogWarn(@"[MApi_MQTTCFSocketTransport] no p12 path given");
        return nil;
    }
    
    NSData *pkcs12data = [[NSData alloc] initWithContentsOfFile:path];
    if (!pkcs12data) {
        DDLogWarn(@"[MApi_MQTTCFSocketTransport] reading p12 failed");
        return nil;
    }
    
    if (!passphrase) {
        DDLogWarn(@"[MApi_MQTTCFSocketTransport] no passphrase given");
        return nil;
    }
    CFArrayRef keyref = NULL;
    OSStatus importStatus = SecPKCS12Import((__bridge CFDataRef)pkcs12data,
                                            (__bridge CFDictionaryRef)[NSDictionary
                                                                       dictionaryWithObject:passphrase
                                                                       forKey:(__bridge id)kSecImportExportPassphrase],
                                            &keyref);
    if (importStatus != noErr) {
        DDLogWarn(@"[MApi_MQTTCFSocketTransport] Error while importing pkcs12 [%d]", (int)importStatus);
        return nil;
    }
    
    CFDictionaryRef identityDict = CFArrayGetValueAtIndex(keyref, 0);
    if (!identityDict) {
        DDLogWarn(@"[MApi_MQTTCFSocketTransport] could not CFArrayGetValueAtIndex");
        return nil;
    }
    
    SecIdentityRef identityRef = (SecIdentityRef)CFDictionaryGetValue(identityDict,
                                                                      kSecImportItemIdentity);
    if (!identityRef) {
        DDLogWarn(@"[MApi_MQTTCFSocketTransport] could not CFDictionaryGetValue");
        return nil;
    };
    
    SecCertificateRef cert = NULL;
    OSStatus status = SecIdentityCopyCertificate(identityRef, &cert);
    if (status != noErr) {
        DDLogWarn(@"[MApi_MQTTCFSocketTransport] SecIdentityCopyCertificate failed [%d]", (int)status);
        return nil;
    }
    
    NSArray *clientCerts = [[NSArray alloc] initWithObjects:(__bridge id)identityRef, (__bridge id)cert, nil];
    return clientCerts;
}

@end
