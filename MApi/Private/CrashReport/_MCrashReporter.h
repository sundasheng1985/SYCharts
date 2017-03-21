//
//  _MCrashReporter.h
//  MAPI
//
//  Created by FanChiangShihWei on 2016/7/4.
//  Copyright © 2016年 Mitake. All rights reserved.
//

#import <Foundation/Foundation.h>

#define MCRASHRESPORTER_TRY_CATCH_START @try {
#define MCRASHRESPORTER_TRY_CATCH_END } @catch (NSException *exception) {[[_MCrashReporter sharedInstance] handleTryCatchException:exception];}

@interface _MCrashReporter : NSObject
+ (instancetype)sharedInstance;
- (void)sendCrashReport;
- (void)handleTryCatchException:(NSException *)exp;
@end
