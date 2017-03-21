//
//  _MDispatchQueuePool.h
//  MAPI
//
//  Created by FanChiangShihWei on 2016/4/27.
//  Copyright © 2016年 Mitake. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface _MDispatchQueuePool : NSObject
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithName:(NSString *)name queueCount:(NSUInteger)queueCount qos:(NSQualityOfService)qos;
@property (nonatomic, readonly) NSString *name;
- (dispatch_queue_t)queue;
+ (instancetype)defaultPoolForQOS:(NSQualityOfService)qos;
@end

extern dispatch_queue_t _MDispatchQueueGetForQOS(NSQualityOfService qos);

