//
//  MApiRequestManager.m
//  TSApi
//
//  Created by 李政修 on 2015/4/18.
//  Copyright (c) 2015年 Mitake. All rights reserved.
//

#import "MApiRequestManager.h"
#import "MApiDebug.h"

@interface MApiRequestManager ()
@property (nonatomic, strong) NSMutableArray *requests;
@end

@implementation MApiRequestManager

+ (instancetype)defaultManager {
    static MApiRequestManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[MApiRequestManager alloc] init];
    });
    return manager;
}

- (NSMutableArray *)requests {
    if (!_requests) {
        _requests = [[NSMutableArray alloc] init];
    }
    return _requests;
}

- (void)addRequest:(id)request {
    if ([self.requests indexOfObject:request] == NSNotFound) {
        MAPI_LOG(@"加入请求:%@", NSStringFromClass([request class]));
        [self.requests addObject:request];
        MAPI_LOG(@"所有请求数:%@", @(self.requests.count));
    }
}

- (void)removeRequest:(id)request {
    if ([self.requests indexOfObject:request] != NSNotFound) {
        MAPI_LOG(@"移除请求:%@", NSStringFromClass([request class]));
        [request cancel];
        [self.requests removeObject:request];
        MAPI_LOG(@"所有请求数:%@", @(self.requests.count));
    }
}

- (void)removeAllRequests {
    for (id request in self.requests) {
        [request cancel];
    }
    [self.requests removeAllObjects];
}

- (NSArray *)allRequests {
    return self.requests;
}

@end
