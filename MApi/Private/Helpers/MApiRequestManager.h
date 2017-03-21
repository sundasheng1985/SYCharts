//
//  MApiRequestManager.h
//  TSApi
//
//  Created by 李政修 on 2015/4/18.
//  Copyright (c) 2015年 Mitake. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MApiRequestManager : NSObject

+ (instancetype)defaultManager;
- (void)addRequest:(id)request;
- (void)removeRequest:(id)request;
- (void)removeAllRequests;
- (NSArray *)allRequests;
@end
