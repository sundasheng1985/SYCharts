//
//  MOrderQuantityResponse.h
//  MAPI
//
//  Created by FanChiangShihWei on 2016/6/30.
//  Copyright © 2016年 Mitake. All rights reserved.
//

#import "MResponse.h"

@interface MOrderQuantityResponse ()
+ (void)parseData:(NSData *)data market:(NSString *)market subtype:(NSString *)subtype buy:(NSArray **)buyItems sell:(NSArray **)sellItems;
+ (NSArray *)orderQuantitiesWithTCPPushString:(NSString *)TCPPushString market:(NSString *)market subtype:(NSString *)subtype;
@end
