//
//  MTransform.h
//  Pods
//
//  Created by 金融研發一部-蕭裕翰 on 7/28/15.
//
//

#import <Foundation/Foundation.h>

@interface MTransform : NSObject

+ (NSString *)transformEncodeStringWithString:(NSString *)string;
+ (NSString *)transformDecodeStringWithString:(NSString *)string;

+ (void)m_transformSetCacheSize:(int)cacheSize;

+ (NSString *)transformBaseEncodeStringByCacheString:(NSString *)string;
+ (NSString *)transformBaseDecodeStringByCacheString:(NSString *)string;
@end
