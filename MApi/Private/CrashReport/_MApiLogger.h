//
//  _MApiLogger.h
//  MAPI
//
//  Created by FanChiangShihWei on 2016/7/7.
//  Copyright © 2016年 Mitake. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface _MApiLogger : NSObject
+ (void)writeContent:(NSString *)content inDirectory:(NSString *)directory;
+ (void)sendReportInDirectory:(NSString *)directory;
@end
