//
//  _MApiLogger.m
//  MAPI
//
//  Created by FanChiangShihWei on 2016/7/7.
//  Copyright © 2016年 Mitake. All rights reserved.
//

#import "_MApiLogger.h"
#import "NSData+MApiAdditions.h"
#import "MApi.h"
#import "MCrashReportRequest.h"

@implementation _MApiLogger

#pragma mark - paths

+ (void)load {
    if (self == self.class) {
        NSString *directoryPath = [self reportDirectory];
        if (![[NSFileManager defaultManager] fileExistsAtPath:directoryPath]) {
            [[NSFileManager defaultManager] createDirectoryAtPath:directoryPath
                                      withIntermediateDirectories:YES
                                                       attributes:nil
                                                            error:nil];
        }
    }
}

+ (NSString *)reportDirectory {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *directory = [paths firstObject];
    
    return [directory stringByAppendingPathComponent:@"com.mitake.mapi.report"];
}

+ (NSArray *)contentsOfDirectoryAtPath:(NSString *)directory {
    NSString *reportPath = [self reportDirectory];
    if (reportPath == nil) return nil;
    reportPath = [reportPath stringByAppendingPathComponent:directory];
    NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:reportPath error:NULL];
    return contents;
}
#define MAPI_DES_ENCRYPT_KEY @"a10dg4a660s874p6wids2d0e"

+ (void)writeContent:(NSString *)content inDirectory:(NSString *)directory {
    
    NSString *reportPath = [self reportDirectory];
    if (reportPath == nil) return;
    
    reportPath = [reportPath stringByAppendingPathComponent:directory];
    if (![[NSFileManager defaultManager] fileExistsAtPath:reportPath]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:reportPath
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:nil];
    }
    
    NSString *dateString = [[NSString stringWithFormat:@"%@", [NSDate date]] stringByReplacingOccurrencesOfString:@" " withString:@""];
    reportPath = [reportPath stringByAppendingPathComponent:dateString];
    
    NSData *encryptedData = [[content dataUsingEncoding:NSUTF8StringEncoding] tripleDESEncryptWithKey:MAPI_DES_ENCRYPT_KEY];
    [encryptedData writeToFile:reportPath atomically:YES];
    
}

+ (void)sendReportInDirectory:(NSString *)directory {
    NSString *reportPath = [self reportDirectory];
    if (reportPath == nil) return;
    reportPath = [reportPath stringByAppendingPathComponent:directory];
    
    NSArray *paths = [self contentsOfDirectoryAtPath:directory];
    
    for (NSString *lastPathComponent in paths) {
        NSString *filePath = [reportPath stringByAppendingPathComponent:lastPathComponent];
        
        BOOL isDirectory = NO;
        NSData *data = nil;
        if ([[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:&isDirectory]) {
            if (!isDirectory) {
                data = [[NSData alloc] initWithContentsOfFile:filePath];
            }
            [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
        }
        if (data) {
            //send
            NSString *content = [data tripleDESDecryptWithKey:MAPI_DES_ENCRYPT_KEY];
            if (content) {
                MCrashReportRequest *request = [[MCrashReportRequest alloc] init];
                request.timeoutInterval = 5;
                request.content = content;
                [MApi sendRequest:request completionHandler:^(MResponse *resp) {
                    [self sendReportInDirectory:directory];
                }];
            }
        }
    }
}
#undef MAPI_DES_ENCRYPT_KEY


@end
