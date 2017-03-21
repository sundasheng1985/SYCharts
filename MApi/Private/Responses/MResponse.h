//
//  MResponse.h
//  TSApi
//
//  Created by Mitake on 2015/3/18.
//  Copyright (c) 2015年 Mitake. All rights reserved.
//

#import "MApiObject.h"
#import "MApiObject+Info.h"
#import "MBaseItem.h"
#import "MRequest.h"

#define MRESPONSE_TRY_PARSE_DATA_START @try {
#define MRESPONSE_TRY_PARSE_DATA_END }@catch(NSException *exception){self.status=MResponseStatusDataParseError;} @finally{}
@interface MResponse ()

- (id)initWithData:(NSData *)data request:(MRequest *)request timestamp:(NSString *)timestamp headers:(NSDictionary *)headers;
- (BOOL)getJSONObject:(__autoreleasing id*)obj withData:(NSData *)JSONData parseClass:(Class)parseClass;
@end
