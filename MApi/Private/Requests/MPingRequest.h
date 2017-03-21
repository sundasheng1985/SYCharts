//
//  MPingRequest.h
//  MAPI
//
//  Created by FanChiangShihWei on 2016/11/10.
//  Copyright © 2016年 Mitake. All rights reserved.
//

#import "MRequest.h"

@interface MPingRequest : MRequest
@property (nonatomic, copy) NSString *URLString;
@property (nonatomic, strong) NSDate *startDate;
@end
