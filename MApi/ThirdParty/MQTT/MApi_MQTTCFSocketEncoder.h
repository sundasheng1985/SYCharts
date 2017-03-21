//
// MApi_MQTTCFSocketEncoder.h
// MApi_MQTTClient.framework
//
// Copyright © 2013-2016, Christoph Krey
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, MApi_MQTTCFSocketEncoderState) {
    MApi_MQTTCFSocketEncoderStateInitializing,
    MApi_MQTTCFSocketEncoderStateReady,
    MApi_MQTTCFSocketEncoderStateError
};

@class MApi_MQTTCFSocketEncoder;

@protocol MApi_MQTTCFSocketEncoderDelegate <NSObject>
- (void)encoderDidOpen:(MApi_MQTTCFSocketEncoder *)sender;
- (void)encoder:(MApi_MQTTCFSocketEncoder *)sender didFailWithError:(NSError *)error;
- (void)encoderdidClose:(MApi_MQTTCFSocketEncoder *)sender;

@end

@interface MApi_MQTTCFSocketEncoder : NSObject <NSStreamDelegate>
@property (nonatomic) MApi_MQTTCFSocketEncoderState state;
@property (strong, nonatomic) NSError *error;
@property (strong, nonatomic) NSOutputStream *stream;
@property (strong, nonatomic) NSRunLoop *runLoop;
@property (strong, nonatomic) NSString *runLoopMode;
@property (weak, nonatomic ) id<MApi_MQTTCFSocketEncoderDelegate> delegate;

- (void)open;
- (void)close;
- (BOOL)send:(NSData *)data;

@end

