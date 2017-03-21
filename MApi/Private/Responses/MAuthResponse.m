//
//  MAuthResponse.m
//  TSApi
//
//  Created by Mitake on 2015/3/18.
//  Copyright (c) 2015年 Mitake. All rights reserved.
//

#import "MAuthResponse.h"
#import "MBase64.h"

#define MAPI_DES_ENCRYPT_KEY_AUTH @"b68384a66092849f10f72d0e"  //加密key

@implementation MAuthResponse

- (id)initWithData:(NSData *)data request:(MRequest *)request timestamp:(NSString *)timestamp headers:(NSDictionary *)headers {
    self = [super initWithData:data request:request timestamp:timestamp headers:headers];
    if (self) {
        MRESPONSE_TRY_PARSE_DATA_START
        NSString *text = [data convertToUTF8String];
        NSData *data64 = [MBase64 base64DecodeDataFrom:text];
        NSString *decryptText = [data64 tripleDESDecryptWithKey:MAPI_DES_ENCRYPT_KEY_AUTH];
        NSData *decryptData = [decryptText dataUsingEncoding:NSUTF8StringEncoding];
        if (decryptData) {
            NSDictionary *JSONValue = nil;
            if ([self getJSONObject:&JSONValue withData:decryptData parseClass:NSDictionary.class]) {
                self.quoteServers = JSONValue[@"service"][@"quote"];
                self.token = JSONValue[@"token"];
            }
        } else {
            self.status = MResponseStatusDataParseError;
        }
        MRESPONSE_TRY_PARSE_DATA_END
    }
    return self;
}

@end
