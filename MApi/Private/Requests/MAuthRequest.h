//
//  MAuthRequest.h
//  TSApi
//
//  Created by Mitake on 2015/3/10.
//  Copyright (c) 2015年 Mitake. All rights reserved.
//

#import "MApiObject.h"

@interface MAuthRequest : MRequest

@end

@interface MAuthRequest ()
@property (nonatomic, strong) NSString *appkey;
/** 公司代码 */
@property (nonatomic, strong) NSString *corpID;
/** 手机厂牌 */
@property (nonatomic, strong) NSString *brand;
/** 装置型号 */
@property (nonatomic, strong) NSString *device;
/** 手机操作系统 */
@property (nonatomic, strong) NSString *operationSystem;
/** 硬件识别码 */
@property (nonatomic, strong) NSString *hardwareID;
/** 程序版本 */
@property (nonatomic, strong) NSString *version;
/** 时间戳 */
@property (nonatomic, strong) NSString *timestamp;

@property (nonatomic, copy) NSString *sdkVer;
@end
