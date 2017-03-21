//
//  MApiCache.m
//  TSApi
//
//  Created by Mitake on 2015/3/15.
//  Copyright (c) 2015年 Mitake. All rights reserved.
//

#import "MApiCache.h"

#pragma mark - MApiCache

static NSString * const kMApiCacheVerionKey = @"CACHE_VERSION";
static NSString * const kMApiCacheDirectoryName = @"StockDataCache";

@interface MApiCache (/*Private Methods*/)
+ (NSString*)cacheDirectory;
+ (NSString*)appVersion;
@end

@implementation MApiCache

static NSMutableDictionary *memoryCache;
static NSMutableArray *recentlyAccessedKeys;
static int kCacheMemoryLimit;

static dispatch_queue_t mapi_cache_archive_processing_queue() {
    static dispatch_queue_t mapi_cache_archive_processing_queue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mapi_cache_archive_processing_queue = dispatch_queue_create("com.mitake.mapi.cache.archive.processing",
                                                              DISPATCH_QUEUE_SERIAL);
    });
    
    return mapi_cache_archive_processing_queue;
}

+ (void)initialize {
    if (self == [MApiCache class]) {
        NSString *cacheDirectory = [MApiCache cacheDirectory];
        if (![[NSFileManager defaultManager] fileExistsAtPath:cacheDirectory]) {
            [[NSFileManager defaultManager] createDirectoryAtPath:cacheDirectory
                                      withIntermediateDirectories:YES
                                                       attributes:nil
                                                            error:nil];
        }
        
        double lastSavedCacheVersion = [[NSUserDefaults standardUserDefaults] doubleForKey:kMApiCacheVerionKey];
        double currentAppVersion = [[MApiCache appVersion] doubleValue];
        
        if (lastSavedCacheVersion == 0.0f || lastSavedCacheVersion < currentAppVersion) {
            // assigning current version to preference
            [self clearCache];
            
            [[NSUserDefaults standardUserDefaults] setDouble:currentAppVersion forKey:kMApiCacheVerionKey];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        
        memoryCache = [[NSMutableDictionary alloc] init];
        recentlyAccessedKeys = [[NSMutableArray alloc] init];
        
        // you can set this based on the running device and expected cache size
        kCacheMemoryLimit = 15;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(saveMemoryCacheToDisk:)
                                                     name:UIApplicationDidReceiveMemoryWarningNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(saveMemoryCacheToDisk:)
                                                     name:UIApplicationDidEnterBackgroundNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(saveMemoryCacheToDisk:)
                                                     name:UIApplicationWillTerminateNotification
                                                   object:nil];
    }
}

+ (void)dealloc {
    memoryCache = nil;
    
    recentlyAccessedKeys = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillTerminateNotification object:nil];
    
}

+ (NSString *)appVersion {
    NSString *version = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
    return version;
}

+ (NSString *)cacheDirectory {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cachesDirectory = [paths objectAtIndex:0];
    return [cachesDirectory stringByAppendingPathComponent:kMApiCacheDirectoryName];
}

+ (void)clearCache {
    NSArray *cachedItems = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[MApiCache cacheDirectory] error:nil];
    
    for (NSString *path in cachedItems) {
        NSString *fullPath = [[MApiCache cacheDirectory] stringByAppendingPathComponent:path];
        [[NSFileManager defaultManager] removeItemAtPath:fullPath error:nil];
    }
    
    @synchronized (self) {
        [memoryCache removeAllObjects];
        [recentlyAccessedKeys removeAllObjects];
    }
}

+ (void)clearCacheForPath:(NSString *)path {
    NSString *fullPath = [[MApiCache cacheDirectory] stringByAppendingPathComponent:path];
    [[NSFileManager defaultManager] removeItemAtPath:fullPath error:nil];
    @synchronized (self) {
        [memoryCache removeObjectForKey:path];
    }
}

+ (unsigned long long)cacheSizeInMemory {
    unsigned long long cacheSize = 0;
    for (NSString *key in [memoryCache allKeys]) {
        NSData *data = memoryCache[key];
        cacheSize += [data length];
    }
    return cacheSize;
}

