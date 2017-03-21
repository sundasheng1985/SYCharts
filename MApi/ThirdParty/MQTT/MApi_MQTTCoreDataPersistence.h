//
//  MApi_MQTTCoreDataPersistence.h
//  MApi_MQTTClient
//
//  Created by Christoph Krey on 22.03.15.
//  Copyright © 2015-2016 Christoph Krey. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "MApi_MQTTPersistence.h"

@interface MApi_MQTTCoreDataPersistence : NSObject <MApi_MQTTPersistence>

@end

@interface MApi_MQTTFlow : NSManagedObject <MApi_MQTTFlow>
@end

@interface MApi_MQTTCoreDataFlow : NSObject <MApi_MQTTFlow>
@end
