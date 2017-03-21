//
//  MCoreDataHelper.m
//  TSApi
//
//  Created by Mitake on 2015/3/13.
//  Copyright (c) 2015年 Mitake. All rights reserved.
//

#import "MCoreDataHelper.h"
#import "MApiDebug.h"
#import "MApiObject.h"
#import "MSearchResultItem.h"
#import "MRequest.h"
#import "MApi.h"

@implementation MCoreDataHelper

+ (instancetype)sharedHelper {
    static MCoreDataHelper *helper = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        helper = [[MCoreDataHelper alloc] initSingleton];
    });
    return helper;
}

- (id)initSingleton {
    self = [super init];
    if (self) {
    }
    return self;
}

#pragma mark - Core Data stack

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    
    _managedObjectModel = [[NSManagedObjectModel alloc] init];
    
    NSEntityDescription *stockRecordEntity = [[NSEntityDescription alloc] init];
    [stockRecordEntity setName:@"MSearchResultItem"];
    [stockRecordEntity setManagedObjectClassName:@"MSearchResultItem"];
    
    [_managedObjectModel setEntities:@[stockRecordEntity]];
    
    NSMutableArray *attributes = [NSMutableArray array];
    // Add the Attributes
    //
    NSAttributeDescription *attribute = [[NSAttributeDescription alloc] init];
    
    [attribute setName:@"stockID"];
    [attribute setAttributeType:NSStringAttributeType];
    [attribute setOptional:NO];
    [attributes addObject:attribute];

    attribute = [[NSAttributeDescription alloc] init];
    [attribute setName:@"code"];
    [attribute setAttributeType:NSStringAttributeType];
    [attribute setOptional:YES];
    [attributes addObject:attribute];
    
    attribute = [[NSAttributeDescription alloc] init];
    [attribute setName:@"name"];
    [attribute setAttributeType:NSStringAttributeType];
    [attribute setOptional:NO];
    [attributes addObject:attribute];
    
    attribute = [[NSAttributeDescription alloc] init];
    [attribute setName:@"pinyin"];
    [attribute setAttributeType:NSStringAttributeType];
    [attribute setOptional:YES];
    [attributes addObject:attribute];
    
    attribute = [[NSAttributeDescription alloc] init];
    [attribute setName:@"market"];
    [attribute setAttributeType:NSStringAttributeType];
    [attribute setOptional:YES];
    [attributes addObject:attribute];
    
    attribute = [[NSAttributeDescription alloc] init];
    [attribute setName:@"subtype"];
    [attribute setAttributeType:NSStringAttributeType];
    [attribute setOptional:YES];
    [attributes addObject:attribute];
    
    attribute = [[NSAttributeDescription alloc] init];
    [attribute setName:@"sort"];
    [attribute setAttributeType:NSInteger16AttributeType];
    [attribute setOptional:YES];
    [attributes addObject:attribute];
    
    attribute = [[NSAttributeDescription alloc] init];
    [attribute setName:@"sort1"];
    [attribute setAttributeType:NSInteger16AttributeType];
    [attribute setOptional:YES];
    [attributes addObject:attribute];
    
    attribute = [[NSAttributeDescription alloc] init];
    [attribute setName:@"sort2"];
    [attribute setAttributeType:NSInteger16AttributeType];
    [attribute setOptional:YES];
    [attributes addObject:attribute];

    [stockRecordEntity setProperties:attributes];
    
    return _managedObjectModel;
}

- (void)removeCoreDataFiles {
    NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[self applicationDocumentsDirectory].relativePath error:nil];
    for (NSString *content in contents) {
        if ([content hasPrefix:@"MCoreData.sqlite"]) {
            NSString *path = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:content].relativePath;
            if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
                [[NSFileManager defaultManager] removeItemAtURL:[NSURL fileURLWithPath:path] error:nil];
            }
        }
    }
    _managedObjectContext = nil;
    _persistentStoreCoordinator = nil;
}
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }

    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"MCoreData.sqlite"];
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    
    NSError *error = nil;
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        //abort();
        [self removeCoreDataFiles];
        _persistentStoreCoordinator = nil;
        return [self persistentStoreCoordinator];
    }
    
    return _persistentStoreCoordinator;
}


- (NSManagedObjectContext *)managedObjectContext {
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        [managedObjectContext performBlock:^{
            NSError *error = nil;
            if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
                MAPI_LOG(@"Unresolved error %@, %@", error, [error userInfo]);
                //abort();
            }
        }];
    }
}

- (BOOL)isAllNum:(NSString *)string{
    unichar c;
    for (int i=0; i<string.length; i++) {
        c=[string characterAtIndex:i];
        if (!isdigit(c)) {
            return NO;
        }
    }
    return YES;
}

