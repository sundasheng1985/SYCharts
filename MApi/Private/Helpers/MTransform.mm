//
//  MTransform.m
//  Pods
//
//  Created by 金融研發一部-蕭裕翰 on 7/28/15.
//
//

#import "MTransform.h"
#include "transform.h"

@implementation MTransform

+ (void)initialize {
    if (self == [MTransform class]) {
        setCacheSize(5000);
    }
}

+ (NSString *)transformEncodeStringWithString:(NSString *)string {
    char *pEncode = getBaseEncode((char *)[string cStringUsingEncoding:NSASCIIStringEncoding]);
    NSString *encodeString = [NSString stringWithCString:pEncode encoding:NSASCIIStringEncoding];
    free(pEncode);
    pEncode = NULL;
    return encodeString;
}

+ (NSString *)transformDecodeStringWithString:(NSString *)string {
    char *pDncode = getBaseDecode((char *)[string cStringUsingEncoding:NSASCIIStringEncoding]);
    NSString *decodeString = [NSString stringWithCString:pDncode encoding:NSASCIIStringEncoding];
    free(pDncode);
    pDncode = NULL;
    return decodeString;
}

+ (void)m_transformSetCacheSize:(int)cacheSize {
    setCacheSize(cacheSize);
}

+ (NSString *)transformBaseEncodeStringByCacheString:(NSString *)string {
    char *pEncode = getBaseEncode((char *)[string cStringUsingEncoding:NSASCIIStringEncoding]);
    NSString *encodeString = [NSString stringWithCString:pEncode encoding:NSASCIIStringEncoding];
    free(pEncode);
    pEncode = NULL;
    return encodeString;
}

+ (NSString *)transformBaseDecodeStringByCacheString:(NSString *)string {
    char *pDncode = getBaseDecode((char *)[string cStringUsingEncoding:NSASCIIStringEncoding]);
    NSString *decodeString = [NSString stringWithCString:pDncode encoding:NSASCIIStringEncoding];
    free(pDncode);
    pDncode = NULL;
    return decodeString;
}
@end
