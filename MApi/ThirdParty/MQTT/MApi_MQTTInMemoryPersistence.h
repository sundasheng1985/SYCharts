//
//  MApi_MQTTInMemoryPersistence.h
//  MApi_MQTTClient
//
//  Created by Christoph Krey on 22.03.15.
//  Copyright © 2015-2016 Christoph Krey. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MApi_MQTTPersistence.h"

@interface MApi_MQTTInMemoryPersistence : NSObject <MApi_MQTTPersistence>
@end

@interface MApi_MQTTInMemoryFlow : NSObject <MApi_MQTTFlow>
@end
