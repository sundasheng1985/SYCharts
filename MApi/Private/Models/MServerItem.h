//
//  MServerItem.h
//  MAPI
//
//  Created by Mitake on 2015/8/16.
//  Copyright (c) 2015年 Mitake. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MApiHelper.h"
#import "MBaseItem.h"

@interface MServerItem : MBaseItem
@property (nonatomic, strong, readonly) NSString *IPAddress;
@property (nonatomic, strong, readonly) NSString *market;
@property (nonatomic, strong, readonly) NSString *priority;
+ (id)serverItemWithIPAddress:(NSString *)IPAddress market:(NSString *)market;
+ (id)serverItemWithIPAddress:(NSString *)IPAddress market:(NSString *)market priority:(NSString *)priority;
@end
