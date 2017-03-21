//
// MApi_MQTTCFSocketDecoder.h
// MApi_MQTTClient.framework
// 
// Copyright © 2013-2016, Christoph Krey
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, MApi_MQTTCFSocketDecoderState) {
    MApi_MQTTCFSocketDecoderStateInitializing,
    MApi_MQTTCFSocketDecoderStateReady,
    MApi_MQTTCFSocketDecoderStateError
};

@class MApi_MQTTCFSocketDecoder;

@protocol MApi_MQTTCFSocketDecoderDelegate <NSObject>
- (void)decoder:(MApi_MQTTCFSocketDecoder *)sender didReceiveMessage:(NSData *)data;
- (void)decoderDidOpen:(MApi_MQTTCFSocketDecoder *)sender;
- (void)decoder:(MApi_MQTTCFSocketDecoder *)sender didFailWithError:(NSError *)error;
- (void)decoderdidClose:(MApi_MQTTCFSocketDecoder *)sender;

@end

@interface MApi_MQTTCFSocketDecoder : NSObject <NSStreamDelegate>
@property (nonatomic) MApi_MQTTCFSocketDecoderState state;
@property (strong, nonatomic) NSError *error;
@property (strong, nonatomic) NSInputStream *stream;
@property (strong, nonatomic) NSRunLoop *runLoop;
@property (strong, nonatomic) NSString *runLoopMode;
@property (weak, nonatomic ) id<MApi_MQTTCFSocketDecoderDelegate> delegate;

- (void)open;
- (void)close;

@end


