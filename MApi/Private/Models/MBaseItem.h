//
//  MBaseItem.h
//  TSApi
//
//  Created by Mitake on 2015/3/18.
//  Copyright (c) 2015年 Mitake. All rights reserved.
//

#import "MApiObject.h"
#import "MApiObject+Info.h"
#import "MApiHelper.h"
#import "MApiCache.h"
#import "MCoreDataHelper.h"
#import "NSData+MApiAdditions.h"
#import "NSString+MTransform.h"

extern id ___mapi_object_fixes_20161216_hk_ignore_server_volume(id anyObj, NSString *market, NSString *subtype);

@interface MBaseItem ()
+ (instancetype)itemWithData:(NSData *)data;
+ (instancetype)itemWithData:(NSData *)data market:(NSString *)market subtype:(NSString *)subtype;
+ (instancetype)itemWithJSONObject:(NSDictionary *)JSONObject;
- (instancetype)initWithData:(NSData *)data;
- (instancetype)initWithData:(NSData *)data market:(NSString *)market subtype:(NSString *)subtype;
- (instancetype)initWithJSONObject:(NSDictionary *)JSONObject;
@end


@interface MSearchBaseItem ()
+ (instancetype)itemWithData:(NSData *)data;
+ (instancetype)itemWithData:(NSData *)data market:(NSString *)market subtype:(NSString *)subtype;
+ (instancetype)itemWithJSONObject:(NSDictionary *)JSONObject;
- (instancetype)initWithData:(NSData *)data;
- (instancetype)initWithData:(NSData *)data market:(NSString *)market subtype:(NSString *)subtype;
- (instancetype)initWithJSONObject:(NSDictionary *)JSONObject;
@end
