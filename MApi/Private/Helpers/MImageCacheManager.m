//
//  NewsImageCacheManager.m
//  TSApi
//
//  Created by Mitake on 2015/4/16.
//  Copyright (c) 2015年 Mitake. All rights reserved.
//

#import "MImageCacheManager.h"

@implementation MImageCacheManager


+ (instancetype)defaultManager {
    static MImageCacheManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[MImageCacheManager alloc] init];
    });
    return instance;
}

- (unsigned long long)imageDataCacheSizeInPath:(NSString *)path {
    NSFileManager *manager = [NSFileManager defaultManager];
    
    unsigned long long cacheSize = 0;
    NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:nil];
    for (NSString *content in contents) {
        NSString *fullPath = [path stringByAppendingPathComponent:content];
        
        BOOL isDirectory = NO;
        [[NSFileManager defaultManager] fileExistsAtPath:fullPath isDirectory:&isDirectory];
        if (isDirectory) {
            cacheSize += [self imageDataCacheSizeInPath:fullPath];
        }
        else {
            cacheSize += [[manager attributesOfItemAtPath:fullPath error:nil] fileSize];
        }
    }
    return cacheSize;
}

- (unsigned long long)imageDataCacheSize {
    return [self imageDataCacheSizeInPath:[self imageDataCachePath] ];
}



- (void)saveImageDataCacheWithIdentifier:(NSString *)identifier andImageData:(NSData*)imageData{
    NSString *path = [self
 creatImageDataPathWithString:identifier];
    if (imageData) {
        [imageData writeToFile:path atomically:YES];
    }
}

- (NSData *)loadImageDataCacheWithIdentifier:(NSString *)identifier
{
    NSString *path = [self creatImageDataPathWithString:identifier];
    NSData *data = [NSData dataWithContentsOfFile:path];
    return data;
}

- (NSString *)creatImageDataPathWithString:(NSString *)string
{
    NSString *path = [self imageDataCachePath];
    path = [path stringByAppendingPathComponent:string];
    return path;
}

- (void)clearImageDataCache {
    NSArray *cachedItems = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[self imageDataCachePath] error:nil];
    
    for (NSString *path in cachedItems) {
        NSString *fullPath = [[self imageDataCachePath] stringByAppendingPathComponent:path];
        [[NSFileManager defaultManager] removeItemAtPath:fullPath error:nil];
    }
}

- (NSString *)imageDataCachePath{
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    path = [path stringByAppendingPathComponent:@"StockDataCache"];
    path = [path stringByAppendingPathComponent:@"NewsDataCache"];
    path = [path stringByAppendingPathComponent:@"NewsImageData"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return path;
}

@end
