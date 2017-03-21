//
//  NSData+MApiAdditions.m
//  TSApi
//
//  Created by Mitake on 2015/3/18.
//  Copyright (c) 2015年 Mitake. All rights reserved.
//

#import "NSData+MApiAdditions.h"
#import <CommonCrypto/CommonCrypto.h>
#import "mitake_des.h"

@implementation NSData (MApiAdditions)

- (NSArray *)componentsSeparatedByByte:(Byte)byte {
    NSData *data = [NSData dataWithBytes:&byte length:1];
    return [self componentsSeparatedByData:data];
}

- (NSArray *)componentsSeparatedByString:(NSString *)string {
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    return [self componentsSeparatedByData:data];
}

- (NSArray *)componentsSeparatedByData:(NSData *)data {
    NSMutableArray *rows = [NSMutableArray array];

    NSInteger dataLength = [self length];
    NSInteger currentLocation = 0;
    NSRange range = [self rangeOfData:data options:0 range:(NSRange) {
        currentLocation, dataLength - currentLocation
    }];
    while (range.location != NSNotFound) {
        NSData *d = [self subdataWithRange:(NSRange) {
            currentLocation, range.location - currentLocation
        }];
        
        [rows addObject:d];
        
        currentLocation = range.location + [data length];
        range = [self rangeOfData:data options:0 range:(NSRange) {
            currentLocation, dataLength - currentLocation
        }];
    }
    if (currentLocation != dataLength) {
        NSData *d = [self subdataWithRange:(NSRange) {
            currentLocation, dataLength - currentLocation
        }];
        [rows addObject:d];
    }
    return rows;
}

- (NSString *)convertToUTF8String {
    __autoreleasing NSString *string = [[NSString alloc] initWithData:self encoding:NSUTF8StringEncoding];
    return string;
}

/******************************************************************************
 函数名称 : + (NSData *)DESEncrypt:(NSData *)data WithKey:(NSString *)key
 函数描述 : 文本数据进行DES加密
 输入参数 : (NSData *)data
 (NSString *)key
 输出参数 : N/A
 返回参数 : (NSData *)
 备注信息 : 此函数不可用于过长文本
 ******************************************************************************/
- (NSData *)DESEncryptWithKey:(NSString *)key
{
    char keyPtr[kCCKeySizeAES256+1];
    bzero(keyPtr, sizeof(keyPtr));
    
    [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    
    NSUInteger dataLength = [self length];
    
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    
    size_t numBytesEncrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt, kCCAlgorithmDES,
                                          kCCOptionPKCS7Padding | kCCOptionECBMode,
                                          keyPtr, kCCBlockSizeDES,
                                          NULL,
                                          [self bytes], dataLength,
                                          buffer, bufferSize,
                                          &numBytesEncrypted);
    if (cryptStatus == kCCSuccess) {
        return [NSData dataWithBytesNoCopy:buffer length:numBytesEncrypted];
    }
    
    free(buffer);
    return nil;
}


- (NSData *)tripleDESEncryptWithKey:(NSString *)key
{
    const void *vplainText;
    size_t plainTextBufferSize;
    
    plainTextBufferSize = [self length];
    vplainText = (const void *)[self bytes];
    
//    CCCryptorStatus ccStatus;
    uint8_t *bufferPtr = NULL;
    size_t bufferPtrSize = 0;
    size_t movedBytes = 0;
    
    bufferPtrSize = (plainTextBufferSize + kCCBlockSize3DES) & ~(kCCBlockSize3DES - 1);
    bufferPtr = malloc( bufferPtrSize * sizeof(uint8_t));
    memset((void *)bufferPtr, 0x0, bufferPtrSize);
    
    const void *vkey = (const void *)[key UTF8String];
    
    //    ccStatus =
    CCCrypt(kCCEncrypt,
            kCCAlgorithm3DES,
            kCCOptionPKCS7Padding | kCCOptionECBMode,
            vkey,
            kCCKeySize3DES,
            nil,
            vplainText,
            plainTextBufferSize,
            (void *)bufferPtr,
            bufferPtrSize,
            &movedBytes);
    
    NSData *myData = [NSData dataWithBytes:(const void *)bufferPtr length:(NSUInteger)movedBytes];
    free(bufferPtr);
    bufferPtr = NULL;
    return myData;
}

- (NSString *)tripleDESDecryptWithKey:(NSString *)key {
    if (key.length != 24) return nil;
    char *keyBytes = (char *)key.UTF8String;
    
    mitake_des3_context ctx;
    uint8 key1[8];
    uint8 key2[8];
    uint8 key3[8];
    memcpy(&key1, keyBytes, sizeof(char)*kCCBlockSize3DES);
    memcpy(&key2, keyBytes+8, sizeof(char)*kCCBlockSize3DES);
    memcpy(&key3, keyBytes+16, sizeof(char)*kCCBlockSize3DES);
    mitake_des3_set_3keys(&ctx, key1, key2, key3);
    
    size_t alen = self.length;
    size_t bufferPtrSize = (alen + kCCBlockSize3DES) & ~(kCCBlockSize3DES - 1);
    char *r=(char*)malloc(bufferPtrSize);
    memset(r, 0, bufferPtrSize);
    uint8_t *input = (uint8_t*)malloc(kCCBlockSize3DES);
    uint8_t *output = (uint8_t*)malloc(kCCBlockSize3DES);
    char *arrayBody = (char *)self.bytes;
    for (int i = 0; i <= alen-kCCBlockSize3DES; i+=kCCBlockSize3DES) {
        memcpy(input, arrayBody+i, sizeof(uint8_t)*kCCBlockSize3DES);
        mitake_des3_decrypt( &ctx, input, output );
        memcpy(r+i, output, sizeof(uint8_t)*kCCBlockSize3DES);
    }
    free(input); free(output);

    NSString *decryptString = [[NSString alloc] initWithUTF8String:r];
    
    if (r) {
        free(r); r = NULL;
    }
    return [decryptString stringByTrimmingCharactersInSet:[NSCharacterSet controlCharacterSet]];
}

- (NSData *)dataUsingTripleDESDecryptWithKey:(NSString *)key {
    const void *vplainText;
    size_t plainTextBufferSize;
    
    plainTextBufferSize = [self length];
    vplainText = (const void *)[self bytes];
    
    //    CCCryptorStatus ccStatus;
    uint8_t *bufferPtr = NULL;
    size_t bufferPtrSize = 0;
    size_t movedBytes = 0;
    
    bufferPtrSize = (plainTextBufferSize + kCCBlockSize3DES) & ~(kCCBlockSize3DES - 1);
    bufferPtr = malloc( bufferPtrSize * sizeof(uint8_t));
    memset((void *)bufferPtr, 0x0, bufferPtrSize);
    
    const void *vkey = (const void *)[key UTF8String];
    
    //    ccStatus =
    CCCrypt(kCCDecrypt,
            kCCAlgorithm3DES,
            kCCOptionPKCS7Padding | kCCOptionECBMode,
            vkey,
            kCCKeySize3DES,
            nil,
            vplainText,
            plainTextBufferSize,
            (void *)bufferPtr,
            bufferPtrSize,
            &movedBytes);
    NSData *data = [NSData dataWithBytes:(const void *)bufferPtr length:(NSUInteger)movedBytes];
    free(bufferPtr);
    bufferPtr = NULL;
    return data;
}

@end
