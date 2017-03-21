//
//  NSData+MApiAdditions.h
//  TSApi
//
//  Created by Mitake on 2015/3/18.
//  Copyright (c) 2015年 Mitake. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (MApiAdditions)
- (NSArray *)componentsSeparatedByByte:(Byte)byte;
- (NSArray *)componentsSeparatedByData:(NSData *)data;
- (NSArray *)componentsSeparatedByString:(NSString *)string;
- (NSString *)convertToUTF8String;
- (NSData *)DESEncryptWithKey:(NSString *)key;
- (NSData *)tripleDESEncryptWithKey:(NSString *)key;
- (NSString *)tripleDESDecryptWithKey:(NSString *)key;
- (NSData *)dataUsingTripleDESDecryptWithKey:(NSString *)key;
@end
