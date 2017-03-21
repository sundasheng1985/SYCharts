//
//  MCrashReportRequest.m
//  MAPI
//
//  Created by FanChiangShihWei on 2016/7/4.
//  Copyright © 2016年 Mitake. All rights reserved.
//

#import "MCrashReportRequest.h"
#import "MApiHelper.h"
#import "sys/utsname.h"
#import "MApi_OpenUDID.h"
#import "MApiHelper.h"

@implementation MCrashReportRequest

- (NSString *)httpMethod {
    return MApiHttpMethodPOST;
}

- (NSString *)path {
    return @"exception";
}

- (NSString *)_market {
    return @"exception";
}

- (NSDictionary *)HTTPHeaderFields {
    NSMutableDictionary *headerFields = [NSMutableDictionary dictionary];
    return headerFields;
}

- (NSDictionary *)postParam {
    
    //b = (values.toString() + "&st=" + line).getBytes("utf-8");
    //values.append("bid=").append(AppInfo.bid);
    //values.append("&platform=Android");
    //values.append("&device=Phone");
    //values.append("&vc=").append(versionCode);
    //values.append("&vn=").append(versionName);
    //values.append("&name=").append(packageName);
    //values.append("&pm=").append(Build.MODEL);
    //values.append("&os=").append(Build.VERSION.RELEASE);
    //values.append("&imei=").append(imei);
    NSMutableDictionary *headerFields = [NSMutableDictionary dictionary];
    headerFields[@"bid"] = [MApiHelper sharedHelper].corpID;
    headerFields[@"platform"] = self.platform;
    headerFields[@"device"] = self.device;
    headerFields[@"vc"] = self.version;
    headerFields[@"vn"] = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
    headerFields[@"name"] = self.bundleID;
    headerFields[@"brand"] = self.brand;
    headerFields[@"os"] = self.operationSystem;
    headerFields[@"imei"] = self.hardwareID.length > 0 ? self.hardwareID : @"145c0a9075725701aafe786f1f09f71c0f74c799";
    headerFields[@"st"] = self.content ?: @"";
    return headerFields;
}


- (NSString *)brand {
    return @"Apple";
}

- (NSString *)device {
    NSString *deviceName = [self deviceName];
    return deviceName;
}

- (NSString *)deviceName {
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *deviceHardwareName = [NSString stringWithCString:systemInfo.machine
                                                      encoding:NSUTF8StringEncoding];
    __block NSString __weak *deviceName = @"";
    [[self deviceHardwareNames] enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *obj, BOOL *stop) {
        if ([deviceHardwareName isEqualToString:key]) {
            deviceName = obj;
            *stop = YES;
        }
    }];
    return deviceName;
}

- (NSDictionary *)deviceHardwareNames {
    return @{@"i386"      : @"32-bit Simulator",
             @"x86_64"    : @"64-bit Simulator",
             @"iPod1,1"   : @"iPod Touch",
             @"iPod2,1"   : @"iPod Touch Second Generation",
             @"iPod3,1"   : @"iPod Touch Third Generation",
             @"iPod4,1"   : @"iPod Touch Fourth Generation",
             @"iPod7,1"   : @"iPod Touch 6th Generation",
             @"iPhone1,1" : @"iPhone",
             @"iPhone1,2" : @"iPhone 3G",
             @"iPhone2,1" : @"iPhone 3GS",
             @"iPad1,1"   : @"iPad",
             @"iPad2,1"   : @"iPad 2",
             @"iPad3,1"   : @"3rd Generation iPad",
             @"iPhone3,1" : @"iPhone 4 (GSM)",
             @"iPhone3,3" : @"iPhone 4 (CDMA/Verizon/Sprint)",
             @"iPhone4,1" : @"iPhone 4S",
             @"iPhone5,1" : @"iPhone 5 (model A1428, AT&T/Canada)",
             @"iPhone5,2" : @"iPhone 5 (model A1429, everything else)",
             @"iPad3,4" : @"4th Generation iPad",
             @"iPad2,5" : @"iPad Mini",
             @"iPhone5,3" : @"iPhone 5c (model A1456, A1532 | GSM)",
             @"iPhone5,4" : @"iPhone 5c (model A1507, A1516, A1526 (China), A1529 | Global)",
             @"iPhone6,1" : @"iPhone 5s (model A1433, A1533 | GSM)",
             @"iPhone6,2" : @"iPhone 5s (model A1457, A1518, A1528 (China), A1530 | Global)",
             @"iPad4,1" : @"5th Generation iPad (iPad Air) - Wifi",
             @"iPad4,2" : @"5th Generation iPad (iPad Air) - Cellular",
             @"iPad4,4" : @"2nd Generation iPad Mini - Wifi",
             @"iPad4,5" : @"2nd Generation iPad Mini - Cellular",
             @"iPad4,7" : @"3rd Generation iPad Mini - Wifi (model A1599)",
             @"iPhone7,1" : @"iPhone 6 Plus",
             @"iPhone7,2" : @"iPhone 6",
             @"iPhone8,1" : @"iPhone 6S",
             @"iPhone8,2" : @"iPhone 6S Plus"};
}

- (NSString *)operationSystem {
    return [[UIDevice currentDevice] systemVersion];
}

- (NSString *)hardwareID {
    return [MApi_OpenUDID value];
}

- (NSString *)version {
#if DEBUG
    if ([MApiHelper sharedHelper].unitTest_version) {
        return [MApiHelper sharedHelper].unitTest_version;
    }
#endif
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
}

@end
