//
//  MRequest.m
//  TSApi
//
//  Created by Mitake on 2015/3/18.
//  Copyright (c) 2015年 Mitake. All rights reserved.
//

#import "MRequest.h"
#import "MApi_MKNetworkOperation.h"
#import "MApi_MKNetworkRequest.h"
#import <objc/runtime.h>
#import <libkern/OSAtomic.h>
#import "MApi.h"

static const NSTimeInterval kDefaultRequestTimeoutInterval = 10.;

@interface MRequest() {
    int32_t _sentinel;
}

@end

@implementation MRequest
@synthesize operation = private_operation;
@synthesize operation_v2 = private_operation_v2;
@synthesize handler = private_handler;
@synthesize timeoutHandler = private_timeoutHandler;
@synthesize sendingURLString = private_sendingURLString;

- (id)init {
    self = [super init];
    if (self) {
        _timeoutInterval = kDefaultRequestTimeoutInterval;
    }
    return self;
}

- (NSDictionary *)HTTPHeaderFields {
    return @{};
}

- (NSString *)httpMethod {
    return MApiHttpMethodGET;
}

- (NSDictionary *)postParam {
    return nil;
}

- (NSString *)bundleID {
    if ([MApiHelper sharedHelper].unitTest_bundleID) {
        return [MApiHelper sharedHelper].unitTest_bundleID;
    }
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleIdentifier"];
}

- (BOOL)isContinueAfterGetCache {
    return NO;
}

- (NSString *)platform {
    return @"iPhone";
}

- (NSString *)path {
    return @"";
}

- (NSString *)APIVersion {
    return @"v1";
}

- (NSString *)_market {
    return MREQUEST_MARKET_PB;
}

- (NSMutableDictionary *)commonHTTPHeaderFields {
    NSMutableDictionary *headerFields = [NSMutableDictionary dictionary];
    if ([[MApiHelper sharedHelper] token]) {
        headerFields[@"Token"] = [[MApiHelper sharedHelper] token];
    }
    headerFields[@"Accept-Encoding"] = @"gzip";
    return headerFields;
}

- (void)_cancelOperation {
    [self.operation cancel];
    self.operation = nil;
    [self.operation_v2 cancel];
    self.operation_v2 = nil;
}

- (void)_cancel {
    [self _cancelOperation];
    self.handler = nil;
    self.timeoutHandler = nil;
    OSAtomicIncrement32(&_sentinel);
}

- (void)cancel {
    [MApi cancelRequest:self];
}

- (void)start:(BOOL)resend {
    private_sendingURLString = nil;
    _sentinel = 0;
    int32_t sentinel = _sentinel;
    __weak MRequest *weakSelf = self;
    self.isCancelledBlock = ^BOOL() {
        __strong MRequest *strongSelf = weakSelf;
        return sentinel != strongSelf->_sentinel;
    };
    if (!resend) {
        _sendCount = 0;
    }
}

- (BOOL)isCancelled {
    return self.isCancelledBlock();
}

- (void)increaseSendCount {
    self.sendCount++;
}

- (BOOL)isValidate {
    return YES;
}

- (NSString *)level2_marketStringWithMarket:(NSString *)market {
    if (self.level == MApiSourceLevel1) {
        return market;
    }
    return [NSString stringWithFormat:@"%@l2", market];
}

- (NSString *)level2_marketString {
    NSString *code = [self valueForKey:@"code"];
    NSArray *component = [code componentsSeparatedByString:@","];
    NSString *string = [component firstObject];
    if (string) {
        component = [string componentsSeparatedByString:@"."];
        if (component.count == 2) {
            return [self level2_marketStringWithMarket:[[component lastObject] lowercaseString]];
        }
    }
    return MREQUEST_MARKET_PB;
}
#pragma mark - MApiCaching

- (id)cachePath {
    return nil;
}

- (id)cachedObject {
    return nil;
}

@end



@implementation MListRequest

//- (BOOL)isEqual:(id)object {
//    if (![object isKindOfClass:self.class]) {
//         return NO;
//    }
//    MListRequest *other = object;
//    BOOL theSame = [super isEqual:object];
//    return theSame && (other.pageIndex == _pageIndex);
//}

@end