+ (unsigned long long)cacheSizeInPath:(NSString *)path {
    NSFileManager *manager = [NSFileManager defaultManager];
    
    unsigned long long cacheSize = 0;
    NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:nil];
    for (NSString *content in contents) {
        NSString *fullPath = [path stringByAppendingPathComponent:content];
        
        BOOL isDirectory = NO;
        [[NSFileManager defaultManager] fileExistsAtPath:fullPath isDirectory:&isDirectory];
        if (isDirectory) {
            cacheSize += [self cacheSizeInPath:fullPath];
        }
        else {
            cacheSize += [[manager attributesOfItemAtPath:fullPath error:nil] fileSize];
        }
    }
    return cacheSize;
}

+ (unsigned long long)cacheSize {
    return [self cacheSizeInPath:[MApiCache cacheDirectory]] + [self cacheSizeInMemory];
}

+ (void)saveMemoryCacheToDisk:(NSNotification *)notification {
    @synchronized (self) {
        for (NSString *filename in [memoryCache allKeys]) {
            NSString *archivePath = [[MApiCache cacheDirectory] stringByAppendingPathComponent:filename];
            NSString *directory = [archivePath stringByDeletingLastPathComponent];
            if (![[NSFileManager defaultManager] fileExistsAtPath:directory]) {
                [[NSFileManager defaultManager] createDirectoryAtPath:directory
                                          withIntermediateDirectories:YES
                                                           attributes:nil
                                                                error:nil];
            }
            NSData *cacheData = [memoryCache objectForKey:filename];
            [cacheData writeToFile:archivePath atomically:YES];
        }
        
        [memoryCache removeAllObjects];
        [recentlyAccessedKeys removeAllObjects];
    }
}

#pragma mark -
#pragma mark Custom Methods

// Add your custom methods here

+ (void)cacheData:(NSData *)data toFile:(NSString *)fileName {
    @synchronized(self) {
        [memoryCache setObject:data forKey:fileName];

        if ([recentlyAccessedKeys containsObject:fileName]) {
            [recentlyAccessedKeys removeObject:fileName];
        }
        [recentlyAccessedKeys insertObject:fileName atIndex:0];
        
        if ([recentlyAccessedKeys count] > kCacheMemoryLimit) {
            NSString *leastRecentlyUsedDataFilename = [recentlyAccessedKeys lastObject];
            NSData *leastRecentlyUsedCacheData = [memoryCache objectForKey:leastRecentlyUsedDataFilename];
            NSString *archivePath = [[MApiCache cacheDirectory] stringByAppendingPathComponent:leastRecentlyUsedDataFilename];
            NSString *directory = [archivePath stringByDeletingLastPathComponent];
            if (![[NSFileManager defaultManager] fileExistsAtPath:directory]) {
                [[NSFileManager defaultManager] createDirectoryAtPath:directory
                                          withIntermediateDirectories:YES
                                                           attributes:nil
                                                                error:nil];
            }
            [leastRecentlyUsedCacheData writeToFile:archivePath atomically:YES];
            
            [recentlyAccessedKeys removeLastObject];
            [memoryCache removeObjectForKey:leastRecentlyUsedDataFilename];
        }
    }
}

+ (NSData *)dataForFile:(NSString *)fileName {
    @synchronized (self) {
        NSData *data = [memoryCache objectForKey:fileName];
        if(data) return data; // data is present in memory cache

        /// Maybe thread
        NSString *archivePath = [[MApiCache cacheDirectory] stringByAppendingPathComponent:fileName];
        data = [NSData dataWithContentsOfFile:archivePath];
        
        /// use other thread to store
        dispatch_async(mapi_cache_archive_processing_queue(), ^{
            if (data) {
                [self cacheData:data toFile:fileName]; // put the recently accessed data to memory cache
            }
        });
        return data;
    }
}

+ (void)cacheObject:(id)object toPath:(NSString *)path {
    dispatch_async(mapi_cache_archive_processing_queue(), ^{
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:object];
        [self cacheData:data
                 toFile:path];
    });
}

+ (id)cachedObjectFromPath:(NSString *)path {
    NSData *data = [self dataForFile:path];
    if (!data) {
        return nil;
    }
    return [NSKeyedUnarchiver unarchiveObjectWithData:data];
}

+ (void)removeObjectFromPath:(NSString *)path {
    [self clearCacheForPath:path];
}

@end
