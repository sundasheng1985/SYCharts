//
//  MCoreDataHelper.h
//  TSApi
//
//  Created by Mitake on 2015/3/13.
//  Copyright (c) 2015年 Mitake. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class MSearchRequest;
@class MStockTableRequest;

@interface MCoreDataHelper : NSObject
@property (nonatomic, strong) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, strong) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

+ (instancetype)sharedHelper;
- (void)saveContext;
- (void)fetchStockRecordsWithRequest:(MSearchRequest *)request
                   completionHandler:(void(^)(NSArray *resultItems))handler;
+ (MStockTableRequest *)getStockTableWithCompletionHandler:(void (^)(NSError *error))handler;
@end
