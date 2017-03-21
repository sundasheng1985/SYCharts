//
//  MBrokerSeatResponse.h
//  TSApi
//
//  Created by 李政修 on 2015/4/17.
//  Copyright (c) 2015年 Mitake. All rights reserved.
//

#import "MResponse.h"

@interface MBrokerSeatResponse ()
+ (void)parseData:(NSData *)data buy:(NSArray **)buyItems sell:(NSArray **)sellItems;
+ (NSArray *)brokerSeatItemsWithData:(NSData *)data;
@end
