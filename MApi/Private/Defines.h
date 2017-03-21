//
//  Defines.h
//  MAPI
//
//  Created by FanChiangShihWei on 2016/2/29.
//  Copyright © 2016年 Mitake. All rights reserved.
//


#ifndef MAPI_UTIL_MACRO_2983610023_h
#define MAPI_UTIL_MACRO_2983610023_h

#import <pthread.h>

#define MAPI_OVERLOADABLE __attribute__((overloadable))

#define MAPI_ASSERT_SIGNAL(condition, description, ...) NSAssert(condition, description, ##__VA_ARGS__)
#define MAPI_ASSERT_MAIN_THREAD() MAPI_ASSERT_SIGNAL(0 != pthread_main_np(), nil, @"This method must be called on the main thread")

#define MAPI_GET_SP_LOCKER() dispatch_semaphore_create(1)
#define MAPI_SP_LOCK(l) dispatch_semaphore_wait(l, DISPATCH_TIME_FOREVER)
#define MAPI_SP_UNLOCK(l) dispatch_semaphore_signal(l)

#endif /* Defines_h */
