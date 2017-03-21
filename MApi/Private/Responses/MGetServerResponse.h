//
//  MGetServerResponse.h
//  MAPI
//
//  Created by FanChiangShihWei on 2016/11/16.
//  Copyright © 2016年 Mitake. All rights reserved.
//

#import "MResponse.h"

@interface MGetServerResponse : MResponse
@property (nonatomic, strong) NSDictionary *servers;
@property (nonatomic, copy) NSString *fileVersion;
@end
