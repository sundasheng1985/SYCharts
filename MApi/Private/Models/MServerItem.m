//
//  MServerItem.m
//  MAPI
//
//  Created by Mitake on 2015/8/16.
//  Copyright (c) 2015年 Mitake. All rights reserved.
//

#import "MServerItem.h"

@interface MServerItem()
@property (nonatomic, strong, readwrite) NSString *IPAddress;
@property (nonatomic, strong, readwrite) NSString *market;
@property (nonatomic, strong, readwrite) NSString *priority;
@end

@implementation MServerItem
+ (id)serverItemWithIPAddress:(NSString *)IPAddress market:(NSString *)market priority:(NSString *)priority {
    MServerItem *serverItem = [[MServerItem alloc] init];
    serverItem.market = market?:@"";
    serverItem.IPAddress = IPAddress?:@"" ;
    serverItem.priority = priority;
    return serverItem;
}

+ (id)serverItemWithIPAddress:(NSString *)IPAddress market:(NSString *)market {
    return [self serverItemWithIPAddress:IPAddress market:market priority:nil];
}


@end