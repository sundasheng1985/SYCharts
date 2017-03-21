//
//  MBaseItem.m
//  TSApi
//
//  Created by Mitake on 2015/3/18.
//  Copyright (c) 2015年 Mitake. All rights reserved.
//

#import "MBaseItem.h"
#import <objc/runtime.h>

/// 因为server的量是错的，所以忽略港股指数的量，不要问我为什么要这样做
id ___mapi_object_fixes_20161216_hk_ignore_server_volume(id anyObj, NSString *market, NSString *subtype) {
    if ([[market lowercaseString] isEqualToString:@"hk"] && [subtype isEqualToString:@"1400"]) {
        return nil;
    }
    return anyObj;
}


@implementation MBaseItem

+ (instancetype)itemWithData:(NSData *)data {
    __autoreleasing id item = [[[self class] alloc] initWithData:data];
    return item;
}

+ (instancetype)itemWithData:(NSData *)data market:(NSString *)market subtype:(NSString *)subtype {
    __autoreleasing id item = [[[self class] alloc] initWithData:data market:market  subtype:subtype];
    return item;
}

+ (instancetype)itemWithJSONObject:(NSDictionary *)JSONObject {
    __autoreleasing id item = [[[self class] alloc] initWithJSONObject:JSONObject];
    return item;
}

- (instancetype)initWithData:(NSData *)data {
    return [super init];
}

- (instancetype)initWithData:(NSData *)data market:(NSString *)market subtype:(NSString *)subtype {
    return [super init];
}

- (instancetype)initWithJSONObject:(NSDictionary *)JSONObject {
    return [super init];
}

- (id)valueForUndefinedKey:(NSString *)key {
    return @"";
}

@end


/////////////////////////////////////////////////////////////////////

#import "MCoreDataHelper.h"

@implementation MSearchBaseItem

+ (instancetype)itemWithData:(NSData *)data {
    __autoreleasing id item = [[[self class] alloc] initWithData:data];
    return item;
}

+ (instancetype)itemWithData:(NSData *)data market:(NSString *)market subtype:(NSString *)subtype {
    __autoreleasing id item = [[[self class] alloc] initWithData:data market:market subtype:subtype];
    return item;
}

+ (instancetype)itemWithJSONObject:(NSDictionary *)JSONObject {
    __autoreleasing id item = [[[self class] alloc] initWithJSONObject:JSONObject];
    return item;
}

- (instancetype)_init {
    return [super initWithEntity:[NSEntityDescription entityForName:NSStringFromClass([self class])
                                             inManagedObjectContext:[MCoreDataHelper sharedHelper].managedObjectContext]
  insertIntoManagedObjectContext:nil];
}

- (instancetype)init {
    return [self _init];
}

- (instancetype)initWithData:(NSData *)data {
    return [self _init];
}

- (instancetype)initWithData:(NSData *)data market:(NSString *)market subtype:(NSString *)subtype {
    return [self _init];
}

- (instancetype)initWithJSONObject:(NSDictionary *)JSONObject {
    return [self _init];
}

- (id)valueForUndefinedKey:(NSString *)key {
    return @"";
}

#pragma mark - NSCopying

- (instancetype)copyWithZone:(NSZone *)zone {
    id copy = [[[self class] allocWithZone:zone] init];
    return copy;
}

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder {
    
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
   return [self _init];
}

@end