- (void)fetchStockRecordsWithRequest:(MSearchRequest *)request completionHandler:(void(^)(NSArray *resultItems))handler {
    [[self managedObjectContext] performBlock:^{
//        [[self managedObjectContext] rollback];
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"MSearchResultItem"];
        NSString *key = nil;
        NSMutableArray *fetchedObjects = [NSMutableArray array];
        
        if (request.isCancelled) return;
        
        for (NSInteger performCount = 0; performCount < 2; performCount++) {
            NSMutableArray *compounds = [NSMutableArray array];
            
            if (performCount == 0) {
                key = [NSString stringWithFormat:@"%@", request.keyword];
                [compounds addObject:[[NSPredicate predicateWithFormat:@"(code BEGINSWITH[cd] $key OR name BEGINSWITH[cd] $key OR pinyin BEGINSWITH[cd] $key)"] predicateWithSubstitutionVariables:@{@"key":key}]];
            } else {
                NSString *notKey = [NSString stringWithFormat:@"%@", request.keyword];
                key = [NSString stringWithFormat:@"%@", request.keyword];
                [compounds addObject:[[NSPredicate predicateWithFormat:@"(code CONTAINS[cd] $key OR name CONTAINS[cd] $key OR pinyin CONTAINS[cd] $key)"] predicateWithSubstitutionVariables:@{@"key":key}]];
                [compounds addObject:[[NSPredicate predicateWithFormat:@"NOT (code BEGINSWITH[cd] $key OR name BEGINSWITH[cd] $key OR pinyin BEGINSWITH[cd] $key)"] predicateWithSubstitutionVariables:@{@"key":notKey}]];
            }
            if (request.markets) {
                NSMutableArray *marketCompound = [NSMutableArray array];
                for (NSString *market in request.markets) {
                    [marketCompound addObject:[NSPredicate predicateWithFormat:@"(market == %@)", market]];
                }
                [compounds addObject:[NSCompoundPredicate orPredicateWithSubpredicates:marketCompound]];
            }
            else if (request.market.length > 0) {
                [compounds addObject:[NSPredicate predicateWithFormat:@"(market == %@)", request.market]];
            }
            
            if (request.subtypes) {
                NSMutableArray *subtypeCompound = [NSMutableArray array];
                for (NSString *subtype in request.subtypes) {
                    [subtypeCompound addObject:[NSPredicate predicateWithFormat:@"(subtype == %@)", subtype]];
                }
                [compounds addObject:[NSCompoundPredicate orPredicateWithSubpredicates:subtypeCompound]];
            }
            else if (request.subtype.length > 0) {
                [compounds addObject:[NSPredicate predicateWithFormat:@"(subtype == %@)", request.subtype]];
            }
            
            fetchRequest.predicate = [NSCompoundPredicate andPredicateWithSubpredicates:compounds];
            
            NSSortDescriptor *sortCode = [NSSortDescriptor sortDescriptorWithKey:@"code" ascending:YES];
            NSSortDescriptor *sort1Code = [NSSortDescriptor sortDescriptorWithKey:@"sort" ascending:YES];
            NSSortDescriptor *sort2Code = [NSSortDescriptor sortDescriptorWithKey:@"sort1" ascending:YES];
            NSSortDescriptor *sort3Code = [NSSortDescriptor sortDescriptorWithKey:@"sort2" ascending:YES];
            
            [fetchRequest setSortDescriptors:@[sort1Code, sort2Code, sort3Code, sortCode]];
            fetchRequest.fetchLimit = request.searchLimit;
            NSError *error;
            if (request.isCancelled) {
                [[self managedObjectContext] rollback];
                return;
            }
            
            NSArray *ret = [[self managedObjectContext] executeFetchRequest:fetchRequest error:&error];
            if (request.isCancelled) {
                [[self managedObjectContext] rollback];
                return;
            }
            
            if (ret && ret.count) {
                [fetchedObjects addObjectsFromArray:ret];
            }
            
            /// 如果条件一搜到的数量就已经满足searchLimit则返回结果, 就不执行条件二的搜索
            if (request.searchLimit > 0 && fetchedObjects.count == request.searchLimit) {
                handler(fetchedObjects);
                return;
            }
        }
        if (request.isCancelled) {
            [[self managedObjectContext] rollback];
            return;
        }
        
        if (request.searchLimit == 0) {
            handler(fetchedObjects);
        } else {
            handler([fetchedObjects subarrayWithRange:NSMakeRange(0, MIN(fetchedObjects.count, request.searchLimit))]);
        }
    }];
}


