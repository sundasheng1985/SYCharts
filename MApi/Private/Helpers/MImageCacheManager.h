//
//  MImageCacheManager.h
//  TSApi
//
//  Created by Mitake on 2015/4/16.
//  Copyright (c) 2015年 Mitake. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MImageCacheManager : NSObject
@property (nonatomic, retain) NSMutableDictionary *dataDictionary;

+ (instancetype)defaultManager;

- (unsigned long long)imageDataCacheSize;

- (void)saveImageDataCacheWithIdentifier:(NSString *)identifier andImageData:(NSData*)imageData ;

- (NSData *)loadImageDataCacheWithIdentifier:(NSString *)identifier;

- (void)clearImageDataCache;

@end
