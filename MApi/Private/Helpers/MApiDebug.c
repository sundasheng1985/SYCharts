//
//  MApiDebug.c
//  MAPI
//
//  Created by FanChiangShihWei on 2016/3/10.
//  Copyright © 2016年 Mitake. All rights reserved.
//

#include <stdio.h>
#include "MApiDebug.h"


#include <mach/mach_time.h>

static bool kDebugEnabled = false;
static unsigned long kDebugModeFlags = 0;

/**
 * 1 general log
 * 2 curl log
 * 4 mqtt log
 **/
bool __mapi_log_0_enabled() { return kDebugEnabled && kDebugModeFlags & (1UL << 0); }
bool __mapi_log_1_enabled() { return kDebugEnabled && kDebugModeFlags & (1UL << 1); }
bool __mapi_log_2_enabled() { return kDebugEnabled && kDebugModeFlags & (1UL << 2); }

void __mapi_setDebugMode(bool enabled, uint16_t mode) {
    printf("debug:%s, mode:%d\n", enabled?"true":"false", mode);
    kDebugEnabled = enabled;
    kDebugModeFlags = mode;
}
