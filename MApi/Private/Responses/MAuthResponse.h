//
//  MAuthResponse.h
//  TSApi
//
//  Created by Mitake on 2015/3/18.
//  Copyright (c) 2015年 Mitake. All rights reserved.
//

#import "MResponse.h"

@interface MAuthResponse : MResponse
@property (nonatomic, strong) NSDictionary *quoteServers;
@property (nonatomic, copy) NSString *token;
@end
