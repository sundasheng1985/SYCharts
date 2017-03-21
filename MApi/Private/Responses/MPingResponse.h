//
//  MPingResponse.h
//  MAPI
//
//  Created by FanChiangShihWei on 2016/11/10.
//  Copyright © 2016年 Mitake. All rights reserved.
//

#import "MResponse.h"

@interface MPingResponse : MResponse
@property (nonatomic, assign) NSTimeInterval responseTime;
@end
