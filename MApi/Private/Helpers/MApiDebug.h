//
//  MApiDebug.h
//  MAPI
//
//  Created by FanChiangShihWei on 2016/3/10.
//  Copyright © 2016年 Mitake. All rights reserved.
//

#ifndef MApiDebug_h
#define MApiDebug_h

#include <stdbool.h>

extern void __mapi_setDebugMode(bool enabled, uint16_t mode);

extern bool __mapi_log_0_enabled();
extern bool __mapi_log_1_enabled();
extern bool __mapi_log_2_enabled();

#ifdef DEBUG

#define MAPI_LOG(fmt, ...) \
do { \
if ( __mapi_log_0_enabled() ) { \
NSLog((@"%s [Line %d] \n" fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__); \
} \
} while(0)

#define MAPI_CURL_LOG(fmt, ...) \
do { \
if ( __mapi_log_1_enabled() ) { \
NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__); \
} \
} while(0)

#define MAPI_MQTT_LOG(fmt, ...) \
do { \
if ( __mapi_log_2_enabled() ) { \
printf("[MApi_MQTT] %s\n", [[NSString stringWithFormat:fmt, ##__VA_ARGS__] UTF8String]); \
} \
} while(0)

#else //////////////////////////////////////////////////////////////////////////

#define MAPI_LOG(fmt, ...) \
do { \
if ( __mapi_log_0_enabled() ) { \
NSLog((@"\n" fmt), ##__VA_ARGS__); \
} \
} while(0)

#define MAPI_CURL_LOG(fmt, ...) \
do { \
if ( __mapi_log_1_enabled() ) { \
NSLog((@"\n" fmt), ##__VA_ARGS__); \
} \
} while(0)

#define MAPI_MQTT_LOG(fmt, ...) \
do { \
if ( __mapi_log_2_enabled() ) { \
printf("[MApi_MQTT] %s\n", [[NSString stringWithFormat:fmt, ##__VA_ARGS__] UTF8String]); \
} \
} while(0)

#endif /* ifdef DEBUG */

#endif /* MApiDebug_h */
