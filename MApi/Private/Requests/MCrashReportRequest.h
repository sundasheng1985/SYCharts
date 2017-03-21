//
//  MCrashReportRequest.h
//  MAPI
//
//  Created by FanChiangShihWei on 2016/7/4.
//  Copyright © 2016年 Mitake. All rights reserved.
//

#import "MRequest.h"

@interface MCrashReportRequest : MRequest
@property (nonatomic, copy) NSString *content;
@end
