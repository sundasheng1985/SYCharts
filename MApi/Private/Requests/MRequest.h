//
//  MRequest.h
//  TSApi
//
//  Created by Mitake on 2015/3/18.
//  Copyright (c) 2015年 Mitake. All rights reserved.
//

#import "MApiObject.h"
#import "MApiObject+Info.h"
#import "MBaseItem.h"
#import "NSString+MApiAdditions.h"

#define MREQUEST_MARKET_PB @"pb"

@class MApi_MKNetworkOperation, MApi_MKNetworkRequest;

typedef void (^MRequestHandler)(MResponse *resp);
typedef void (^MRequestTimeoutHandler)(MRequest *request, BOOL *reload);

@interface MRequest () <MApiCaching>
@property (nonatomic, assign) MApiSourceLevel level;
@property (nonatomic, weak) MApi_MKNetworkOperation *operation;
@property (nonatomic, weak) MApi_MKNetworkRequest *operation_v2;
@property (nonatomic, copy) MRequestHandler handler;
@property (nonatomic, copy) MRequestTimeoutHandler timeoutHandler;
@property (nonatomic, assign) NSUInteger sendCount;
@property (nonatomic, copy) NSString *sendingURLString;
@property (nonatomic, copy) BOOL (^isCancelledBlock)();


/** 平台 */
@property (nonatomic, readonly) NSString *platform;
/** 程序识别码 */
@property (nonatomic, readonly) NSString *bundleID;
- (NSString *)level2_marketStringWithMarket:(NSString *)market;
- (NSString *)level2_marketString;
- (void)start:(BOOL)resend;
- (NSString *)path;
- (NSString *)httpMethod;
- (NSDictionary *)postParam;
- (NSString *)_market;
- (NSDictionary *)HTTPHeaderFields;
- (NSMutableDictionary *)commonHTTPHeaderFields;
- (BOOL)isContinueAfterGetCache;
- (void)increaseSendCount;

// MApi call function
@property (readonly) BOOL isCancelled;
- (void)_cancelOperation;
- (void)_cancel;

/// 基础参数校验, 预设是YES
- (BOOL)isValidate;


@end
