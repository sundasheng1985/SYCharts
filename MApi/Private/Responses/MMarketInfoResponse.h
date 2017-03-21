//
//  MMarketInfoResponse.h
//  MAPI
//
//  Created by mitake on 2015/5/28.
//  Copyright (c) 2015年 Mitake. All rights reserved.
//

#import "MResponse.h"

@interface MMarketInfoResponse : MResponse
@property (nonatomic, copy) NSDictionary *marketInfos;
@end
