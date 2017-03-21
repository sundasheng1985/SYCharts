//
//  MApiCache.h
//  TSApi
//
//  Created by Mitake on 2015/3/15.
//  Copyright (c) 2015年 Mitake. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MApiCaching <NSObject>
- (id)cachePath;
- (id)cachedObject;
@end

@interface MApiCache : NSObject
+ (void)clearCache;
+ (unsigned long long)cacheSize;
+ (void)cacheObject:(id)object toPath:(NSString *)path;
+ (id)cachedObjectFromPath:(NSString *)path;
+ (void)removeObjectFromPath:(NSString *)path;
@end