+ (MStockTableRequest *)getStockTableWithCompletionHandler:(void (^)(NSError *error))handler {
    
    
//    public static final String HUA = "1001";        //沪A
//    public static final String HUB = "1002";        //沪B
//    public static final String SHENA1 = "1001";     //深A
//    public static final String SHENA2 = "1003";
//    public static final String SHENA3 = "1004";
//    public static final String SHENB = "1002";      //深B
//    public static final String HK = "1010";      //港股
//    public static final String FUND = "1100";       //基金
//    public static final String BOND = "1300";       // 债券
//    public static final String ALL_INDEX = "1400";  //指数
//    public static final String OPTION = "3002";     ///期权
//    public static final String WARRANT = "1500";     //港股-涡轮
//    public static final String MASTER = "1501";     //港股-主板
//    public static final String ENTERPRISE = "1502";     //港股-创业
//    public static final String DERIVATE = "1503";    //港股-衍生
    
    MStockTableRequest *request = [[MStockTableRequest alloc] init];
    [MApi sendRequest:request completionHandler:^(MResponse *resp) {
        if (resp.status == MResponseStatusSuccess) {

            [[MCoreDataHelper sharedHelper] removeCoreDataFiles];

            MSearchResponse *response = (MSearchResponse *)resp;
            for (MSearchResultItem *item in response.resultItems) {
                NSInteger sortIndex  = 9999; /// 沪深 > 期权 > 港股 > 海外
                NSInteger sortIndex1 = 9999; /// 指数 > 股票A > 股票B > 基金 > 债券
                NSInteger sortIndex2 = 9999; /// 沪 > 深
                
                /// 市场别先
                // 沪深先
                if ([item.market isEqualToString:@"sh"] || [item.market isEqualToString:@"sz"]) {
                    sortIndex = 1;
                }
                // 期权
                else if ([item.subtype isEqualToString:@"3002"]) {
                    sortIndex = 2;
                }
                // 港股
                else if ([item.market isEqualToString:@"hk"]) {
                    sortIndex = 3;
                    if ([item.subtype isEqualToString:@"1010"]) { // 港股
                        sortIndex1 = 1;
                    }
                    else if ([item.subtype isEqualToString:@"1500"]) {
                        sortIndex1 = 2;
                    }
                    else if ([item.subtype isEqualToString:@"1501"]) {
                        sortIndex1 = 3;
                    }
                    else if ([item.subtype isEqualToString:@"1502"]) {
                        sortIndex1 = 4;
                    }
                    else if ([item.subtype isEqualToString:@"1503"]) {
                        sortIndex1 = 5;
                    }
                }
                
                /// 子类别判断
                // 指数
                if ([item.subtype isEqualToString:@"1400"]) {
                    sortIndex1 = 1;
                }
                // A股
                else if ([item.subtype isEqualToString:@"1001"]) {
                    sortIndex1 = 2;
                    // 沪先
                    if ([item.market isEqualToString:@"sh"]) {
                        sortIndex2 = 1;
                    }
                    // 深第二
                    else if ([item.market isEqualToString:@"sz"]) {
                        sortIndex2 = 2;
                    }
                }
                // B股
                else if ([item.subtype isEqualToString:@"1002"]) {
                    sortIndex1 = 3;
                    // 沪先
                    if ([item.market isEqualToString:@"sh"]) {
                        sortIndex2 = 1;
                    }
                    // 深第二
                    else if ([item.market isEqualToString:@"sz"]) {
                        sortIndex2 = 2;
                    }
                }
                //基金
                else if ([item.subtype isEqualToString:@"1100"]) {
                    sortIndex1 = 4;
                }
                //债券
                else if ([item.subtype isEqualToString:@"1300"]) {
                    sortIndex1 = 5;
                }
                //深A
                if ([item.market isEqualToString:@"sz"] && ([item.subtype isEqualToString:@"1003"] ||
                                                            [item.subtype isEqualToString:@"1004"])) {
                    sortIndex1 = 2;
                    
                }

                item.sort = @(sortIndex);
                item.sort1  = @(sortIndex1);
                item.sort2 = @(sortIndex2);
                [[MCoreDataHelper sharedHelper].managedObjectContext insertObject:item];
            }
            [[MCoreDataHelper sharedHelper] saveContext];
            
            handler(nil);
        }
        else {
            NSError *error = [NSError errorWithDomain:@"MApi.ErrorDomain" code:resp.status userInfo:@{NSLocalizedDescriptionKey: @"获取股票代码表失败"}];
            if (handler) {
                handler(error);
            }
        }
    }];
    return request;
}

@end
